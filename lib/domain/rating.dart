/// Regole dei voti.
///
/// La stessa media è calcolata anche da SQLite nella colonna generata
/// `games.overall_rating`: questa versione Dart serve all'anteprima dal vivo
/// mentre l'utente muove i cursori nella scheda, prima che qualcosa venga
/// salvato. Un test confronta le due su tutte le combinazioni possibili, così
/// non possono divergere.
///
/// Dart puro: nessun import di Flutter.
library;

/// Voto minimo assegnabile a una categoria.
const double minRating = 0;

/// Voto massimo assegnabile a una categoria.
const double maxRating = 10;

/// Passo dei cursori: mezzo punto.
const double ratingStep = 0.5;

/// Vero se [value] è un voto valido: fra 0 e 10 e a mezzi punti.
///
/// È la stessa condizione del CHECK nello schema; qui serve per non proporre
/// all'utente un valore che il database rifiuterebbe.
bool isValidRating(double value) {
  if (value < minRating || value > maxRating) return false;
  final double doubled = value * 2;
  return doubled == doubled.roundToDouble();
}

/// Media delle sole categorie valutate.
///
/// Restituisce `null` quando non è stata valutata nessuna categoria: «non
/// valutato» non è zero, e i due casi vanno mostrati e ordinati in modo diverso.
/// Uno zero esplicito invece è un voto a tutti gli effetti e abbassa la media.
double? overallRating({
  double? story,
  double? gameplay,
  double? graphics,
  double? soundtrack,
}) {
  double sum = 0;
  int count = 0;
  for (final double? value in <double?>[story, gameplay, graphics, soundtrack]) {
    if (value != null) {
      sum += value;
      count++;
    }
  }
  if (count == 0) return null;
  return sum / count;
}

/// Quante categorie su quattro sono state valutate: serve alla didascalia
/// «Media di {n} categorie su 4».
int ratedCategories({
  double? story,
  double? gameplay,
  double? graphics,
  double? soundtrack,
}) {
  int count = 0;
  for (final double? value in <double?>[story, gameplay, graphics, soundtrack]) {
    if (value != null) count++;
  }
  return count;
}
