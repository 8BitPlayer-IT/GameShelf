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
