// Il voto complessivo esiste in due posti: la colonna generata di SQLite (usata da
// libreria, ordinamenti e statistiche) e la funzione Dart `overallRating` (usata
// per l'anteprima dal vivo mentre si muovono i cursori nella scheda).
//
// Se divergessero, l'utente vedrebbe un numero mentre modifica e un altro dopo aver
// salvato. Questo test le confronta su tutte e 16 le combinazioni di categorie
// valutate e non valutate.
import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/data/database.dart';
import 'package:gameshelf/domain/rating.dart';

import '../helpers/test_db.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());

  test('la media di Dart e quella di SQLite coincidono in tutti i 16 casi', () async {
    // Valori scelti diversi fra loro, compreso uno zero e un mezzo punto.
    const List<double> values = <double>[0, 7.5, 8, 9];

    for (int mask = 0; mask < 16; mask++) {
      final double? story = (mask & 1) != 0 ? values[0] : null;
      final double? gameplay = (mask & 2) != 0 ? values[1] : null;
      final double? graphics = (mask & 4) != 0 ? values[2] : null;
      final double? soundtrack = (mask & 8) != 0 ? values[3] : null;

      final int id = await insertGame(
        db,
        title: 'Combinazione $mask',
        ratingStory: story,
        ratingGameplay: gameplay,
        ratingGraphics: graphics,
        ratingSoundtrack: soundtrack,
      );

      final Game row = await (db.select(
        db.games,
      )..where((Games g) => g.id.equals(id))).getSingle();

      final double? expected = overallRating(
        story: story,
        gameplay: gameplay,
        graphics: graphics,
        soundtrack: soundtrack,
      );

      if (expected == null) {
        expect(
          row.overallRating,
          isNull,
          reason: 'combinazione $mask: nessuna categoria valutata',
        );
      } else {
        expect(
          row.overallRating,
          closeTo(expected, 1e-9),
          reason: 'combinazione $mask: Dart dice $expected, SQLite ${row.overallRating}',
        );
      }
    }
  });
}
