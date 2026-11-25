// Verifica della milestone M0: tutta la strategia di test dipende dal fatto che
// SQLite funzioni sul PC sotto `flutter test`, perché l'emulatore Android non è
// utilizzabile su questa macchina (virtualizzazione disattivata nel firmware).
//
// I test controllano anche le due regole SQL da cui dipende il voto complessivo,
// che nel piano sono state corrette proprio qui: divisione in virgola mobile e
// valori nulli in fondo all'ordinamento.
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('SQLite è disponibile per i test sul PC', () {
    expect(
      sqlite3.version.versionNumber,
      greaterThanOrEqualTo(3044000),
      reason: 'servono le colonne generate (3.31+) e NULLS LAST (3.30+)',
    );
  });

  test('la media dei voti è in virgola mobile e nulla se non c\'è alcun voto', () {
    final Database db = sqlite3.openInMemory();
    addTearDown(db.close);

    db.execute('''
      CREATE TABLE giochi (
        id INTEGER PRIMARY KEY,
        voto_storia REAL,
        voto_gameplay REAL,
        voto_grafica REAL,
        voto_ost REAL,
        voto_totale REAL GENERATED ALWAYS AS (
          CASE
            WHEN COALESCE(voto_storia, voto_gameplay, voto_grafica, voto_ost) IS NULL THEN NULL
            ELSE (COALESCE(voto_storia, 0) + COALESCE(voto_gameplay, 0)
                  + COALESCE(voto_grafica, 0) + COALESCE(voto_ost, 0)) * 1.0
                 / ((voto_storia IS NOT NULL) + (voto_gameplay IS NOT NULL)
                    + (voto_grafica IS NOT NULL) + (voto_ost IS NOT NULL))
          END
        ) VIRTUAL
      );
    ''');

    db.execute('''
      INSERT INTO giochi (id, voto_storia, voto_gameplay, voto_grafica, voto_ost) VALUES
        (1, 9, 8, 7, NULL),      -- media di 3 categorie: 8,0
        (2, 7.5, 8, NULL, NULL), -- mezzi punti: 7,75
        (3, NULL, NULL, NULL, NULL);
    ''');

    final ResultSet rows = db.select('SELECT id, voto_totale FROM giochi ORDER BY id');
    expect(rows[0]['voto_totale'], closeTo(8.0, 1e-9));
    expect(rows[1]['voto_totale'], closeTo(7.75, 1e-9),
        reason: 'senza * 1.0 SQLite troncherebbe la divisione tra interi');
    expect(rows[2]['voto_totale'], isNull,
        reason: 'nessuna categoria valutata significa nessun voto, non zero');
  });

  test('i giochi non valutati restano in fondo in entrambe le direzioni', () {
    final Database db = sqlite3.openInMemory();
    addTearDown(db.close);

    db.execute('CREATE TABLE giochi (id INTEGER PRIMARY KEY, voto REAL)');
    db.execute('INSERT INTO giochi VALUES (1, 8), (2, NULL), (3, 6)');

    List<Object?> idsOrderedBy(String direction) => db
        .select('SELECT id FROM giochi ORDER BY voto $direction NULLS LAST, id ASC')
        .map((Row row) => row['id'])
        .toList();

    expect(idsOrderedBy('ASC'), <int>[3, 1, 2]);
    expect(idsOrderedBy('DESC'), <int>[1, 3, 2]);
  });
}
