import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/catalog_repository.dart';
import '../../data/library_repository.dart';
import '../../data/settings_repository.dart';
import '../../domain/enums.dart';
import '../../domain/normalizer.dart';
import '../../domain/library_query.dart';
import '../../ui/widgets.dart';
import '../game/game_detail_screen.dart';
import '../game/game_edit_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _searching = false;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ordinamento dell'ultima volta, salvato nelle impostazioni.
    ref.read(settingsRepositoryProvider).read(SettingsRepository.librarySort).then((String? value) {
      if (!mounted || value == null) return;
      final List<String> parts = value.split(':');
      final SortCriterion? sort = SortCriterion.values.asNameMap()[parts.first];
      if (sort != null) _setQuery(_query.copyWith(sort: sort, ascending: parts.length < 2 || parts[1] != 'desc'));
    });
  }

  void _setSort(LibraryQuery query) {
    _setQuery(query);
    ref
        .read(settingsRepositoryProvider)
        .set(SettingsRepository.librarySort, '${query.sort.name}:${query.ascending ? 'asc' : 'desc'}');
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  LibraryQuery get _query => ref.read(libraryQueryProvider);

  void _setQuery(LibraryQuery query) => ref.read(libraryQueryProvider.notifier).set(query);

  void _closeSearch() {
    setState(() => _searching = false);
    _search.clear();
    _setQuery(_query.copyWith(search: ''));
  }

  @override
  Widget build(BuildContext context) {
    final LibraryQuery query = ref.watch(libraryQueryProvider);
    final AsyncValue<List<LibraryItem>> items = ref.watch(libraryItemsProvider);
    final LibraryView view = ref.watch(libraryViewProvider).value ?? defaultLibraryView;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const SkinBarBackground(),
        title: _searching
            ? TextField(
                controller: _search,
                autofocus: true,
                // Il campo sta dentro la barra, non su un fondo chiaro: senza
                // questi due colori scriveresti blu notte sul vetro blu.
                style: TextStyle(color: skinOf(context).onBar, fontSize: 18),
                cursorColor: skinOf(context).onBar,
                decoration: InputDecoration(
                  hintText: 'Cerca per titolo',
                  hintStyle: TextStyle(color: skinOf(context).onBar.withValues(alpha: 0.6)),
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (String value) => _setQuery(_query.copyWith(search: value)),
              )
            : const Text('Libreria'),
        actions: <Widget>[
          IconButton(
            tooltip: _searching ? 'Chiudi ricerca' : 'Cerca',
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: _searching ? _closeSearch : () => setState(() => _searching = true),
          ),
          _SortMenu(query: query, onChanged: _setSort),
          _ViewMenu(
            view: view,
            onChanged: (String value) =>
                ref.read(settingsRepositoryProvider).set(SettingsRepository.libraryView, value),
          ),
          IconButton(
            tooltip: 'Filtri',
            icon: Badge(
              isLabelVisible: query.activeFilterCount > 0,
              label: Text('${query.activeFilterCount}'),
              child: const Icon(Icons.tune),
            ),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              showDragHandle: true,
              builder: (_) => const FilterSheet(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: items.when(
        skipLoadingOnReload: true,
        data: (List<LibraryItem> list) {
          if (list.isEmpty) return _emptyState(query);
          return view.mode == LibraryViewMode.griglia
              ? _Grid(items: list, columns: view.columns)
              : _ListView(items: list);
        },
        loading: () => Center(child: CircularProgressIndicator(color: skinOf(context).backdropAccent)),
        error: (Object error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Impossibile leggere la libreria',
          message: '$error',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openGameEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi'),
      ),
    );
  }

  Widget _emptyState(LibraryQuery query) {
    final bool filtered = query.activeFilterCount > 0 || query.search.trim().isNotEmpty;
    if (!filtered) {
      return EmptyState(
        icon: Icons.videogame_asset_outlined,
        title: 'La tua libreria è vuota',
        message: 'Aggiungi il primo gioco della collezione: titolo, console, copertina e stato.',
        action: FilledButton.icon(
          onPressed: () => openGameEditor(context),
          icon: const Icon(Icons.add),
          label: const Text('Aggiungi un gioco'),
        ),
      );
    }
    return EmptyState(
      icon: Icons.search_off,
      title: 'Nessun gioco trovato',
      message: 'Prova a modificare la ricerca o a togliere qualche filtro.',
      action: FilledButton.tonalIcon(
        onPressed: () {
          _search.clear();
          setState(() => _searching = false);
          _setQuery(query.withoutFilters().copyWith(search: ''));
        },
        icon: const Icon(Icons.filter_alt_off_outlined),
        label: const Text('Azzera i filtri'),
      ),
    );
  }
}

Future<void> openGameEditor(BuildContext context, {int? gameId, int? collectionId}) {
  return Navigator.of(context).push<void>(
    skinnedRoute<void>((_) => GameEditScreen(gameId: gameId, collectionId: collectionId)),
  );
}

/// «parte di «Nome»» con una sola raccolta, «in 2 collection» con più d'una.
String memberLabel(LibraryItem item) => item.collectionTitles.length == 1
    ? 'parte di «${item.collectionTitles.single}»'
    : 'in ${item.collectionTitles.length} collection';

/// Apre la scheda di un gioco. [title] e [coverPath] sono quelli che il
/// chiamante sta già mostrando: passandoli, la scheda disegna la copertina
/// subito e il volo dalla libreria parte davvero.
void openGameDetail(BuildContext context, int gameId, {String? title, String? coverPath}) {
  Navigator.of(context).push<void>(
    skinnedRoute<void>((_) => GameDetailScreen(gameId: gameId, previewTitle: title, previewCover: coverPath)),
  );
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.query, required this.onChanged});

  final LibraryQuery query;
  final ValueChanged<LibraryQuery> onChanged;

  static const Map<SortCriterion, String> _labels = <SortCriterion, String>{
    SortCriterion.titolo: 'Titolo',
    SortCriterion.anno: 'Anno di uscita',
    SortCriterion.voto: 'Voto complessivo',
    SortCriterion.aggiunta: 'Aggiunti di recente',
  };

  String get _directionLabel => switch (query.sort) {
    SortCriterion.titolo => query.ascending ? 'Dalla A alla Z' : 'Dalla Z alla A',
    SortCriterion.anno => query.ascending ? 'Dal più vecchio' : 'Dal più recente',
    SortCriterion.voto => query.ascending ? 'Dal più basso' : 'Dal più alto',
    SortCriterion.aggiunta => query.ascending ? 'Prima i più vecchi' : 'Prima i più recenti',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Object>(
      tooltip: 'Ordina',
      icon: const Icon(Icons.sort),
      onSelected: (Object value) {
        if (value is SortCriterion) {
          // Voto e aggiunta hanno senso soprattutto dal più alto / più recente.
          final bool ascending = value == SortCriterion.titolo || value == SortCriterion.anno;
          onChanged(query.copyWith(sort: value, ascending: value == query.sort ? query.ascending : ascending));
        } else {
          onChanged(query.copyWith(ascending: !query.ascending));
        }
      },
      itemBuilder: (_) => <PopupMenuEntry<Object>>[
        for (final MapEntry<SortCriterion, String> entry in _labels.entries)
          CheckedPopupMenuItem<Object>(
            value: entry.key,
            checked: query.sort == entry.key,
            child: Text(entry.value),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<Object>(
          value: 'direction',
          child: Row(
            children: <Widget>[
              Icon(query.ascending ? Icons.arrow_upward : Icons.arrow_downward, size: 20),
              const SizedBox(width: 12),
              Text(_directionLabel),
            ],
          ),
        ),
      ],
    );
  }
}

class _ViewMenu extends StatelessWidget {
  const _ViewMenu({required this.view, required this.onChanged});

  final LibraryView view;

  /// Valore da salvare: `lista:N` o `griglia:N`.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool grid = view.mode == LibraryViewMode.griglia;
    return PopupMenuButton<String>(
      tooltip: 'Vista',
      icon: Icon(grid ? Icons.grid_view_outlined : Icons.view_list_outlined),
      onSelected: onChanged,
      itemBuilder: (_) => <PopupMenuEntry<String>>[
        CheckedPopupMenuItem<String>(value: 'lista:${view.columns}', checked: !grid, child: const Text('Lista')),
        for (final int n in const <int>[2, 3, 4])
          CheckedPopupMenuItem<String>(
            value: 'griglia:$n',
            checked: grid && view.columns == n,
            child: Text('Griglia · $n per riga'),
          ),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.items, required this.columns});

  final List<LibraryItem> items;
  final int columns;

  @override
  Widget build(BuildContext context) {
    const double spacing = 12;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double tileWidth = (constraints.maxWidth - 32 - spacing * (columns - 1)) / columns;
        // Altezza fissa: copertina 3:4 più lo spazio del titolo, che con più
        // colonne passa a due righe senza «parte di» e poi a una sola riga.
        final double textHeight = MediaQuery.textScalerOf(context).scale(switch (columns) {
          2 => 62,
          3 => 42,
          _ => 24,
        });
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: tileWidth * 4 / 3 + textHeight,
            mainAxisSpacing: columns == 4 ? 10 : 16,
            crossAxisSpacing: spacing,
          ),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) => _GridCard(item: items[index], columns: columns),
        );
      },
    );
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({required this.item, required this.columns});

  final LibraryItem item;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final StatusVisual status = statusVisual(item.status, theme.brightness);
    final double inset = columns == 4 ? 4 : 8;
    return Semantics(
      button: true,
      label:
          '${item.title}. ${status.label}. ${item.consoleLabels.join(', ')}. '
          '${item.overallRating == null ? 'Non valutato' : 'Voto ${formatRating(item.overallRating)} su 10'}.'
          '${item.isInCollection ? ' ${memberLabel(item)}.' : ''}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => openGameDetail(context, item.id, title: item.title, coverPath: item.coverPath),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Hero(
                tag: 'cover-${item.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CoverImage(path: item.coverPath, title: item.title, cacheWidth: 400),
                    // Sfumatura in basso per rendere leggibili i badge su copertine chiare.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: <Color>[Colors.transparent, Color(0x99000000)],
                        ),
                      ),
                    ),
                    Positioned(
                      top: inset,
                      left: inset,
                      child: Container(
                        padding: EdgeInsets.all(columns == 4 ? 3 : 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(status.icon, size: columns == 4 ? 12 : 16, color: status.color),
                      ),
                    ),
                    Positioned(
                      top: inset,
                      right: inset,
                      child: RatingBadge(
                        rating: item.overallRating,
                        onImage: true,
                        size: switch (columns) {
                          2 => 36,
                          3 => 30,
                          _ => 25,
                        },
                      ),
                    ),
                    Positioned(
                      left: inset,
                      right: inset,
                      bottom: inset,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                            child: ConsoleBadges(
                              labels: item.consoleLabels,
                              onImage: true,
                              iconsOnly: columns >= 3,
                              max: columns == 4 ? 1 : 2,
                              showMore: columns < 4,
                              trailing: item.releaseYear?.toString(),
                            ),
                          ),
                          if (item.isCollection && item.itemCount > 0 && columns < 4)
                            _ImageTag(icon: Icons.layers_outlined, text: '${item.itemCount}'),
                          if (item.isInCollection && columns < 4)
                            const _ImageTag(icon: Icons.subdirectory_arrow_right),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: columns == 4 ? 4 : 8),
            Text(
              item.title,
              maxLines: columns == 4 ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: skinOf(context).backdrop(
                (columns == 2 ? theme.textTheme.titleSmall : theme.textTheme.labelMedium)?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
            if (item.isInCollection && columns == 2)
              Text(
                memberLabel(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: skinOf(context).backdrop(theme.textTheme.labelSmall, muted: true),
              ),
          ],
        ),
      ),
    );
  }
}

