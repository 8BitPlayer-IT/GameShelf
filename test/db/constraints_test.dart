// Ogni vincolo dello schema deve rifiutare esattamente il dato sbagliato, e
// accettare il caso limite legittimo che gli somiglia.
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/data/database.dart';
import 'package:gameshelf/domain/normalizer.dart';
import 'package:sqlite3/sqlite3.dart';

import '../helpers/test_db.dart';

final Matcher throwsSqlite = throwsA(isA<SqliteException>());

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());

  group('giochi', () {
    test('il titolo non può essere vuoto o fatto di soli spazi', () {
      expect(() => insertGame(db, title: '   '), throwsSqlite);
    });

    test('l\'anno di uscita è facoltativo ma dev\'essere plausibile', () async {
      await insertGame(db, title: 'Senza anno');
      await insertGame(db, title: 'Super Mario Bros.', releaseYear: 1985);
      expect(() => insertGame(db, title: 'Troppo vecchio', releaseYear: 1800), throwsSqlite);
    });

    test('lo stato di completamento accetta solo i sei valori previsti', () async {
      for (final String status in <String>[
        'backlog',
        'arcade',
        'abbandonato',
        'in_corso',
        'finito',
        'completato',
      ]) {
        await insertGame(db, title: 'Gioco $status', status: status);
      }
      expect(() => insertGame(db, title: 'Boh', status: 'in_pausa'), throwsSqlite);
    });

    test('i voti vanno da 0 a 10 e solo a mezzi punti', () async {
      await insertGame(db, title: 'Mezzo punto', ratingStory: 7.5);
      await insertGame(db, title: 'Zero', ratingStory: 0);
      await insertGame(db, title: 'Dieci', ratingStory: 10);
      expect(() => insertGame(db, title: 'Undici', ratingStory: 11), throwsSqlite);
      expect(() => insertGame(db, title: 'Negativo', ratingStory: -1), throwsSqlite);
      expect(
        () => insertGame(db, title: 'Decimale', ratingStory: 7.3),
        throwsSqlite,
        reason: 'i decimi non sono ammessi: il voto è a mezzi punti',
      );
    });

    test('«tutti gli achievement sbloccati» richiede «ha achievement»', () async {
      await insertGame(
        db,
        title: 'Con achievement',
        hasAchievements: true,
        allAchievementsUnlocked: true,
      );
      expect(
        () => insertGame(db, title: 'Incoerente', allAchievementsUnlocked: true),
        throwsSqlite,
      );
    });

    test('una collection non può essere contenuta in un\'altra collection', () async {
      final int collectionId = await insertGame(db, title: 'Raccolta', isCollection: true);
      expect(
        () => insertGame(db, title: 'Sotto-raccolta', isCollection: true, inCollection: collectionId),
        throwsSqlite,
      );
    });
  });

  group('copie possedute', () {
    test('la stessa console può avere sia il fisico sia il digitale', () async {
      final int gameId = await insertGame(db, title: 'Hollow Knight');
      final int ps4 = await consoleIdByLabel(db, 'PS4');

      await insertCopy(db, gameId: gameId, consoleId: ps4, format: 'fisico');
      await insertCopy(db, gameId: gameId, consoleId: ps4, format: 'digitale');

      final List<GameCopy> copies = await db.select(db.gameCopies).get();
      expect(copies, hasLength(2));
    });

    test('la stessa combinazione gioco/console/formato non si ripete', () async {
      final int gameId = await insertGame(db, title: 'Celeste');
      final int switchId = await consoleIdByLabel(db, 'Switch');

      await insertCopy(db, gameId: gameId, consoleId: switchId, format: 'digitale');
      expect(
        () => insertCopy(db, gameId: gameId, consoleId: switchId, format: 'digitale'),
        throwsSqlite,
      );
    });

    test('il formato accetta solo fisico o digitale', () async {
      final int gameId = await insertGame(db, title: 'Bloodborne');
      final int ps4 = await consoleIdByLabel(db, 'PS4');
      expect(
        () => insertCopy(db, gameId: gameId, consoleId: ps4, format: 'noleggiato'),
        throwsSqlite,
      );
    });
  });

  group('cataloghi', () {
    test('i nomi normalizzati sono unici: niente doppioni Nintendo/nintendo', () async {
      await db
          .into(db.companies)
          .insert(CompaniesCompanion.insert(name: 'Nintendo', nameNorm: normalize('Nintendo')));
      expect(
        () => db
            .into(db.companies)
            .insert(CompaniesCompanion.insert(name: 'nintendo', nameNorm: normalize('nintendo'))),
        throwsSqlite,
      );
    });

    test('i cataloghi iniziali ci sono e non si duplicano riaprendo il database', () async {
      expect(await db.consoles.count().getSingle(), 42);
      expect(await db.genres.count().getSingle(), 27);

      // Rieseguire il seeding non deve aggiungere nulla.
      await db.seedCatalogs();
      expect(await db.consoles.count().getSingle(), 42);
      expect(await db.genres.count().getSingle(), 27);
    });

    test('la sigla della console non supera i 10 caratteri', () {
      expect(
        () => db.into(db.consoles).insert(
          ConsolesCompanion.insert(
            name: 'Console dal nome lunghissimo',
            nameNorm: 'console dal nome lunghissimo',
            shortLabel: 'SIGLA TROPPO LUNGA',
          ),
        ),
        throwsSqlite,
      );
    });
  });
}
