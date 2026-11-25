import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/app/providers.dart';
import 'package:gameshelf/app/theme.dart';
import 'package:gameshelf/domain/enums.dart';
import 'package:gameshelf/ui/console_icons.dart';

void main() {
  group('fasce di colore dei voti', () {
    test('ai confini indicati', () {
      expect(ratingTier(null), RatingTier.nessuno);
      expect(ratingTier(0), RatingTier.insufficiente);
      expect(ratingTier(4.9), RatingTier.insufficiente);
      expect(ratingTier(5.0), RatingTier.sufficiente);
      expect(ratingTier(6.9), RatingTier.sufficiente);
      expect(ratingTier(7.0), RatingTier.buono);
      expect(ratingTier(7.9), RatingTier.buono);
      expect(ratingTier(8.0), RatingTier.argento);
      expect(ratingTier(8.9), RatingTier.argento);
      expect(ratingTier(9.0), RatingTier.oro);
      expect(ratingTier(9.9), RatingTier.oro);
      expect(ratingTier(10), RatingTier.platino);
    });

    test('decisa sul valore mostrato, arrotondato a una decimale', () {
      expect(formatRating(4.96), '5,0');
      expect(ratingTier(4.96), RatingTier.sufficiente);
      expect(formatRating(4.94), '4,9');
      expect(ratingTier(4.94), RatingTier.insufficiente);
      expect(formatRating(9.97), '10,0');
      expect(ratingTier(9.97), RatingTier.platino);
    });
  });

  test('vista della libreria salvata', () {
    expect(parseLibraryView(null), defaultLibraryView);
    expect(parseLibraryView('griglia:4'), (mode: LibraryViewMode.griglia, columns: 4));
    expect(parseLibraryView('lista:3'), (mode: LibraryViewMode.lista, columns: 3));
    expect(parseLibraryView('griglia:7').columns, 2, reason: 'valori non previsti tornano a 2');
  });

  test('icone delle console dalla sigla', () {
    expect(consoleIconAsset('PS Vita'), 'assets/consoles/psvita.png');
    expect(consoleIconAsset('Xbox X|S'), 'assets/consoles/xboxxs.png');
    expect(consoleIconAsset('Switch 2'), 'assets/consoles/switch2.png');
    expect(consoleIconAsset('iOS'), 'assets/consoles/mobile.png');
    expect(consoleIconAsset('Console inventata'), isNull);
  });
}
