// Il voto complessivo è calcolato dal database, non dall'app: così interfaccia,
// ordinamenti e statistiche non possono dare numeri diversi fra loro.
// `isNull` esiste sia in drift (per le query) sia nei matcher dei test: qui serve
// quello dei matcher.
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/data/database.dart';

import '../helpers/test_db.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());

  Future<double?> overallOf(int id) async {
    final Game row = await (db.select(db.games)..where((Games g) => g.id.equals(id))).getSingle();
    return row.overallRating;
  }

  test('con tutte e quattro le categorie è la media semplice', () async {
    final int id = await insertGame(
      db,
      title: 'Gioco completo',
      ratingStory: 9,
      ratingGameplay: 8,
      ratingGraphics: 7,
      ratingSoundtrack: 8,
    );
    expect(await overallOf(id), closeTo(8.0, 1e-9));
  });

  test('le categorie non valutate non contano come zero', () async {
    final int id = await insertGame(
      db,
      title: 'Tre categorie',
      ratingStory: 9,
      ratingGameplay: 8,
      ratingGraphics: 7,
    );
    expect(
      await overallOf(id),
      closeTo(8.0, 1e-9),
      reason: 'media di 3 valori, non (9+8+7+0)/4 = 6',
    );
  });

  test('la divisione è in virgola mobile, anche con i mezzi punti', () async {
    final int id = await insertGame(
      db,
      title: 'Mezzi punti',
      ratingStory: 7.5,
      ratingGameplay: 8,
    );
    expect(
      await overallOf(id),
      closeTo(7.75, 1e-9),
      reason: 'senza * 1.0 SQLite troncherebbe il risultato a 7',
    );
  });

  test('un voto zero è un voto, e abbassa la media', () async {
    final int id = await insertGame(db, title: 'Colonna sonora assente', ratingStory: 8, ratingSoundtrack: 0);
    expect(await overallOf(id), closeTo(4.0, 1e-9));
  });

  test('senza alcuna categoria valutata non c\'è voto, e non è zero', () async {
    final int id = await insertGame(db, title: 'Non valutato');
    expect(await overallOf(id), isNull);
  });

  test('si aggiorna da solo quando cambia una categoria', () async {
    final int id = await insertGame(db, title: 'Da rivalutare', ratingStory: 6);
    expect(await overallOf(id), closeTo(6.0, 1e-9));

    await (db.update(db.games)..where((Games g) => g.id.equals(id))).write(
      const GamesCompanion(ratingGameplay: Value<double?>(9)),
    );
    expect(await overallOf(id), closeTo(7.5, 1e-9));

    // Togliendo il voto alla storia resta solo il gameplay.
    await (db.update(db.games)..where((Games g) => g.id.equals(id))).write(
      const GamesCompanion(ratingStory: Value<double?>(null)),
    );
    expect(await overallOf(id), closeTo(9.0, 1e-9));
  });
}
