import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/domain/normalizer.dart';

void main() {
  group('normalize — ricerca e unicità dei cataloghi', () {
    test('toglie accenti e maiuscole', () {
      expect(normalize('Pokémon Rosso'), 'pokemon rosso');
      expect(normalize('ŌKAMI'), 'okami');
      expect(normalize('NieR: Automata'), 'nier automata');
    });

    test('la punteggiatura diventa spazio e gli spazi si compattano', () {
      expect(normalize('Ratchet & Clank'), 'ratchet clank');
      expect(normalize("L'Ombra   del   Colosso"), 'l ombra del colosso');
      expect(normalize('  Celeste  '), 'celeste');
    });

    test('i numeri restano', () {
      expect(normalize('FIFA 23'), 'fifa 23');
    });

    test('è idempotente: normalizzare due volte non cambia nulla', () {
      const String title = 'Métal Gear Solid 2: Sons of Liberty';
      expect(normalize(normalize(title)), normalize(title));
    });

    test('«Nintendo» e «nintendo» sono lo stesso catalogo', () {
      expect(normalize('Nintendo'), normalize('NINTENDO'));
      expect(normalize('Nintendo'), normalize('  nintendo '));
    });

    test('un titolo fatto di soli simboli non diventa stringa vuota', () {
      // Altrimenti tutti i nomi di soli simboli collasserebbero sullo stesso
      // valore e il vincolo UNIQUE dei cataloghi ne rifiuterebbe il secondo.
      expect(normalize('!!!'), '!!!');
    });
  });

  group('sortKey — ordinamento alfabetico', () {
    test('i numeri sono riempiti di zeri, così 9 viene prima di 23', () {
      final List<String> titles = <String>['FIFA 23', 'FIFA 9', 'FIFA 100'];
      titles.sort((String a, String b) => sortKey(a).compareTo(sortKey(b)));
      expect(titles, <String>['FIFA 9', 'FIFA 23', 'FIFA 100']);
    });

    test('l\'articolo iniziale viene ignorato quando richiesto', () {
      expect(sortKey('The Last of Us'), 'last of us');
      expect(sortKey('Il Signore degli Anelli'), 'signore degli anelli');
      expect(sortKey('The Last of Us', ignoreArticles: false), 'the last of us');
    });

    test('un articolo che è parte del titolo resta al suo posto', () {
      expect(
        sortKey('Ilomilo'),
        'ilomilo',
        reason: 'si toglie solo una parola intera, non un prefisso',
      );
    });

    test('ordina come ci si aspetta una manciata di titoli reali', () {
      final List<String> titles = <String>[
        'The Legend of Zelda',
        'Animal Crossing',
        'Élite Beat Agents',
        'Super Mario Bros. 3',
        'Super Mario Bros.',
        'Zelda II',
      ];
      titles.sort((String a, String b) => sortKey(a).compareTo(sortKey(b)));
      expect(titles, <String>[
        'Animal Crossing',
        'Élite Beat Agents',
        'The Legend of Zelda',
        'Super Mario Bros.',
        'Super Mario Bros. 3',
        'Zelda II',
      ]);
    });
  });
}
