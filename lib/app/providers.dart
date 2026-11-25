import 'package:flutter/material.dart' show ThemeMode;

import 'theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/backup_service.dart';
import '../data/catalog_admin.dart';
import '../data/catalog_repository.dart';
import '../data/cover_service.dart';
import '../data/covers/online_cover_service.dart';
import '../data/database.dart';
import '../data/game_repository.dart';
import '../data/library_repository.dart';
import '../data/settings_repository.dart';
import '../data/stats_repository.dart';
import '../domain/enums.dart';
import '../domain/library_query.dart';

final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>((Ref ref) {
  final AppDatabase db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Cartella documenti dell'app, letta una volta all'avvio in `main()` e passata
/// come override: i widget delle copertine ne hanno bisogno in modo sincrono.
final Provider<String> documentsDirProvider = Provider<String>(
  (Ref ref) => throw UnimplementedError('documentsDirProvider va impostato in main()'),
);

final Provider<CoverService> coverServiceProvider = Provider<CoverService>(
  (Ref ref) => CoverService(ref.watch(documentsDirProvider)),
);

/// Ricerca delle copertine online. Senza stato condiviso tranne la cache degli
/// indici di Libretro, che per la ricerca in blocco fa la differenza.
final Provider<OnlineCoverService> onlineCoverServiceProvider = Provider<OnlineCoverService>(
  (Ref ref) => OnlineCoverService(),
);

final Provider<CatalogRepository> catalogRepositoryProvider = Provider<CatalogRepository>(
  (Ref ref) => CatalogRepository(ref.watch(databaseProvider)),
);

final Provider<GameRepository> gameRepositoryProvider = Provider<GameRepository>(
  (Ref ref) => GameRepository(ref.watch(databaseProvider), ref.watch(catalogRepositoryProvider)),
);

final Provider<LibraryRepository> libraryRepositoryProvider = Provider<LibraryRepository>(
  (Ref ref) => LibraryRepository(ref.watch(databaseProvider)),
);

class LibraryQueryNotifier extends Notifier<LibraryQuery> {
  @override
  LibraryQuery build() => const LibraryQuery();

  void set(LibraryQuery query) => state = query;
}

final NotifierProvider<LibraryQueryNotifier, LibraryQuery> libraryQueryProvider =
    NotifierProvider<LibraryQueryNotifier, LibraryQuery>(LibraryQueryNotifier.new);

final StreamProvider<List<LibraryItem>> libraryItemsProvider = StreamProvider<List<LibraryItem>>(
  (Ref ref) => ref.watch(libraryRepositoryProvider).watchLibrary(ref.watch(libraryQueryProvider)),
);

final StreamProvider<FilterOptions> filterOptionsProvider = StreamProvider<FilterOptions>(
  (Ref ref) => ref.watch(libraryRepositoryProvider).watchFilterOptions(),
);

final gameDetailsProvider = StreamProvider.autoDispose.family<GameDetails?, int>(
  (Ref ref, int id) => ref.watch(gameRepositoryProvider).watchDetails(id),
);

/// Raccolte esistenti, per scegliere a quali far appartenere un gioco.
final StreamProvider<List<(int, String)>> collectionsProvider = StreamProvider<List<(int, String)>>(
  (Ref ref) => ref.watch(gameRepositoryProvider).watchCollections(),
);

final StreamProvider<List<ConsoleRow>> consolesProvider = StreamProvider<List<ConsoleRow>>(
  (Ref ref) => ref.watch(catalogRepositoryProvider).watchConsoles(),
);

final StreamProvider<List<CatalogEntry>> genresProvider = StreamProvider<List<CatalogEntry>>(
  (Ref ref) => ref.watch(catalogRepositoryProvider).watchGenres(),
);

final StreamProvider<List<CatalogEntry>> seriesProvider = StreamProvider<List<CatalogEntry>>(
  (Ref ref) => ref.watch(catalogRepositoryProvider).watchSeries(),
);

final StreamProvider<List<CatalogEntry>> companiesProvider = StreamProvider<List<CatalogEntry>>(
  (Ref ref) => ref.watch(catalogRepositoryProvider).watchCompanies(),
);

final Provider<StatsRepository> statsRepositoryProvider = Provider<StatsRepository>(
  (Ref ref) => StatsRepository(ref.watch(databaseProvider)),
);

final StreamProvider<StatsSnapshot> statsProvider = StreamProvider<StatsSnapshot>(
  (Ref ref) => ref.watch(statsRepositoryProvider).watchStats(),
);

final Provider<SettingsRepository> settingsRepositoryProvider = Provider<SettingsRepository>(
  (Ref ref) => SettingsRepository(ref.watch(databaseProvider)),
);

final StreamProvider<ThemeMode> themeModeProvider = StreamProvider<ThemeMode>(
  (Ref ref) => ref
      .watch(settingsRepositoryProvider)
      .watch(SettingsRepository.themeMode)
      .map((String? value) => ThemeMode.values.firstWhere((ThemeMode m) => m.name == value, orElse: () => ThemeMode.system)),
);

typedef LibraryView = ({LibraryViewMode mode, int columns});

const LibraryView defaultLibraryView = (mode: LibraryViewMode.griglia, columns: 2);

LibraryView parseLibraryView(String? value) {
  if (value == null) return defaultLibraryView;
  final List<String> parts = value.split(':');
  final int columns = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 2;
  return (
    mode: parts.first == 'lista' ? LibraryViewMode.lista : LibraryViewMode.griglia,
    columns: const <int>{2, 3, 4}.contains(columns) ? columns : 2,
  );
}

/// Vista della libreria salvata nelle impostazioni, così resta quella dell'ultima volta.
final StreamProvider<LibraryView> libraryViewProvider = StreamProvider<LibraryView>(
  (Ref ref) =>
      ref.watch(settingsRepositoryProvider).watch(SettingsRepository.libraryView).map(parseLibraryView),
);

final StreamProvider<AppSkin> appSkinProvider = StreamProvider<AppSkin>(
  (Ref ref) => ref.watch(settingsRepositoryProvider).watch(SettingsRepository.appSkin).map(AppSkin.fromName),
);

final StreamProvider<String?> lastBackupProvider = StreamProvider<String?>(
  (Ref ref) => ref.watch(settingsRepositoryProvider).watch(SettingsRepository.lastBackupAt),
);

final Provider<BackupService> backupServiceProvider = Provider<BackupService>(
  (Ref ref) => BackupService(ref.watch(databaseProvider), ref.watch(documentsDirProvider)),
);

final Provider<CatalogAdmin> catalogAdminProvider = Provider<CatalogAdmin>(
  (Ref ref) => CatalogAdmin(ref.watch(databaseProvider)),
);

final catalogUsageProvider = StreamProvider.autoDispose.family<List<CatalogUsage>, CatalogKind>(
  (Ref ref, CatalogKind kind) => ref.watch(catalogAdminProvider).watch(kind),
);
