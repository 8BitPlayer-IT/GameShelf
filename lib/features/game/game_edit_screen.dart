import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/catalog_repository.dart';
import '../../data/cover_service.dart';
import '../../data/database.dart';
import '../../data/game_repository.dart';
import '../../domain/enums.dart';
import '../../domain/game_draft.dart';
import '../../domain/normalizer.dart';
import '../../ui/console_icons.dart';
import '../../ui/widgets.dart';
import 'cover_crop_screen.dart';
import 'cover_proposal.dart';

class GameEditScreen extends ConsumerStatefulWidget {
  const GameEditScreen({super.key, this.gameId, this.collectionId});

  /// Gioco da modificare; `null` per crearne uno nuovo.
  final int? gameId;

  /// Per un gioco nuovo: la collection in cui va inserito subito.
  final int? collectionId;

  @override
  ConsumerState<GameEditScreen> createState() => _GameEditScreenState();
}

class _GameEditScreenState extends ConsumerState<GameEditScreen> {
  GameDraft? _draft;
  String? _originalCover;
  bool _dirty = false;
  bool _saving = false;
  bool _processingCover = false;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _year = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final int? id = widget.gameId;
    final GameDraft draft = id == null
        ? GameDraft(collectionIds: <int>[?widget.collectionId])
        : await ref.read(gameRepositoryProvider).loadDraft(id);
    if (!mounted) return;
    setState(() {
      _draft = draft;
      _originalCover = draft.coverPath;
      _title.text = draft.title;
      _year.text = draft.releaseYear?.toString() ?? '';
    });
  }

  void _edit(void Function(GameDraft draft) change) {
    setState(() {
      change(_draft!);
      _dirty = true;
    });
  }

  /// Chiude la schermata dopo aver disattivato la protezione delle modifiche:
  /// PopScope legge `canPop` dall'ultima costruzione, quindi va aspettato un frame.
  void _close() {
    setState(() => _dirty = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _save() async {
    final GameDraft draft = _draft!;
    draft.title = _title.text;
    final String yearText = _year.text.trim();
    draft.releaseYear = yearText.isEmpty ? null : int.tryParse(yearText);
    if (yearText.isNotEmpty && draft.releaseYear == null) {
      showMessage(context, 'L\'anno di uscita deve essere un numero.');
      return;
    }
    final List<String> errors = draft.validate(currentYear: DateTime.now().year);
    if (errors.isNotEmpty) {
      HapticFeedback.vibrate();
      showMessage(context, errors.first);
      return;
    }

    setState(() => _saving = true);

    // Copertina online: solo per un gioco nuovo che non ne ha ancora una, e
    // prima di scrivere sul database, così la copertina entra insieme al resto
    // in una sola scrittura. La proposta automatica avviene una volta sola,
    // alla nascita del gioco: dopo c'è il pulsante «Cerca online».
    bool noCoverFound = false;
    if (draft.id == null && draft.coverPath == null) {
      final ({bool applied, bool nothingFound}) outcome = await _proposeCover(draft);
      if (!mounted) return;
      noCoverFound = outcome.nothingFound;
    }

    try {
      await ref.read(gameRepositoryProvider).save(draft);
      if (_originalCover != null && _originalCover != draft.coverPath) {
        await ref.read(coverServiceProvider).delete(_originalCover);
      }
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      final String saved = draft.id == null
          ? '«${draft.title.trim()}» aggiunto alla libreria'
          : 'Modifiche salvate';
      showMessage(context, noCoverFound ? '$saved. Nessuna copertina trovata.' : saved);
      _close();
    } catch (error) {
      if (mounted) showMessage(context, describeSaveError(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _discard() async {
    final GameDraft? draft = _draft;
    // Una copertina scelta ma mai salvata non deve restare orfana su disco.
    if (draft != null && draft.coverPath != _originalCover) {
      await ref.read(coverServiceProvider).delete(draft.coverPath);
    }
    _close();
  }

  /// Spegne il fuoco prima di aprire un foglio o una finestra, e dopo averla
  /// chiusa.
  ///
  /// Chiudendo un foglio Flutter restituisce il fuoco al campo che ce l'aveva
  /// prima - di solito «Anno di uscita», l'ultimo campo di testo sopra le
  /// console - e la tastiera che riappare si trascina dietro la pagina fin
  /// lassù. Spento il fuoco non c'è niente da restituire, e la pagina resta
  /// dov'era.
  void _dropFocus() {
    if (mounted) FocusScope.of(context).unfocus();
  }

  Future<void> _pickCover() async {
    _dropFocus();
    final CoverService covers = ref.read(coverServiceProvider);
    try {
      final String? source = await covers.pickImage();
      if (source == null || !mounted) return;
      final Rect? region = await Navigator.of(context).push<Rect>(
        skinnedRoute<Rect>((_) => CoverCropScreen(imagePath: source), fullscreenDialog: true),
      );
      if (region == null || !mounted) return;

      setState(() => _processingCover = true);
      final String relative = await covers.saveCrop(source, region);
      final String? previous = _draft!.coverPath;
      if (previous != null && previous != _originalCover) await covers.delete(previous);
      _edit((GameDraft d) => d.coverPath = relative);
    } catch (error) {
      debugPrint('Errore copertina: $error');
      if (mounted) {
        showMessage(context, 'Non è stato possibile usare questa immagine (${error.runtimeType}). Riprova, oppure scegline un\'altra.');
      }
    } finally {
      if (mounted) setState(() => _processingCover = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final GameDraft? draft = _draft;
    final bool creating = widget.gameId == null;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final bool? leave = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Uscire senza salvare?'),
            content: const Text('Le modifiche fatte a questa scheda andranno perse.'),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Continua a modificare')),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Esci senza salvare')),
            ],
          ),
        );
        if (leave == true) await _discard();
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: const SkinBarBackground(),
          title: Text(
            creating ? (widget.collectionId == null ? 'Nuovo gioco' : 'Nuovo gioco contenuto') : 'Modifica gioco',
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                onPressed: draft == null || _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Salva'),
              ),
            ),
          ],
        ),
        body: draft == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: <Widget>[
                  _coverSection(draft),
                  const SizedBox(height: 12),
                  _infoSection(draft),
                  const SizedBox(height: 12),
                  _copiesSection(draft),
                  const SizedBox(height: 12),
                  _platformsSection(draft),
                  const SizedBox(height: 12),
                  _statusSection(draft),
                  const SizedBox(height: 12),
                  _featuresSection(draft),
                  const SizedBox(height: 12),
                  if (draft.isCollection) _collectionRatingNote() else _ratingSection(draft),
                  const SizedBox(height: 12),
                  _collectionSection(draft),
                ],
              ),
      ),
    );
  }

  /// I nomi delle console del gioco: prima quelle delle copie possedute, poi
  /// quelle di uscita. La ricerca segue le fonti della prima che ne ha.
  List<String> _consoleNames(GameDraft draft) {
    final Map<int, ConsoleRow> consoles = <int, ConsoleRow>{
      for (final ConsoleRow c in ref.read(consolesProvider).value ?? const <ConsoleRow>[]) c.id: c,
    };
    final List<String> names = <String>[];
    for (final int id in <int>[
      for (final CopyDraft c in draft.copies) c.consoleId,
      ...draft.platformIds,
    ]) {
      final String? name = consoles[id]?.name;
      if (name != null && !names.contains(name)) names.add(name);
    }
    return names;
  }

  /// Cerca la copertina online e, se l'utente accetta la proposta, la salva e
  /// la mette nel draft.
  ///
  /// `nothingFound` è vero solo quando la ricerca è davvero avvenuta e non ha
  /// dato niente: senza rete resta falso e non si dice nulla.
  Future<({bool applied, bool nothingFound})> _proposeCover(GameDraft draft) async {
    final CoverLookup lookup = await lookupCover(
      ref.read(onlineCoverServiceProvider),
      title: draft.title,
      consoles: _consoleNames(draft),
    );
    if (!mounted) return (applied: false, nothingFound: false);

    final CoverProposal? proposal = lookup.proposal;
    if (proposal == null) return (applied: false, nothingFound: lookup.worthTelling);
    if (!await showCoverProposal(context, proposal)) return (applied: false, nothingFound: false);

    final String relative = await ref.read(coverServiceProvider).saveDownloaded(proposal.bytes);
    draft.coverPath = relative;
    return (applied: true, nothingFound: false);
  }

  /// Il pulsante «Cerca online», per i giochi già in libreria.
  Future<void> _searchCoverOnline() async {
    _dropFocus();
    final GameDraft? draft = _draft;
    if (draft == null) return;
    draft.title = _title.text;
    if (draft.title.trim().isEmpty) {
      showMessage(context, 'Scrivi prima il titolo del gioco.');
      return;
    }

    setState(() => _processingCover = true);
    try {
      final ({bool applied, bool nothingFound}) outcome = await _proposeCover(draft);
      if (!mounted) return;
      if (outcome.nothingFound) showMessage(context, 'Nessuna copertina trovata');
    } finally {
      if (mounted) setState(() => _processingCover = false);
    }
  }

  Widget _coverSection(GameDraft draft) {
    return SectionCard(
      title: 'Copertina',
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 96,
            height: 128,
            child: _processingCover
                ? const Center(child: CircularProgressIndicator())
                : CoverImage(
                    path: draft.coverPath,
                    title: _title.text.isEmpty ? '?' : _title.text,
                    borderRadius: 14,
                    cacheWidth: 300,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: _pickCover,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Scegli dalla galleria'),
                ),
                if (draft.coverPath == null)
                  TextButton.icon(
                    onPressed: _processingCover ? null : _searchCoverOnline,
                    icon: const Icon(Icons.travel_explore),
                    label: const Text('Cerca online'),
                  ),
                if (draft.coverPath != null)
                  TextButton.icon(
                    onPressed: () => _edit((GameDraft d) => d.coverPath = null),
                    icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                    label: Text('Rimuovi', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection(GameDraft draft) {
    final List<String> seriesNames = <String>[
      for (final CatalogEntry e in ref.watch(seriesProvider).value ?? const <CatalogEntry>[]) e.name,
    ];
    final List<String> companyNames = <String>[
      for (final CatalogEntry e in ref.watch(companiesProvider).value ?? const <CatalogEntry>[]) e.name,
    ];
    final List<CatalogEntry> genres = ref.watch(genresProvider).value ?? const <CatalogEntry>[];

    return SectionCard(
      title: 'Informazioni',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _title,
            autofocus: widget.gameId == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Titolo *'),
            onChanged: (_) => setState(() => _dirty = true),
          ),
          const SizedBox(height: 12),
          _NameField(
            label: 'Serie',
            initial: draft.seriesName,
            options: seriesNames,
            onChanged: (String v) => _edit((GameDraft d) => d.seriesName = v),
          ),
          const SizedBox(height: 12),
          _NameField(
            label: 'Sviluppatore',
            initial: draft.developerName,
            options: companyNames,
            onChanged: (String v) => _edit((GameDraft d) => d.developerName = v),
          ),
          const SizedBox(height: 12),
          _NameField(
            label: 'Publisher',
            initial: draft.publisherName,
            options: companyNames,
            onChanged: (String v) => _edit((GameDraft d) => d.publisherName = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _year,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: const InputDecoration(labelText: 'Anno di uscita', helperText: 'Lascialo vuoto se non lo sai'),
            onChanged: (_) => setState(() => _dirty = true),
          ),
          const SizedBox(height: 16),
          Text('Generi', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final CatalogEntry genre in genres)
                FilterChip(
                  label: Text(genre.name),
                  selected: draft.genreIds.contains(genre.id),
                  onSelected: (bool selected) => _edit((GameDraft d) {
                    d.genreIds = Set<int>.of(d.genreIds);
                    selected ? d.genreIds.add(genre.id) : d.genreIds.remove(genre.id);
                  }),
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Nuovo genere'),
                onPressed: _newGenre,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _newGenre() async {
    final String? name = await _askText(title: 'Nuovo genere', label: 'Nome del genere');
    if (name == null || name.trim().isEmpty) return;
    final int id = await ref.read(catalogRepositoryProvider).genreIdFor(name);
    _edit((GameDraft d) => d.genreIds = <int>{...d.genreIds, id});
  }

  Widget _copiesSection(GameDraft draft) {
    final ThemeData theme = Theme.of(context);
    final Map<int, ConsoleRow> consoles = <int, ConsoleRow>{
      for (final ConsoleRow c in ref.watch(consolesProvider).value ?? const <ConsoleRow>[]) c.id: c,
    };
    return SectionCard(
      title: 'Console e copie',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (draft.copies.isEmpty)
            Text(
              'Aggiungi le console su cui possiedi il gioco.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          for (final (int index, CopyDraft copy) in draft.copies.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  ConsoleIcon(
                    label: consoles[copy.consoleId]?.shortLabel ?? '',
                    family: consoles[copy.consoleId]?.family,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(consoles[copy.consoleId]?.name ?? '…', style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 6),
                        SegmentedButton<CopyFormat>(
                          showSelectedIcon: false,
                          segments: <ButtonSegment<CopyFormat>>[
                            for (final CopyFormat f in CopyFormat.values)
                              ButtonSegment<CopyFormat>(value: f, label: Text(formatLabel(f)), icon: Icon(formatIcon(f))),
                          ],
                          selected: <CopyFormat>{copy.format},
                          onSelectionChanged: (Set<CopyFormat> value) => _edit((GameDraft d) {
                            d.copies = List<CopyDraft>.of(d.copies)..[index] = copy.withFormat(value.first);
                          }),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Rimuovi copia',
                    icon: const Icon(Icons.close),
                    onPressed: () => _edit((GameDraft d) => d.copies = List<CopyDraft>.of(d.copies)..removeAt(index)),
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _addConsole(consoles.values.toList()),
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi console'),
            ),
          ),
        ],
      ),
    );
  }

  /// Console di uscita originale: un'informazione sul gioco, non una copia.
  Widget _platformsSection(GameDraft draft) {
    final ThemeData theme = Theme.of(context);
    final Map<int, ConsoleRow> consoles = <int, ConsoleRow>{
      for (final ConsoleRow c in ref.watch(consolesProvider).value ?? const <ConsoleRow>[]) c.id: c,
    };
    return SectionCard(
      title: 'Console di uscita',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Dove il gioco è uscito in origine, se diverso dalle copie che possiedi. '
            'Non conta come copia nelle statistiche.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final int id in draft.platformIds)
                InputChip(
                  avatar: ConsoleIcon(label: consoles[id]?.shortLabel ?? '', family: consoles[id]?.family, size: 18),
                  label: Text(consoles[id]?.name ?? '…'),
                  onDeleted: () => _edit((GameDraft d) => d.platformIds = List<int>.of(d.platformIds)..remove(id)),
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Aggiungi console'),
                onPressed: () => _addPlatform(consoles.values.toList()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<int?> _pickConsole(List<ConsoleRow> consoles, {required Set<int> disabled, required String disabledLabel}) async {
    _dropFocus();
    final Object? picked = await showModalBottomSheet<Object>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) =>
          _ConsolePicker(consoles: consoles, disabled: disabled, disabledLabel: disabledLabel),
    );
    _dropFocus();
    if (picked is int) return picked;
    if (picked == 'new') return _newConsole();
    return null;
  }

  Future<void> _addPlatform(List<ConsoleRow> consoles) async {
    final int? id = await _pickConsole(consoles, disabled: _draft!.platformIds.toSet(), disabledLabel: 'già aggiunta');
    if (id == null || _draft!.platformIds.contains(id)) return;
    _edit((GameDraft d) => d.platformIds = <int>[...d.platformIds, id]);
  }

  Future<void> _addConsole(List<ConsoleRow> consoles) async {
    final GameDraft draft = _draft!;
    final Set<int> full = <int>{
      for (final ConsoleRow c in consoles)
        if (CopyFormat.values.every((CopyFormat f) => draft.copies.contains(CopyDraft(consoleId: c.id, format: f))))
          c.id,
    };
    final int? consoleId = await _pickConsole(
      consoles,
      disabled: full,
      disabledLabel: 'già aggiunta in entrambi i formati',
    );
    if (consoleId == null) return;
    final int id = consoleId;
    final bool hasPhysical = draft.copies.contains(CopyDraft(consoleId: id, format: CopyFormat.fisico));
    final CopyFormat format = hasPhysical ? CopyFormat.digitale : CopyFormat.fisico;
    if (draft.copies.contains(CopyDraft(consoleId: id, format: format))) return;
    _edit((GameDraft d) => d.copies = <CopyDraft>[...d.copies, CopyDraft(consoleId: id, format: format)]);
  }

  Future<int?> _newConsole() async {
    final TextEditingController name = TextEditingController();
    final TextEditingController label = TextEditingController();
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Nuova console'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Nome esteso')),
            const SizedBox(height: 12),
            TextField(
              controller: label,
              maxLength: 10,
              decoration: const InputDecoration(labelText: 'Sigla', helperText: 'Es. PS5, Switch'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annulla')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Aggiungi')),
        ],
      ),
    );
    final String nameText = name.text.trim();
    final String labelText = label.text.trim().isEmpty ? nameText : label.text.trim();
    name.dispose();
    label.dispose();
    if (ok != true || nameText.isEmpty) return null;
    try {
      return await ref
          .read(catalogRepositoryProvider)
          .consoleIdFor(name: nameText, shortLabel: labelText.length > 10 ? labelText.substring(0, 10) : labelText);
    } catch (error) {
      if (mounted) showMessage(context, describeSaveError(error));
      return null;
    }
  }

  Widget _statusSection(GameDraft draft) {
    final Brightness brightness = Theme.of(context).brightness;
    return SectionCard(
      title: 'Stato di completamento',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final GameStatus s in GameStatus.values)
                ChoiceChip(
                  avatar: Icon(statusVisual(s, brightness).icon, size: 18, color: statusVisual(s, brightness).color),
                  label: Text(statusVisual(s, brightness).label),
                  selected: draft.status == s,
                  showCheckmark: false,
                  onSelected: (_) => _edit((GameDraft d) => d.status = s),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            statusVisual(draft.status, brightness).description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _featuresSection(GameDraft draft) {
    Widget flag(String title, String subtitle, IconData icon, bool value, void Function(GameDraft, bool) set) {
      return SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: (bool v) => _edit((GameDraft d) => set(d, v)),
      );
    }

    return SectionCard(
      title: 'Caratteristiche',
      child: Column(
        children: <Widget>[
          flag('Rigiocabile', 'New Game+ o sfide infinite', Icons.replay, draft.isReplayable,
              (GameDraft d, bool v) => d.isReplayable = v),
          flag('Post-game', 'Contenuti dopo i titoli di coda', Icons.more_time, draft.hasPostGame,
              (GameDraft d, bool v) => d.hasPostGame = v),
          flag('Achievement', 'Ha trofei o obiettivi da sbloccare', Icons.emoji_events_outlined,
              draft.hasAchievements, (GameDraft d, bool v) {
            d.hasAchievements = v;
            if (!v) d.allAchievementsUnlocked = false;
          }),
          if (draft.hasAchievements)
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: flag('Tutti gli achievement sbloccati', 'Collezione completa', Icons.military_tech,
                  draft.allAchievementsUnlocked, (GameDraft d, bool v) => d.allAchievementsUnlocked = v),
            ),
          flag('DLC', 'Ha contenuti scaricabili', Icons.extension_outlined, draft.hasDlc,
              (GameDraft d, bool v) => d.hasDlc = v),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Icon(Icons.group_outlined),
              const SizedBox(width: 16),
              const Expanded(child: Text('Giocatori')),
              for (final int n in const <int>[1, 2, 4])
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    label: Text('${n}G'),
                    selected: draft.players == n,
                    onSelected: (bool selected) => _edit((GameDraft d) => d.players = selected ? n : null),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratingSection(GameDraft draft) {
    final ThemeData theme = Theme.of(context);
    // Il cursore sta sotto al nome della categoria, a tutta larghezza: accanto
    // all'etichetta era troppo corto per scegliere il mezzo punto giusto.
    Widget row(String label, double? value, void Function(GameDraft, double?) set) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
                if (value == null)
                  TextButton(onPressed: () => _edit((GameDraft d) => set(d, 5)), child: const Text('Valuta'))
                else ...<Widget>[
                  Text(formatHalf(value), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  IconButton(
                    tooltip: 'Rimuovi voto',
                    iconSize: 18,
                    onPressed: () => _edit((GameDraft d) => set(d, null)),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ],
            ),
            if (value != null)
              SliderTheme(
                data: SliderTheme.of(context).copyWith(trackHeight: 6),
                child: Slider(
                  value: value,
                  max: 10,
                  divisions: 20,
                  label: formatHalf(value),
                  onChanged: (double v) => _edit((GameDraft d) => set(d, v)),
                ),
              ),
          ],
        ),
      );
    }

    return SectionCard(
      title: 'Valutazione',
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(formatRating(draft.overall), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          Text(
            draft.ratedCount == 0 ? 'Non valutato' : 'media di ${draft.ratedCount} su 4',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          row('Storia', draft.ratingStory, (GameDraft d, double? v) => d.ratingStory = v),
          row('Gameplay', draft.ratingGameplay, (GameDraft d, double? v) => d.ratingGameplay = v),
          row('Grafica', draft.ratingGraphics, (GameDraft d, double? v) => d.ratingGraphics = v),
          row('Colonna sonora', draft.ratingSoundtrack, (GameDraft d, double? v) => d.ratingSoundtrack = v),
        ],
      ),
    );
  }

  Widget _collectionRatingNote() {
    final ThemeData theme = Theme.of(context);
    return SectionCard(
      title: 'Valutazione',
      child: Row(
        children: <Widget>[
          Icon(Icons.functions, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Il voto di una collection è la media dei voti dei giochi che contiene: valutali dalle loro schede.'),
          ),
        ],
      ),
    );
  }

  Widget _collectionSection(GameDraft draft) {
    final ThemeData theme = Theme.of(context);
    final List<(int, String)> collections = ref.watch(collectionsProvider).value ?? const <(int, String)>[];
    final Map<int, String> titles = <int, String>{for (final (int id, String title) in collections) id: title};
    // Una raccolta non può stare dentro un'altra raccolta, e viceversa.
    final bool canBeCollection = draft.collectionIds.isEmpty;
    final List<(int, String)> available = collections
        .where(((int, String) c) => c.$1 != draft.id && !draft.collectionIds.contains(c.$1))
        .toList();

    return SectionCard(
      title: 'Collection',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (!draft.isCollection) ...<Widget>[
            Text(
              'Raccolte che contengono questo gioco. Puoi aggiungerlo a più di una e '
              'tenere comunque le tue copie: resta un gioco solo, con un solo voto.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final int id in draft.collectionIds)
                  InputChip(
                    avatar: const Icon(Icons.layers_outlined, size: 18),
                    label: Text(titles[id] ?? '…'),
                    onDeleted: () =>
                        _edit((GameDraft d) => d.collectionIds = List<int>.of(d.collectionIds)..remove(id)),
                  ),
                if (available.isNotEmpty)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: const Text('Aggiungi a una collection'),
                    onPressed: () => _addToCollection(available),
                  ),
              ],
            ),
            const Divider(height: 24),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.layers_outlined),
            title: const Text('Questo gioco è una collection'),
            subtitle: Text(
              canBeCollection
                  ? 'Contiene più giochi: dopo il salvataggio li aggiungi dalla sua scheda.'
                  : 'Non disponibile: questo gioco è già dentro un\'altra collection.',
            ),
            value: draft.isCollection,
            onChanged: canBeCollection ? (bool v) => _edit((GameDraft d) => d.isCollection = v) : null,
          ),
        ],
      ),
    );
  }

  Future<void> _addToCollection(List<(int, String)> available) async {
    _dropFocus();
    final int? picked = await showDialog<int>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: const Text('Aggiungi a una collection'),
        children: <Widget>[
          for (final (int id, String title) in available)
            SimpleDialogOption(onPressed: () => Navigator.of(context).pop(id), child: Text(title)),
        ],
      ),
    );
    if (picked == null) return;
    _edit((GameDraft d) => d.collectionIds = <int>[...d.collectionIds, picked]);
  }

  Future<String?> _askText({required String title, required String label}) async {
    _dropFocus();
    final TextEditingController controller = TextEditingController();
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: label),
          onSubmitted: (String v) => Navigator.of(context).pop(v),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annulla')),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Aggiungi')),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}

