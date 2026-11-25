import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/domain/rating.dart';

void main() {
  group('voto complessivo', () {
    test('senza alcuna categoria valutata non c\'è voto', () {
      expect(overallRating(), isNull);
    });

    test('con una sola categoria il voto è quello', () {
      expect(overallRating(gameplay: 8), 8);
    });

    test('con tutte e quattro è la media semplice', () {
      expect(overallRating(story: 9, gameplay: 8, graphics: 7, soundtrack: 8), 8);
    });

    test('le categorie non valutate non contano come zero', () {
      expect(
        overallRating(story: 9, gameplay: 8, graphics: 7),
        closeTo(8, 1e-9),
        reason: 'media di 3 valori, non (9+8+7+0)/4',
      );
    });

    test('uno zero esplicito invece è un voto e abbassa la media', () {
      expect(overallRating(story: 8, soundtrack: 0), 4);
      expect(ratedCategories(story: 8, soundtrack: 0), 2);
    });

    test('i mezzi punti danno medie con i quarti', () {
      expect(overallRating(story: 7.5, gameplay: 8), closeTo(7.75, 1e-9));
    });
  });

  group('validità di un voto', () {
    test('accetta gli estremi e i mezzi punti', () {
      expect(isValidRating(0), isTrue);
      expect(isValidRating(10), isTrue);
      expect(isValidRating(7.5), isTrue);
    });

    test('rifiuta i decimi e i valori fuori scala', () {
      expect(isValidRating(7.3), isFalse);
      expect(isValidRating(-0.5), isFalse);
      expect(isValidRating(10.5), isFalse);
    });
  });
}
