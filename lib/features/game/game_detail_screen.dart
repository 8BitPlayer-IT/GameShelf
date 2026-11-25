import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/native_bridge.dart';
import '../../data/game_repository.dart';
import '../../domain/enums.dart';
import '../../ui/console_icons.dart';
import '../../ui/widgets.dart';
import '../library/library_screen.dart';
import 'add_to_collection_sheet.dart';
import 'merge_dialog.dart';

class GameDetailScreen extends ConsumerWidget {
  const GameDetailScreen({super.key, required this.gameId, this.previewTitle, this.previewCover});

  final int gameId;

  /// Titolo e copertina che chi apre la scheda ha già in mano: la libreria li
  /// sta mostrando, e passandoli qui l'intestazione si disegna nello stesso
  /// fotogramma in cui la rotta nasce, prima che il database risponda.
  ///
  /// Senza, il volo della copertina non parte proprio: Flutter cerca le due
  /// copertine da collegare nel fotogramma in cui la pagina nuova viene
  /// costruita, e in quel momento la scheda mostrava solo una rotella.
  final String? previewTitle;
  final String? previewCover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<GameDetails?> details = ref.watch(gameDetailsProvider(gameId));
    return details.when(
      skipLoadingOnReload: true,
      loading: () => Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            _CoverHeader(gameId: gameId, title: previewTitle ?? '', coverPath: previewCover),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 56),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: CircularProgressIndicator(color: skinOf(context).backdropAccent),
                ),
              ),
            ),
          ],
        ),
      ),
      error: (Object e, _) => Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.error_outline, title: 'Impossibile aprire il gioco', message: '$e'),
      ),
      data: (GameDetails? d) => d == null
          ? Scaffold(
              appBar: AppBar(),
              body: const EmptyState(
                icon: Icons.search_off,
                title: 'Gioco non trovato',
                message: 'Potrebbe essere stato eliminato.',
              ),
            )
          : _DetailView(details: d),
    );
  }
}

/// L'intestazione della scheda: copertina sfocata, velo nel colore dello sfondo
/// della grafica e copertina vera, quella che vola dalla libreria.
///
/// Non ha nessuna tinta piena: la coda sfuma fino a sparire, così sotto
/// ricomincia lo sfondo della grafica senza nessuna riga di stacco. La barra,
/// quando si richiude, se la ridipinge [_CollapsedBar].
class _CoverHeader extends StatelessWidget {
  const _CoverHeader({
    required this.gameId,
    required this.title,
    required this.coverPath,
    this.actions = const <Widget>[],
  });

  final int gameId;
  final String title;
  final String? coverPath;
  final List<Widget> actions;

  /// Altezza a tutta apertura e altezza della coda che sfuma nello sfondo.
  static const double expanded = 390;
  static const double _tail = 92;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SkinTokens tokens = skinOf(context);
    final bool skinned = tokens.skin != AppSkin.originale;
    final Color base = tokens.backdropBase;
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: expanded,
      // Trasparente, e senza il Material opaco che l'AppBar mette attorno allo
      // spazio flessibile: è quel rettangolo che tagliava di netto lo sfondo.
      backgroundColor: Colors.transparent,
      forceMaterialTransparency: true,
      title: Text(title),
      actions: actions,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                // Copertina sfocata e velo si mascherano INSIEME con una sola
                // rampa che arriva a zero prima del bordo: mascherarne una sola
                // sposterebbe il taglio invece di toglierlo.
                ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (Rect bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const <Color>[Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0x00FFFFFF)],
                    stops: <double>[0, (1 - _tail / bounds.height).clamp(0.0, 1.0), 1],
                  ).createShader(bounds),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                        child: Opacity(
                          opacity: theme.brightness == Brightness.dark ? 0.45 : 0.3,
                          child: CoverImage(path: coverPath, title: title, borderRadius: 0, cacheWidth: 200),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            // Sempre lo stesso colore, con l'alpha che scende:
                            // sfumare verso Colors.transparent vorrebbe dire
                            // sfumare verso il NERO trasparente, e a metà
                            // strada comparirebbe una banda grigia.
                            colors: <Color>[
                              base.withValues(alpha: 0.25),
                              base.withValues(alpha: 0.88),
                              base.withValues(alpha: 0),
                            ],
                            stops: const <double>[0, 0.66, 1],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Sulle grafiche con il titolo bianco serve un po' di buio in
                // alto, perché lì sopra adesso si vede lo sfondo chiaro.
                if (skinned)
                  const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[Color(0x73000F1E), Color(0x00000F1E)],
                          stops: <double>[0, 0.42],
                        ),
                      ),
                    ),
                  ),
                Align(
                  alignment: const Alignment(0, 0.22),
                  child: Container(
                    width: 165,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(color: Color(0x55000000), blurRadius: 24, offset: Offset(0, 10)),
                      ],
                    ),
                    child: Hero(
                      tag: 'cover-$gameId',
                      child: CoverImage(path: coverPath, title: title, borderRadius: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _CollapsedBar(),
        ],
      ),
    );
  }
}

