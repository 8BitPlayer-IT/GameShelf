// Le viste che reggono filtri e statistiche:
// - effective_copies somma le copie proprie a quelle delle raccolte di appartenenza;
// - game_consoles aggiunge le console di uscita, che non sono copie;
// - stat_games decide che cosa conta come «gioco» nelle statistiche.
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/data/database.dart';

import '../helpers/test_db.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());

  Future<List<(int, int, String?)>> consolesOf(int gameId) async {
    final List<QueryRow> rows = await db
        .customSelect('SELECT console_id, format FROM game_consoles WHERE game_id = $gameId')
        .get();
    return <(int, int, String?)>[
      for (final QueryRow r in rows) (gameId, r.read<int>('console_id'), r.readNullable<String>('format')),
    ];
  }

  test('un gioco dentro una raccolta eredita le copie della raccolta', () async {
    final int ps4 = await consoleIdByLabel(db, 'PS4');
    final int collectionId = await insertGame(db, title: 'Raccolta', isCollection: true);
    await insertCopy(db, gameId: collectionId, consoleId: ps4, format: 'fisico');
    final int gameId = await insertGame(db, title: 'Primo gioco', inCollection: collectionId);

    final List<EffectiveCopy> copies = await (db.select(
      db.effectiveCopies,
    )..where((EffectiveCopies c) => c.gameId.equals(gameId))).get();

    expect(copies, hasLength(1));
    expect(copies.single.consoleId, ps4);
    expect(copies.single.format, 'fisico');
  });

  test('somma copie proprie e copie delle raccolte, senza ripetere la stessa', () async {
    final int ps4 = await consoleIdByLabel(db, 'PS4');
    final int n64 = await consoleIdByLabel(db, 'N64');
    final int collectionId = await insertGame(db, title: 'Raccolta', isCollection: true);
    await insertCopy(db, gameId: collectionId, consoleId: ps4, format: 'fisico');

    final int gameId = await insertGame(db, title: 'Super Mario 64', inCollection: collectionId);
    await insertCopy(db, gameId: gameId, consoleId: n64, format: 'fisico');
    // La stessa console e formato della raccolta: non deve comparire due volte.
    await insertCopy(db, gameId: gameId, consoleId: ps4, format: 'fisico');

    final List<EffectiveCopy> copies = await (db.select(
      db.effectiveCopies,
    )..where((EffectiveCopies c) => c.gameId.equals(gameId))).get();
    expect(copies, hasLength(2));
    expect(copies.map((EffectiveCopy c) => c.consoleId).toSet(), <int>{ps4, n64});
  });

  test('la console di uscita compare fra le console ma non ha formato', () async {
    final int n64 = await consoleIdByLabel(db, 'N64');
    final int collectionId = await insertGame(db, title: 'Raccolta', isCollection: true);
    await insertCopy(db, gameId: collectionId, consoleId: await consoleIdByLabel(db, 'Switch'));
    final int gameId = await insertGame(db, title: 'Super Mario 64', inCollection: collectionId);
    await db.into(db.gamePlatforms).insert(GamePlatformsCompanion.insert(gameId: gameId, consoleId: n64));

    final List<(int, int, String?)> consoles = await consolesOf(gameId);
    expect(consoles, hasLength(2));
    expect(consoles.firstWhere(((int, int, String?) c) => c.$2 == n64).$3, isNull);
  });

  test('le statistiche contano i giochi contenuti, non il cofanetto', () async {
    final int collectionId = await insertGame(db, title: 'Raccolta', isCollection: true);
    for (final String title in <String>['Primo', 'Secondo', 'Terzo']) {
      await insertGame(db, title: title, inCollection: collectionId);
    }
    final int standalone = await insertGame(db, title: 'Gioco singolo');

    final List<int> counted = (await db.select(db.statGames).get()).map((StatGame row) => row.gameId).toList();

    expect(counted, hasLength(4), reason: '3 contenuti + 1 singolo, il contenitore no');
    expect(counted, contains(standalone));
    expect(counted, isNot(contains(collectionId)));
  });

  test('un gioco in due raccolte conta una volta sola', () async {
    final int first = await insertGame(db, title: 'Prima raccolta', isCollection: true);
    final int second = await insertGame(db, title: 'Seconda raccolta', isCollection: true);
    final int gameId = await insertGame(db, title: 'Gioco condiviso', inCollection: first);
    await addToCollection(db, collectionId: second, gameId: gameId);

    final List<int> counted = (await db.select(db.statGames).get()).map((StatGame row) => row.gameId).toList();
    expect(counted, <int>[gameId]);
  });

  test('una raccolta ancora vuota conta come un gioco', () async {
    final int emptyCollection = await insertGame(db, title: 'Raccolta vuota', isCollection: true);

    final List<int> counted = (await db.select(db.statGames).get()).map((StatGame row) => row.gameId).toList();
    expect(counted, <int>[emptyCollection]);
  });
}
