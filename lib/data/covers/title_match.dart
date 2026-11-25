/// Confronto fra il titolo scritto a mano e il nome di un file di copertina.
///
/// È il punto delicato di tutta la ricerca online: una corrispondenza sbagliata
/// mette la copertina di un altro gioco, e quello è l'unico esito da evitare
/// davvero. La regola decisa è «nel dubbio nessuna copertina», quindi qui si
/// preferisce sempre rispondere `null` piuttosto che tirare a indovinare.
///
/// I nomi di Libretro seguono le convenzioni della preservazione, che non sono
/// quelle di una persona:
///
///   The Legend of Zelda: A Link to the Past
///     -> Legend of Zelda, The - A Link to the Past (Canada)
///   Castlevania: Symphony of the Night
///     -> Castlevania - Symphony of the Night (USA)
///
/// L'articolo va in coda dopo una virgola, i due punti diventano « - », e in
/// fondo c'è sempre una parentesi con la regione. Da qui le regole:
/// via le parentesi, via gli articoli da entrambe le parti, e confronto.
///
/// Dart puro, nessun import di Flutter: interamente provabile sul PC.
library;

import '../../domain/normalizer.dart';

/// Articoli toccati via da entrambe le parti del confronto.
///
/// Si togliono invece di spostarli: così «Legend of Zelda, The» e «The Legend of
/// Zelda» diventano la stessa chiave senza dover indovinare dove andava
/// l'articolo. Il rischio di confondere due giochi diversi che differiscono
/// soltanto per un articolo è teorico.
const Set<String> _articles = <String>{
  'the', 'a', 'an',
  'il', 'lo', 'la', 'i', 'gli', 'le', 'un', 'uno', 'una',
  'el', 'los', 'las', 'les', 'der', 'die', 'das', 'den', 'het',
};

/// Parentesi tonde e quadre con tutto il loro contenuto: regione, revisione,
/// lingua, raccolta di provenienza. Non fanno parte del titolo.
final RegExp _brackets = RegExp(r'[\(\[][^\)\]]*[\)\]]');

final RegExp _digits = RegExp(r'\d+');

const Map<String, String> _romanToArabic = <String, String>{
  'ii': '2', 'iii': '3', 'iv': '4', 'vi': '6', 'vii': '7', 'viii': '8',
  'ix': '9', 'xi': '11', 'xii': '12', 'xiii': '13', 'xiv': '14', 'xv': '15',
  'xvi': '16', 'xvii': '17', 'xviii': '18', 'xix': '19', 'xx': '20',
};

const Map<String, String> _arabicToRoman = <String, String>{
  '2': 'ii', '3': 'iii', '4': 'iv', '6': 'vi', '7': 'vii', '8': 'viii',
  '9': 'ix', '11': 'xi', '12': 'xii', '13': 'xiii', '14': 'xiv', '15': 'xv',
  '16': 'xvi', '17': 'xvii', '18': 'xviii', '19': 'xix', '20': 'xx',
};

/// Chiave canonica di confronto.
///
/// `I`, `V` e `X` da soli restano come sono: `Mega Man X` non è «Mega Man 10» e
/// `Grand Theft Auto V` non va confuso con un ipotetico capitolo «5» diverso.
/// La conversione fra numeri romani e arabi si fa dopo, come tentativo a parte.
String coverKey(String raw) {
  final String withoutBrackets = raw.replaceAll(_brackets, ' ');
  final List<String> words = normalize(withoutBrackets)
      .split(' ')
      .where((String w) => w.isNotEmpty && !_articles.contains(w))
      .toList();
  return words.join(' ');
}

/// Le chiavi da cercare, in ordine di fiducia calante.
///
/// La prima è il confronto esatto; le altre provano le due direzioni fra numeri
/// romani e arabi, perché «Final Fantasy VII» e «Final Fantasy 7» sono lo stesso
/// gioco ma nessuno scrive il titolo allo stesso modo.
List<String> coverKeyVariants(String raw) {
  final String base = coverKey(raw);
  final List<String> out = <String>[base];

  String convert(Map<String, String> table) => base
      .split(' ')
      .map((String w) => table[w] ?? w)
      .join(' ');

  for (final String variant in <String>[convert(_romanToArabic), convert(_arabicToRoman)]) {
    if (variant != base && !out.contains(variant)) out.add(variant);
  }
  return out;
}

/// I numeri contenuti nella chiave, ordinati.
///
/// Fa da sbarramento alla somiglianza approssimata: «FIFA 21» e «FIFA 22» si
/// assomigliano al 95%, ma non sono lo stesso gioco. Due titoli con numeri
/// diversi non sono mai lo stesso titolo.
List<String> numericSignature(String key) {
  final List<String> found = _digits.allMatches(key).map((Match m) => m.group(0)!).toList()..sort();
  return found;
}

