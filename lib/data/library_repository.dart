import 'package:drift/drift.dart';

import '../domain/enums.dart';
import '../domain/library_query.dart';
import '../domain/normalizer.dart';
import 'catalog_repository.dart';
import 'database.dart';

/// Una voce della libreria, con tutto ciò che mostrano griglia e lista.
class LibraryItem {
  const LibraryItem({
    required this.id,
    required this.title,
    required this.status,
    required this.consoleLabels,
    required this.formats,
    required this.isCollection,
    required this.itemCount,
    required this.collectionTitles,
    this.overallRating,
    this.coverPath,
    this.releaseYear,
    this.seriesName,
    this.players,
  });

  final int id;
  final String title;
  final GameStatus status;

  /// Per una raccolta è la media dei giochi che contiene.
  final double? overallRating;
  final String? coverPath;

  /// Sigle delle console, in ordine di catalogo: copie possedute, copie delle
  /// raccolte di cui fa parte e console di uscita.
  final List<String> consoleLabels;
  final Set<CopyFormat> formats;
  final bool isCollection;

  /// Quanti giochi contiene, se è una raccolta.
  final int itemCount;

  /// Raccolte di cui questo gioco fa parte.
  final List<String> collectionTitles;
  final int? releaseYear;
  final String? seriesName;
  final int? players;

  bool get isInCollection => collectionTitles.isNotEmpty;
}

/// Valori effettivamente usati in libreria, da proporre nel foglio filtri.
class FilterOptions {
  const FilterOptions({
    required this.consoles,
    required this.genres,
    required this.series,
    required this.developers,
    required this.publishers,
  });

  final List<CatalogEntry> consoles;
  final List<CatalogEntry> genres;
  final List<CatalogEntry> series;
  final List<CatalogEntry> developers;
  final List<CatalogEntry> publishers;
}

class LibraryRepository {
  LibraryRepository(this.db);

  final AppDatabase db;

  Stream<List<LibraryItem>> watchLibrary(LibraryQuery query) {
    final List<Variable> variables = <Variable>[];
    final String where;
    if (query.effectiveShowChildren) {
      where = _predicate('g', query, variables);
    } else {
      // Con i contenuti nascosti restano fuori solo i giochi che possiedi
      // unicamente dentro una raccolta: se hai anche una copia tua (la cartuccia
      // di Super Mario 64) la voce compare comunque. Una raccolta compare se
      // corrisponde lei o uno dei giochi che contiene, altrimenti cercare un
      // titolo contenuto non troverebbe nulla.
      final String own = _predicate('g', query, variables);
      final String item = _predicate('it', query, variables);
      where =
          '(NOT EXISTS (SELECT 1 FROM collection_items m WHERE m.game_id = g.id) '
          ' OR EXISTS (SELECT 1 FROM game_copies oc WHERE oc.game_id = g.id)) '
          'AND (($own) OR (g.is_collection = 1 AND EXISTS '
          '(SELECT 1 FROM collection_items ci JOIN games it ON it.id = ci.game_id '
          'WHERE ci.collection_id = g.id AND ($item))))';
    }

    final String sql =
        '''
        SELECT g.id, g.title, g.status, g.cover_path,
               g.is_collection, g.release_year, g.players, s.name AS series_name,
               CASE WHEN g.is_collection = 1
                    THEN (SELECT avg(it.overall_rating) FROM collection_items ci
                          JOIN games it ON it.id = ci.game_id WHERE ci.collection_id = g.id)
                    ELSE g.overall_rating END AS rating,
               (SELECT count(*) FROM collection_items ci WHERE ci.collection_id = g.id) AS item_count,
               (SELECT group_concat(c.title, '|') FROM collection_items ci
                   JOIN games c ON c.id = ci.collection_id WHERE ci.game_id = g.id) AS collections,
               (SELECT group_concat(label, '|' ORDER BY so) FROM (
                   SELECT DISTINCT c.short_label AS label, lower(c.short_label) AS so
                   FROM game_consoles e2 JOIN consoles c ON c.id = e2.console_id
                   WHERE e2.game_id = g.id)) AS console_labels,
               (SELECT group_concat(DISTINCT e3.format) FROM effective_copies e3
                   WHERE e3.game_id = g.id) AS formats
        FROM games g
        LEFT JOIN series s ON s.id = g.series_id
        WHERE $where
        ORDER BY ${_orderBy(query)}
        ''';

    return db
        .customSelect(
          sql,
          variables: variables,
          readsFrom: {db.games, db.gameCopies, db.gameGenres, db.gamePlatforms, db.collectionItems, db.consoles, db.series},
        )
        .watch()
        .map((List<QueryRow> rows) => rows.map(_toItem).toList());
  }