class _ImageTag extends StatelessWidget {
  const _ImageTag({required this.icon, this.text});

  final IconData icon;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: Colors.white),
          if (text != null) ...<Widget>[
            const SizedBox(width: 2),
            Text(text!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView({required this.items});

  final List<LibraryItem> items;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final LibraryItem item = items[index];
        final String subtitle = item.seriesName ?? '';
        return Card(
          child: InkWell(
            onTap: () => openGameDetail(context, item.id, title: item.title, coverPath: item.coverPath),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 60,
                    height: 80,
                    child: Hero(
                      tag: 'cover-${item.id}',
                      child: CoverImage(path: item.coverPath, title: item.title, borderRadius: 10, cacheWidth: 160),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        if (item.isInCollection)
                          Text(
                            memberLabel(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                          ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            StatusChip(status: item.status, dense: true),
                            ConsoleBadges(labels: item.consoleLabels, trailing: item.releaseYear?.toString()),
                            for (final CopyFormat format in item.formats)
                              Icon(formatIcon(format), size: 16, color: theme.colorScheme.onSurfaceVariant),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  RatingBadge(rating: item.overallRating, size: 44),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Foglio filtri: ogni modifica si applica subito alla libreria.
class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LibraryQuery q = ref.watch(libraryQueryProvider);
    final FilterOptions? options = ref.watch(filterOptionsProvider).value;
    final int count = ref.watch(libraryItemsProvider).value?.length ?? 0;
    final ThemeData theme = Theme.of(context);
    void set(LibraryQuery value) => ref.read(libraryQueryProvider.notifier).set(value);

    Set<T> toggled<T>(Set<T> values, T value) =>
        values.contains(value) ? (Set<T>.of(values)..remove(value)) : (Set<T>.of(values)..add(value));

    Widget section(String title, List<Widget> chips, {String? note}) {
      if (chips.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: theme.textTheme.titleSmall),
            if (note != null)
              Text(note, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: chips),
          ],
        ),
      );
    }

    List<Widget> entryChips(List<CatalogEntry>? entries, Set<int> selected, LibraryQuery Function(Set<int>) apply) => <Widget>[
      for (final CatalogEntry e in entries ?? const <CatalogEntry>[])
        FilterChip(
          label: Text(e.name),
          selected: selected.contains(e.id),
          onSelected: (_) => set(apply(toggled(selected, e.id))),
        ),
    ];

    /// Sezione con l'elenco in un menu a parte: serie, sviluppatori e publisher
    /// sono centinaia e come file di pulsanti riempirebbero lo schermo.
    Widget pickerSection(
      String title,
      List<CatalogEntry>? entries,
      Set<int> selected,
      LibraryQuery Function(Set<int>) apply,
    ) {
      final List<CatalogEntry> all = entries ?? const <CatalogEntry>[];
      if (all.isEmpty) return const SizedBox.shrink();
      final List<CatalogEntry> chosen = all.where((CatalogEntry e) => selected.contains(e.id)).toList();
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final Set<int>? picked = await showModalBottomSheet<Set<int>>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  showDragHandle: true,
                  builder: (_) => _EntryPicker(title: title, entries: all, selected: selected),
                );
                if (picked != null) set(apply(picked));
              },
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                minimumSize: const Size.fromHeight(48),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      chosen.isEmpty
                          ? 'Tutti (${all.length})'
                          : chosen.length <= 2
                          ? chosen.map((CatalogEntry e) => e.name).join(', ')
                          : '${chosen.length} selezionati',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: chosen.isEmpty ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                        fontWeight: chosen.isEmpty ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (chosen.isNotEmpty)
                    IconButton(
                      tooltip: 'Azzera',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => set(apply(<int>{})),
                    ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (BuildContext context, ScrollController controller) => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
            child: Row(
              children: <Widget>[
                Expanded(child: Text('Filtri', style: theme.textTheme.titleLarge)),
                TextButton(
                  onPressed: q.activeFilterCount == 0 ? null : () => set(q.withoutFilters()),
                  child: const Text('Azzera i filtri'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mostra i giochi nelle collection'),
                  subtitle: const Text('Anche i singoli giochi contenuti, come voci separate.'),
                  value: q.effectiveShowChildren,
                  onChanged: q.kind == LibraryKind.soloContenuti
                      ? null
                      : (bool value) => set(q.copyWith(showChildren: value)),
                ),
                Text(
                  'Le sezioni diverse si sommano. Console e formato si applicano alla stessa copia.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                section('Stato di completamento', <Widget>[
                  for (final GameStatus s in GameStatus.values)
                    FilterChip(
                      avatar: Icon(statusVisual(s, theme.brightness).icon, size: 18),
                      label: Text(statusVisual(s, theme.brightness).label),
                      selected: q.statuses.contains(s),
                      onSelected: (_) => set(q.copyWith(statuses: toggled(q.statuses, s))),
                    ),
                ]),
                section('Formato', <Widget>[
                  for (final CopyFormat f in CopyFormat.values)
                    FilterChip(
                      avatar: Icon(formatIcon(f), size: 18),
                      label: Text(formatLabel(f)),
                      selected: q.formats.contains(f),
                      onSelected: (_) => set(q.copyWith(formats: toggled(q.formats, f))),
                    ),
                ]),
                section('Giocatori', <Widget>[
                  for (final int n in const <int>[1, 2, 4])
                    FilterChip(
                      avatar: const Icon(Icons.group_outlined, size: 18),
                      label: Text(n == 1 ? '1 giocatore' : 'Fino a $n'),
                      selected: q.players.contains(n),
                      onSelected: (_) => set(q.copyWith(players: toggled(q.players, n))),
                    ),
                ]),
                section('Console', entryChips(options?.consoles, q.consoleIds, (Set<int> v) => q.copyWith(consoleIds: v))),
                section('Genere', entryChips(options?.genres, q.genreIds, (Set<int> v) => q.copyWith(genreIds: v))),
                pickerSection('Serie', options?.series, q.seriesIds, (Set<int> v) => q.copyWith(seriesIds: v)),
                pickerSection(
                  'Sviluppatore',
                  options?.developers,
                  q.developerIds,
                  (Set<int> v) => q.copyWith(developerIds: v),
                ),
                pickerSection(
                  'Publisher',
                  options?.publishers,
                  q.publisherIds,
                  (Set<int> v) => q.copyWith(publisherIds: v),
                ),
                section('Caratteristiche', note: 'Devono essere presenti tutte quelle selezionate.', <Widget>[
                  for (final (GameFlag flag, String label) in const <(GameFlag, String)>[
                    (GameFlag.rigiocabile, 'Rigiocabile'),
                    (GameFlag.postGame, 'Post-game'),
                    (GameFlag.achievement, 'Achievement'),
                    (GameFlag.tuttiAchievement, 'Tutti gli achievement'),
                    (GameFlag.dlc, 'DLC'),
                  ])
                    FilterChip(
                      label: Text(label),
                      selected: q.flags.contains(flag),
                      onSelected: (_) => set(q.copyWith(flags: toggled(q.flags, flag))),
                    ),
                ]),
                section('Tipo', <Widget>[
                  for (final (LibraryKind kind, String label) in const <(LibraryKind, String)>[
                    (LibraryKind.tutti, 'Tutti'),
                    (LibraryKind.soloSingoli, 'Giochi singoli'),
                    (LibraryKind.soloCollection, 'Collection'),
                    (LibraryKind.soloContenuti, 'Giochi contenuti'),
                  ])
                    ChoiceChip(
                      label: Text(label),
                      selected: q.kind == kind,
                      onSelected: (_) => set(q.copyWith(kind: kind)),
                    ),
                ]),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(count == 1 ? 'Vedi 1 gioco' : 'Vedi $count giochi'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Elenco a parte per le sezioni di filtro con troppe voci: ricerca in cima e
/// caselle da spuntare. Restituisce la nuova selezione, o `null` se si annulla.
class _EntryPicker extends StatefulWidget {
  const _EntryPicker({required this.title, required this.entries, required this.selected});

  final String title;
  final List<CatalogEntry> entries;
  final Set<int> selected;

  @override
  State<_EntryPicker> createState() => _EntryPickerState();
}

class _EntryPickerState extends State<_EntryPicker> {
  late Set<int> _selected = Set<int>.of(widget.selected);
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String query = normalize(_search.text);
    // Prima le voci scelte, così restano sotto gli occhi anche in un elenco lungo.
    final List<CatalogEntry> visible =
        widget.entries.where((CatalogEntry e) => query.isEmpty || normalize(e.name).contains(query)).toList()
          ..sort((CatalogEntry a, CatalogEntry b) {
            final bool sa = _selected.contains(a.id);
            final bool sb = _selected.contains(b.id);
            return sa == sb ? 0 : (sa ? -1 : 1);
          });

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (BuildContext context, ScrollController controller) => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(widget.title, style: Theme.of(context).textTheme.titleLarge)),
                TextButton(
                  onPressed: _selected.isEmpty ? null : () => setState(() => _selected = <int>{}),
                  child: const Text('Azzera'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(hintText: 'Cerca', prefixIcon: Icon(Icons.search)),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('Nessun risultato.'))
                : ListView.builder(
                    controller: controller,
                    itemCount: visible.length,
                    itemBuilder: (BuildContext context, int index) {
                      final CatalogEntry entry = visible[index];
                      return CheckboxListTile(
                        value: _selected.contains(entry.id),
                        title: Text(entry.name),
                        onChanged: (bool? on) => setState(() {
                          if (on ?? false) {
                            _selected.add(entry.id);
                          } else {
                            _selected.remove(entry.id);
                          }
                        }),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_selected),
                  child: Text(_selected.isEmpty ? 'Fatto' : 'Applica (${_selected.length})'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
