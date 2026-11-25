// Le chiavi esterne devono comportarsi in tre modi diversi a seconda del legame:
// a cascata per ciò che appartiene al gioco, azzerando per i cataloghi facoltativi,
// bloccando per ciò che l'utente deve decidere consapevolmente.
//
// Tutto questo funziona solo con `PRAGMA foreign_keys = ON`, che SQLite tiene
// spento di default e che l'app attiva in `beforeOpen`.
// `isNull` esiste sia in drift (per le query) sia nei matcher dei test: qui serve
// quello dei matcher.
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/data/database.dart';
import 'package:gameshelf/domain/normalizer.dart';
import 'package:sqlite3/sqlite3.dart';

import '../helpers/test_db.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());

  test('le chiavi esterne sono attive', () async {
    final QueryRow row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.data.values.first, 1);
  });

  test('eliminando un gioco spariscono le sue copie e i suoi generi', () async {
    final int gameId = await insertGame(db, title: 'Hades');
    await insertCopy(db, gameId: gameId, consoleId: await consoleIdByLabel(db, 'Switch'));
    await db
        .into(db.gameGenres)
        .insert(
          GameGenresCompanion.insert(
            gameId: gameId,
            genreId: await genreIdByName(db, 'Roguelike'),
          ),
        );

    await (db.delete(db.games)..where((Games g) => g.id.equals(gameId))).go();

    expect(await db.gameCopies.count().getSingle(), 0);
    expect(await db.gameGenres.count().getSingle(), 0);
  });

  test('eliminando una serie o un\'azienda il gioco resta, senza quel riferimento', () async {
    final int seriesId = await db
        .into(db.series)
        .insert(SeriesCompanion.insert(name: 'Metroid', nameNorm: normalize('Metroid')));
    final int companyId = await db
        .into(db.companies)
        .insert(CompaniesCompanion.insert(name: 'Nintendo', nameNorm: normalize('Nintendo')));
    final int gameId = await insertGame(
      db,
      title: 'Metroid Dread',
      seriesId: seriesId,
      developerId: companyId,
      publisherId: companyId,
    );

    await (db.delete(db.series)..where((Series s) => s.id.equals(seriesId))).go();
    await (db.delete(db.companies)..where((Companies c) => c.id.equals(companyId))).go();

    final Game row = await (db.select(
      db.games,
    )..where((Games g) => g.id.equals(gameId))).getSingle();
    expect(row.title, 'Metroid Dread');
    expect(row.seriesId, isNull);
    expect(row.developerId, isNull);
    expect(row.publisherId, isNull);
  });

  test('una console usata da qualche copia non si elimina', () async {
    final int ps5 = await consoleIdByLabel(db, 'PS5');
    final int gameId = await insertGame(db, title: 'Returnal');
    await insertCopy(db, gameId: gameId, consoleId: ps5);

    expect(
      () => (db.delete(db.consoles)..where((Consoles c) => c.id.equals(ps5))).go(),
      throwsA(isA<SqliteException>()),
    );
  });

  test('un genere in uso non si elimina', () async {
    final int genreId = await genreIdByName(db, 'Azione');
    final int gameId = await insertGame(db, title: 'Devil May Cry 5');
    await db
        .into(db.gameGenres)
        .insert(GameGenresCompanion.insert(gameId: gameId, genreId: genreId));

    expect(
      () => (db.delete(db.genres)..where((Genres g) => g.id.equals(genreId))).go(),
      throwsA(isA<SqliteException>()),
    );
  });

  test('eliminando una raccolta spariscono le appartenenze, non i giochi', () async {
    final int collectionId = await insertGame(db, title: 'Mega Man Collection', isCollection: true);
    await insertGame(db, title: 'Mega Man 2', inCollection: collectionId);

    await (db.delete(db.games)..where((Games g) => g.id.equals(collectionId))).go();

    expect(await db.collectionItems.count().getSingle(), 0);
    expect(await db.games.count().getSingle(), 1, reason: 'Mega Man 2 resta in libreria');
  });

  test('eliminando un gioco sparisce la sua appartenenza alla raccolta', () async {
    final int collectionId = await insertGame(db, title: 'Mega Man Collection', isCollection: true);
    final int gameId = await insertGame(db, title: 'Mega Man 2', inCollection: collectionId);

    await (db.delete(db.games)..where((Games g) => g.id.equals(gameId))).go();

    expect(await db.collectionItems.count().getSingle(), 0);
    expect(await db.games.count().getSingle(), 1, reason: 'la raccolta resta');
  });
}