  Stream<FilterOptions> watchFilterOptions() {
    return db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            db.games,
            db.gameCopies,
            db.gameGenres,
            db.gamePlatforms,
            db.collectionItems,
            db.consoles,
            db.genres,
            db.series,
            db.companies,
          },
        )
        .watch()
        .asyncMap((_) async {
          Future<List<CatalogEntry>> entries(String sql) async => <CatalogEntry>[
            for (final QueryRow r in await db.customSelect(sql).get())
              CatalogEntry(r.read<int>('id'), r.read<String>('name')),
          ];
          return FilterOptions(
            consoles: await entries(
              'SELECT DISTINCT c.id, c.name, c.name_norm FROM consoles c '
              'JOIN game_consoles gc ON gc.console_id = c.id ORDER BY c.name_norm',
            ),
            genres: await entries(
              'SELECT DISTINCT x.id, x.name, x.name_norm FROM genres x '
              'JOIN game_genres gg ON gg.genre_id = x.id ORDER BY x.name_norm',
            ),
            series: await entries(
              'SELECT DISTINCT x.id, x.name, x.name_norm FROM series x '
              'JOIN games g ON g.series_id = x.id ORDER BY x.name_norm',
            ),
            developers: await entries(
              'SELECT DISTINCT x.id, x.name, x.name_norm FROM companies x '
              'JOIN games g ON g.developer_id = x.id ORDER BY x.name_norm',
            ),
            publishers: await entries(
              'SELECT DISTINCT x.id, x.name, x.name_norm FROM companies x '
              'JOIN games g ON g.publisher_id = x.id ORDER BY x.name_norm',
            ),
          );
        });
  }

  /// Condizione di filtro sull'alias [x]. Ogni dimensione a più valori è una
  /// sottoquery EXISTS e mai una JOIN: con due generi selezionati una JOIN
  /// duplicherebbe le righe della libreria.
  static String _predicate(String x, LibraryQuery q, List<Variable> vars) {
    final List<String> parts = <String>[];

    final String search = normalize(q.search);
    if (q.search.trim().isNotEmpty && search.isNotEmpty) {
      parts.add('$x.title_norm LIKE ?');
      vars.add(Variable<String>('%$search%'));
    }
    if (q.statuses.isNotEmpty) {
      parts.add('$x.status IN (${_in(q.statuses.map((GameStatus s) => s.dbValue), vars)})');
    }
    // Console e formato nella stessa EXISTS: «PS4 + Digitale» significa una
    // copia digitale su PS4, non «qualcosa su PS4 e qualcosa in digitale».
    // game_consoles comprende le console di uscita, che non hanno formato:
    // corrispondono ai filtri per console ma mai a quelli per formato.
    if (q.consoleIds.isNotEmpty || q.formats.isNotEmpty) {
      final List<String> copy = <String>['ec.game_id = $x.id'];
      if (q.consoleIds.isNotEmpty) copy.add('ec.console_id IN (${_in(q.consoleIds, vars)})');
      if (q.formats.isNotEmpty) {
        copy.add('ec.format IN (${_in(q.formats.map((CopyFormat f) => f.dbValue), vars)})');
      }
      parts.add('EXISTS (SELECT 1 FROM game_consoles ec WHERE ${copy.join(' AND ')})');
    }
    if (q.genreIds.isNotEmpty) {
      parts.add(
        'EXISTS (SELECT 1 FROM game_genres gg WHERE gg.game_id = $x.id '
        'AND gg.genre_id IN (${_in(q.genreIds, vars)}))',
      );
    }
    if (q.seriesIds.isNotEmpty) parts.add('$x.series_id IN (${_in(q.seriesIds, vars)})');
    if (q.developerIds.isNotEmpty) parts.add('$x.developer_id IN (${_in(q.developerIds, vars)})');
    if (q.publisherIds.isNotEmpty) parts.add('$x.publisher_id IN (${_in(q.publisherIds, vars)})');
    if (q.players.isNotEmpty) parts.add('$x.players IN (${_in(q.players, vars)})');

    for (final GameFlag flag in q.flags) {
      parts.add(switch (flag) {
        GameFlag.rigiocabile => '$x.is_replayable = 1',
        GameFlag.postGame => '$x.has_post_game = 1',
        GameFlag.achievement => '$x.has_achievements = 1',
        GameFlag.tuttiAchievement => '$x.all_achievements_unlocked = 1',
        GameFlag.dlc => '$x.has_dlc = 1',
      });
    }

    switch (q.kind) {
      case LibraryKind.tutti:
        break;
      case LibraryKind.soloCollection:
        parts.add('$x.is_collection = 1');
      case LibraryKind.soloSingoli:
        parts.add(
          '$x.is_collection = 0 AND NOT EXISTS '
          '(SELECT 1 FROM collection_items k WHERE k.game_id = $x.id)',
        );
      case LibraryKind.soloContenuti:
        parts.add('EXISTS (SELECT 1 FROM collection_items k WHERE k.game_id = $x.id)');
    }

    return parts.isEmpty ? '1' : parts.join(' AND ');
  }

  static String _in(Iterable<Object> values, List<Variable> vars) {
    for (final Object value in values) {
      vars.add(value is int ? Variable<int>(value) : Variable<String>(value as String));
    }
    return List<String>.filled(values.length, '?').join(', ');
  }

  /// I valori mancanti (anno sconosciuto, gioco non valutato) restano in fondo in
  /// entrambe le direzioni; lo spareggio finale rende l'ordine sempre riproducibile.
  static String _orderBy(LibraryQuery q) {
    final String dir = q.ascending ? 'ASC' : 'DESC';
    return switch (q.sort) {
      SortCriterion.titolo => 'g.sort_title $dir, g.id $dir',
      SortCriterion.anno => 'g.release_year $dir NULLS LAST, g.sort_title ASC, g.id ASC',
      SortCriterion.voto => 'rating $dir NULLS LAST, g.sort_title ASC, g.id ASC',
      SortCriterion.aggiunta => 'g.created_at $dir, g.id $dir',
    };
  }

  static LibraryItem _toItem(QueryRow r) {
    final String? labels = r.readNullable<String>('console_labels');
    final String? formats = r.readNullable<String>('formats');
    final String? collections = r.readNullable<String>('collections');
    return LibraryItem(
      id: r.read<int>('id'),
      title: r.read<String>('title'),
      status: GameStatus.fromDb(r.read<String>('status')),
      overallRating: r.readNullable<double>('rating'),
      players: r.readNullable<int>('players'),
      coverPath: r.readNullable<String>('cover_path'),
      isCollection: r.read<bool>('is_collection'),
      releaseYear: r.readNullable<int>('release_year'),
      seriesName: r.readNullable<String>('series_name'),
      itemCount: r.read<int>('item_count'),
      collectionTitles: collections == null || collections.isEmpty ? const <String>[] : collections.split('|'),
      consoleLabels: labels == null || labels.isEmpty ? const <String>[] : labels.split('|'),
      formats: <CopyFormat>{
        if (formats != null)
          for (final String f in formats.split(',')) CopyFormat.fromDb(f),
      },
    );
  }
}
