// Console di uscita, voto delle raccolte, numero di giocatori (schema v2) e
// appartenenze multiple con copie proprie (schema v3).
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
  late int n64;
  late int switchId;
  late int collection;
  late int sm64;

  setUp(() async {
    db = createTestDatabase();
    games = GameRepository(db, CatalogRepository(db), clock: () => DateTime(2026, 9, 13));
    library = LibraryRepository(db);
    n64 = await consoleIdByLabel(db, 'N64');
    switchId = await consoleIdByLabel(db, 'Switch');

    collection = await games.save(
      GameDraft(
        title: 'Super Mario 3D All-Stars',
        isCollection: true,
        releaseYear: 2020,
        copies: <CopyDraft>[CopyDraft(consoleId: switchId, format: CopyFormat.fisico)],
        ratingStory: 3, // una raccolta non tiene un voto proprio: va ignorato
      ),
    );
    await games.save(
      GameDraft(
        title: 'Super Mario Galaxy',
        collectionIds: <int>[collection],
        releaseYear: 2007,
        platformIds: <int>[await consoleIdByLabel(db, 'Wii')],
        ratingGameplay: 10,
      ),
    );
    sm64 = await games.save(
      GameDraft(
        title: 'Super Mario 64',
        collectionIds: <int>[collection],
        releaseYear: 1996,
        platformIds: <int>[n64],
        players: 1,
        ratingGameplay: 9,
      ),
    );
  });

  Future<List<String>> titles(LibraryQuery query) async =>
      (await library.watchLibrary(query).first).map((LibraryItem i) => i.title).toList();

  test('una raccolta non salva un voto proprio: vale la media dei contenuti', () async {
    final GameDetails details = (await games.watchDetails(collection).first)!;
    expect(details.game.overallRating, isNull);
    expect(details.displayRating, 9.5);
    expect((await library.watchLibrary(const LibraryQuery()).first).single.overallRating, 9.5);
  });

  test('un gioco contenuto mostra la console di uscita e quella della raccolta', () async {
    final GameDetails details = (await games.watchDetails(sm64).first)!;
    expect(details.platforms.single.shortLabel, 'N64');
    expect(details.copies, isEmpty, reason: 'non possiede copie proprie');
    expect(details.memberships.single.title, 'Super Mario 3D All-Stars');
    expect(details.memberships.single.copies.single.shortLabel, 'Switch');

    final GameDetails box = (await games.watchDetails(collection).first)!;
    expect(box.items.first.title, 'Super Mario 64', reason: 'contenuti in ordine di uscita');
    expect(box.items.first.consoleLabels, 'N64');
    expect(box.items.first.releaseYear, 1996);
  });

  test('il filtro per console trova i giochi contenuti dalla loro console di uscita', () async {
    expect(await titles(LibraryQuery(consoleIds: <int>{n64})), <String>['Super Mario 3D All-Stars']);
    expect(await titles(LibraryQuery(consoleIds: <int>{n64}, showChildren: true)), <String>['Super Mario 64']);
    expect(
      await titles(
        LibraryQuery(consoleIds: <int>{n64}, formats: const <CopyFormat>{CopyFormat.fisico}, showChildren: true),
      ),
      isEmpty,
      reason: 'la console di uscita non è una copia e non ha formato',
    );
  });

  test('numero di giocatori: salvato, riletto, filtrabile e solo 1, 2 o 4', () async {
    expect((await games.loadDraft(sm64)).players, 1);
    expect(await titles(const LibraryQuery(players: <int>{1}, showChildren: true)), <String>['Super Mario 64']);
    expect(() => games.save(GameDraft(title: 'Tre giocatori', players: 3)), throwsA(isA<GameValidationException>()));
  });

  group('appartenenze multiple (v3)', () {
    test('un gioco dentro una raccolta può avere copie proprie e compare in libreria', () async {
      final GameDraft draft = await games.loadDraft(sm64)
        ..copies = <CopyDraft>[CopyDraft(consoleId: n64, format: CopyFormat.fisico)];
      await games.save(draft);

      // Interruttore spento: la cartuccia N64 è roba sua, quindi si vede comunque.
      expect(await titles(const LibraryQuery()), <String>['Super Mario 3D All-Stars', 'Super Mario 64']);
      final GameDetails details = (await games.watchDetails(sm64).first)!;
      expect(details.copies.single.shortLabel, 'N64');
      expect(details.memberships.single.copies.single.shortLabel, 'Switch');
    });

    test('lo stesso gioco può stare in due raccolte e conta una volta sola', () async {
      final int other = await games.save(
        GameDraft(title: 'Altra raccolta', isCollection: true, copies: <CopyDraft>[
          CopyDraft(consoleId: switchId, format: CopyFormat.digitale),
        ]),
      );
      final GameDraft draft = await games.loadDraft(sm64)..collectionIds = <int>[collection, other];
      await games.save(draft);

      final GameDetails details = (await games.watchDetails(sm64).first)!;
      expect(details.memberships.map((MembershipView m) => m.title), <String>['Altra raccolta', 'Super Mario 3D All-Stars']);
      expect(await db.statGames.count().getSingle(), 2, reason: 'i due contenuti, non le raccolte');
    });

    test('unire due voci somma copie e appartenenze, e tiene i voti di quella rimasta', () async {
      // Il doppione: Super Mario 64 inserito anche come gioco singolo su N64.
      final int duplicate = await games.save(
        GameDraft(
          title: 'Super Mario 64',
          copies: <CopyDraft>[CopyDraft(consoleId: n64, format: CopyFormat.fisico)],
          developerName: 'Nintendo',
          ratingStory: 6,
        ),
      );

      final String? unusedCover = await games.merge(keepId: sm64, otherId: duplicate);

      expect(unusedCover, isNull);
      expect(await (db.select(db.games)..where((Games g) => g.id.equals(duplicate))).getSingleOrNull(), isNull);
      final GameDetails details = (await games.watchDetails(sm64).first)!;
      expect(details.copies.single.shortLabel, 'N64', reason: 'la copia arriva dal doppione');
      expect(details.memberships.single.title, 'Super Mario 3D All-Stars');
      expect(details.developerName, 'Nintendo', reason: 'campo vuoto riempito dall\'altra voce');
      expect(details.game.ratingGameplay, 9, reason: 'i voti di chi resta non si toccano');
      expect(details.game.ratingStory, isNull);
    });

    test('unire un gioco con sé stesso o con una raccolta è rifiutato', () async {
      expect(() => games.merge(keepId: sm64, otherId: sm64), throwsA(isA<GameValidationException>()));
      expect(() => games.merge(keepId: sm64, otherId: collection), throwsA(isA<GameValidationException>()));
    });
  });

  test('eliminare e annullare riporta console di uscita e appartenenze', () async {
    final DeletedGameSnapshot snapshot = await games.delete(sm64);
    expect(await db.gamePlatforms.count().getSingle(), 1, reason: 'resta quella di Galaxy');
    expect(await db.collectionItems.count().getSingle(), 1);

    await games.undoDelete(snapshot);
    expect(await db.gamePlatforms.count().getSingle(), 2);
    expect(await db.collectionItems.count().getSingle(), 2);
  });
}
