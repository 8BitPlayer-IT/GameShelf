import 'package:drift/drift.dart';

import '../domain/enums.dart';
import '../domain/game_draft.dart';
import '../domain/normalizer.dart';
import 'catalog_repository.dart';
import 'database.dart';

/// Una copia posseduta come la mostra la scheda.
class CopyView {
  const CopyView({
    required this.consoleId,
    required this.consoleName,
    required this.shortLabel,
    required this.family,
    required this.format,
  });

  final int consoleId;
  final String consoleName;
  final String shortLabel;
  final String family;
  final CopyFormat format;
}

/// Una console senza formato: la console di uscita originale.
class ConsoleView {
  const ConsoleView({required this.consoleId, required this.name, required this.shortLabel, required this.family});

  final int consoleId;
  final String name;
  final String shortLabel;
  final String family;
}

/// Riga dell'elenco «Giochi contenuti» di una raccolta.
class ItemSummary {
  const ItemSummary({
    required this.id,
    required this.title,
    required this.status,
    this.overallRating,
    this.coverPath,
    this.releaseYear,
    this.consoleLabels,
  });

  final int id;
  final String title;
  final GameStatus status;
  final double? overallRating;
  final String? coverPath;
  final int? releaseYear;

  /// Sigle delle console di uscita, già unite: «N64 · GC».
  final String? consoleLabels;
}

/// Una raccolta a cui il gioco appartiene, con le console di quella raccolta.
class MembershipView {
  const MembershipView({required this.collectionId, required this.title, required this.copies});

  final int collectionId;
  final String title;
  final List<CopyView> copies;
}

/// Tutto quello che serve alla schermata di dettaglio.
class GameDetails {
  const GameDetails({
    required this.game,
    required this.genres,
    required this.copies,
    required this.platforms,
    required this.items,
    required this.memberships,
    this.seriesName,
    this.developerName,
    this.publisherName,
  });

  final Game game;
  final String? seriesName;
  final String? developerName;
  final String? publisherName;
  final List<String> genres;

  /// Copie possedute direttamente da questo gioco.
  final List<CopyView> copies;

  /// Console di uscita originale.
  final List<ConsoleView> platforms;

  /// Giochi contenuti, se questo è una raccolta.
  final List<ItemSummary> items;

  /// Raccolte di cui questo gioco fa parte.
  final List<MembershipView> memberships;

  GameStatus get status => GameStatus.fromDb(game.status);

  /// Voto da mostrare: per una raccolta è la media dei giochi contenuti.
  double? get displayRating {
    if (!game.isCollection) return game.overallRating;
    final List<double> rated = <double>[
      for (final ItemSummary i in items)
        if (i.overallRating != null) i.overallRating!,
    ];
    if (rated.isEmpty) return null;
    return rated.reduce((double a, double b) => a + b) / rated.length;
  }

  int get ratedItems => items.where((ItemSummary i) => i.overallRating != null).length;
}

/// Tutto ciò che un'eliminazione ha cancellato, per poterlo rimettere identico
/// se l'utente preme ANNULLA.
class DeletedGameSnapshot {
  const DeletedGameSnapshot({
    required this.rootId,
    required this.title,
    required this.games,
    required this.copies,
    required this.genres,
    required this.platforms,
    required this.memberships,
  });

  final int rootId;
  final String title;
  final List<Map<String, Object?>> games;
  final List<Map<String, Object?>> copies;
  final List<Map<String, Object?>> genres;
  final List<Map<String, Object?>> platforms;
  final List<Map<String, Object?>> memberships;
}

class GameValidationException implements Exception {
  const GameValidationException(this.errors);

  final List<String> errors;

  @override
  String toString() => errors.join('\n');
}

/// Messaggi dei trigger dello schema: sono già in italiano e pensati per l'utente.
const List<String> _schemaMessages = <String>[
  'Un gioco può essere contenuto solo in una collection',
  'Una collection non può essere contenuta in una collection',
  'La collection contiene ancora dei giochi: scioglila prima',
];

