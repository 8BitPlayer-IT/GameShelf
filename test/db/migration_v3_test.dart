// La migrazione alla v3 su dati veri: in libreria ci sono già centinaia di giochi,
// 18 raccolte e un centinaio di appartenenze da convertire da `games.parent_id` a
// `collection_items`, più le copie messe da parte da restituire ai loro giochi.
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/data/database.dart';

import '../drift/gameshelf/generated/schema.dart';
import '../drift/gameshelf/generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('dalla v2 alla v3: appartenenze convertite e copie messe da parte restituite', () async {
    final InitializedSchema schema = await verifier.schemaAt(2);

    // Database alla versione 2, riempito come quello sul telefono.
    final v2.DatabaseAtV2 old = v2.DatabaseAtV2(schema.newConnection());
    await old.customStatement(
      "INSERT INTO consoles (id, name, name_norm, short_label, family, sort_order) VALUES "
      "(1, 'Nintendo 64', 'nintendo 64', 'N64', 'nintendo', 20), "
      "(2, 'Nintendo Switch', 'nintendo switch', 'Switch', 'nintendo', 60)",
    );
    await old.customStatement(
      "INSERT INTO games (id, title, title_norm, sort_title, status, is_collection, parent_id) VALUES "
      "(10, 'Super Mario 3D All-Stars', 'super mario 3d all stars', 'super mario 000003d all stars', 'backlog', 1, NULL), "
      "(11, 'Super Mario 64', 'super mario 64', 'super mario 000064', 'finito', 0, 10), "
      "(12, 'Gioco singolo', 'gioco singolo', 'gioco singolo', 'backlog', 0, NULL)",
    );
    await old.customStatement("INSERT INTO game_copies (game_id, console_id, format) VALUES (10, 2, 'fisico')");
    await old.customStatement("INSERT INTO game_copies (game_id, console_id, format) VALUES (12, 1, 'fisico')");
    // Copia che il gioco possedeva prima di entrare nella raccolta.
    await old.customStatement("INSERT INTO detached_copies (game_id, console_id, format) VALUES (11, 1, 'fisico')");
    await old.customStatement('INSERT INTO game_platforms (game_id, console_id) VALUES (11, 1)');
    await old.close();

    // Riapertura con il codice attuale: scatta la migrazione.
    final AppDatabase db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    addTearDown(db.close);

    final CollectionItem membership = await db.select(db.collectionItems).getSingle();
    expect(membership.collectionId, 10);
    expect(membership.gameId, 11, reason: 'il vecchio parent_id è diventato un\'appartenenza');

    final List<GameCopy> copies = await (db.select(
      db.gameCopies,
    )..where((GameCopies c) => c.gameId.equals(11))).get();
    expect(copies.single.consoleId, 1, reason: 'la copia messa da parte torna al gioco');

    // Le copie efficaci del gioco contenuto: la sua più quella della raccolta.
    final List<EffectiveCopy> effective = await (db.select(
      db.effectiveCopies,
    )..where((EffectiveCopies c) => c.gameId.equals(11))).get();
    expect(effective.map((EffectiveCopy c) => c.consoleId).toSet(), <int>{1, 2});

    expect(await db.games.count().getSingle(), 3, reason: 'nessun gioco perso');
    expect(await db.gamePlatforms.count().getSingle(), 1);
    final List<StatGame> counted = await db.select(db.statGames).get();
    expect(counted.map((StatGame g) => g.gameId).toSet(), <int>{11, 12}, reason: 'la raccolta piena non conta');
  });
}
