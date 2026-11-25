/// Ricerca in blocco delle copertine mancanti.
///
/// Serve per una libreria già piena: con il pulsante «Cerca online» nella
/// scheda di un gioco servirebbe aprire centinaia di schede a mano.
///
/// Qui le copertine trovate vengono applicate **da sole**, senza chiedere una
/// per una. Non è una scorciatoia: le fonti restituiscono solo corrispondenze
/// certe (vedi `title_match.dart`), quindi non c'è niente su cui decidere. Una
/// copertina che non piace si toglie dalla scheda del gioco come tutte.
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/cover_service.dart';
import '../../data/covers/online_cover_service.dart';
import '../../data/game_repository.dart';
import '../../ui/widgets.dart';

/// Pausa fra una richiesta e l'altra: i server che ci regalano le copertine
/// non vanno martellati, e 250 ms su qualche centinaio di giochi non cambiano
/// la vita a nessuno.
const Duration _politePause = Duration(milliseconds: 250);

class BulkCoverScreen extends ConsumerStatefulWidget {
  const BulkCoverScreen({super.key});

  @override
  ConsumerState<BulkCoverScreen> createState() => _BulkCoverScreenState();
}

class _BulkCoverScreenState extends ConsumerState<BulkCoverScreen> {
  Future<List<GameWithoutCover>>? _games;
  bool _running = false;
  bool _cancelled = false;
  bool _finished = false;
  int _done = 0;
  int _found = 0;
  String? _current;

  @override
  void initState() {
    super.initState();
    _games = ref.read(gameRepositoryProvider).gamesWithoutCover();
  }

  Future<void> _run(List<GameWithoutCover> games) async {
    setState(() {
      _running = true;
      _cancelled = false;
      _finished = false;
      _done = 0;
      _found = 0;
    });

    final OnlineCoverService service = ref.read(onlineCoverServiceProvider);
    final CoverService covers = ref.read(coverServiceProvider);
    final GameRepository repository = ref.read(gameRepositoryProvider);

    for (final GameWithoutCover game in games) {
      if (_cancelled || !mounted) break;
      setState(() => _current = game.title);
      try {
        final CoverSearchResult result = await service.search(game.title, consoles: game.consoles);
        final CoverCandidate? candidate = result.candidate;
        if (candidate != null) {
          final Uint8List? bytes = await service.download(candidate);
          if (bytes != null) {
            final String relative = await covers.saveDownloaded(bytes);
            await repository.setCover(game.id, relative);
            if (mounted) setState(() => _found++);
          }
        }
      } catch (_) {
        // Un gioco che va storto non ferma gli altri: alla fine si vede solo
        // che quello è rimasto senza copertina.
      }
      if (mounted) setState(() => _done++);
      await Future<void>.delayed(_politePause);
    }

    if (!mounted) return;
    setState(() {
      _running = false;
      _finished = true;
      _current = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Copertine mancanti'), flexibleSpace: const SkinBarBackground()),
      body: FutureBuilder<List<GameWithoutCover>>(
        future: _games,
        builder: (BuildContext context, AsyncSnapshot<List<GameWithoutCover>> snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Impossibile leggere la libreria',
              message: '${snapshot.error}',
            );
          }
          final List<GameWithoutCover>? games = snapshot.data;
          if (games == null) return const Center(child: CircularProgressIndicator());

          if (games.isEmpty) {
            return const EmptyState(
              icon: Icons.check_circle_outline,
              title: 'Nessuna copertina da cercare',
              message: 'Tutti i giochi della libreria hanno già la loro copertina.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              SectionCard(
                title: _finished ? 'Fatto' : '${games.length} giochi senza copertina',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_finished)
                      Text(
                        _found == 0
                            ? 'Nessuna copertina trovata. Succede: per le console più recenti le fonti sono poche.'
                            : 'Trovate $_found copertine su $_done giochi controllati.',
                        style: theme.textTheme.bodyMedium,
                      )
                    else if (_running)
                      _progress(theme, games.length)
                    else
                      Text(
                        'Cerca online una copertina per ogni gioco che non ne ha. Vengono applicate '
                        'solo le corrispondenze certe: i giochi su cui resta un dubbio restano '
                        'senza copertina.\n\n'
                        'Ogni copertina pesa qualche centinaio di kB, quindi su ${games.length} '
                        'giochi si possono scaricare diverse decine di MB: meglio con il wi-fi.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    const SizedBox(height: 16),
                    if (_running)
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _cancelled = true),
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: const Text('Interrompi'),
                      )
                    else
                      FilledButton.icon(
                        onPressed: () => _run(games),
                        icon: const Icon(Icons.travel_explore),
                        label: Text(_finished ? 'Cerca di nuovo' : 'Cerca le copertine'),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _progress(ThemeData theme, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LinearProgressIndicator(value: total == 0 ? null : _done / total),
        const SizedBox(height: 12),
        Text('$_done di $total · $_found trovate', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          _current ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