/// Campo con suggerimenti dal catalogo; un nome nuovo viene creato al salvataggio.
class _NameField extends StatelessWidget {
  const _NameField({required this.label, required this.initial, required this.options, required this.onChanged});

  final String label;
  final String initial;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: initial),
      optionsBuilder: (TextEditingValue value) {
        final String query = normalize(value.text);
        if (query.isEmpty) return const Iterable<String>.empty();
        return options.where((String o) => normalize(o).contains(query) && o != value.text).take(8);
      },
      onSelected: onChanged,
      fieldViewBuilder: (BuildContext context, TextEditingController controller, FocusNode focusNode, VoidCallback onSubmit) =>
          TextField(
            controller: controller,
            focusNode: focusNode,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: label),
            onChanged: onChanged,
          ),
    );
  }
}

class _ConsolePicker extends StatelessWidget {
  const _ConsolePicker({required this.consoles, required this.disabled, required this.disabledLabel});

  final List<ConsoleRow> consoles;

  /// Console non selezionabili (già aggiunte), con la spiegazione da mostrare.
  final Set<int> disabled;
  final String disabledLabel;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (BuildContext context, ScrollController controller) => ListView(
        controller: controller,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('Aggiungi console', style: Theme.of(context).textTheme.titleLarge),
          ),
          for (final ConsoleRow console in consoles)
            ListTile(
              enabled: !disabled.contains(console.id),
              leading: ConsoleIcon(label: console.shortLabel, family: console.family, size: 28),
              title: Text(console.name),
              subtitle: disabled.contains(console.id) ? Text(disabledLabel) : null,
              trailing: Text(console.shortLabel),
              onTap: () => Navigator.of(context).pop(console.id),
            ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Crea nuova console…'),
            onTap: () => Navigator.of(context).pop('new'),
          ),
        ],
      ),
    );
  }
}
