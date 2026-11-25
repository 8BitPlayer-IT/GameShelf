import 'package:drift/drift.dart';

import '../domain/normalizer.dart';
import 'database.dart';

enum CatalogKind {
  console('Console', 'consoles'),
  genere('Generi', 'genres'),
  serie('Serie', 'series'),
  azienda('Sviluppatori e publisher', 'companies');

  const CatalogKind(this.label, this.table);

  final String label;
  final String table;
}

class CatalogUsage {
  const CatalogUsage({required this.id, required this.name, required this.uses, this.shortLabel});

  final int id;
  final String name;
  final String? shortLabel;

  /// Copie (per le console) o giochi che usano la voce.
  final int uses;
}

class CatalogException implements Exception {
  const CatalogException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Gestione dei cataloghi: rinomina, unione ed eliminazione delle voci.
class CatalogAdmin {
  CatalogAdmin(this.db);

  final AppDatabase db;

  Set<TableInfo<Table, Object?>> get _touched => {
    db.consoles,
    db.genres,
    db.series,
    db.companies,
    db.games,
    db.gameCopies,
    db.gameGenres,
    db.gamePlatforms,
    db.collectionItems,
  };

  String _usesSql(CatalogKind kind) => switch (kind) {
    CatalogKind.console =>
      '(SELECT count(*) FROM game_copies WHERE console_id = x.id) + '
          '(SELECT count(*) FROM game_platforms WHERE console_id = x.id)',
    CatalogKind.genere => '(SELECT count(*) FROM game_genres WHERE genre_id = x.id)',
    CatalogKind.serie => '(SELECT count(*) FROM games WHERE series_id = x.id)',
    CatalogKind.azienda => '(SELECT count(*) FROM games WHERE developer_id = x.id OR publisher_id = x.id)',
  };

  Stream<List<CatalogUsage>> watch(CatalogKind kind) {
    final bool console = kind == CatalogKind.console;
    return db
        .customSelect(
          'SELECT x.id, x.name, ${console ? 'x.short_label' : 'NULL'} AS short_label, '
          '${_usesSql(kind)} AS uses FROM ${kind.table} x '
          'ORDER BY x.name_norm',
          readsFrom: _touched,
        )
        .watch()
        .map(
          (List<QueryRow> rows) => <CatalogUsage>[
            for (final QueryRow r in rows)
              CatalogUsage(
                id: r.read<int>('id'),
                name: r.read<String>('name'),
                shortLabel: r.readNullable<String>('short_label'),
                uses: r.read<int>('uses'),
              ),
          ],
        );
  }

  Future<void> rename(CatalogKind kind, int id, String name, {String? shortLabel}) async {
    final String clean = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) throw const CatalogException('Il nome non può essere vuoto.');
    final String? label = shortLabel?.trim();
    if (label != null && (label.isEmpty || label.length > 10)) {
      throw const CatalogException('La sigla deve avere da 1 a 10 caratteri.');
    }
    try {
      await db.customUpdate(
        'UPDATE ${kind.table} SET name = ?, name_norm = ?${label != null ? ', short_label = ?' : ''} WHERE id = ?',
        variables: <Variable>[
          Variable<String>(clean),
          Variable<String>(normalize(clean)),
          if (label != null) Variable<String>(label),
          Variable<int>(id),
        ],
        updates: _touched,
      );
    } catch (error) {
      if ('$error'.contains('UNIQUE')) {
        throw CatalogException('Esiste già «$clean». Per riunirle usa «Unisci con…».');
      }
      rethrow;
    }
  }

  Future<void> delete(CatalogKind kind, int id) async {
    final QueryRow row = await db
        .customSelect('SELECT ${_usesSql(kind)} AS uses FROM ${kind.table} x WHERE x.id = ?', variables: <Variable>[
          Variable<int>(id),
        ])
        .getSingle();
    final int uses = row.read<int>('uses');
    if (uses > 0) {
      throw CatalogException(
        'La voce è usata da $uses ${kind == CatalogKind.console ? 'copie' : 'giochi'}: '
        'prima uniscila a un\'altra voce.',
      );
    }
    await db.customUpdate(
      'DELETE FROM ${kind.table} WHERE id = ?',
      variables: <Variable>[Variable<int>(id)],
      updates: _touched,
      updateKind: UpdateKind.delete,
    );
  }

  /// Sposta tutti gli usi di [sourceId] su [targetId] ed elimina la voce sorgente.
  Future<void> merge(CatalogKind kind, int sourceId, int targetId) async {
    // Unire una voce con sé stessa cancellerebbe tutte le sue copie nel passaggio
    // di pulizia dei duplicati.
    if (sourceId == targetId) throw const CatalogException('Scegli una voce diversa.');
    final List<Variable> ids = <Variable>[Variable<int>(sourceId), Variable<int>(targetId)];

    Future<void> run(String sql, [List<Variable>? variables]) =>
        db.customUpdate(sql, variables: variables ?? ids, updates: _touched);

    await db.transaction(() async {
      switch (kind) {
        case CatalogKind.console:
          for (final String table in const <String>['game_copies']) {
            // Prima le righe che diventerebbero doppioni (stesso gioco e formato già
            // presenti sulla destinazione), poi lo spostamento delle altre.
            await run(
              'DELETE FROM $table WHERE console_id = ? AND EXISTS (SELECT 1 FROM $table t '
              'WHERE t.game_id = $table.game_id AND t.format = $table.format AND t.console_id = ?)',
            );
            await run('UPDATE $table SET console_id = ?2 WHERE console_id = ?1');
          }
          await run(
            'DELETE FROM game_platforms WHERE console_id = ? AND EXISTS (SELECT 1 FROM game_platforms t '
            'WHERE t.game_id = game_platforms.game_id AND t.console_id = ?)',
          );
          await run('UPDATE game_platforms SET console_id = ?2 WHERE console_id = ?1');
        case CatalogKind.genere:
          await run(
            'DELETE FROM game_genres WHERE genre_id = ? AND EXISTS (SELECT 1 FROM game_genres t '
            'WHERE t.game_id = game_genres.game_id AND t.genre_id = ?)',
          );
          await run('UPDATE game_genres SET genre_id = ?2 WHERE genre_id = ?1');
        case CatalogKind.serie:
          await run('UPDATE games SET series_id = ?2 WHERE series_id = ?1');
        case CatalogKind.azienda:
          await run('UPDATE games SET developer_id = ?2 WHERE developer_id = ?1');
          await run('UPDATE games SET publisher_id = ?2 WHERE publisher_id = ?1');
      }
      await run('DELETE FROM ${kind.table} WHERE id = ?', <Variable>[Variable<int>(sourceId)]);
    });
  }
}
