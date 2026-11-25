import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/game_repository.dart';
import '../../ui/widgets.dart';
import '../library/library_screen.dart';

/// Aggiunge giochi a una raccolta: creandone uno nuovo oppure scegliendone di già
/// presenti in libreria, così non serve inserirli due volte e unirli dopo.
Future<void> showAddToCollectionSheet(BuildContext context, WidgetRef ref, {required int collectionId}) async {
  final String? choice = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Crea un gioco nuovo'),
            subtitle: const Text('Compili la scheda e il gioco entra subito nella collection'),
            onTap: () => Navigator.of(context).pop('new'),
          ),
          ListTile(
            leading: const Icon(Icons.library_add_check_outlined),
            title: const Text('Scegli giochi già in libreria'),
            subtitle: const Text('Ne puoi selezionare più di uno: restano una voce sola'),
            onTap: () => Navigator.of(context).pop('existing'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (choice == null || !context.mounted) return;

  if (choice == 'new') {
    await openGameEditor(context, collectionId: collectionId);
    return;
  }

  final List<(int, String, int?)>? picked = await showDialog<List<(int, String, int?)>>(
    context: context,
    builder: (BuildContext context) =>
        _ExistingGamesPicker(repository: ref.read(gameRepositoryProvider), collectionId: collectionId),
  );
  if (picked == null || picked.isEmpty || !context.mounted) return;

  final GameRepository repository = ref.read(gameRepositoryProvider);
  for (final (int id, String _, int? _) in picked) {
    await repository.setMembership(id, collectionId, member: true);
  }
  if (context.mounted) {
    showMessage(
      context,
      picked.length == 1 ? '«${picked.single.$2}» aggiunto alla collection' : '${picked.length} giochi aggiunti',
    );
  }
}

class _ExistingGamesPicker extends StatefulWidget {
  const _ExistingGamesPicker({required this.repository, required this.collectionId});

  final GameRepository repository;
  final int collectionId;

  @override
  State<_ExistingGamesPicker> createState() => _ExistingGamesPickerState();
}

class _ExistingGamesPickerState extends State<_ExistingGamesPicker> {
  late Future<List<(int, String, int?)>> _results;
  final TextEditingController _search = TextEditingController();
  final Map<int, (int, String, int?)> _selected = <int, (int, String, int?)>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() => _results = widget.repository.searchGamesForCollection(widget.collectionId, _search.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scegli dalla libreria'),
      content: SizedBox(
        width: 400,
        height: 440,
        child: Column(
          children: <Widget>[
            TextField(
              controller: _search,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Cerca', prefixIcon: Icon(Icons.search)),
              onChanged: (_) => setState(_load),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<(int, String, int?)>>(
                future: _results,
                builder: (BuildContext context, AsyncSnapshot<List<(int, String, int?)>> snapshot) {
                  final List<(int, String, int?)>? games = snapshot.data;
                  if (games == null) return const Center(child: CircularProgressIndicator());
                  if (games.isEmpty) return const Center(child: Text('Nessun gioco disponibile.'));
                  return ListView.builder(
                    itemCount: games.length,
                    itemBuilder: (BuildContext context, int index) {
                      final (int id, String title, int? year) = games[index];
                      return CheckboxListTile(
                        value: _selected.containsKey(id),
                        title: Text(title),
                        subtitle: year == null ? null : Text('$year'),
                        onChanged: (bool? on) => setState(() {
                          if (on ?? false) {
                            _selected[id] = games[index];
                          } else {
                            _selected.remove(id);
                          }
                        }),
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
        FilledButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selected.values.toList()),
          child: Text(_selected.isEmpty ? 'Aggiungi' : 'Aggiungi ${_selected.length}'),
        ),
      ],
    );
  }
}
