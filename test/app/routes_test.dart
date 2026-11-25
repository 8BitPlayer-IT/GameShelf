import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ogni schermata deve aprirsi con `skinnedRoute`, che le mette dentro lo sfondo
/// della grafica. Una rotta nuda resterebbe trasparente: durante la transizione
/// si vedrebbe in trasparenza la pagina sotto, il vetro delle barre non avrebbe
/// niente da sfocare, e con lo sfondo globale un giorno tolto resterebbe nera.
void main() {
  test('nessuna schermata si apre con una rotta nuda', () {
    final List<String> colpevoli = <String>[];
    for (final FileSystemEntity entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      // L'unico punto che può nominarla è il costruttore di skinnedRoute.
      if (entity.path.replaceAll(r'\', '/').endsWith('lib/ui/widgets.dart')) continue;
      if (entity.readAsStringSync().contains('MaterialPageRoute')) colpevoli.add(entity.path);
    }
    expect(colpevoli, isEmpty, reason: 'usa skinnedRoute al posto di MaterialPageRoute');
  });
}
