// Le regole delle raccolte che i CHECK non possono esprimere, perché guardano
// righe diverse da quella scritta. Dalla v3 un gioco può stare in più raccolte e
// avere comunque copie proprie: restano vietati l'annidamento e i legami verso
// righe che non esistono.
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/data/database.dart';
import 'package:sqlite3/sqlite3.dart';

import '../helpers/test_db.dart';

Matcher throwsAbortContaining(String fragment) => throwsA(
  isA<SqliteException>().having((SqliteException e) => e.message, 'messaggio', contains(fragment)),
);

void main() {
  late AppDatabase db;
  late int collectionId;
  late int ps4;

  setUp(() async {
    db = createTestDatabase();
    ps4 = await consoleIdByLabel(db, 'PS4');
    collectionId = await insertGame(db, title: 'Kingdom Hearts HD 1.5 ReMIX', isCollection: true);
    await insertCopy(db, gameId: collectionId, consoleId: ps4);
  });

  test('un gioco dentro una raccolta può avere anche copie proprie', () async {
    final int gameId = await insertGame(db, title: 'Kingdom Hearts Final Mix', inCollection: collectionId);
    await insertCopy(db, gameId: gameId, consoleId: await consoleIdByLabel(db, 'PS2'));

    final List<GameCopy> copies = await (db.select(
      db.gameCopies,
    )..where((GameCopies c) => c.gameId.equals(gameId))).get();
    expect(copies, hasLength(1), reason: 'la cartuccia PS2 è sua, il disco PS4 è della raccolta');
  });

  test('lo stesso gioco può stare in più raccolte', () async {
    final int other = await insertGame(db, title: 'Altra raccolta', isCollection: true);
    final int gameId = await insertGame(db, title: 'Gioco condiviso', inCollection: collectionId);
    await addToCollection(db, collectionId: other, gameId: gameId);

    expect(await db.collectionItems.count().getSingle(), 2);
  });

  test('si può mettere un gioco solo dentro una raccolta vera', () async {
    final int normalGame = await insertGame(db, title: 'Gioco normale');
    final int gameId = await insertGame(db, title: 'Preteso contenuto');

    expect(
      () => addToCollection(db, collectionId: normalGame, gameId: gameId),
      throwsAbortContaining('solo in una collection'),
    );
  });

  test('una raccolta che non esiste viene rifiutata, non ignorata', () async {
    final int gameId = await insertGame(db, title: 'Gioco');
    expect(
      () => db.customStatement('INSERT INTO collection_items VALUES (9999, $gameId)'),
      throwsAbortContaining('solo in una collection'),
    );
  });

  test('niente raccolte dentro raccolte, in nessuna delle due direzioni', () async {
    final int other = await insertGame(db, title: 'Altra raccolta', isCollection: true);
    expect(
      () => addToCollection(db, collectionId: collectionId, gameId: other),
      throwsAbortContaining('non può essere contenuta'),
    );

    final int gameId = await insertGame(db, title: 'Gioco contenuto', inCollection: collectionId);
    expect(
      () => (db.update(db.games)..where((Games g) => g.id.equals(gameId))).write(
        const GamesCompanion(isCollection: Value<bool>(true)),
      ),
      throwsAbortContaining('non può essere contenuta'),
    );
  });

  test('un gioco non può contenere sé stesso', () {
    expect(
      () => db.customStatement('INSERT INTO collection_items VALUES ($collectionId, $collectionId)'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('una raccolta piena non si declassa a gioco singolo', () async {
    await insertGame(db, title: 'Kingdom Hearts Final Mix', inCollection: collectionId);

    expect(
      () => (db.update(db.games)..where((Games g) => g.id.equals(collectionId))).write(
        const GamesCompanion(isCollection: Value<bool>(false)),
      ),
      throwsAbortContaining('contiene ancora dei giochi'),
    );
  });

  test('una raccolta vuota invece si declassa senza problemi', () async {
    final int emptyCollection = await insertGame(db, title: 'Raccolta vuota', isCollection: true);

    await (db.update(db.games)..where((Games g) => g.id.equals(emptyCollection))).write(
      const GamesCompanion(isCollection: Value<bool>(false)),
    );

    final Game row = await (db.select(
      db.games,
    )..where((Games g) => g.id.equals(emptyCollection))).getSingle();
    expect(row.isCollection, isFalse);
  });

  test('eliminando una raccolta i giochi contenuti restano in libreria', () async {
    final int gameId = await insertGame(db, title: 'Kingdom Hearts Final Mix', inCollection: collectionId);

    await (db.delete(db.games)..where((Games g) => g.id.equals(collectionId))).go();

    expect(await db.collectionItems.count().getSingle(), 0);
    final Game row = await (db.select(db.games)..where((Games g) => g.id.equals(gameId))).getSingle();
    expect(row.title, 'Kingdom Hearts Final Mix');
  });
}
