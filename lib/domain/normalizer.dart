/// Normalizzazione dei testi per ricerca, confronto e ordinamento.
///
/// Serve a tre cose diverse, tutte scritte nel database accanto al testo originale:
/// - `normalize`  → confronti e ricerca ("pokemon" trova "Pokémon", "nintendo" è
///   lo stesso catalogo di "Nintendo");
/// - `sortKey`    → ordinamento alfabetico gradevole, con i numeri allineati
///   ("FIFA 9" prima di "FIFA 23") e gli articoli iniziali opzionalmente ignorati;
/// - `_stripDiacritics` è condiviso dalle due.
///
/// Dart puro: nessun import di Flutter, così è interamente testabile sul PC.
library;

/// Articoli iniziali ignorati nell'ordinamento quando l'opzione è attiva.
const Set<String> _leadingArticles = <String>{
  'il', 'lo', 'la', 'i', 'gli', 'le', 'un', 'uno', 'una',
  'the', 'a', 'an',
};

const Map<String, String> _diacritics = <String, String>{
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ā': 'a',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'ō': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ū': 'u',
  'ñ': 'n', 'ç': 'c', 'ß': 'ss', 'æ': 'ae', 'œ': 'oe', 'ý': 'y', 'ÿ': 'y',
};

/// Tutto ciò che non è una lettera o una cifra decimale diventa separatore.
///
/// Si usano le classi Unicode e non `[^a-z0-9]`: con quest'ultima un titolo
/// giapponese o cirillico si ridurrebbe a stringa vuota, e siccome `name_norm` è
/// UNIQUE il secondo catalogo scritto in quell'alfabeto verrebbe rifiutato come
/// doppione del primo. `\p{Nd}` (solo cifre decimali) e non `\p{N}`, perché il
/// riempimento con gli zeri di `sortKey` lavora sulle cifre ASCII: un carattere
/// come ½ resterebbe comunque fuori dall'ordinamento numerico.
final RegExp _nonAlphanumeric = RegExp(r'[^\p{L}\p{Nd}]+', unicode: true);

final RegExp _whitespace = RegExp(r'\s+');

String _stripDiacritics(String input) {
  final StringBuffer buffer = StringBuffer();
  for (final int rune in input.runes) {
    final String char = String.fromCharCode(rune);
    buffer.write(_diacritics[char] ?? char);
  }
  return buffer.toString();
}

/// Forma normalizzata usata per ricerca e unicità dei cataloghi.
///
/// Minuscolo, senza accenti, senza punteggiatura, con gli spazi compattati:
/// `Pokémon Rosso` → `pokemon rosso`, `Ratchet & Clank` → `ratchet clank`,
/// `L'Ombra` → `l ombra`.
String normalize(String input) {
  final String lower = _stripDiacritics(input.toLowerCase());
  final String cleaned = lower
      .replaceAll(_nonAlphanumeric, ' ')
      .trim()
      .replaceAll(_whitespace, ' ');
  if (cleaned.isNotEmpty) return cleaned;

  // Nome fatto di soli simboli (per esempio «★»): si tiene la forma minuscola con
  // gli spazi compattati. Restituire una stringa vuota renderebbe tutti questi
  // nomi lo stesso nome, e il vincolo UNIQUE ne rifiuterebbe il secondo.
  return lower.trim().replaceAll(_whitespace, ' ');
}

/// Chiave di ordinamento alfabetico.
///
/// Parte dalla forma normalizzata e in più:
/// - riempie i numeri con zeri a sinistra, così `fifa 9` viene prima di `fifa 23`
///   invece che dopo (l'ordinamento è testuale, non numerico);
/// - se [ignoreArticles] è vero toglie l'articolo iniziale, così `The Last of Us`
///   si ordina alla L. È un'opzione dell'utente: cambiandola si riscrivono tutte
///   le chiavi con un solo passaggio.
String sortKey(String title, {bool ignoreArticles = true}) {
  String value = normalize(title);
  if (value.isEmpty) return value;

  if (ignoreArticles) {
    final int firstSpace = value.indexOf(' ');
    if (firstSpace > 0) {
      final String firstWord = value.substring(0, firstSpace);
      if (_leadingArticles.contains(firstWord)) {
        value = value.substring(firstSpace + 1);
      }
    }
  }

  return value.replaceAllMapped(
    RegExp(r'\d+'),
    (Match match) => match.group(0)!.padLeft(6, '0'),
  );
}
