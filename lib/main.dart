// GameShelf — un catalogo dei videogiochi che possiedi, per Android.
//
// Copyright (C) 2026 Andrea Piva (8BitPlayer-IT)
//
// Questo programma è software libero: puoi ridistribuirlo e modificarlo secondo i
// termini della GNU General Public License come pubblicata dalla Free Software
// Foundation, nella versione 3 o (a tua scelta) in una successiva, insieme al
// termine aggiuntivo sull'attribuzione descritto nel README (articolo 7b).
//
// È distribuito nella speranza che sia utile, ma SENZA ALCUNA GARANZIA, nemmeno
// quella implicita di commerciabilità o di idoneità a un particolare scopo. Il
// testo completo della licenza è nel file LICENSE, e anche su
// <https://www.gnu.org/licenses/>.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Directory documents = await getApplicationDocumentsDirectory();

  runApp(
    ProviderScope(
      // Riverpod 3 ritenta da solo i provider falliti: per un'app offline che
      // scrive su database e file è solo un modo di ripetere un errore.
      retry: (int retryCount, Object error) => null,
      overrides: [documentsDirProvider.overrideWith((Ref ref) => documents.path)],
      child: const GameShelfApp(),
    ),
  );
}
