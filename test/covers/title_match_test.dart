import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/data/covers/cover_routes.dart';
import 'package:gameshelf/data/covers/libretro_index.dart';
import 'package:gameshelf/data/covers/title_match.dart';

/// Gli indici veri, letti dal disco invece che dagli assets: i test girano sul
/// PC e non hanno un bundle di Flutter.
Future<Uint8List> _fromDisk(String assetPath) async => File(assetPath).readAsBytes();

Future<LibretroIndex> _index(String system) => LibretroIndex.load(system, _fromDisk);

void main() {
  group('chiave di confronto', () {
    test('toglie le parentesi della preservazione', () {
      expect(coverKey('Super Mario World (Europe) (Rev 1)'), 'super mario world');
      expect(coverKey('Metal Gear Solid (Europe) (Disc 1)'), 'metal gear solid');
    });

    test('l articolo in coda e quello in testa danno la stessa chiave', () {
      expect(
        coverKey('Legend of Zelda, The - A Link to the Past (Canada)'),
        coverKey('The Legend of Zelda: A Link to the Past'),
      );
    });

    test('i due punti e il trattino della preservazione sono equivalenti', () {
      expect(
        coverKey('Castlevania - Symphony of the Night (USA)'),
        coverKey('Castlevania: Symphony of the Night'),
      );
    });

    test('gli accenti non contano', () {
      expect(coverKey('Pokémon Versione Rosso Fuoco'), coverKey('Pokemon - Versione Rosso Fuoco (Italy)'));
    });

    test('I, V e X da soli non diventano numeri', () {
      // «Mega Man X» non è «Mega Man 10», e sono due giochi che esistono
      // entrambi: la conversione automatica sarebbe un falso positivo.
      expect(coverKeyVariants('Mega Man X').first, 'mega man x');
      expect(coverKeyVariants('Mega Man X'), isNot(contains('mega man 10')));
    });

    test('le varianti coprono romano e arabo', () {
      expect(coverKeyVariants('Final Fantasy VII'), contains('final fantasy 7'));
      expect(coverKeyVariants('Final Fantasy 7'), contains('final fantasy vii'));
    });
  });

  group('sbarramento dei numeri', () {
    test('due anni diversi non sono lo stesso gioco', () {
      expect(similarity('fifa 21', 'fifa 22'), greaterThan(0.8));
      expect(numericSignature('fifa 21'), isNot(numericSignature('fifa 22')));
      expect(bestCoverMatch(<String>['FIFA 22 (Europe)'], 'FIFA 21'), isNull);
    });

    test('un seguito non e il capitolo precedente', () {
      expect(bestCoverMatch(<String>['Sonic The Hedgehog 2 (Europe)'], 'Sonic The Hedgehog 3'), isNull);
    });
  });

  group('corrispondenze sull indice vero', () {
    test('Super Nintendo', () async {
      final LibretroIndex snes = await _index('Nintendo_-_Super_Nintendo_Entertainment_System');
      expect(snes.names.length, greaterThan(3000));
      expect(snes.match('Super Mario World'), 'Super Mario World (Europe)');
      expect(snes.match('The Legend of Zelda: A Link to the Past'), 'Legend of Zelda, The - A Link to the Past (Europe)');
      expect(snes.match('Donkey Kong Country'), startsWith('Donkey Kong Country (Europe)'));
    });

    test('PlayStation, anche col numero scritto in arabo', () async {
      final LibretroIndex ps1 = await _index('Sony_-_PlayStation');
      expect(ps1.match('Final Fantasy VII'), 'Final Fantasy VII (Europe)');
      expect(ps1.match('Final Fantasy 7'), 'Final Fantasy VII (Europe)');
      expect(ps1.match('Metal Gear Solid'), 'Metal Gear Solid (Europe)');
    });

    test('titolo italiano su Game Boy Advance', () async {
      final LibretroIndex gba = await _index('Nintendo_-_Game_Boy_Advance');
      expect(gba.match('Pokémon Versione Rosso Fuoco'), 'Pokemon - Versione Rosso Fuoco (Italy)');
    });

    test('un titolo che non esiste non da nessuna copertina', () async {
      final LibretroIndex snes = await _index('Nintendo_-_Super_Nintendo_Entertainment_System');
      expect(snes.match('Zorblax Hyperdrive 9'), isNull);
      expect(snes.match(''), isNull);
    });

    test('un gioco di un altro sistema non viene trovato qui', () async {
      // Halo non è mai esistito su Super Nintendo: l'appartenenza al sistema è
      // il primo sbarramento contro le copertine sbagliate.
      final LibretroIndex snes = await _index('Nintendo_-_Super_Nintendo_Entertainment_System');
      expect(snes.match('Halo Infinite'), isNull);
    });
  });

  group('titoli restituiti dai negozi', () {
    test('la colonna sonora non e il gioco', () {
      expect(titlesMatch('The Witcher 3: Wild Hunt', 'The Witcher 3: Wild Hunt — Remastered Soundtrack'), isFalse);
      expect(titlesMatch('Hollow Knight', 'Hollow Knight: Silksong'), isFalse);
    });

    test('lo stesso gioco scritto in modo diverso passa', () {
      expect(titlesMatch('The Witcher 3 Wild Hunt', 'The Witcher 3: Wild Hunt'), isTrue);
      expect(titlesMatch('Cyberpunk 2077', 'Cyberpunk 2077'), isTrue);
    });
  });

  group('instradamento per console', () {
    test('ogni console del catalogo ha una fonte, o volutamente nessuna', () async {
      final String seed = File('lib/data/seed_data.dart').readAsStringSync();
      final Iterable<RegExpMatch> righe = RegExp(r"\(name: '([^']+)', shortLabel:").allMatches(seed);
      expect(righe, isNotEmpty, reason: 'il catalogo delle console deve essere leggibile dal seed');

      // Le uniche console senza fonte pubblica senza chiave.
      const Set<String> senzaFonte = <String>{'Android'};
      for (final RegExpMatch m in righe) {
        final String console = m.group(1)!;
        if (senzaFonte.contains(console)) {
          expect(coverRoutes.containsKey(console), isFalse, reason: '$console non deve avere un instradamento');
        } else {
          expect(coverRoutes.containsKey(console), isTrue, reason: 'manca l instradamento per $console');
        }
      }
    });

    test('ogni sistema Libretro usato ha il suo indice negli assets', () {
      for (final String system in libretroSystemsInUse) {
        expect(
          File(LibretroIndex.assetPathFor(system)).existsSync(),
          isTrue,
          reason: 'manca assets/copertine/$system.txt.gz: rilanciare tool/genera_indici_copertine.dart',
        );
      }
    });

    test('senza console si prova solo Steam', () {
      expect(coverRouteWithoutConsole.sources, <CoverSource>[CoverSource.steam]);
    });
  });
}
