import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guardia sull'attribuzione all'autore.
///
/// Il termine aggiuntivo che accompagna la licenza (articolo 7b della GPL-3.0)
/// richiede che l'attribuzione resti nella schermata delle impostazioni e nel
/// README. Un test che la cerca nel codice non è un capriccio: è il modo di
/// accorgersene prima di pubblicare, invece che dopo. Vale anche per chi forka
/// il progetto, perché la verifica automatica gira su ogni modifica.
const String _author = 'Andrea Piva (8BitPlayer-IT)';

void main() {
  test('la riga di attribuzione è nella schermata delle impostazioni', () {
    final String settings = File('lib/features/settings/settings_screen.dart').readAsStringSync();
    expect(
      settings,
      contains('di $_author'),
      reason:
          'l\'attribuzione all\'autore nelle impostazioni è richiesta dalla licenza '
          '(articolo 7b della GPL-3.0, vedi la sezione «Licenza e autore» del README): '
          'non si può togliere',
    );
    expect(
      settings,
      contains('assets/icona_app.png'),
      reason: 'la riga di attribuzione mostra anche l\'icona dell\'app',
    );
  });

  test('l icona della riga esiste fra gli assets ed è dichiarata nel pubspec', () {
    expect(File('assets/icona_app.png').existsSync(), isTrue);
    expect(File('pubspec.yaml').readAsStringSync(), contains('assets/icona_app.png'));
  });

  test('il README dichiara autore, copyright e termine aggiuntivo', () {
    final String readme = File('README.md').readAsStringSync();
    expect(readme, contains(_author));
    expect(readme, contains('Copyright (C)'));
    expect(readme, contains('7(b)'), reason: 'il termine aggiuntivo va citato con il suo articolo');
  });

  test('main.dart porta l avviso di copyright e di licenza', () {
    final String main = File('lib/main.dart').readAsStringSync();
    expect(main, contains('Copyright (C)'));
    expect(main, contains(_author));
    expect(main, contains('GNU General Public License'));
  });
}
