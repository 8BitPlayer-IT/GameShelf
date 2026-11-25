/// L'indice dei nomi delle copertine di un sistema Libretro.
///
/// Gli indici sono file di testo compressi spediti dentro l'APK
/// (`assets/copertine/<sistema>.txt.gz`), una riga per copertina, generati da
/// `tool/genera_indici_copertine.dart`. In tutto sono 96.505 nomi in 0,81 MB:
/// il prezzo è trascurabile e in cambio **la ricerca del nome giusto avviene
/// senza rete**. L'unica richiesta che parte dal telefono è il download
/// dell'immagine già individuata.
///
/// Il nome nel file è anche il nome da rimettere nell'URL: Libretro sostituisce
/// i caratteri che non stanno in un percorso (`& * / : \` `< > ? |`) con un
/// trattino basso, e qui i nomi sono già nella forma sostituita.
library;

import 'dart:convert';
import 'dart:io' show gzip;
import 'dart:typed_data';

import 'title_match.dart';

/// Da dove arrivano i byte di un indice. L'app passa il bundle degli assets,
/// i test leggono direttamente dal disco.
typedef IndexLoader = Future<Uint8List> Function(String assetPath);

class LibretroIndex {
  LibretroIndex(this.system, this.names);

  final String system;

  /// I nomi dei file, senza cartella e senza `.png`.
  final List<String> names;

  static const String assetFolder = 'assets/copertine';

  static String assetPathFor(String system) => '$assetFolder/$system.txt.gz';

  /// Legge e decomprime l'indice di [system].
  static Future<LibretroIndex> load(String system, IndexLoader loader) async {
    final Uint8List compressed = await loader(assetPathFor(system));
    final List<int> plain = gzip.decode(compressed);
    final List<String> names = utf8
        .decode(plain)
        .split('\n')
        .map((String r) => r.trim())
        .where((String r) => r.isNotEmpty)
        .toList();
    return LibretroIndex(system, names);
  }

  /// Il nome del file della copertina di [title], o `null` se non c'è una
  /// corrispondenza certa.
  String? match(String title) => bestCoverMatch(names, title);
}
