import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '../domain/normalizer.dart';
import 'database.steps.dart';
import 'seed_data.dart';

part 'database.g.dart';

/// Il database dell'app. Tabelle, viste, indici e trigger sono definiti in SQL in
/// `sql/schema.drift`: drift ne genera le classi Dart e ne tiene traccia per le
/// migrazioni.
@DriftDatabase(include: <String>{'sql/schema.drift'})
class AppDatabase extends _$AppDatabase {
  /// Database reale dell'app, nella cartella documenti (inclusa nel backup ZIP).
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'gameshelf'));

  /// Usato dai test con un database in memoria.
  AppDatabase.forTesting(super.executor);

  /// v1: schema iniziale.
  /// v2: numero di giocatori e console di uscita dei giochi contenuti.
  /// v3: un gioco può stare in più collection e avere comunque copie proprie.
  /// v4: nuove console nel catalogo iniziale (nessuna modifica alle tabelle).
  /// v5: via la colonna delle miniature delle copertine, che nessuno riempiva.
  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await seedCatalogs();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Le chiavi esterne vanno spente fuori dalla transazione: la v3 ricrea la
      // tabella dei giochi, e con i controlli attivi le righe collegate
      // verrebbero cancellate a metà strada.
      await customStatement('PRAGMA foreign_keys = OFF');
      await transaction(() async {
        // Serve anche la versione di arrivo: senza, un aggiornamento alla v2
        // eseguirebbe pure i passi della v3.
        if (from < 2 && to >= 2) {
          await m.addColumn(games, games.players);
          await m.createTable(gamePlatforms);
          await m.createIndex(gamePlatformsConsoleId);
          // Vista e trigger della v2, scritti a mano perché nello schema attuale
          // non esistono più: il passo successivo li sostituisce. Servono perché
          // un aggiornamento alla sola v2 produca esattamente lo schema v2.
          await customStatement(
            'CREATE VIEW game_consoles AS SELECT game_id, console_id, format FROM game_copies '
            'UNION ALL SELECT game_id, console_id, NULL AS format FROM game_platforms',
          );
          await customStatement('''CREATE TRIGGER platforms_only_for_children_insert
BEFORE INSERT ON game_platforms
BEGIN
    SELECT RAISE(ABORT, 'La console di uscita si indica solo per i giochi dentro una collection')
    WHERE (SELECT parent_id FROM games WHERE id = NEW.game_id) IS NULL;
END;''');
        }
        if (from < 3 && to >= 3) await _upgradeToV3(m);
        // Console aggiunte al catalogo iniziale: il seeding è idempotente, quindi
        // aggiunge solo quelle che mancano e lascia intatte le voci rinominate.
        if (from < 4 && to >= 4) await seedCatalogs();
        // La colonna delle miniature non è mai stata riempita: le copertine si
        // ridimensionano al volo con `cacheWidth`. SQLite sa togliere una colonna
        // senza ricreare la tabella, quindi indici, viste e trigger restano in piedi.
        if (from < 5 && to >= 5) {
          await customStatement('ALTER TABLE games DROP COLUMN cover_thumb_path');
        }
      });
      if (kDebugMode) {
        final List<QueryRow> broken = await customSelect('PRAGMA foreign_key_check').get();
        assert(broken.isEmpty, 'Migrazione: riferimenti rotti ${broken.map((QueryRow r) => r.data)}');
      }
      await customStatement('PRAGMA foreign_keys = ON');
    },
    beforeOpen: (OpeningDetails details) async {
      // SQLite tiene le chiavi esterne disattivate di default: senza questo
      // pragma i vincoli ON DELETE CASCADE dello schema non scatterebbero,
      // e resterebbero copie o generi orfani.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Dalla singola collection di appartenenza (`games.parent_id`) alle appartenenze
  /// multiple (`collection_items`), con le copie messe da parte restituite ai loro
  /// giochi: ora che un gioco contenuto può possedere copie proprie, non servono più.
  Future<void> _upgradeToV3(Migrator m) async {
    await m.createTable(collectionItems);
    await m.createIndex(collectionItemsGameId);
    await customStatement(
      'INSERT OR IGNORE INTO collection_items (collection_id, game_id) '
      'SELECT parent_id, id FROM games WHERE parent_id IS NOT NULL',
    );
    // Viste e trigger della v2 nominano games.parent_id: vanno tolti prima di
    // ricreare la tabella senza quella colonna, e prima di restituire le copie
    // messe da parte (il vecchio trigger le rifiuterebbe, perché per lui un gioco
    // dentro una raccolta non può possedere nulla).
    for (final String view in const <String>['effective_copies', 'stat_games', 'game_consoles']) {
      await customStatement('DROP VIEW IF EXISTS $view');
    }
    for (final String trigger in const <String>[
      'copies_only_on_owner_insert',
      'copies_only_on_owner_update',
      'parent_must_be_collection_insert',
      'parent_must_be_collection_update',
      'no_nested_collections',
      'collection_with_children_cannot_be_demoted',
      'child_must_not_own_copies',
      'detached_copies_only_for_children_insert',
      'detached_copies_only_for_children_update',
      'platforms_only_for_children_insert',
    ]) {
      await customStatement('DROP TRIGGER IF EXISTS $trigger');
    }
    await customStatement(
      'INSERT OR IGNORE INTO game_copies (game_id, console_id, format) '
      'SELECT game_id, console_id, format FROM detached_copies',
    );
    await customStatement('DROP TABLE IF EXISTS detached_copies');
    await customStatement('DROP INDEX IF EXISTS games_parent_id');

    // Ricrea `games` dalla definizione attuale, cioè senza parent_id.
    // La tabella si ricrea dalla forma congelata della v3 (in `database.steps.dart`)
    // e non da quella attuale: la v5 ha poi tolto una colonna, e un aggiornamento
    // che si ferma alla v3 deve produrre esattamente lo schema della v3.
    final Schema3 schemaV3 = Schema3(database: this);
    await Migrator(this, schemaV3).alterTable(TableMigration(schemaV3.games));

    await m.create(effectiveCopies);
    await m.create(gameConsoles);
    await m.create(statGames);
    await m.create(collectionMustBeCollectionInsert);
    await m.create(collectionMustBeCollectionUpdate);
    await m.create(noNestedCollections);
    await m.create(collectionWithItemsCannotBeDemoted);
    await m.create(itemCannotBecomeCollection);
  }

  /// Inserisce console e generi iniziali.
  ///
  /// È idempotente: `insertOrIgnore` più l'indice UNIQUE su `name_norm` fanno sì
  /// che rieseguirlo non crei doppioni, anche se l'utente ha nel frattempo
  /// rinominato o cancellato qualche voce.
  Future<void> seedCatalogs() async {
    await batch((Batch batch) {
      batch.insertAll(
        consoles,
        <ConsolesCompanion>[
          for (final (int index, SeedConsole console) in seedConsoles.indexed)
            ConsolesCompanion.insert(
              name: console.name,
              nameNorm: normalize(console.name),
              shortLabel: console.shortLabel,
              family: Value<String>(console.family),
              sortOrder: Value<int>(index * 10),
            ),
        ],
        mode: InsertMode.insertOrIgnore,
      );
      batch.insertAll(
        genres,
        <GenresCompanion>[
          for (final String genre in seedGenres)
            GenresCompanion.insert(name: genre, nameNorm: normalize(genre)),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }
}
