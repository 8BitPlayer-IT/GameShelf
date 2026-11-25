import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../data/game_repository.dart';
import '../../ui/widgets.dart';

/// Unisce due voci che sono lo stesso gioco, per esempio Super Mario 64 inserito
/// una volta da solo e una dentro Super Mario 3D All-Stars.
///
/// La voce aperta è quella che resta: prende le copie, i generi, le console di
/// uscita e le appartenenze dell'altra, più i campi che qui sono vuoti.
Future<void> showMergeDialog(BuildContext context, WidgetRef ref, {required Game keep}) async {
  final GameRepository repository = ref.read(gameRepositoryProvider);
  final (int, String, int?)? other = await showDialog<(int, String, int?)>(
    context: context,
    builder: (BuildContext context) => _MergePicker(repository: repository, keep: keep),
  );
  if (other == null || !context.mounted) return;

  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Unire i due giochi?'),
      content: Text(
        'Resta «${keep.title}», che prende le copie, i generi, le console di uscita e le collection '
        'di «${other.$2}». I campi vuoti vengono riempiti con quelli dell\'altra voce. '
        '«${other.$2}» viene eliminato.',
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annulla')),
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Unisci')),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  try {
    final String? unusedCover = await repository.merge(keepId: keep.id, otherId: other.$1);
    await ref.read(coverServiceProvider).delete(unusedCover);
    if (context.mounted) showMessage(context, '«${other.$2}» unito a «${keep.title}»');
  } catch (error) {
    if (context.mounted) showMessage(context, describeSaveError(error));
  }
}

class _MergePicker extends StatefulWidget {
  const _MergePicker({required this.repository, required this.keep});

  final GameRepository repository;
  final Game keep;

  @override
  State<_MergePicker> createState() => _MergePickerState();
}

class _MergePickerState extends State<_MergePicker> {
  late Future<List<(int, String, int?)>> _results;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Si parte dal titolo del gioco aperto: il doppione di solito si chiama uguale.
    _search.text = widget.keep.title;
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() => _results = widget.repository.searchMergeCandidates(widget.keep.id, _search.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unisci con…'),
      content: SizedBox(
        width: 400,
        height: 420,
        child: Column(
          children: <Widget>[
            TextField(
              controller: _search,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Cerca il doppione', prefixIcon: Icon(Icons.search)),
              onChanged: (_) => setState(_load),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<(int, String, int?)>>(
                future: _results,
                builder: (BuildContext context, AsyncSnapshot<List<(int, String, int?)>> snapshot) {
                  final List<(int, String, int?)>? games = snapshot.data;
                  if (games == null) return const Center(child: CircularProgressIndicator());
                  if (games.isEmpty) return const Center(child: Text('Nessun gioco trovato.'));
                  return ListView.builder(
                    itemCount: games.length,
                    itemBuilder: (BuildContext context, int index) {
                      final (int id, String title, int? year) = games[index];
                      return ListTile(
                        title: Text(title),
                        subtitle: year == null ? null : Text('$year'),
                        onTap: () => Navigator.of(context).pop(games[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annulla')),
      ],
    );
  }
}
