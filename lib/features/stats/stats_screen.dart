import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/stats_repository.dart';
import '../../domain/enums.dart';
import '../../ui/widgets.dart';

/// Una fetta: etichetta, valore e colore.
typedef Slice = (String, int, Color);

/// Colori delle fette quando non ne esiste uno di dominio (console, decenni).
/// L'ultimo è riservato alla voce «Altro».
const List<Color> _palette = <Color>[
  Color(0xFF5B8DEF),
  Color(0xFF59C3A3),
  Color(0xFFF2994A),
  Color(0xFFBB6BD9),
  Color(0xFFEB5757),
  Color(0xFF7E8794),
];

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<StatsSnapshot> stats = ref.watch(statsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiche'), flexibleSpace: const SkinBarBackground()),
      body: stats.when(
        skipLoadingOnReload: true,
        loading: () => Center(child: CircularProgressIndicator(color: skinOf(context).backdropAccent)),
        error: (Object e, _) =>
            EmptyState(icon: Icons.error_outline, title: 'Impossibile calcolare le statistiche', message: '$e'),
        data: (StatsSnapshot s) => s.games == 0 && s.copies == 0
            ? const EmptyState(
                icon: Icons.insights_outlined,
                title: 'Ancora nessuna statistica',
                message: 'Aggiungi qualche gioco alla libreria per vedere qui i grafici della collezione.',
              )
            : _StatsBody(stats: s),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});

  final StatsSnapshot stats;

  /// Le prime [keep] voci come fette, il resto raccolto in «Altro».
  (List<Slice>, List<CountEntry>) _topSlices(List<CountEntry> entries, {int keep = 5}) {
    final List<Slice> slices = <Slice>[
      for (final (int i, CountEntry e) in entries.take(keep).indexed) (e.label, e.count, _palette[i % 5]),
    ];
    final int rest = entries.skip(keep).fold<int>(0, (int sum, CountEntry e) => sum + e.count);
    if (rest > 0) slices.add(('Altro', rest, _palette.last));
    return (slices, entries);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Brightness brightness = theme.brightness;

    final (List<Slice> consoleSlices, List<CountEntry> consoleAll) = _topSlices(stats.byConsole);
    final (List<Slice> decadeSlices, List<CountEntry> decadeAll) = _topSlices(
      <CountEntry>[
        for (final CountEntry e in stats.byDecade) CountEntry('Anni ${e.label}', e.count),
      ],
      keep: 6,
    );

    const List<String> tierLabels = <String>[
      'Sotto il 5',
      'Da 5 a 6,9',
      'Da 7 a 7,9',
      'Da 8 a 8,9',
      'Da 9 a 9,9',
      'Voto 10',
    ];
    const List<double> tierSample = <double>[4, 6, 7.5, 8.5, 9.5, 10];
    final List<Slice> ratingSlices = <Slice>[
      for (final (int i, int count) in stats.ratingTiers.indexed)
        (tierLabels[i], count, ratingColor(tierSample[i], brightness)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: <Widget>[
        if (stats.games > 0 && stats.games < 5)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Con pochi giochi le statistiche sono poco significative.',
              style: skinOf(context).backdrop(theme.textTheme.bodySmall, muted: true),
            ),
          ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.7,
          children: <Widget>[
            _Kpi(icon: Icons.videogame_asset_outlined, value: '${stats.games}', label: 'Giochi'),
            _Kpi(icon: Icons.album_outlined, value: '${stats.copies}', label: 'Copie possedute'),
            _Kpi(icon: Icons.star_outline, value: formatRating(stats.averageRating), label: 'Voto medio'),
            _Kpi(icon: Icons.flag_outlined, value: '${stats.completedPercent}%', label: 'Finiti o completati'),
          ],
        ),
        const SizedBox(height: 12),
        _ChartCard(
          title: 'Stato di completamento',
          unit: stats.arcade > 0
              ? 'Conteggio: giochi · la percentuale dei finiti esclude i ${stats.arcade} arcade'
              : 'Conteggio: giochi',
          child: _Donut(
            slices: <Slice>[
              for (final GameStatus s in GameStatus.values)
                (statusVisual(s, brightness).label, stats.byStatus[s]!, statusVisual(s, brightness).color),
            ],
          ),
        ),
        _ChartCard(
          title: 'Console',
          unit: 'Conteggio: copie possedute — una collection conta come una copia',
          details: consoleAll.length > 5 ? _Table(entries: consoleAll) : null,
          child: _Donut(slices: consoleSlices),
        ),
        _ChartCard(
          title: 'Fisico e digitale',
          unit: 'Conteggio: copie possedute',
          child: _Donut(
            slices: <Slice>[
              ('Fisico', stats.physicalCopies, theme.colorScheme.primary),
              ('Digitale', stats.digitalCopies, theme.colorScheme.tertiary),
            ],
          ),
        ),
        if (stats.byGenre.isNotEmpty)
          _ChartCard(
            title: 'Generi più presenti',
            unit: 'Conteggio: giochi',
            child: _RankedBars(entries: stats.byGenre, color: theme.colorScheme.secondary),
          ),
        if (decadeSlices.isNotEmpty)
          _ChartCard(
            title: 'Anno di uscita',
            unit: 'Giochi per decennio',
            details: decadeAll.length > 6 ? _Table(entries: decadeAll) : null,
            child: _Donut(slices: decadeSlices),
          ),
        if (stats.ratingTiers.any((int v) => v > 0))
          _ChartCard(
            title: 'Distribuzione dei voti',
            unit:
                'Giochi valutati per fascia di voto'
                '${stats.unrated > 0 ? ' · ${stats.unrated} non valutati' : ''}',
            child: _Donut(slices: ratingSlices),
          ),
        if (stats.topSeries.isNotEmpty)
          _ChartCard(
            title: 'Serie',
            unit: 'Conteggio: giochi',
            child: _RankedBars(entries: stats.topSeries, color: theme.colorScheme.primary),
          ),
        if (stats.topDevelopers.isNotEmpty)
          _ChartCard(
            title: 'Sviluppatori',
            unit: 'Conteggio: giochi',
            child: _RankedBars(entries: stats.topDevelopers, color: theme.colorScheme.secondary),
          ),
        if (stats.topPublishers.isNotEmpty)
          _ChartCard(
            title: 'Publisher',
            unit: 'Conteggio: giochi',
            child: _RankedBars(entries: stats.topPublishers, color: theme.colorScheme.tertiary),
          ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(icon, color: theme.colorScheme.primary),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FittedBox(
                  child: Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                ),
                Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatefulWidget {
  const _ChartCard({required this.title, required this.unit, required this.child, this.details});

  final String title;
  final String unit;
  final Widget child;

  /// Elenco completo, mostrato solo se l'utente lo apre.
  final Widget? details;

  @override
  State<_ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<_ChartCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(widget.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text(widget.unit, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              widget.child,
              if (widget.details != null) ...<Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _open = !_open),
                    icon: Icon(_open ? Icons.expand_less : Icons.expand_more),
                    label: Text(_open ? 'Nascondi il dettaglio' : 'Mostra tutto'),
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 180),
                  crossFadeState: _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: widget.details!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Donut extends StatelessWidget {
  const _Donut({required this.slices});

  final List<Slice> slices;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Slice> visible = slices.where((Slice s) => s.$2 > 0).toList();
    final int total = visible.fold<int>(0, (int sum, Slice s) => sum + s.$2);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 132,
          height: 132,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  startDegreeOffset: -90,
                  sections: <PieChartSectionData>[
                    if (total == 0)
                      PieChartSectionData(
                        value: 1,
                        color: theme.colorScheme.surfaceContainerHighest,
                        radius: 24,
                        showTitle: false,
                      ),
                    for (final Slice s in visible)
                      PieChartSectionData(value: s.$2.toDouble(), color: s.$3, radius: 24, showTitle: false),
                  ],
                ),
              ),
              Text('$total', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: <Widget>[
              for (final Slice s in visible)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: <Widget>[
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: s.$3, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(s.$1, overflow: TextOverflow.ellipsis)),
                      Text('${s.$2}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(
                        width: 44,
                        child: Text(
                          total == 0 ? '' : '${(s.$2 * 100 / total).round()}%',
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Elenco completo in due colonne, sotto un grafico.
class _Table extends StatelessWidget {
  const _Table({required this.entries});

  final List<CountEntry> entries;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        for (final CountEntry e in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(e.label, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium)),
                Text('${e.count}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
      ],
    );
  }
}

class _RankedBars extends StatelessWidget {
  const _RankedBars({required this.entries, required this.color});

  final List<CountEntry> entries;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int top = entries.fold<int>(0, (int m, CountEntry e) => e.count > m ? e.count : m);
    if (entries.isEmpty) return const Text('Nessun dato.');
    return Column(
      children: <Widget>[
        for (final CountEntry e in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: <Widget>[
                SizedBox(width: 118, child: Text(e.label, overflow: TextOverflow.ellipsis)),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: top == 0 ? 0 : e.count / top,
                      minHeight: 12,
                      color: color,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text('${e.count}', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
