import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/data/backup_service.dart';
import 'package:gameshelf/data/catalog_admin.dart';
import 'package:gameshelf/data/catalog_repository.dart';
import 'package:gameshelf/data/database.dart';
import 'package:gameshelf/data/game_repository.dart';
import 'package:gameshelf/data/stats_repository.dart';
import 'package:gameshelf/domain/enums.dart';
import 'package:gameshelf/domain/game_draft.dart';
import 'package:path/path.dart' as p;

import '../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late GameRepository games;
  late int ps4;
  late int switchId;
  late int collection;

  setUp(() async {
    db = createTestDatabase();
    games = GameRepository(db, CatalogRepository(db), clock: () => DateTime(2026, 9, 12));
    ps4 = await consoleIdByLabel(db, 'PS4');
    switchId = await consoleIdByLabel(db, 'Switch');

    // Un cofanetto PS4 fisico con due giochi, un gioco su due console, uno digitale.
    collection = await games.save(
      GameDraft(
        title: 'Kingdom Hearts HD 1.5',
        isCollection: true,
        releaseYear: 2013,
        copies: <CopyDraft>[CopyDraft(consoleId: ps4, format: CopyFormat.fisico)],
      ),
    );
    await games.save(GameDraft(title: 'Final Mix', collectionIds: <int>[collection], status: GameStatus.finito, ratingStory: 9));
    await games.save(GameDraft(title: 'Re:Chain', collectionIds: <int>[collection]));
    await games.save(
      GameDraft(
        title: 'Hollow Knight',
        status: GameStatus.completato,
        releaseYear: 2017,
        developerName: 'Team Cherry',
        genreIds: <int>{await genreIdByName(db, 'Metroidvania')},
        copies: <CopyDraft>[
          CopyDraft(consoleId: ps4, format: CopyFormat.fisico),
          CopyDraft(consoleId: switchId, format: CopyFormat.digitale),
        ],
        ratingGameplay: 7.5,
        hasDlc: true,
      ),
    );
    await games.save(
      GameDraft(
        title: 'Celeste',
        releaseYear: 2018,
        copies: <CopyDraft>[CopyDraft(consoleId: switchId, format: CopyFormat.digitale)],
      ),
    );
  });

  group('statistiche (unità: supporti reali)', () {
    test('console e formato contano le copie, il resto conta i giochi', () async {
      final StatsSnapshot s = await StatsRepository(db).load();

      expect(s.games, 4, reason: '2 contenuti + Hollow Knight + Celeste; il cofanetto no');
      expect(s.copies, 4, reason: 'il cofanetto è una copia sola, Hollow Knight due');
      expect(s.physicalCopies, 2);
      expect(s.digitalCopies, 2);
      expect({for (final CountEntry e in s.byConsole) e.label: e.count}, <String, int>{'PS4': 2, 'Switch': 2});
      expect(s.byStatus[GameStatus.finito], 1);
      expect(s.byStatus[GameStatus.backlog], 2);
      expect(s.completed, 2);
      expect(s.averageRating, closeTo(8.25, 1e-9));
      expect(s.unrated, 2);
      // Fasce: 0 sotto il 5, 1 da 5 a 6,9, 2 da 7 a 7,9, 3 da 8 a 8,9, 4 da 9 a 9,9, 5 il 10.
      expect(s.ratingTiers[4], 1, reason: 'Final Mix ha 9');
      expect(s.ratingTiers[2], 1, reason: 'Hollow Knight ha 7,5');
      expect(s.topDevelopers.single.label, 'Team Cherry');
    });

    test('la percentuale dei finiti esclude i giochi arcade', () async {
      await db.customStatement("UPDATE games SET status = 'arcade' WHERE title = 'Celeste'");
      final StatsSnapshot s = await StatsRepository(db).load();

      expect(s.games, 4);
      expect(s.arcade, 1);
      expect(s.completable, 3, reason: 'un arcade non può essere finito');
      expect(s.completedPercent, 67, reason: '2 finiti o completati su 3');
    });

    test('su una libreria vuota restituisce zeri, non errori', () async {
      
      await db.customStatement('DELETE FROM games');
      final StatsSnapshot s = await StatsRepository(db).load();
      expect(s.games, 0);
      expect(s.copies, 0);
      expect(s.averageRating, isNull);
    });
  });

  group('backup', () {
    late Directory docs;
    late Directory out;

    setUp(() async {
      docs = await Directory.systemTemp.createTemp('gameshelf_docs');
      out = await Directory.systemTemp.createTemp('gameshelf_out');
      addTearDown(() async {
        await docs.delete(recursive: true);
        await out.delete(recursive: true);
      });
      await Directory(p.join(docs.path, 'covers')).create();
      await File(p.join(docs.path, 'covers', 'abc-123.jpg')).writeAsBytes(<int>[1, 2, 3, 4]);
      final GameDraft celeste = (await games.loadDraft(
        (await (db.select(db.games)..where((Games g) => g.title.equals('Celeste'))).getSingle()).id,
      ))..coverPath = 'covers/abc-123.jpg';
      await games.save(celeste);
    });

    test('esportare e ripristinare riporta libreria, collection e copertine', () async {
      await db.customStatement(
        "INSERT INTO game_platforms VALUES ((SELECT id FROM games WHERE title = 'Final Mix'), "
        "(SELECT id FROM consoles WHERE short_label = 'PS2'))",
      );
      await db.customStatement("UPDATE games SET players = 4 WHERE title = 'Hollow Knight'");

      final BackupService service = BackupService(db, docs.path);
      final File zip = await service.export(out.path);

      // Si svuota tutto, compresa la copertina, poi si ripristina.
      
      await db.customStatement('DELETE FROM games');
      await Directory(p.join(docs.path, 'covers')).delete(recursive: true);

      final BackupSummary summary = await service.import(zip.path);
      expect(summary.games, 5);
      expect(summary.covers, 1);
      expect(await db.games.count().getSingle(), 5);
      expect(await db.gameCopies.count().getSingle(), 4);
      expect(await db.gamePlatforms.count().getSingle(), 1);
      final Game hollow = await (db.select(db.games)..where((Games g) => g.title.equals('Hollow Knight'))).getSingle();
      expect(hollow.players, 4);

      final Game child = await (db.select(db.games)..where((Games g) => g.title.equals('Final Mix'))).getSingle();
      expect(await db.collectionItems.count().getSingle(), 2);
      expect(child.overallRating, 9, reason: 'la colonna generata si ricalcola');
      expect(child.titleNorm, 'final mix', reason: 'le chiavi derivate si ricalcolano');
      expect(File(p.join(docs.path, 'covers', 'abc-123.jpg')).readAsBytesSync(), <int>[1, 2, 3, 4]);
    });

    test('un file che non è un backup viene rifiutato e la libreria resta intatta', () async {
      final File notBackup = File(p.join(out.path, 'altro.zip'))..writeAsStringSync('non sono uno zip');
      await expectLater(BackupService(db, docs.path).import(notBackup.path), throwsA(isA<BackupException>()));
      expect(await db.games.count().getSingle(), 5);
    });
  });

  group('gestione cataloghi', () {
    test('unire due console sposta le copie senza creare doppioni', () async {
      final int ps5 = await consoleIdByLabel(db, 'PS5');
      final int hollow = (await (db.select(db.games)..where((Games g) => g.title.equals('Hollow Knight'))).getSingle()).id;
      // Hollow Knight fisico sia su PS4 sia su PS5: dopo l'unione deve restarne uno.
      await db.into(db.gameCopies).insert(GameCopiesCompanion.insert(gameId: hollow, consoleId: ps5, format: 'fisico'));

      await CatalogAdmin(db).merge(CatalogKind.console, ps5, ps4);

      final List<GameCopy> copies = await (db.select(db.gameCopies)..where((GameCopies c) => c.gameId.equals(hollow))).get();
      expect(copies.where((GameCopy c) => c.consoleId == ps4 && c.format == 'fisico'), hasLength(1));
      expect(copies.any((GameCopy c) => c.consoleId == ps5), isFalse);
      expect(await (db.select(db.consoles)..where((Consoles c) => c.id.equals(ps5))).getSingleOrNull(), isNull);
    });

    test('unire una voce con sé stessa è rifiutato e non tocca nulla', () async {
      await expectLater(CatalogAdmin(db).merge(CatalogKind.console, ps4, ps4), throwsA(isA<CatalogException>()));
      expect(await db.gameCopies.count().getSingle(), 4);
    });

    test('una voce in uso non si elimina, una inutilizzata sì', () async {
      final CatalogAdmin admin = CatalogAdmin(db);
      await expectLater(admin.delete(CatalogKind.console, ps4), throwsA(isA<CatalogException>()));
      final int unused = await consoleIdByLabel(db, 'Dreamcast');
      await admin.delete(CatalogKind.console, unused);
      expect(await db.consoles.count().getSingle(), 41);
    });
  });
}
