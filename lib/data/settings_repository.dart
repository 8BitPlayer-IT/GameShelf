import 'package:drift/drift.dart';

import 'database.dart';

/// Preferenze salvate nella tabella `settings`, così viaggiano dentro il backup.
class SettingsRepository {
  SettingsRepository(this.db);

  final AppDatabase db;

  static const String themeMode = 'theme_mode';
  static const String lastBackupAt = 'last_backup_at';

  /// Grafica scelta: originale, ios1, aero.
  static const String appSkin = 'app_skin';

  /// Vista della libreria: `griglia:3`, `lista:2` (le colonne restano ricordate).
  static const String libraryView = 'library_view';

  /// Ordinamento della libreria: `voto:desc`.
  static const String librarySort = 'library_sort';

  Future<String?> read(String name) async {
    final QueryRow? row = await db
        .customSelect('SELECT value FROM settings WHERE name = ?', variables: <Variable>[Variable<String>(name)])
        .getSingleOrNull();
    return row?.read<String>('value');
  }

  Stream<String?> watch(String name) {
    return db
        .customSelect(
          'SELECT value FROM settings WHERE name = ?',
          variables: <Variable>[Variable<String>(name)],
          readsFrom: {db.settings},
        )
        .watch()
        .map((List<QueryRow> rows) => rows.isEmpty ? null : rows.first.read<String>('value'));
  }

  Future<void> set(String name, String value) {
    return db.customInsert(
      'INSERT INTO settings (name, value) VALUES (?, ?) '
      'ON CONFLICT(name) DO UPDATE SET value = excluded.value',
      variables: <Variable>[Variable<String>(name), Variable<String>(value)],
      updates: {db.settings},
    );
  }
}