/// La tinta della barra quando l'intestazione si richiude: compare man mano,
/// così la scheda ha la stessa barra di tutte le altre schermate senza che
/// l'intestazione aperta debba essere opaca.
class _CollapsedBar extends StatelessWidget {
  const _CollapsedBar();

  @override
  Widget build(BuildContext context) {
    final FlexibleSpaceBarSettings? settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    if (settings == null) return const SizedBox.shrink();
    final double span = settings.maxExtent - settings.minExtent;
    // 0 = tutta aperta, 1 = tutta richiusa.
    final double closed = span <= 0
        ? 1
        : (1 - (settings.currentExtent - settings.minExtent) / span).clamp(0.0, 1.0);
    if (closed < 0.01) return const SizedBox.shrink();
    final SkinTokens tokens = skinOf(context);
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: settings.minExtent,
          child: Opacity(
            opacity: Curves.easeIn.transform(closed),
            child: tokens.barGradient == null
                ? ColoredBox(color: Theme.of(context).colorScheme.surface)
                : const SkinBarBackground(),
          ),
        ),
      ),
    );
  }
}

class _DetailView extends ConsumerWidget {
  const _DetailView({required this.details});

  final GameDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final SkinTokens tokens = skinOf(context);
    final game = details.game;
    final String subtitle = <String>[
      ?details.seriesName,
      if (game.releaseYear != null) '${game.releaseYear}',
    ].join(' · ');

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          _CoverHeader(
            gameId: game.id,
            title: game.title,
            coverPath: game.coverPath,
            actions: <Widget>[
              IconButton(
                tooltip: 'Modifica',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => openGameEditor(context, gameId: game.id),
              ),
              PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'merge') showMergeDialog(context, ref, keep: game);
                  if (value == 'delete') _delete(context, ref);
                },
                itemBuilder: (_) => <PopupMenuEntry<String>>[
                  if (!game.isCollection)
                    const PopupMenuItem<String>(
                      value: 'merge',
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.merge),
                          SizedBox(width: 12),
                          Text('Unisci con un altro gioco…'),
                        ],
                      ),
                    ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.delete_outline, color: theme.colorScheme.error),
                        const SizedBox(width: 12),
                        Text('Elimina', style: TextStyle(color: theme.colorScheme.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
            sliver: SliverList.list(
              children: <Widget>[
                // Titolo, anno e stato stanno in un pannello come tutto il
                // resto della scheda: sullo sfondo nudo, su Aero, erano blu
                // notte su blu.
                SkinPanel(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        game.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: tokens.onPanel,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 8,
                        children: <Widget>[
                          StatusChip(status: details.status, onTap: () => _changeStatus(context, ref)),
                          _YouTubeSearchButton(title: game.title),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _ConsolesSection(details: details),
                const SizedBox(height: 12),
                _FeaturesSection(details: details),
                _RatingSection(details: details),
                const SizedBox(height: 12),
                _InfoSection(details: details),
                if (game.isCollection) ...<Widget>[const SizedBox(height: 12), _ItemsSection(details: details)],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeStatus(BuildContext context, WidgetRef ref) async {
    final Brightness brightness = Theme.of(context).brightness;
    final GameStatus? picked = await showModalBottomSheet<GameStatus>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            for (final GameStatus s in GameStatus.values)
              ListTile(
                leading: Icon(statusVisual(s, brightness).icon, color: statusVisual(s, brightness).color),
                title: Text(statusVisual(s, brightness).label),
                subtitle: Text(statusVisual(s, brightness).description),
                trailing: s == details.status ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(s),
              ),
          ],
        ),
      ),
    );
    if (picked == null || picked == details.status) return;
    await ref.read(gameRepositoryProvider).setStatus(details.game.id, picked);
    if (context.mounted) showMessage(context, 'Stato aggiornato: ${statusVisual(picked, brightness).label}');
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final int items = details.items.length;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Eliminare «${details.game.title}»?'),
        content: Text(
          items > 0
              ? 'I $items giochi che contiene restano in libreria: perdono solo questa appartenenza. '
                    'Potrai annullare subito dopo.'
              : 'Potrai annullare subito dopo.',
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annulla')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final GameRepository repository = ref.read(gameRepositoryProvider);
    final DeletedGameSnapshot snapshot = await repository.delete(details.game.id);
    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('«${snapshot.title}» eliminato'),
          duration: const Duration(seconds: 6),
          persist: false,
          action: SnackBarAction(label: 'ANNULLA', onPressed: () => repository.undoDelete(snapshot)),
        ),
      );
  }
}