/// Somiglianza fra due chiavi, da 0 a 1, col coefficiente di Dice sulle coppie
/// di caratteri. Robusta su refusi e parole mancanti, e non premia le stringhe
/// lunghe come farebbe il semplice conteggio dei caratteri comuni.
double similarity(String a, String b) {
  if (a == b) return 1;
  if (a.length < 2 || b.length < 2) return 0;

  final Map<String, int> pairsA = _bigrams(a);
  final Map<String, int> pairsB = _bigrams(b);
  int total = 0;
  int shared = 0;
  for (final MapEntry<String, int> e in pairsA.entries) {
    total += e.value;
    final int other = pairsB[e.key] ?? 0;
    shared += e.value < other ? e.value : other;
  }
  for (final int v in pairsB.values) {
    total += v;
  }
  return total == 0 ? 0 : 2 * shared / total;
}

Map<String, int> _bigrams(String s) {
  final Map<String, int> out = <String, int>{};
  for (int i = 0; i < s.length - 1; i++) {
    final String pair = s.substring(i, i + 2);
    out[pair] = (out[pair] ?? 0) + 1;
  }
  return out;
}

/// Soglia oltre la quale due titoli diversi si considerano lo stesso gioco.
///
/// 0,82 è il punto in cui, sulla libreria di prova, spariscono i falsi positivi
/// restando sopra il 90% di copertine trovate. Più in basso iniziano ad
/// arrivare i seguiti sbagliati, ed è peggio di nessuna copertina.
const double coverMatchThreshold = 0.82;

/// Regioni preferite, in ordine: una libreria italiana vuole la scatola europea.
const List<String> _regionPreference = <String>[
  'europe', 'world', 'usa', 'japan',
];

/// Punteggio di preferenza fra più file che hanno la stessa chiave.
///
/// A parità di titolo si sceglie la regione più vicina a chi usa la app, e fra
/// due file della stessa regione quello col nome più corto, che è la versione
/// base e non «(Rev 1)» o «(Demo)» o «(Virtual Console)».
int _regionRank(String fileName) {
  final String lower = fileName.toLowerCase();
  for (int i = 0; i < _regionPreference.length; i++) {
    if (lower.contains('(${_regionPreference[i]}')) return i;
    if (lower.contains('${_regionPreference[i]},') || lower.contains(', ${_regionPreference[i]}')) return i;
  }
  return _regionPreference.length;
}

/// Sceglie fra [candidates] il nome di file che corrisponde a [title], oppure
/// `null` se nessuno corrisponde con certezza.
///
/// [candidates] sono i nomi dei file di un solo sistema, senza estensione:
/// l'appartenenza allo stesso sistema è già di per sé uno sbarramento, perché
/// «Aladdin» su Mega Drive e «Aladdin» su Game Boy sono giochi diversi.
String? bestCoverMatch(Iterable<String> candidates, String title) {
  final List<String> wanted = coverKeyVariants(title);
  if (wanted.first.isEmpty) return null;

  final Map<String, List<String>> byKey = <String, List<String>>{};
  for (final String c in candidates) {
    byKey.putIfAbsent(coverKey(c), () => <String>[]).add(c);
  }

  // 1. Corrispondenza esatta della chiave, poi le varianti romano/arabo.
  for (final String key in wanted) {
    final List<String>? exact = byKey[key];
    if (exact != null && exact.isNotEmpty) return _preferred(exact);
  }

  // 2. Somiglianza approssimata, con lo sbarramento dei numeri. Si tiene solo
  //    se il migliore stacca il secondo: due candidati altrettanto simili
  //    vogliono dire che non si sa quale sia, e allora niente copertina.
  final String base = wanted.first;
  final List<String> signature = numericSignature(base);
  double bestScore = 0;
  double runnerUp = 0;
  String? bestKey;
  for (final String key in byKey.keys) {
    if (!_sameSignature(signature, numericSignature(key))) continue;
    final double score = similarity(base, key);
    if (score > bestScore) {
      runnerUp = bestScore;
      bestScore = score;
      bestKey = key;
    } else if (score > runnerUp) {
      runnerUp = score;
    }
  }

  if (bestKey == null || bestScore < coverMatchThreshold) return null;
  if (bestScore - runnerUp < 0.03) return null;
  return _preferred(byKey[bestKey]!);
}

bool _sameSignature(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

String _preferred(List<String> names) {
  final List<String> sorted = names.toList()
    ..sort((String a, String b) {
      final int byRegion = _regionRank(a).compareTo(_regionRank(b));
      if (byRegion != 0) return byRegion;
      final int byLength = a.length.compareTo(b.length);
      if (byLength != 0) return byLength;
      return a.compareTo(b);
    });
  return sorted.first;
}

/// Vale per le fonti che rispondono con un elenco di titoli (Steam, eShop,
/// iTunes): il titolo trovato deve corrispondere a quello cercato, altrimenti
/// si scarta. Senza questo controllo cercare «The Witcher 3» darebbe la
/// copertina di «The Witcher 3 — Remastered Soundtrack», che è il primo
/// risultato che Steam restituisce davvero.
bool titlesMatch(String searched, String found) {
  final List<String> wanted = coverKeyVariants(searched);
  final String other = coverKey(found);
  if (wanted.contains(other)) return true;
  if (!_sameSignature(numericSignature(wanted.first), numericSignature(other))) return false;
  return similarity(wanted.first, other) >= coverMatchThreshold;
}
