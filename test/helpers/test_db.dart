import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/data/database.dart';
import 'package:gameshelf/domain/normalizer.dart';

/// Database in memoria, creato da zero a ogni test (quindi con i cataloghi iniziali)
/// e chiuso automaticamente alla fine.
///
/// `closeStreamsSynchronously` evita i fallimenti da "timer ancora attivo" quando un
/// test osserva un flusso e termina subito dopo.
AppDatabase createTestDatabase() {
  final AppDatabase db = AppDatabase.forTesting(
    DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
  );
  addTearDown(db.close);
  return db;
}

/// Inserisce un gioco compilando da sé i campi derivati (forma normalizzata e
/// chiave di ordinamento), che nell'app sono responsabilità del repository.
Future<int> insertGame(
  AppDatabase db, {
  required String title,
  String status = 'backlog',
  bool isCollection = false,
  int? inCollection,
  int? releaseYear,
  int? seriesId,
  int? developerId,
  int? publisherId,
  double? ratingStory,
  double? ratingGameplay,
  double? ratingGraphics,
  double? ratingSoundtrack,
  bool hasAchievements = false,
  bool allAchievementsUnlocked = false,
}) async {
  final int id = await db
      .into(db.games)
      .insert(
        GamesCompanion.insert(
          title: title,
          titleNorm: normalize(title),
          sortTitle: sortKey(title),
          status: Value<String>(status),
          isCollection: Value<bool>(isCollection),
          releaseYear: Value<int?>(releaseYear),
          seriesId: Value<int?>(seriesId),
          developerId: Value<int?>(developerId),
          publisherId: Value<int?>(publisherId),
          ratingStory: Value<double?>(ratingStory),
          ratingGameplay: Value<double?>(ratingGameplay),
          ratingGraphics: Value<double?>(ratingGraphics),
          ratingSoundtrack: Value<double?>(ratingSoundtrack),
          hasAchievements: Value<bool>(hasAchievements),
          allAchievementsUnlocked: Value<bool>(allAchievementsUnlocked),
        ),
      );
  if (inCollection != null) await addToCollection(db, collectionId: inCollection, gameId: id);
  return id;
}

/// Mette un gioco dentro una raccolta.
Future<void> addToCollection(AppDatabase db, {required int collectionId, required int gameId}) {
  return db
      .into(db.collectionItems)
      .insert(CollectionItemsCompanion.insert(collectionId: collectionId, gameId: gameId));
}

/// Aggiunge una copia posseduta (console + formato) a un gioco.
Future<int> insertCopy(
  AppDatabase db, {
  required int gameId,
  required int consoleId,
  String format = 'fisico',
}) {
  return db
      .into(db.gameCopies)
      .insert(
        GameCopiesCompanion.insert(
          gameId: gameId,
          consoleId: consoleId,
          format: format,
        ),
      );
}

/// Id di una console dei cataloghi iniziali, cercata per sigla (es. `PS4`).
Future<int> consoleIdByLabel(AppDatabase db, String shortLabel) async {
  final ConsoleRow row = await (db.select(
    db.consoles,
  )..where((Consoles c) => c.shortLabel.equals(shortLabel))).getSingle();
  return row.id;
}

/// Id di un genere dei cataloghi iniziali, cercato per nome.
Future<int> genreIdByName(AppDatabase db, String name) async {
  final Genre row = await (db.select(
    db.genres,
  )..where((Genres g) => g.nameNorm.equals(normalize(name)))).getSingle();
  return row.id;
}