/// Traduce un errore di salvataggio in una frase da mostrare all'utente.
String describeSaveError(Object error) {
  if (error is GameValidationException) return error.errors.first;
  final String text = error.toString();
  for (final String message in _schemaMessages) {
    if (text.contains(message)) return '$message.';
  }
  if (text.contains('UNIQUE constraint failed')) return 'Esiste già una voce con questo nome.';
  if (text.contains('FOREIGN KEY constraint failed')) {
    return 'Questa voce è ancora usata da qualche gioco.';
  }
  return 'Operazione non riuscita: $text';
}

/// Colonne scrivibili di `games` (la colonna generata `overall_rating` è esclusa).
const List<String> _gameColumns = <String>[
  'id', 'title', 'title_norm', 'sort_title', 'series_id', 'developer_id', 'publisher_id',
  'release_year', 'status', 'is_replayable', 'has_post_game', 'has_achievements',
  'all_achievements_unlocked', 'has_dlc', 'is_collection', 'rating_story',
  'rating_gameplay', 'rating_graphics', 'rating_soundtrack', 'cover_path',
  'created_at', 'updated_at', 'players',
];

class GameRepository {
  GameRepository(this.db, this.catalogs, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final AppDatabase db;
  final CatalogRepository catalogs;
  final DateTime Function() _now;

  Set<TableInfo<Table, Object?>> get _touched => <TableInfo<Table, Object?>>{
    db.games,
    db.gameCopies,
    db.gameGenres,
    db.gamePlatforms,
    db.collectionItems,
  };

  /// Crea o aggiorna un gioco con copie, generi, console di uscita e appartenenze,
  /// in una transazione. Sostituisce gli elenchi, non li somma.
  /// Lancia [GameValidationException] se la scheda non è valida.
  /// I giochi senza copertina, con i nomi delle console che servono a cercarla:
  /// prima quelle delle copie possedute, poi quelle di uscita, nello stesso
  /// ordine che usa l'editor.
  ///
  /// Serve alla ricerca in blocco dalle impostazioni. Il separatore è `§§`
  /// perché un nome di console può contenere la barra verticale: «Xbox Series
  /// X|S» con un `|` come separatore si spezzerebbe in due console inesistenti.
  Future<List<GameWithoutCover>> gamesWithoutCover() async {
    final List<QueryRow> rows = await db
        .customSelect(
          'SELECT g.id, g.title, '
          "(SELECT group_concat(c.name, '§§') FROM game_copies gc "
          'JOIN consoles c ON c.id = gc.console_id WHERE gc.game_id = g.id) AS copie, '
          "(SELECT group_concat(c.name, '§§') FROM game_platforms gp "
          'JOIN consoles c ON c.id = gp.console_id WHERE gp.game_id = g.id) AS piattaforme '
          'FROM games g WHERE g.cover_path IS NULL ORDER BY g.sort_title, g.id',
        )
        .get();

    return <GameWithoutCover>[
      for (final QueryRow r in rows)
        GameWithoutCover(
          id: r.read<int>('id'),
          title: r.read<String>('title'),
          consoles: <String>{
            for (final String part in <String>[
              ...?r.readNullable<String>('copie')?.split('§§'),
              ...?r.readNullable<String>('piattaforme')?.split('§§'),
            ])
              if (part.isNotEmpty) part,
          }.toList(),
        ),
    ];
  }

  Future<int> save(GameDraft draft, {bool ignoreArticles = true}) {
    final List<String> errors = draft.validate(currentYear: _now().year);
    if (errors.isNotEmpty) throw GameValidationException(errors);

    // Il voto di una raccolta è la media dei giochi contenuti: non se ne salva uno proprio.
    final bool ownRating = !draft.isCollection;

    return db.transaction(() async {
      final DateTime now = _now();
      final String title = draft.title.trim();
      final GamesCompanion values = GamesCompanion(
        title: Value<String>(title),
        titleNorm: Value<String>(normalize(title)),
        sortTitle: Value<String>(sortKey(title, ignoreArticles: ignoreArticles)),
        seriesId: Value<int?>(await catalogs.seriesIdFor(draft.seriesName)),
        developerId: Value<int?>(await catalogs.companyIdFor(draft.developerName)),
        publisherId: Value<int?>(await catalogs.companyIdFor(draft.publisherName)),
        releaseYear: Value<int?>(draft.releaseYear),
        status: Value<String>(draft.status.dbValue),
        isReplayable: Value<bool>(draft.isReplayable),
        hasPostGame: Value<bool>(draft.hasPostGame),
        hasAchievements: Value<bool>(draft.hasAchievements),
        allAchievementsUnlocked: Value<bool>(draft.hasAchievements && draft.allAchievementsUnlocked),
        hasDlc: Value<bool>(draft.hasDlc),
        isCollection: Value<bool>(draft.isCollection),
        ratingStory: Value<double?>(ownRating ? draft.ratingStory : null),
        ratingGameplay: Value<double?>(ownRating ? draft.ratingGameplay : null),
        ratingGraphics: Value<double?>(ownRating ? draft.ratingGraphics : null),
        ratingSoundtrack: Value<double?>(ownRating ? draft.ratingSoundtrack : null),
        coverPath: Value<String?>(draft.coverPath),
        players: Value<int?>(draft.players),
        updatedAt: Value<DateTime>(now),
      );

      final int id;
      final int? existingId = draft.id;
      if (existingId == null) {
        id = await db.into(db.games).insert(values.copyWith(createdAt: Value<DateTime>(now)));
      } else {
        id = existingId;
        await (db.update(db.games)..where((Games g) => g.id.equals(id))).write(values);
        await (db.delete(db.gameCopies)..where((GameCopies c) => c.gameId.equals(id))).go();
      }

      for (final CopyDraft copy in draft.copies) {
        await db
            .into(db.gameCopies)
            .insert(GameCopiesCompanion.insert(gameId: id, consoleId: copy.consoleId, format: copy.format.dbValue));
      }

      await (db.delete(db.gamePlatforms)..where((GamePlatforms p) => p.gameId.equals(id))).go();
      for (final int consoleId in draft.platformIds.toSet()) {
        await db.into(db.gamePlatforms).insert(GamePlatformsCompanion.insert(gameId: id, consoleId: consoleId));
      }

      await (db.delete(db.collectionItems)..where((CollectionItems ci) => ci.gameId.equals(id))).go();
      for (final int collectionId in draft.collectionIds.toSet()) {
        await db
            .into(db.collectionItems)
            .insert(CollectionItemsCompanion.insert(collectionId: collectionId, gameId: id));
      }

      await (db.delete(db.gameGenres)..where((GameGenres g) => g.gameId.equals(id))).go();
      for (final int genreId in draft.genreIds) {
        await db.into(db.gameGenres).insert(GameGenresCompanion.insert(gameId: id, genreId: genreId));
      }
      return id;
    });
  }

  Future<GameDraft> loadDraft(int id) async {
    final Game game = await (db.select(db.games)..where((Games g) => g.id.equals(id))).getSingle();
    final QueryRow names = await db
        .customSelect(
          'SELECT (SELECT name FROM series WHERE id = ?) AS series_name, '
          '(SELECT name FROM companies WHERE id = ?) AS developer_name, '
          '(SELECT name FROM companies WHERE id = ?) AS publisher_name',
          variables: <Variable>[
            Variable<int>(game.seriesId),
            Variable<int>(game.developerId),
            Variable<int>(game.publisherId),
          ],
        )
        .getSingle();
    final List<GameGenre> genres = await (db.select(db.gameGenres)..where((GameGenres g) => g.gameId.equals(id))).get();
    final List<GameCopy> copies = await (db.select(db.gameCopies)..where((GameCopies c) => c.gameId.equals(id))).get();
    final List<GamePlatform> platforms = await (db.select(
      db.gamePlatforms,
    )..where((GamePlatforms p) => p.gameId.equals(id))).get();
    final List<CollectionItem> memberships = await (db.select(
      db.collectionItems,
    )..where((CollectionItems ci) => ci.gameId.equals(id))).get();

    return GameDraft(
      id: game.id,
      title: game.title,
      seriesName: names.readNullable<String>('series_name') ?? '',
      developerName: names.readNullable<String>('developer_name') ?? '',
      publisherName: names.readNullable<String>('publisher_name') ?? '',
      releaseYear: game.releaseYear,
      genreIds: <int>{for (final GameGenre g in genres) g.genreId},
      copies: <CopyDraft>[
        for (final GameCopy c in copies) CopyDraft(consoleId: c.consoleId, format: CopyFormat.fromDb(c.format)),
      ],
      platformIds: <int>[for (final GamePlatform p in platforms) p.consoleId],
      collectionIds: <int>[for (final CollectionItem ci in memberships) ci.collectionId],
      status: GameStatus.fromDb(game.status),
      isReplayable: game.isReplayable,
      hasPostGame: game.hasPostGame,
      hasAchievements: game.hasAchievements,
      allAchievementsUnlocked: game.allAchievementsUnlocked,
      hasDlc: game.hasDlc,
      isCollection: game.isCollection,
      ratingStory: game.ratingStory,
      ratingGameplay: game.ratingGameplay,
      ratingGraphics: game.ratingGraphics,
      ratingSoundtrack: game.ratingSoundtrack,
      coverPath: game.coverPath,
      players: game.players,
    );
  }

  /// Scheda completa, aggiornata a ogni modifica di gioco, copie, generi o cataloghi.
  Stream<GameDetails?> watchDetails(int id) {
    return db
        .customSelect(
          'SELECT id FROM games WHERE id = ?',
          variables: <Variable>[Variable<int>(id)],
          readsFrom: <TableInfo<Table, Object?>>{..._touched, db.consoles, db.genres, db.series, db.companies},
        )
        .watch()
        .asyncMap((List<QueryRow> rows) async {
          if (rows.isEmpty) return null;
          final Game game = await (db.select(db.games)..where((Games g) => g.id.equals(id))).getSingle();
          final List<Variable> idVar = <Variable>[Variable<int>(id)];

          final QueryRow names = await db
              .customSelect(
                'SELECT (SELECT name FROM series WHERE id = ?) AS series_name, '
                '(SELECT name FROM companies WHERE id = ?) AS developer_name, '
                '(SELECT name FROM companies WHERE id = ?) AS publisher_name',
                variables: <Variable>[
                  Variable<int>(game.seriesId),
                  Variable<int>(game.developerId),
                  Variable<int>(game.publisherId),
                ],
              )
              .getSingle();

          final List<QueryRow> genreRows = await db
              .customSelect(
                'SELECT ge.name FROM game_genres gg JOIN genres ge ON ge.id = gg.genre_id '
                'WHERE gg.game_id = ? ORDER BY ge.name_norm',
                variables: idVar,
              )
              .get();

          final List<QueryRow> copyRows = await db
              .customSelect(
                'SELECT gc.console_id, c.name, c.short_label, c.family, gc.format '
                'FROM game_copies gc JOIN consoles c ON c.id = gc.console_id '
                'WHERE gc.game_id = ? ORDER BY c.name_norm, gc.format',
                variables: idVar,
              )
              .get();

          final List<QueryRow> platformRows = await db
              .customSelect(
                'SELECT c.id, c.name, c.short_label, c.family FROM game_platforms gp '
                'JOIN consoles c ON c.id = gp.console_id WHERE gp.game_id = ? ORDER BY c.name_norm',
                variables: idVar,
              )
              .get();

          final List<QueryRow> itemRows = await db
              .customSelect(
                'SELECT g.id, g.title, g.status, g.overall_rating, g.cover_path, g.release_year, '
                "(SELECT group_concat(c.short_label, ' · ') FROM game_platforms gp "
                'JOIN consoles c ON c.id = gp.console_id WHERE gp.game_id = g.id) AS labels '
                'FROM collection_items ci JOIN games g ON g.id = ci.game_id WHERE ci.collection_id = ? '
                'ORDER BY g.release_year IS NULL, g.release_year, g.sort_title, g.id',
                variables: idVar,
              )
              .get();

          final List<QueryRow> membershipRows = await db
              .customSelect(
                'SELECT g.id, g.title FROM collection_items ci JOIN games g ON g.id = ci.collection_id '
                'WHERE ci.game_id = ? ORDER BY g.sort_title',
                variables: idVar,
              )
              .get();

          final List<MembershipView> memberships = <MembershipView>[];
          for (final QueryRow r in membershipRows) {
            final int collectionId = r.read<int>('id');
            memberships.add(
              MembershipView(
                collectionId: collectionId,
                title: r.read<String>('title'),
                copies: await _copiesOf(collectionId),
              ),
            );
          }

          return GameDetails(
            game: game,
            seriesName: names.readNullable<String>('series_name'),
            developerName: names.readNullable<String>('developer_name'),
            publisherName: names.readNullable<String>('publisher_name'),
            genres: <String>[for (final QueryRow r in genreRows) r.read<String>('name')],
            copies: <CopyView>[for (final QueryRow r in copyRows) _copyView(r)],
            platforms: <ConsoleView>[
              for (final QueryRow r in platformRows)
                ConsoleView(
                  consoleId: r.read<int>('id'),
                  name: r.read<String>('name'),
                  shortLabel: r.read<String>('short_label'),
                  family: r.read<String>('family'),
                ),
            ],
            items: <ItemSummary>[
              for (final QueryRow r in itemRows)
                ItemSummary(
                  id: r.read<int>('id'),
                  title: r.read<String>('title'),
                  status: GameStatus.fromDb(r.read<String>('status')),
                  overallRating: r.readNullable<double>('overall_rating'),
                  coverPath: r.readNullable<String>('cover_path'),
                  releaseYear: r.readNullable<int>('release_year'),
                  consoleLabels: r.readNullable<String>('labels'),
                ),
            ],
            memberships: memberships,
          );
        });
  }

  Future<List<CopyView>> _copiesOf(int gameId) async {
    final List<QueryRow> rows = await db
        .customSelect(
          'SELECT gc.console_id, c.name, c.short_label, c.family, gc.format '
          'FROM game_copies gc JOIN consoles c ON c.id = gc.console_id '
          'WHERE gc.game_id = ? ORDER BY c.name_norm, gc.format',
          variables: <Variable>[Variable<int>(gameId)],
        )
        .get();
    return <CopyView>[for (final QueryRow r in rows) _copyView(r)];
  }

  static CopyView _copyView(QueryRow r) => CopyView(
    consoleId: r.read<int>('console_id'),
    consoleName: r.read<String>('name'),
    shortLabel: r.read<String>('short_label'),
    family: r.read<String>('family'),
    format: CopyFormat.fromDb(r.read<String>('format')),
  );

  /// Mette su un gioco già salvato una copertina trovata online.
  ///
  /// Nel database va il percorso **relativo** (`covers/<uuid>.jpg`), come per
  /// quelle scelte dalla galleria: una copertina scaricata non è diversa dalle
  /// altre e sopravvive a un ripristino.
  Future<void> setCover(int id, String relativePath) {
    return (db.update(db.games)..where((Games g) => g.id.equals(id))).write(
      GamesCompanion(coverPath: Value<String?>(relativePath), updatedAt: Value<DateTime>(_now())),
    );
  }

  Future<void> setStatus(int id, GameStatus status) {
    return (db.update(db.games)..where((Games g) => g.id.equals(id))).write(
      GamesCompanion(status: Value<String>(status.dbValue), updatedAt: Value<DateTime>(_now())),
    );
  }

  /// Aggiunge o toglie l'appartenenza di un gioco a una raccolta.
  Future<void> setMembership(int gameId, int collectionId, {required bool member}) async {
    if (member) {
      await db
          .into(db.collectionItems)
          .insert(
            CollectionItemsCompanion.insert(collectionId: collectionId, gameId: gameId),
            mode: InsertMode.insertOrIgnore,
          );
    } else {
      await (db.delete(db.collectionItems)..where(
            (CollectionItems ci) => ci.collectionId.equals(collectionId) & ci.gameId.equals(gameId),
          ))
          .go();
    }
  }

  /// Raccolte esistenti, per l'elenco «appartiene a».
  Stream<List<(int, String)>> watchCollections() {
    return db
        .customSelect(
          'SELECT id, title FROM games WHERE is_collection = 1 ORDER BY sort_title',
          readsFrom: <TableInfo<Table, Object?>>{db.games},
        )
        .watch()
        .map((List<QueryRow> rows) => <(int, String)>[
          for (final QueryRow r in rows) (r.read<int>('id'), r.read<String>('title')),
        ]);
    }

  /// Giochi già in libreria che si possono aggiungere a una raccolta: esclusi
  /// quelli che ci sono già e le altre raccolte.
  Future<List<(int, String, int?)>> searchGamesForCollection(int collectionId, String query) async {
    final String norm = normalize(query);
    final List<QueryRow> rows = await db
        .customSelect(
          'SELECT id, title, release_year FROM games g '
          'WHERE g.is_collection = 0 AND g.title_norm LIKE ? '
          'AND NOT EXISTS (SELECT 1 FROM collection_items ci WHERE ci.collection_id = ? AND ci.game_id = g.id) '
          'ORDER BY g.sort_title LIMIT 60',
          variables: <Variable>[Variable<String>('%$norm%'), Variable<int>(collectionId)],
        )
        .get();
    return <(int, String, int?)>[
      for (final QueryRow r in rows)
        (r.read<int>('id'), r.read<String>('title'), r.readNullable<int>('release_year')),
    ];
  }

  /// Giochi fra cui scegliere per un'unione: tutti tranne [exceptId] e le raccolte.
  Future<List<(int, String, int?)>> searchMergeCandidates(int exceptId, String query) async {
    final String norm = normalize(query);
    final List<QueryRow> rows = await db
        .customSelect(
          'SELECT id, title, release_year FROM games '
          'WHERE id <> ? AND is_collection = 0 AND title_norm LIKE ? ORDER BY sort_title LIMIT 40',
          variables: <Variable>[Variable<int>(exceptId), Variable<String>('%$norm%')],
        )
        .get();
    return <(int, String, int?)>[
      for (final QueryRow r in rows)
        (r.read<int>('id'), r.read<String>('title'), r.readNullable<int>('release_year')),
    ];
  }

  /// Fonde [otherId] dentro [keepId] e cancella l'altra voce.
  ///
  /// Serve per i doppioni: lo stesso gioco inserito una volta da solo e una dentro
  /// una raccolta. La voce da tenere conserva i propri dati; dall'altra arrivano le
  /// copie, i generi, le console di uscita, le appartenenze e i campi che qui sono
  /// vuoti (voti, anno, serie, sviluppatore, publisher, copertina, giocatori).
  ///
  /// Restituisce il percorso della copertina rimasta inutilizzata, se c'è: il
  /// chiamante può cancellarne il file.
  Future<String?> merge({required int keepId, required int otherId}) {
    if (keepId == otherId) throw const GameValidationException(<String>['Scegli due giochi diversi.']);
    return db.transaction(() async {
      final Game keep = await (db.select(db.games)..where((Games g) => g.id.equals(keepId))).getSingle();
      final Game other = await (db.select(db.games)..where((Games g) => g.id.equals(otherId))).getSingle();
      if (keep.isCollection || other.isCollection) {
        throw const GameValidationException(<String>['Le collection non si possono unire.']);
      }

      Future<void> move(String sql) =>
          db.customUpdate(sql, variables: <Variable>[Variable<int>(keepId), Variable<int>(otherId)], updates: _touched);

      // Prima si eliminano le righe che diventerebbero doppioni, poi si spostano
      // le altre: le chiavi primarie composte rifiuterebbero un semplice UPDATE.
      await move(
        'DELETE FROM game_copies WHERE game_id = ?2 AND EXISTS (SELECT 1 FROM game_copies t '
        'WHERE t.game_id = ?1 AND t.console_id = game_copies.console_id AND t.format = game_copies.format)',
      );
      await move('UPDATE game_copies SET game_id = ?1 WHERE game_id = ?2');
      await move(
        'DELETE FROM game_genres WHERE game_id = ?2 AND EXISTS (SELECT 1 FROM game_genres t '
        'WHERE t.game_id = ?1 AND t.genre_id = game_genres.genre_id)',
      );
      await move('UPDATE game_genres SET game_id = ?1 WHERE game_id = ?2');
      await move(
        'DELETE FROM game_platforms WHERE game_id = ?2 AND EXISTS (SELECT 1 FROM game_platforms t '
        'WHERE t.game_id = ?1 AND t.console_id = game_platforms.console_id)',
      );
      await move('UPDATE game_platforms SET game_id = ?1 WHERE game_id = ?2');
      await move(
        'DELETE FROM collection_items WHERE game_id = ?2 AND EXISTS (SELECT 1 FROM collection_items t '
        'WHERE t.game_id = ?1 AND t.collection_id = collection_items.collection_id)',
      );
      await move('UPDATE collection_items SET game_id = ?1 WHERE game_id = ?2');

      // Campi vuoti riempiti con quelli dell'altra voce.
      final bool keepUnrated = keep.overallRating == null;
      final GamesCompanion filled = GamesCompanion(
        seriesId: Value<int?>(keep.seriesId ?? other.seriesId),
        developerId: Value<int?>(keep.developerId ?? other.developerId),
        publisherId: Value<int?>(keep.publisherId ?? other.publisherId),
        releaseYear: Value<int?>(keep.releaseYear ?? other.releaseYear),
        players: Value<int?>(keep.players ?? other.players),
        coverPath: Value<String?>(keep.coverPath ?? other.coverPath),
        isReplayable: Value<bool>(keep.isReplayable || other.isReplayable),
        hasPostGame: Value<bool>(keep.hasPostGame || other.hasPostGame),
        hasAchievements: Value<bool>(keep.hasAchievements || other.hasAchievements),
        allAchievementsUnlocked: Value<bool>(keep.allAchievementsUnlocked || other.allAchievementsUnlocked),
        hasDlc: Value<bool>(keep.hasDlc || other.hasDlc),
        // I voti si prendono in blocco dall'altra solo se qui non ce n'è nessuno:
        // mescolare due valutazioni darebbe una media che non ha mai dato nessuno.
        ratingStory: Value<double?>(keepUnrated ? other.ratingStory : keep.ratingStory),
        ratingGameplay: Value<double?>(keepUnrated ? other.ratingGameplay : keep.ratingGameplay),
        ratingGraphics: Value<double?>(keepUnrated ? other.ratingGraphics : keep.ratingGraphics),
        ratingSoundtrack: Value<double?>(keepUnrated ? other.ratingSoundtrack : keep.ratingSoundtrack),
        updatedAt: Value<DateTime>(_now()),
      );
      await (db.update(db.games)..where((Games g) => g.id.equals(keepId))).write(filled);
      await (db.delete(db.games)..where((Games g) => g.id.equals(otherId))).go();

      final String? survivingCover = keep.coverPath ?? other.coverPath;
      return other.coverPath == survivingCover ? null : other.coverPath;
    });
  }

  /// Elimina subito il gioco restituendo tutto ciò che serve per annullare.
  ///
  /// Una raccolta viene eliminata da sola: i giochi che conteneva restano in
  /// libreria, semplicemente non appartengono più a nulla.
  ///
  /// L'eliminazione è immediata e non differita: la libreria legge un flusso dal
  /// database, quindi una riga «in attesa di cancellazione» resterebbe visibile.
  Future<DeletedGameSnapshot> delete(int id) {
    return db.transaction(() async {
      final List<QueryRow> gameRows = await db
          .customSelect(
            'SELECT ${_gameColumns.join(', ')} FROM games WHERE id = ?',
            variables: <Variable>[Variable<int>(id)],
          )
          .get();
      if (gameRows.isEmpty) throw StateError('Gioco $id inesistente');

      final List<Variable> idVar = <Variable>[Variable<int>(id)];
      Future<List<Map<String, Object?>>> rowsOf(String sql) async => <Map<String, Object?>>[
        for (final QueryRow r in await db.customSelect(sql, variables: idVar).get()) Map<String, Object?>.of(r.data),
      ];

      final DeletedGameSnapshot snapshot = DeletedGameSnapshot(
        rootId: id,
        title: gameRows.single.read<String>('title'),
        games: <Map<String, Object?>>[Map<String, Object?>.of(gameRows.single.data)],
        copies: await rowsOf('SELECT game_id, console_id, format FROM game_copies WHERE game_id = ?'),
        genres: await rowsOf('SELECT game_id, genre_id FROM game_genres WHERE game_id = ?'),
        platforms: await rowsOf('SELECT game_id, console_id FROM game_platforms WHERE game_id = ?'),
        memberships: await rowsOf(
          'SELECT collection_id, game_id FROM collection_items WHERE game_id = ? OR collection_id = ?1',
        ),
      );

      await db.customUpdate(
        'DELETE FROM games WHERE id = ?',
        variables: idVar,
        updates: _touched,
        updateKind: UpdateKind.delete,
      );
      return snapshot;
    });
  }

  /// Rimette esattamente ciò che [delete] aveva tolto, con gli stessi id.
  Future<void> undoDelete(DeletedGameSnapshot snapshot) {
    return db.transaction(() async {
      for (final Map<String, Object?> row in snapshot.games) {
        await _insertRaw('games', row, db.games);
      }
      for (final Map<String, Object?> row in snapshot.copies) {
        await _insertRaw('game_copies', row, db.gameCopies);
      }
      for (final Map<String, Object?> row in snapshot.genres) {
        await _insertRaw('game_genres', row, db.gameGenres);
      }
      for (final Map<String, Object?> row in snapshot.platforms) {
        await _insertRaw('game_platforms', row, db.gamePlatforms);
      }
      for (final Map<String, Object?> row in snapshot.memberships) {
        await _insertRaw('collection_items', row, db.collectionItems);
      }
    });
  }

  Future<void> _insertRaw(String table, Map<String, Object?> row, TableInfo<Table, Object?> info) {
    final List<String> columns = row.keys.toList();
    return db.customInsert(
      'INSERT INTO $table (${columns.join(', ')}) '
      'VALUES (${List<String>.filled(columns.length, '?').join(', ')})',
      variables: <Variable>[for (final String c in columns) _variable(row[c])],
      updates: {info},
    );
  }

  static Variable _variable(Object? value) => switch (value) {
    null => const Variable<Object>(null),
    final int v => Variable<int>(v),
    final double v => Variable<double>(v),
    final String v => Variable<String>(v),
    final Object v => Variable<Object>(v),
  };
}

/// Un gioco senza copertina, con le console su cui cercarla.
class GameWithoutCover {
  const GameWithoutCover({required this.id, required this.title, required this.consoles});

  final int id;
  final String title;

  /// Nomi delle console, nell'ordine in cui vanno provate le fonti.
  final List<String> consoles;
}
