import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../domain/normalizer.dart';
import 'database.dart';

class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupSummary {
  const BackupSummary({required this.games, required this.covers, this.exportedAt});

  final int games;
  final int covers;
  final DateTime? exportedAt;
}

/// Backup e ripristino dell'intera libreria in un file ZIP:
/// `manifest.json` + `data/library.json` + `covers/`.
///
/// I dati sono esportati in JSON e non come copia del file SQLite, così un backup
/// resta leggibile anche dopo un cambio di schema. Le colonne derivate (forme
/// normalizzate, chiavi di ordinamento, voto complessivo) non vengono esportate:
/// si ricalcolano in importazione.
class BackupService {
  BackupService(this.db, this.documentsDir, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final AppDatabase db;
  final String documentsDir;
  final DateTime Function() _now;

  /// v1: una sola collection per gioco (`games.parent_id`) e copie messe da parte.
  /// v2: appartenenze multiple in `collection_items`. I backup v1 si importano
  /// comunque: il vecchio legame diventa un'appartenenza e le copie messe da parte
  /// tornano al gioco, che ora può possederle anche stando in una raccolta.
  static const int formatVersion = 2;

  /// Colonne esportate e reimportate per ogni tabella. È anche la lista bianca
  /// dell'importazione: un backup non può scrivere colonne che non sono qui.
  static const Map<String, List<String>> _columns = <String, List<String>>{
    'consoles': <String>['id', 'name', 'short_label', 'family', 'sort_order'],
    'genres': <String>['id', 'name'],
    'series': <String>['id', 'name'],
    'companies': <String>['id', 'name'],
    'games': <String>[
      'id', 'title', 'series_id', 'developer_id', 'publisher_id', 'release_year', 'status',
      'is_replayable', 'has_post_game', 'has_achievements', 'all_achievements_unlocked', 'has_dlc',
      'is_collection', 'rating_story', 'rating_gameplay', 'rating_graphics',
      'rating_soundtrack', 'cover_path', 'created_at', 'updated_at', 'players',
    ],
    'game_copies': <String>['game_id', 'console_id', 'format'],
    'game_genres': <String>['game_id', 'genre_id'],
    'collection_items': <String>['collection_id', 'game_id'],
    'game_platforms': <String>['game_id', 'console_id'],
    'settings': <String>['name', 'value'],
  };

  static final RegExp _coverName = RegExp(r'^covers/[A-Za-z0-9_-]+\.(jpg|jpeg|png)$');

  File _coverFile(String relative) => File(p.joinAll(<String>[documentsDir, ...p.posix.split(relative)]));

  /// Scrive il backup in [targetDirectory] e restituisce il file creato.
  Future<File> export(String targetDirectory) async {
    final Map<String, List<Map<String, Object?>>> data = <String, List<Map<String, Object?>>>{};
    for (final MapEntry<String, List<String>> table in _columns.entries) {
      data[table.key] = <Map<String, Object?>>[
        for (final QueryRow r in await db.customSelect('SELECT ${table.value.join(', ')} FROM ${table.key}').get())
          Map<String, Object?>.of(r.data),
      ];
    }

    final List<String> covers = <String>{
      for (final Map<String, Object?> g in data['games']!)
        if (g['cover_path'] is String) g['cover_path']! as String,
    }.where((String c) => _coverName.hasMatch(c) && _coverFile(c).existsSync()).toList();

    final DateTime now = _now();
    String two(int v) => v.toString().padLeft(2, '0');
    final String path = p.join(
      targetDirectory,
      'gameshelf_backup_${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}.zip',
    );

    final ZipFileEncoder encoder = ZipFileEncoder()..create(path);
    encoder.addArchiveFile(
      ArchiveFile.string(
        'manifest.json',
        jsonEncode(<String, Object?>{
          'app': 'GameShelf',
          'formatVersion': formatVersion,
          'schemaVersion': db.schemaVersion,
          'exportedAt': now.toIso8601String(),
          'counts': <String, int>{'games': data['games']!.length, 'covers': covers.length},
        }),
      ),
    );
    encoder.addArchiveFile(ArchiveFile.string('data/library.json', jsonEncode(data)));
    for (final String cover in covers) {
      await encoder.addFile(_coverFile(cover), cover);
    }
    await encoder.close();
    return File(path);
  }

  /// Sostituisce l'intera libreria con il contenuto del backup.
  ///
  /// Tutto o niente: la scrittura sul database avviene in una sola transazione e
  /// le copertine vengono scambiate solo dopo che questa è andata a buon fine.
  /// Se qualcosa non torna la libreria attuale resta intatta.
  Future<BackupSummary> import(String zipPath) async {
    // Lettura in streaming: un backup con le copertine supera i 100 MB e tenerlo
    // tutto in memoria basterebbe a far chiudere l'app.
    final InputFileStream input = InputFileStream(zipPath);
    final Archive archive;
    try {
      archive = ZipDecoder().decodeStream(input);
    } catch (_) {
      await input.close();
      throw const BackupException('Il file scelto non è un archivio ZIP valido.');
    }
    try {
      return await _importArchive(archive);
    } finally {
      await input.close();
    }
  }

  Future<BackupSummary> _importArchive(Archive archive) async {

    for (final ArchiveFile entry in archive.files) {
      final String name = entry.name;
      final bool allowed =
          name == 'manifest.json' ||
          name == 'data/library.json' ||
          name == 'data/' ||
          name == 'covers/' ||
          _coverName.hasMatch(name);
      if (!allowed) throw BackupException('Il backup contiene un file non previsto: $name');
    }

    final ArchiveFile? manifestEntry = archive.findFile('manifest.json');
    final ArchiveFile? dataEntry = archive.findFile('data/library.json');
    if (manifestEntry == null || dataEntry == null) {
      throw const BackupException('Il file scelto non è un backup di GameShelf.');
    }

    final Map<String, dynamic> manifest;
    final Map<String, dynamic> data;
    try {
      manifest = jsonDecode(utf8.decode(manifestEntry.readBytes()!)) as Map<String, dynamic>;
      data = jsonDecode(utf8.decode(dataEntry.readBytes()!)) as Map<String, dynamic>;
    } catch (_) {
      throw const BackupException('Il backup è danneggiato: impossibile leggerne il contenuto.');
    }
    if (manifest['app'] != 'GameShelf') {
      throw const BackupException('Il file scelto non è un backup di GameShelf.');
    }
    final Object? version = manifest['formatVersion'];
    if (version is! int || version > formatVersion) {
      throw const BackupException('Questo backup è stato creato da una versione più recente di GameShelf.');
    }

    List<Map<String, dynamic>> rows(String table) => <Map<String, dynamic>>[
      for (final Object? r in (data[table] as List<dynamic>? ?? const <dynamic>[]))
        (r! as Map<dynamic, dynamic>).cast<String, dynamic>(),
    ];
    final List<Map<String, dynamic>> games = rows('games');
    final Object? expectedGames = (manifest['counts'] as Map<dynamic, dynamic>?)?['games'];
    if (expectedGames is int && expectedGames != games.length) {
      throw const BackupException('Il backup è incompleto: il numero di giochi non corrisponde.');
    }

    // Copertine estratte a parte: vengono messe al loro posto solo alla fine.
    final Directory staging = Directory(p.join(documentsDir, 'covers_import'));
    if (staging.existsSync()) await staging.delete(recursive: true);
    await staging.create(recursive: true);
    int covers = 0;
    for (final ArchiveFile entry in archive.files) {
      if (!entry.isFile || !_coverName.hasMatch(entry.name)) continue;
      final List<int>? bytes = entry.readBytes();
      if (bytes == null) continue;
      await File(p.join(staging.path, p.posix.basename(entry.name))).writeAsBytes(bytes);
      covers++;
    }

    try {
      await db.transaction(() async {
        await db.customStatement('PRAGMA defer_foreign_keys = ON');
        for (final String table in const <String>[
          'game_platforms', 'collection_items', 'game_genres', 'game_copies', 'games',
          'genres', 'series', 'companies', 'consoles', 'settings',
        ]) {
          await db.customStatement('DELETE FROM $table');
        }

        for (final String table in const <String>['consoles', 'genres', 'series', 'companies']) {
          for (final Map<String, dynamic> r in rows(table)) {
            await _insert(table, r, extra: <String, Object?>{'name_norm': normalize('${r['name']}')});
          }
        }
        for (final Map<String, dynamic> g in games) {
          final String title = '${g['title']}';
          await _insert(
            'games',
            g,
            extra: <String, Object?>{'title_norm': normalize(title), 'sort_title': sortKey(title)},
          );
        }
        for (final Map<String, dynamic> r in rows('game_copies')) {
          await _insert('game_copies', r);
        }
        // Backup v1: le copie messe da parte tornano al gioco, che adesso può
        // possederle anche stando dentro una raccolta.
        for (final Map<String, dynamic> r in rows('detached_copies')) {
          await db.customStatement(
            'INSERT OR IGNORE INTO game_copies (game_id, console_id, format) VALUES (?, ?, ?)',
            <Object?>[r['game_id'], r['console_id'], r['format']],
          );
        }
        for (final Map<String, dynamic> r in rows('game_genres')) {
          await _insert('game_genres', r);
        }
        // Le appartenenze dopo i giochi: il trigger rifiuta una raccolta che non
        // esiste ancora. Nei backup v1 il legame sta su games.parent_id.
        for (final Map<String, dynamic> r in rows('collection_items')) {
          await _insert('collection_items', r);
        }
        for (final Map<String, dynamic> g in games) {
          if (g['parent_id'] != null) {
            await db.customStatement(
              'INSERT OR IGNORE INTO collection_items (collection_id, game_id) VALUES (?, ?)',
              <Object?>[g['parent_id'], g['id']],
            );
          }
        }
        for (final Map<String, dynamic> r in rows('game_platforms')) {
          await _insert('game_platforms', r);
        }
        for (final Map<String, dynamic> r in rows('settings')) {
          await _insert('settings', r);
        }
      });
    } catch (error) {
      await staging.delete(recursive: true);
      throw BackupException(
        'Il backup contiene dati incoerenti e non è stato ripristinato. '
        'La libreria attuale non è stata toccata.\n($error)',
      );
    }

    final Directory current = Directory(p.join(documentsDir, 'covers'));
    final Directory old = Directory(p.join(documentsDir, 'covers_old'));
    if (old.existsSync()) await old.delete(recursive: true);
    if (current.existsSync()) await current.rename(old.path);
    await staging.rename(current.path);
    if (old.existsSync()) await old.delete(recursive: true);

    db.markTablesUpdated(<TableInfo<Table, Object?>>[
      db.games, db.gameCopies, db.gameGenres, db.collectionItems, db.gamePlatforms,
      db.consoles, db.genres, db.series, db.companies, db.settings,
    ]);
    return BackupSummary(
      games: games.length,
      covers: covers,
      exportedAt: DateTime.tryParse('${manifest['exportedAt']}'),
    );
  }

  Future<void> _insert(String table, Map<String, dynamic> row, {Map<String, Object?> extra = const <String, Object?>{}}) {
    final Map<String, Object?> values = <String, Object?>{
      for (final String column in _columns[table]!) column: row[column],
      ...extra,
    };
    final List<String> columns = values.keys.toList();
    return db.customStatement(
      'INSERT INTO $table (${columns.join(', ')}) VALUES (${List<String>.filled(columns.length, '?').join(', ')})',
      <Object?>[for (final String c in columns) values[c]],
    );
  }
}
