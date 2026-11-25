// Genera gli indici dei nomi delle copertine di Libretro, uno per sistema, e li
// scrive compressi in assets/copertine/.
//
// Uso: dart run tool/genera_indici_copertine.dart
//
// PERCHÉ SERVE UN INDICE. Le copertine di `libretro-thumbnails` si scaricano
// con una GET su raw.githubusercontent.com, ma il nome del file è il nome
// canonico della preservazione, non quello che scrive una persona:
//
//   «The Legend of Zelda: A Link to the Past»
//     -> Named_Boxarts/Legend of Zelda, The - A Link to the Past (Canada).png
//
// L'articolo finisce in coda dopo una virgola, i due punti diventano « - », e
// alla fine c'è la regione tra parentesi. Senza la parentesi la richiesta dà
// 404, quindi indovinare l'URL non funziona: bisogna conoscere i nomi.
//
// PERCHÉ NON SI CHIEDE A GITHUB AL VOLO. L'API degli alberi costa 5,5 MB per lo
// SNES e per la PlayStation risponde 500 (il deposito è troppo grande), e senza
// autenticazione si hanno 60 richieste l'ora per indirizzo IP. Inutilizzabile da
// un telefono.
//
// COME SI FA QUI. Un clone «senza immagini» (--filter=blob:none --no-checkout)
// scarica solo l'elenco dei file: circa 1 MB per sistema invece dei gigabyte
// delle immagini. Da quell'elenco si tengono i nomi, si comprimono e finiscono
// negli assets dell'APK: così la ricerca del nome giusto avviene **offline** e
// la rete serve solo per scaricare l'immagine trovata.
import 'dart:convert';
import 'dart:io';

import 'package:gameshelf/data/covers/cover_routes.dart';

const String _org = 'https://github.com/libretro-thumbnails';
const String _cloneDir = 'build/libretro';
const String _assetDir = 'assets/copertine';

Future<void> main(List<String> args) async {
  final bool riscarica = args.contains('--riscarica');
  final List<String> sistemi = libretroSystemsInUse.toList()..sort();

  await Directory(_cloneDir).create(recursive: true);
  await Directory(_assetDir).create(recursive: true);

  stdout.writeln('Indici da generare: ${sistemi.length}');
  int totaleNomi = 0;
  int totaleByte = 0;
  final List<String> falliti = <String>[];

  for (final String sistema in sistemi) {
    final Directory clone = Directory('$_cloneDir/$sistema');
    stdout.write('  $sistema ... ');

    if (riscarica && clone.existsSync()) await clone.delete(recursive: true);

    if (!clone.existsSync()) {
      final ProcessResult esito = await Process.run('git', <String>[
        'clone',
        '--quiet',
        // Niente immagini: solo i commit e gli alberi, cioè i nomi dei file.
        '--filter=blob:none',
        '--no-checkout',
        '--depth',
        '1',
        '$_org/$sistema.git',
        clone.path,
      ]);
      if (esito.exitCode != 0) {
        stdout.writeln('CLONE FALLITO');
        stderr.writeln('    ${esito.stderr}'.trim());
        falliti.add(sistema);
        continue;
      }
    }

    final ProcessResult elenco = await Process.run('git', <String>[
      '-C',
      clone.path,
      'ls-tree',
      '-r',
      '--name-only',
      'HEAD',
    ], stdoutEncoding: utf8);
    if (elenco.exitCode != 0) {
      stdout.writeln('ELENCO FALLITO');
      falliti.add(sistema);
      continue;
    }

    // Solo le copertine, senza la cartella davanti e senza l'estensione: il
    // nome che resta è quello che va confrontato con il titolo dell'utente, e
    // anche quello da rimettere nell'URL.
    final List<String> nomi =
        (elenco.stdout as String)
            .split('\n')
            .map((String r) => r.trim())
            .where((String r) => r.startsWith('Named_Boxarts/') && r.toLowerCase().endsWith('.png'))
            .map((String r) => r.substring('Named_Boxarts/'.length, r.length - '.png'.length))
            .where((String r) => r.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    if (nomi.isEmpty) {
      stdout.writeln('nessuna copertina, salto');
      falliti.add(sistema);
      continue;
    }

    final List<int> compresso = GZipCodec(level: 9).encode(utf8.encode(nomi.join('\n')));
    await File('$_assetDir/$sistema.txt.gz').writeAsBytes(compresso, flush: true);

    totaleNomi += nomi.length;
    totaleByte += compresso.length;
    stdout.writeln('${nomi.length} copertine, ${(compresso.length / 1024).round()} kB');
  }

  stdout.writeln('');
  stdout.writeln('Totale: $totaleNomi nomi in ${(totaleByte / 1024 / 1024).toStringAsFixed(2)} MB compressi.');
  if (falliti.isNotEmpty) {
    stdout.writeln('Sistemi senza indice: ${falliti.join(', ')}');
    exitCode = 1;
  }
  stdout.writeln('I cloni restano in $_cloneDir (non sono nel repository): '
      'rilanciare con --riscarica per aggiornarli.');
}
