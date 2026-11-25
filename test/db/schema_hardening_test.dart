// Regole aggiunte dopo la revisione dello schema: ognuna chiude un modo concreto
// in cui i dati potevano diventare incoerenti senza alcun errore.
import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/data/database.dart';
import 'package:sqlite3/sqlite3.dart';

import '../helpers/test_db.dart';

final Matcher throwsSqlite = throwsA(isA<SqliteException>());

void main() {
  late AppDatabase db;
  late int ps4;

  setUp(() async {
    db = createTestDatabase();
    ps4 = await consoleIdByLabel(db, 'PS4');
  });

  test('i campi booleani accettano solo 0 e 1', () {
    expect(
      () => db.customStatement(
        "INSERT INTO games (title, title_norm, sort_title, has_dlc) VALUES ('X', 'x', 'x', 2)",
      ),
      throwsSqlite,
      reason: 'drift non aggiunge il CHECK alle colonne BOOLEAN dei file .drift',
    );
  });

  test('la famiglia della console e la sigla hanno valori ammessi', () {
    expect(
      () => db.customStatement(
        "INSERT INTO consoles (name, name_norm, short_label, family) VALUES ('Y', 'y', 'Y', 'boh')",
      ),
      throwsSqlite,
    );
    expect(
      () => db.customStatement("INSERT INTO consoles (name, name_norm, short_label) VALUES ('Z', 'z', '   ')"),
      throwsSqlite,
    );
  });

  test('la console di una copia non si può eliminare finché è in uso', () async {
    final int gameId = await insertGame(db, title: 'Returnal');
    await insertCopy(db, gameId: gameId, consoleId: ps4);
    expect(() => db.customStatement('DELETE FROM consoles WHERE id = $ps4'), throwsSqlite);
  });

  group('trigger durante un ripristino con chiavi esterne rinviate', () {
    // Il ripristino di un backup scrive tutto dentro una transazione con
    // PRAGMA defer_foreign_keys = ON: la chiave esterna non protegge più fino al
    // COMMIT, quindi i trigger devono reggere da soli anche su righe mancanti.
    Future<void> inDeferredTransaction(Future<void> Function() body) {
      return db.transaction(() async {
        await db.customStatement('PRAGMA defer_foreign_keys = ON');
        await body();
      });
    }

    test('un\'appartenenza a una raccolta non ancora scritta viene rifiutata', () async {
      await inDeferredTransaction(() async {
        await expectLater(
          db.customStatement('INSERT INTO collection_items (collection_id, game_id) VALUES (1, 2)'),
          throwsSqlite,
        );
      });
    });
  });
}
