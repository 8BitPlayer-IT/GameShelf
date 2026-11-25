/// Stato modificabile della scheda di un gioco, usato dal modulo di modifica.
///
/// Dart puro: nessun import di Flutter.
library;

import 'enums.dart';
import 'rating.dart';

/// Una copia posseduta come la vede il modulo: console + formato.
class CopyDraft {
  const CopyDraft({required this.consoleId, required this.format});

  final int consoleId;
  final CopyFormat format;

  CopyDraft withFormat(CopyFormat value) => CopyDraft(consoleId: consoleId, format: value);

  @override
  bool operator ==(Object other) =>
      other is CopyDraft && other.consoleId == consoleId && other.format == format;

  @override
  int get hashCode => Object.hash(consoleId, format);
}

class GameDraft {
  GameDraft({
    this.id,
    this.title = '',
    this.seriesName = '',
    this.developerName = '',
    this.publisherName = '',
    this.releaseYear,
    Set<int>? genreIds,
    List<CopyDraft>? copies,
    this.status = GameStatus.backlog,
    this.isReplayable = false,
    this.hasPostGame = false,
    this.hasAchievements = false,
    this.allAchievementsUnlocked = false,
    this.hasDlc = false,
    this.isCollection = false,
    List<int>? collectionIds,
    this.ratingStory,
    this.ratingGameplay,
    this.ratingGraphics,
    this.ratingSoundtrack,
    this.coverPath,
    this.players,
    List<int>? platformIds,
  }) : genreIds = genreIds ?? <int>{},
       copies = copies ?? <CopyDraft>[],
       platformIds = platformIds ?? <int>[],
       collectionIds = collectionIds ?? <int>[];

  /// `null` per un gioco nuovo.
  int? id;
  String title;

  /// Serie, sviluppatore e publisher per nome: stringa vuota = nessuno. Il
  /// repository li cerca nel catalogo (ignorando maiuscole e accenti) e li crea
  /// se non esistono.
  String seriesName;
  String developerName;
  String publisherName;
  int? releaseYear;
  Set<int> genreIds;
  List<CopyDraft> copies;
  GameStatus status;
  bool isReplayable;
  bool hasPostGame;
  bool hasAchievements;
  bool allAchievementsUnlocked;
  bool hasDlc;
  bool isCollection;

  /// Raccolte a cui questo gioco appartiene: possono essere più d'una, e il gioco
  /// può comunque avere copie proprie.
  List<int> collectionIds;
  double? ratingStory;
  double? ratingGameplay;
  double? ratingGraphics;
  double? ratingSoundtrack;
  String? coverPath;

  /// Numero massimo di giocatori: 1, 2 o 4; `null` se non indicato.
  int? players;

  /// Console su cui il gioco è uscito in origine, se diverse dalle copie possedute.
  List<int> platformIds;

  bool get isInCollection => collectionIds.isNotEmpty;

  double? get overall => overallRating(
    story: ratingStory,
    gameplay: ratingGameplay,
    graphics: ratingGraphics,
    soundtrack: ratingSoundtrack,
  );

  int get ratedCount => ratedCategories(
    story: ratingStory,
    gameplay: ratingGameplay,
    graphics: ratingGraphics,
    soundtrack: ratingSoundtrack,
  );

  /// Errori in italiano, pronti da mostrare. Lista vuota = scheda valida.
  List<String> validate({required int currentYear}) {
    final List<String> errors = <String>[];
    if (title.trim().isEmpty) errors.add('Il titolo è obbligatorio.');
    final int? year = releaseYear;
    if (year != null && (year < 1950 || year > currentYear + 5)) {
      errors.add('L\'anno di uscita deve essere compreso fra il 1950 e il ${currentYear + 5}.');
    }
    for (final double? rating in <double?>[
      ratingStory,
      ratingGameplay,
      ratingGraphics,
      ratingSoundtrack,
    ]) {
      if (rating != null && !isValidRating(rating)) {
        errors.add('I voti vanno da 0 a 10 a mezzi punti.');
        break;
      }
    }
    if (copies.toSet().length != copies.length) {
      errors.add('La stessa console con lo stesso formato è stata aggiunta due volte.');
    }
    if (players != null && !const <int>{1, 2, 4}.contains(players)) {
      errors.add('Il numero di giocatori può essere 1, 2 o 4.');
    }
    if (isCollection && isInCollection) {
      errors.add('Una collection non può stare dentro un\'altra collection.');
    }
    return errors;
  }
}
