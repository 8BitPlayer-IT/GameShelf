import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/data/catalog_repository.dart';
import 'package:gameshelf/data/database.dart';
import 'package:gameshelf/data/game_repository.dart';
import 'package:gameshelf/data/library_repository.dart';
import 'package:gameshelf/domain/enums.dart';
import 'package:gameshelf/domain/game_draft.dart';
import 'package:gameshelf/domain/library_query.dart';

import '../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late GameRepository games;
  late LibraryRepository library;
  late int ps4;
  late int switchId;
  late int gb;

  setUp(() async {
    db = createTestDatabase();
    final CatalogRepository catalogs = CatalogRepository(db);
    games = GameRepository(db, catalogs, clock: () => DateTime(2026, 9, 12));
    library = LibraryRepository(db);
    ps4 = await consoleIdByLabel(db, 'PS4');
    switchId = await consoleIdByLabel(db, 'Switch');
    gb = await consoleIdByLabel(db, 'GB');
  });

  group('GameRepository', () {
    test('salva e rilegge una scheda completa, creando i cataloghi una volta sola', () async {
      final int azione = await genreIdByName(db, 'Azione');
      final GameDraft draft = GameDraft(
        title: 'Hollow Knight',
        seriesName: 'Hollow Knight',
        developerName: 'Team Cherry',
        publisherName: 'team  cherry',
        releaseYear: 2017,
        genreIds: <int>{azione},
        copies: <CopyDraft>[
          CopyDraft(consoleId: ps4, format: CopyFormat.fisico),
          CopyDraft(consoleId: switchId, format: CopyFormat.digitale),
        ],
        status: GameStatus.completato,
        hasAchievements: true,
        allAchievementsUnlocked: true,
        ratingStory: 8,
        ratingGameplay: 9.5,
      );

      final int id = await games.save(draft);
      final GameDraft loaded = await games.loadDraft(id);

      expect(loaded.title, 'Hollow Knight');
      expect(loaded.publisherName, 'Team Cherry', reason: 'stesso nome normalizzato, stessa azienda');
      expect(await db.companies.count().getSingle(), 1);
      expect(loaded.copies.toSet(), draft.copies.toSet());
      expect(loaded.genreIds, <int>{azione});
      expect(loaded.status, GameStatus.completato);
      expect(loaded.overall, 8.75);

      final GameDetails details = (await games.watchDetails(id).first)!;
      expect(details.copies.map((CopyView c) => c.shortLabel).toList(), <String>['Switch', 'PS4']);
      expect(details.developerName, 'Team Cherry');
      expect(details.genres, <String>['Azione']);
    });

    test('una modifica sostituisce copie e generi invece di sommarli', () async {
      final int id = await games.save(
        GameDraft(
          title: 'Celeste',
          genreIds: <int>{await genreIdByName(db, 'Piattaforme')},
          copies: <CopyDraft>[CopyDraft(consoleId: switchId, format: CopyFormat.digitale)],
        ),
      );
      final GameDraft draft = await games.loadDraft(id)
        ..copies = <CopyDraft>[CopyDraft(consoleId: ps4, format: CopyFormat.fisico)]
        ..genreIds = <int>{await genreIdByName(db, 'Azione')};
      await games.save(draft);

      final GameDraft reloaded = await games.loadDraft(id);
      expect(reloaded.copies, <CopyDraft>[CopyDraft(consoleId: ps4, format: CopyFormat.fisico)]);
      expect(reloaded.genreIds, <int>{await genreIdByName(db, 'Azione')});
    });

    test('una scheda non valida non viene salvata', () {
      expect(() => games.save(GameDraft(title: '   ')), throwsA(isA<GameValidationException>()));
    });

    test('eliminare e annullare riporta il gioco identico', () async {
      final int id = await games.save(
        GameDraft(
          title: 'Bloodborne',
          developerName: 'FromSoftware',
          genreIds: <int>{await genreIdByName(db, 'Souls-like')},
          copies: <CopyDraft>[CopyDraft(consoleId: ps4, format: CopyFormat.fisico)],
          ratingGameplay: 10,
        ),
      );

      final DeletedGameSnapshot snapshot = await games.delete(id);
      expect(await db.games.count().getSingle(), 0);
      expect(await db.gameCopies.count().getSingle(), 0);

      await games.undoDelete(snapshot);
      final GameDraft restored = await games.loadDraft(id);
      expect(restored.title, 'Bloodborne');
      expect(restored.developerName, 'FromSoftware');
      expect(restored.copies, <CopyDraft>[CopyDraft(consoleId: ps4, format: CopyFormat.fisico)]);
      expect(restored.genreIds, hasLength(1));
      expect(restored.overall, 10);
    });

    test('eliminare una collection lascia i contenuti, e l\'annullamento rimette il legame', () async {
      final int collection = await games.save(
        GameDraft(
          title: 'Kingdom Hearts HD 1.5',
          isCollection: true,
          copies: <CopyDraft>[CopyDraft(consoleId: ps4, format: CopyFormat.fisico)],
        ),
      );
      final int child = await games.save(GameDraft(title: 'Final Mix', collectionIds: <int>[collection]));

      final DeletedGameSnapshot snapshot = await games.delete(collection);
      expect(await db.games.count().getSingle(), 1, reason: 'Final Mix resta in libreria');
      expect(await db.collectionItems.count().getSingle(), 0);

      await games.undoDelete(snapshot);
      expect((await games.loadDraft(child)).collectionIds, <int>[collection]);
      final GameDetails childDetails = (await games.watchDetails(child).first)!;
      expect(childDetails.memberships.single.title, 'Kingdom Hearts HD 1.5');
      expect(childDetails.memberships.single.copies.single.shortLabel, 'PS4');
    });
  });

  group('LibraryRepository', () {
    setUp(() async {
      final int collection = await games.save(
        GameDraft(
          title: 'Kingdom Hearts HD 1.5',
          isCollection: true,
          copies: <CopyDraft>[CopyDraft(consoleId: ps4, format: CopyFormat.fisico)],
        ),
      );
      await games.save(
        GameDraft(
          title: 'Kingdom Hearts Final Mix',
          collectionIds: <int>[collection],
          status: GameStatus.inCorso,
          ratingGameplay: 9,
          platformIds: <int>[await consoleIdByLabel(db, 'PS2')],
        ),
      );
      await games.save(GameDraft(title: 'Re:Chain of Memories', collectionIds: <int>[collection]));
      await games.save(
        GameDraft(
          title: 'Hollow Knight',
          status: GameStatus.completato,
          genreIds: <int>{await genreIdByName(db, 'Metroidvania')},
          copies: <CopyDraft>[
            CopyDraft(consoleId: ps4, format: CopyFormat.fisico),
            CopyDraft(consoleId: switchId, format: CopyFormat.digitale),
          ],
          ratingStory: 9.5,
        ),
      );
      await games.save(
        GameDraft(
          title: 'Pokémon Rosso',
          status: GameStatus.finito,
          genreIds: <int>{await genreIdByName(db, 'GDR')},
          copies: <CopyDraft>[CopyDraft(consoleId: gb, format: CopyFormat.fisico)],
          ratingStory: 8,
        ),
      );
      await games.save(
        GameDraft(
          title: 'Celeste',
          status: GameStatus.abbandonato,
          genreIds: <int>{await genreIdByName(db, 'Piattaforme')},
          copies: <CopyDraft>[CopyDraft(consoleId: switchId, format: CopyFormat.digitale)],
        ),
      );
    });

    Future<List<String>> titles(LibraryQuery query) async =>
        (await library.watchLibrary(query).first).map((LibraryItem i) => i.title).toList();

    test('interruttore spento: le collection senza contenuti; acceso: tutto', () async {
      expect(await titles(const LibraryQuery()), <String>[
        'Celeste',
        'Hollow Knight',
        'Kingdom Hearts HD 1.5',
        'Pokémon Rosso',
      ]);
      expect(await titles(const LibraryQuery(showChildren: true)), <String>[
        'Celeste',
        'Hollow Knight',
        'Kingdom Hearts Final Mix',
        'Kingdom Hearts HD 1.5',
        'Pokémon Rosso',
        'Re:Chain of Memories',
      ]);
    });

    test('a interruttore spento una collection compare se corrisponde un suo contenuto', () async {
      expect(
        await titles(const LibraryQuery(statuses: <GameStatus>{GameStatus.inCorso})),
        <String>['Kingdom Hearts HD 1.5'],
      );
      expect(await titles(const LibraryQuery(search: 'final mix')), <String>['Kingdom Hearts HD 1.5']);
    });

    test('console e formato si applicano alla stessa copia', () async {
      expect(
        await titles(LibraryQuery(consoleIds: <int>{ps4}, formats: const <CopyFormat>{CopyFormat.digitale})),
        isEmpty,
        reason: 'Hollow Knight è su PS4 e in digitale, ma non in digitale su PS4',
      );
      expect(
        await titles(LibraryQuery(consoleIds: <int>{ps4}, formats: const <CopyFormat>{CopyFormat.fisico})),
        <String>['Hollow Knight', 'Kingdom Hearts HD 1.5'],
      );
    });

    test('valori della stessa sezione in OR, sezioni diverse in AND', () async {
      final Set<int> genres = <int>{
        await genreIdByName(db, 'Metroidvania'),
        await genreIdByName(db, 'Piattaforme'),
      };
      expect(await titles(LibraryQuery(genreIds: genres)), <String>['Celeste', 'Hollow Knight']);
      expect(
        await titles(LibraryQuery(genreIds: genres, statuses: const <GameStatus>{GameStatus.completato})),
        <String>['Hollow Knight'],
      );
    });

    test('ordinando per voto i non valutati restano in fondo in entrambe le direzioni', () async {
      expect(
        await titles(const LibraryQuery(sort: SortCriterion.voto, ascending: false)),
        // La collection vale 9: la media dei suoi contenuti valutati.
        <String>['Hollow Knight', 'Kingdom Hearts HD 1.5', 'Pokémon Rosso', 'Celeste'],
      );
      expect(
        await titles(const LibraryQuery(sort: SortCriterion.voto)),
        <String>['Pokémon Rosso', 'Kingdom Hearts HD 1.5', 'Hollow Knight', 'Celeste'],
      );
    });

    test('la ricerca ignora accenti e maiuscole', () async {
      expect(await titles(const LibraryQuery(search: 'POKEMON')), <String>['Pokémon Rosso']);
    });

    test('le voci riportano console ereditate, formati e collection di appartenenza', () async {
      final List<LibraryItem> items = await library
          .watchLibrary(const LibraryQuery(showChildren: true))
          .first;
      final LibraryItem child = items.firstWhere((LibraryItem i) => i.title == 'Kingdom Hearts Final Mix');
      // La console mostrata per un gioco contenuto è quella di uscita, non quella
      // della collection; e non ha formato, perché non è una copia posseduta.
      // Console di uscita più quella della raccolta di cui fa parte.
      expect(child.consoleLabels, <String>['PS2', 'PS4']);
      expect(child.formats, <CopyFormat>{CopyFormat.fisico});
      expect(child.collectionTitles, <String>['Kingdom Hearts HD 1.5']);
      expect(child.overallRating, 9);

      final LibraryItem hollow = items.firstWhere((LibraryItem i) => i.title == 'Hollow Knight');
      expect(hollow.consoleLabels, <String>['PS4', 'Switch'], reason: 'console in ordine alfabetico');
      expect(hollow.formats, <CopyFormat>{CopyFormat.fisico, CopyFormat.digitale});

      final LibraryItem box = items.firstWhere((LibraryItem i) => i.title == 'Kingdom Hearts HD 1.5');
      expect(box.itemCount, 2);
      expect(box.overallRating, 9);
    });

    test('il foglio filtri propone solo i valori usati', () async {
      final FilterOptions options = await library.watchFilterOptions().first;
      // In ordine alfabetico per nome esteso, non nell'ordine del catalogo.
      expect(options.consoles.map((CatalogEntry c) => c.name), <String>[
        'Game Boy',
        'Nintendo Switch',
        'PlayStation 2',
        'PlayStation 4',
      ]);
      expect(options.genres, hasLength(3));
    });
  });
}
