/// Stato di ricerca, filtri e ordinamento della libreria.
///
/// Dart puro: nessun import di Flutter.
library;

import 'enums.dart';

/// Caratteristiche filtrabili. Dentro questa sezione i filtri si sommano in AND:
/// chi cerca «rigiocabile» e «con DLC» vuole entrambe le cose.
enum GameFlag { rigiocabile, postGame, achievement, tuttiAchievement, dlc }

/// Che tipo di voci mostrare.
enum LibraryKind { tutti, soloCollection, soloSingoli, soloContenuti }

class LibraryQuery {
  const LibraryQuery({
    this.search = '',
    this.statuses = const <GameStatus>{},
    this.consoleIds = const <int>{},
    this.formats = const <CopyFormat>{},
    this.genreIds = const <int>{},
    this.seriesIds = const <int>{},
    this.developerIds = const <int>{},
    this.publisherIds = const <int>{},
    this.players = const <int>{},
    this.flags = const <GameFlag>{},
    this.kind = LibraryKind.tutti,
    this.showChildren = false,
    this.sort = SortCriterion.titolo,
    this.ascending = true,
  });

  final String search;
  final Set<GameStatus> statuses;
  final Set<int> consoleIds;
  final Set<CopyFormat> formats;
  final Set<int> genreIds;
  final Set<int> seriesIds;
  final Set<int> developerIds;
  final Set<int> publisherIds;

  /// Numero massimo di giocatori (1, 2 o 4).
  final Set<int> players;
  final Set<GameFlag> flags;
  final LibraryKind kind;

  /// Mostra anche i giochi contenuti nelle collection come voci separate.
  final bool showChildren;
  final SortCriterion sort;
  final bool ascending;

  /// Filtrare «solo giochi contenuti» ha senso solo mostrando i contenuti.
  bool get effectiveShowChildren => showChildren || kind == LibraryKind.soloContenuti;

  int get activeFilterCount =>
      statuses.length +
      consoleIds.length +
      formats.length +
      genreIds.length +
      seriesIds.length +
      developerIds.length +
      publisherIds.length +
      players.length +
      flags.length +
      (kind == LibraryKind.tutti ? 0 : 1);

  LibraryQuery copyWith({
    String? search,
    Set<GameStatus>? statuses,
    Set<int>? consoleIds,
    Set<CopyFormat>? formats,
    Set<int>? genreIds,
    Set<int>? seriesIds,
    Set<int>? developerIds,
    Set<int>? publisherIds,
    Set<int>? players,
    Set<GameFlag>? flags,
    LibraryKind? kind,
    bool? showChildren,
    SortCriterion? sort,
    bool? ascending,
  }) {
    return LibraryQuery(
      search: search ?? this.search,
      statuses: statuses ?? this.statuses,
      consoleIds: consoleIds ?? this.consoleIds,
      formats: formats ?? this.formats,
      genreIds: genreIds ?? this.genreIds,
      seriesIds: seriesIds ?? this.seriesIds,
      developerIds: developerIds ?? this.developerIds,
      publisherIds: publisherIds ?? this.publisherIds,
      players: players ?? this.players,
      flags: flags ?? this.flags,
      kind: kind ?? this.kind,
      showChildren: showChildren ?? this.showChildren,
      sort: sort ?? this.sort,
      ascending: ascending ?? this.ascending,
    );
  }

  /// Toglie tutti i filtri tenendo ricerca, vista e ordinamento.
  LibraryQuery withoutFilters() => LibraryQuery(
    search: search,
    showChildren: showChildren,
    sort: sort,
    ascending: ascending,
  );

  @override
  bool operator ==(Object other) =>
      other is LibraryQuery &&
      other.search == search &&
      _sameSet(other.statuses, statuses) &&
      _sameSet(other.consoleIds, consoleIds) &&
      _sameSet(other.formats, formats) &&
      _sameSet(other.genreIds, genreIds) &&
      _sameSet(other.seriesIds, seriesIds) &&
      _sameSet(other.developerIds, developerIds) &&
      _sameSet(other.publisherIds, publisherIds) &&
      _sameSet(other.players, players) &&
      _sameSet(other.flags, flags) &&
      other.kind == kind &&
      other.showChildren == showChildren &&
      other.sort == sort &&
      other.ascending == ascending;

  @override
  int get hashCode => Object.hash(
    search,
    Object.hashAllUnordered(statuses),
    Object.hashAllUnordered(consoleIds),
    Object.hashAllUnordered(formats),
    Object.hashAllUnordered(genreIds),
    Object.hashAllUnordered(seriesIds),
    Object.hashAllUnordered(developerIds),
    Object.hashAllUnordered(publisherIds),
    Object.hashAllUnordered(players),
    Object.hashAllUnordered(flags),
    kind,
    showChildren,
    sort,
    ascending,
  );
}

bool _sameSet<T>(Set<T> a, Set<T> b) => a.length == b.length && a.containsAll(b);