/// Riga «icona della console · nome · (formato)».
class _ConsoleRow extends StatelessWidget {
  const _ConsoleRow({required this.label, required this.family, required this.name, this.format, this.dense = false});

  final String label;
  final String family;
  final String name;
  final CopyFormat? format;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CopyFormat? f = format;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 3 : 6),
      child: Row(
        children: <Widget>[
          ConsoleIcon(label: label, family: family, size: dense ? 22 : 28, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: dense ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge)),
          if (f != null) ...<Widget>[
            Icon(formatIcon(f), size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(formatLabel(f), style: TextStyle(color: theme.colorScheme.primary)),
          ],
        ],
      ),
    );
  }
}

class _ConsolesSection extends StatelessWidget {
  const _ConsolesSection({required this.details});

  final GameDetails details;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? note = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final bool nothing = details.copies.isEmpty && details.memberships.isEmpty;

    return SectionCard(
      title: 'Le tue copie',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (nothing) Text('Nessuna copia registrata.', style: note),
          for (final CopyView c in details.copies)
            _ConsoleRow(label: c.shortLabel, family: c.family, name: c.consoleName, format: c.format),

          // Le raccolte di cui il gioco fa parte: le possiedi tramite quelle.
          for (final MembershipView m in details.memberships) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 2),
              child: Text('Anche in «${m.title}»', style: note),
            ),
            for (final CopyView c in m.copies)
              _ConsoleRow(label: c.shortLabel, family: c.family, name: c.consoleName, format: c.format, dense: true),
          ],

          if (details.platforms.isNotEmpty) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 2),
              child: Text('Uscito in origine su', style: note),
            ),
            for (final ConsoleView p in details.platforms)
              _ConsoleRow(label: p.shortLabel, family: p.family, name: p.name, dense: true),
          ],
        ],
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.details});

  final GameDetails details;

  @override
  Widget build(BuildContext context) {
    final game = details.game;
    final List<(IconData, String)> flags = <(IconData, String)>[
      if (game.isReplayable) (Icons.replay, 'Rigiocabile'),
      if (game.hasPostGame) (Icons.more_time, 'Post-game'),
      if (game.hasAchievements && game.allAchievementsUnlocked) (Icons.military_tech, 'Tutti gli achievement'),
      if (game.hasAchievements && !game.allAchievementsUnlocked) (Icons.emoji_events_outlined, 'Achievement'),
      if (game.hasDlc) (Icons.extension_outlined, 'DLC'),
    ];
    if (flags.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        title: 'Caratteristiche',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final (IconData icon, String label) in flags) Chip(avatar: Icon(icon, size: 18), label: Text(label)),
          ],
        ),
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  const _RatingSection({required this.details});

  final GameDetails details;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final game = details.game;
    final double? rating = details.displayRating;
    final TextStyle? note = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    Widget bigNumber(String caption) => Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          formatRating(rating),
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: rating == null ? null : ratingColor(rating, theme.brightness),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 4),
          child: Text('/10', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(caption, textAlign: TextAlign.end, style: note),
          ),
        ),
      ],
    );

    // Il voto di una raccolta non si inserisce: è la media dei giochi contenuti.
    if (game.isCollection) {
      final int rated = details.ratedItems;
      return SectionCard(
        title: 'Valutazione',
        child: rating == null
            ? Text('Nessun gioco contenuto è ancora stato valutato.', style: note)
            : bigNumber('Media dei voti di $rated ${rated == 1 ? 'gioco contenuto' : 'giochi contenuti'}'),
      );
    }

    final List<(String, double?)> categories = <(String, double?)>[
      ('Storia', game.ratingStory),
      ('Gameplay', game.ratingGameplay),
      ('Grafica', game.ratingGraphics),
      ('Colonna sonora', game.ratingSoundtrack),
    ];
    final int rated = categories.where(((String, double?) c) => c.$2 != null).length;

    return SectionCard(
      title: 'Valutazione',
      child: rating == null
          ? Row(
              children: <Widget>[
                Icon(Icons.star_border, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                const Expanded(child: Text('Non hai ancora valutato questo gioco.')),
                TextButton(onPressed: () => openGameEditor(context, gameId: game.id), child: const Text('Valuta ora')),
              ],
            )
          : Column(
              children: <Widget>[
                bigNumber('Media di $rated ${rated == 1 ? 'categoria' : 'categorie'} su 4'),
                const SizedBox(height: 8),
                for (final (String label, double? value) in categories)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 120, child: Text(label)),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (value ?? 0) / 10,
                              minHeight: 8,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            value == null ? '—' : formatHalf(value),
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.details});

  final GameDetails details;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int? players = details.game.players;
    final List<(String, String)> rows = <(String, String)>[
      if (details.seriesName != null) ('Serie', details.seriesName!),
      if (details.game.releaseYear != null) ('Anno di uscita', '${details.game.releaseYear}'),
      if (details.developerName != null) ('Sviluppatore', details.developerName!),
      if (details.publisherName != null) ('Publisher', details.publisherName!),
      if (details.genres.isNotEmpty) ('Generi', details.genres.join(', ')),
      if (players != null) ('Giocatori', players == 1 ? '1 giocatore' : 'Fino a $players giocatori'),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: 'Informazioni',
      child: Column(
        children: <Widget>[
          for (final (String label, String value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 120, child: Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant))),
                  Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ItemsSection extends ConsumerWidget {
  const _ItemsSection({required this.details});

  final GameDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    // Gli arcade non si finiscono, quindi non entrano nel conto: stessa regola
    // della percentuale nelle statistiche. Se la collection ne contiene solo,
    // la riga non ha senso e sparisce.
    final List<ItemSummary> completable =
        details.items.where((ItemSummary i) => i.status.isCompletable).toList();
    final int done = completable.where((ItemSummary i) => i.status.isCompleted).length;
    return SectionCard(
      title: 'Giochi contenuti (${details.items.length})',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (completable.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '$done su ${completable.length} finiti o completati',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          for (final ItemSummary item in details.items)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => openGameDetail(context, item.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 48,
                      height: 64,
                      child: CoverImage(path: item.coverPath, title: item.title, borderRadius: 8, cacheWidth: 150),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (item.releaseYear != null || item.consoleLabels != null)
                            Text(
                              <String>[
                                if (item.releaseYear != null) '${item.releaseYear}',
                                ?item.consoleLabels,
                              ].join(' · '),
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          const SizedBox(height: 4),
                          StatusChip(status: item.status, dense: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    RatingBadge(rating: item.overallRating, size: 40),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => showAddToCollectionSheet(context, ref, collectionId: details.game.id),
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi un gioco alla collection'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cerca il gioco su YouTube con l'app di sistema.
///
/// Non è GameShelf ad andare in rete: l'indirizzo viene consegnato ad Android,
/// che lo apre nell'app di YouTube se è installata o nel browser se manca. Per
/// questo non serve il permesso INTERNET, e la ricerca funziona per qualunque
/// gioco — anche quelli del 1989 di cui nessun catalogo online sa niente.
class _YouTubeSearchButton extends StatelessWidget {
  const _YouTubeSearchButton({required this.title});

  final String title;

  static const Color _rosso = Color(0xFFCC0000);

  Future<void> _search(BuildContext context) async {
    final String query = Uri.encodeQueryComponent('$title gameplay');
    final bool aperto = await NativeBridge.openLink(
      'https://www.youtube.com/results?search_query=$query',
    );
    if (!aperto && context.mounted) {
      showMessage(context, 'Su questo telefono non c\'è niente che sappia aprire YouTube.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(skinOf(context).buttonRadius);
    return Material(
      color: _rosso,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => _search(context),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.smart_display, size: 18, color: Color(0xFFFFFFFF)),
              SizedBox(width: 6),
              Text(
                'Cerca su YouTube',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
