import 'package:drift/drift.dart';

import '../domain/normalizer.dart';
import 'database.dart';

/// Voce di catalogo (serie, azienda, genere o console) come la mostra l'interfaccia.
class CatalogEntry {
  const CatalogEntry(this.id, this.name);

  final int id;
  final String name;

  @override
  bool operator ==(Object other) => other is CatalogEntry && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

class CatalogRepository {
  CatalogRepository(this.db);

  final AppDatabase db;

  Stream<List<ConsoleRow>> watchConsoles() {
    // Sempre in ordine alfabetico: le console aggiunte dopo finirebbero in fondo
    // seguendo l'ordine del catalogo iniziale.
    return (db.select(db.consoles)..orderBy(<OrderClauseGenerator<Consoles>>[
          (Consoles c) => OrderingTerm(expression: c.nameNorm),
        ]))
        .watch();
  }

  Stream<List<CatalogEntry>> watchGenres() => _watchEntries('genres', db.genres);

  Stream<List<CatalogEntry>> watchSeries() => _watchEntries('series', db.series);

  Stream<List<CatalogEntry>> watchCompanies() => _watchEntries('companies', db.companies);

  /// Id della serie con questo nome, creandola se non c'è. `null` se il nome è vuoto.
  Future<int?> seriesIdFor(String name) => _getOrCreate('series', db.series, name);

  /// Id dell'azienda con questo nome, creandola se non c'è. `null` se il nome è vuoto.
  Future<int?> companyIdFor(String name) => _getOrCreate('companies', db.companies, name);

  /// Id del genere con questo nome, creandolo se non c'è.
  Future<int> genreIdFor(String name) async {
    final int? id = await _getOrCreate('genres', db.genres, name);
    if (id == null) throw ArgumentError.value(name, 'name', 'Il nome del genere è vuoto');
    return id;
  }

  /// Aggiunge una console al catalogo, o restituisce quella che ha già lo stesso nome.
  Future<int> consoleIdFor({
    required String name,
    required String shortLabel,
    String family = 'altro',
  }) async {
    final String cleanName = _clean(name);
    final String norm = normalize(cleanName);
    final QueryRow? existing = await db
        .customSelect('SELECT id FROM consoles WHERE name_norm = ?', variables: <Variable>[
          Variable<String>(norm),
        ])
        .getSingleOrNull();
    if (existing != null) return existing.read<int>('id');
    return db
        .into(db.consoles)
        .insert(
          ConsolesCompanion.insert(
            name: cleanName,
            nameNorm: norm,
            shortLabel: _clean(shortLabel),
            family: Value<String>(family),
          ),
        );
  }

  Stream<List<CatalogEntry>> _watchEntries(String table, TableInfo<Table, Object?> info) {
    return db
        .customSelect('SELECT id, name FROM $table ORDER BY name_norm', readsFrom: {info})
        .watch()
        .map(
          (List<QueryRow> rows) => <CatalogEntry>[
            for (final QueryRow row in rows)
              CatalogEntry(row.read<int>('id'), row.read<String>('name')),
          ],
        );
  }

  Future<int?> _getOrCreate(String table, TableInfo<Table, Object?> info, String name) async {
    final String clean = _clean(name);
    if (clean.isEmpty) return null;
    final String norm = normalize(clean);
    final QueryRow? existing = await db
        .customSelect('SELECT id FROM $table WHERE name_norm = ?', variables: <Variable>[
          Variable<String>(norm),
        ])
        .getSingleOrNull();
    if (existing != null) return existing.read<int>('id');
    return db.customInsert(
      'INSERT INTO $table (name, name_norm) VALUES (?, ?)',
      variables: <Variable>[Variable<String>(clean), Variable<String>(norm)],
      updates: {info},
    );
  }

  static String _clean(String value) => value.trim().replaceAll(RegExp(r'\s+'), ' ');
}
