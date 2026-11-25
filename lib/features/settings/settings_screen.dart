import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme.dart';
import '../../app/version.dart';
import '../../app/providers.dart';
import '../../core/native_bridge.dart';
import '../../data/backup_service.dart';
import '../../data/catalog_admin.dart';
import '../../data/settings_repository.dart';
import '../../ui/widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) showMessage(context, error is BackupException ? error.message : 'Operazione non riuscita: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<File> _exportToCache() async {
    final Directory cache = await getTemporaryDirectory();
    final File file = await ref.read(backupServiceProvider).export(cache.path);
    await ref.read(settingsRepositoryProvider).set(SettingsRepository.lastBackupAt, DateTime.now().toIso8601String());
    return file;
  }

  Future<void> _share() => _run(() async {
    final File file = await _exportToCache();
    await SharePlus.instance.share(
      ShareParams(files: <XFile>[XFile(file.path, mimeType: 'application/zip')], subject: 'Backup GameShelf'),
    );
  });

  Future<void> _saveToPhone() => _run(() async {
    final File file = await _exportToCache();
    // Il file viene copiato in streaming dal codice Android: va bene qualsiasi
    // dimensione, anche un backup da centinaia di megabyte.
    final String? uri = await NativeBridge.exportFile(path: file.path, fileName: p.basename(file.path));
    if (uri != null && mounted) showMessage(context, 'Backup salvato');
  });

  Future<void> _restore() => _run(() async {
    final PlatformFile? picked = await FilePicker.pickFile();
    if (picked == null) return;
    String? path = picked.path;
    if (path == null) {
      final Directory cache = await getTemporaryDirectory();
      final File copy = File(p.join(cache.path, 'backup_da_ripristinare.zip'));
      await copy.writeAsBytes(await picked.readAsBytes());
      path = copy.path;
    }
    if (!mounted) return;
    final int current = ref.read(statsProvider).value?.games ?? 0;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Ripristinare il backup?'),
        content: Text(
          'La libreria attuale${current > 0 ? ' ($current giochi)' : ''} verrà sostituita completamente '
          'dal contenuto di «${picked.name}».',
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annulla')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ripristina'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final BackupSummary summary = await ref.read(backupServiceProvider).import(path);
    if (mounted) showMessage(context, 'Ripristinati ${summary.games} giochi e ${summary.covers} copertine');
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ThemeMode mode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final AppSkin skin = ref.watch(appSkinProvider).value ?? AppSkin.originale;
    final String? lastBackup = ref.watch(lastBackupProvider).value;
    final DateTime? lastBackupDate = lastBackup == null ? null : DateTime.tryParse(lastBackup);

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(text, style: theme.textTheme.titleSmall?.copyWith(color: skinOf(context).backdropAccent, shadows: skinOf(context).backdropShadows)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni'), flexibleSpace: const SkinBarBackground()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: <Widget>[
          if (_busy) const LinearProgressIndicator(),
          header('Aspetto'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Stile'),
                  const SizedBox(height: 4),
                  RadioGroup<AppSkin>(
                    groupValue: skin,
                    onChanged: (AppSkin? value) => value == null
                        ? null
                        : ref.read(settingsRepositoryProvider).set(SettingsRepository.appSkin, value.name),
                    child: Column(
                      children: <Widget>[
                        for (final AppSkin option in AppSkin.values)
                          RadioListTile<AppSkin>(
                            contentPadding: EdgeInsets.zero,
                            value: option,
                            title: Text(option.label),
                            subtitle: Text(option.description),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  const Text('Tema'),
                  const SizedBox(height: 10),
                  if (skin.followsThemeMode)
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        segments: const <ButtonSegment<ThemeMode>>[
                          ButtonSegment<ThemeMode>(value: ThemeMode.system, label: Text('Sistema'), icon: Icon(Icons.brightness_auto)),
                          ButtonSegment<ThemeMode>(value: ThemeMode.light, label: Text('Chiaro'), icon: Icon(Icons.light_mode_outlined)),
                          ButtonSegment<ThemeMode>(value: ThemeMode.dark, label: Text('Scuro'), icon: Icon(Icons.dark_mode_outlined)),
                        ],
                        selected: <ThemeMode>{mode},
                        onSelectionChanged: (Set<ThemeMode> value) =>
                            ref.read(settingsRepositoryProvider).set(SettingsRepository.themeMode, value.first.name),
                      ),
                    )
                  else
                    Text(
                      '${skin.label} è una grafica nata chiara: il tema scuro vale solo per lo stile Originale.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ),
          header('Backup e ripristino'),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('Condividi backup'),
                  subtitle: const Text('Salvalo su Drive, inviatelo per email o su Telegram'),
                  onTap: _busy ? null : _share,
                ),
                ListTile(
                  leading: const Icon(Icons.save_alt),
                  title: const Text('Salva backup nel telefono'),
                  subtitle: const Text('Scegli una cartella, per esempio Download'),
                  onTap: _busy ? null : _saveToPhone,
                ),
                ListTile(
                  leading: Icon(Icons.restore, color: theme.colorScheme.error),
                  title: const Text('Ripristina da backup'),
                  subtitle: const Text('Sostituisce l\'intera libreria'),
                  onTap: _busy ? null : _restore,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Text(
                    '${lastBackupDate == null ? 'Nessun backup esportato finora.' : 'Ultimo backup: ${lastBackupDate.day}/${lastBackupDate.month}/${lastBackupDate.year}.'} '
                    'I dati esistono solo su questo telefono: esporta un backup ogni tanto e conservalo altrove.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          header('Cataloghi'),
          Card(
            child: Column(
              children: <Widget>[
                for (final CatalogKind kind in CatalogKind.values)
                  ListTile(
                    leading: Icon(switch (kind) {
                      CatalogKind.console => Icons.sports_esports_outlined,
                      CatalogKind.genere => Icons.category_outlined,
                      CatalogKind.serie => Icons.collections_bookmark_outlined,
                      CatalogKind.azienda => Icons.business_outlined,
                    }),
                    title: Text(kind.label),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push<void>(
                      skinnedRoute<void>((_) => CatalogScreen(kind: kind)),
                    ),
                  ),
              ],
            ),
          ),
          header('Informazioni'),
          Card(
            child: Column(
              children: <Widget>[
                const ListTile(leading: Icon(Icons.info_outline), title: Text('GameShelf'), subtitle: Text('Versione $appVersion')),
                const ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text('Privacy'),
                  subtitle: Text('Funziona completamente offline: nessun account, nessun dato inviato in rete.'),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Licenze open source'),
                  onTap: () => showLicensePage(context: context, applicationName: 'GameShelf', applicationVersion: 'Versione $appVersion'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key, required this.kind});

  final CatalogKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CatalogUsage>> entries = ref.watch(catalogUsageProvider(kind));
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(kind.label), flexibleSpace: const SkinBarBackground()),
      body: entries.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(icon: Icons.error_outline, title: 'Errore', message: '$e'),
        data: (List<CatalogUsage> list) => list.isEmpty
            ? const EmptyState(icon: Icons.inbox_outlined, title: 'Catalogo vuoto', message: 'Le voci si aggiungono dalla scheda di un gioco.')
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  final CatalogUsage entry = list[index];
                  return ListTile(
                    title: Text(entry.name),
                    subtitle: Text(
                      entry.uses == 0
                          ? 'Non usata'
                          : '${entry.uses} ${kind == CatalogKind.console ? (entry.uses == 1 ? 'copia' : 'copie') : (entry.uses == 1 ? 'gioco' : 'giochi')}',
                      style: TextStyle(color: entry.uses == 0 ? theme.colorScheme.onSurfaceVariant : null),
                    ),
                    trailing: entry.shortLabel == null ? const Icon(Icons.more_vert) : Text(entry.shortLabel!),
                    onTap: () => _actions(context, ref, entry, list),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _actions(BuildContext context, WidgetRef ref, CatalogUsage entry, List<CatalogUsage> all) async {
    final CatalogAdmin admin = ref.read(catalogAdminProvider);
    final String? action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(title: Text(entry.name, style: Theme.of(context).textTheme.titleMedium)),
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Rinomina'), onTap: () => Navigator.of(context).pop('rename')),
            ListTile(
              leading: const Icon(Icons.merge_type),
              title: const Text('Unisci con…'),
              subtitle: const Text('Sposta tutti gli usi su un\'altra voce'),
              onTap: () => Navigator.of(context).pop('merge'),
            ),
            ListTile(
              enabled: entry.uses == 0,
              leading: const Icon(Icons.delete_outline),
              title: const Text('Elimina'),
              subtitle: entry.uses == 0 ? null : const Text('Prima uniscila a un\'altra voce'),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    try {
      switch (action) {
        case 'rename':
          final (String, String?)? result = await _renameDialog(context, entry);
          if (result != null) await admin.rename(kind, entry.id, result.$1, shortLabel: result.$2);
        case 'merge':
          final CatalogUsage? target = await showDialog<CatalogUsage>(
            context: context,
            builder: (BuildContext context) => SimpleDialog(
              title: Text('Unisci «${entry.name}» con…'),
              children: <Widget>[
                for (final CatalogUsage other in all)
                  if (other.id != entry.id)
                    SimpleDialogOption(onPressed: () => Navigator.of(context).pop(other), child: Text(other.name)),
              ],
            ),
          );
          if (target != null) {
            await admin.merge(kind, entry.id, target.id);
            if (context.mounted) showMessage(context, '«${entry.name}» unita a «${target.name}»');
          }
        case 'delete':
          await admin.delete(kind, entry.id);
      }
    } catch (error) {
      if (context.mounted) showMessage(context, error is CatalogException ? error.message : 'Operazione non riuscita: $error');
    }
  }

  Future<(String, String?)?> _renameDialog(BuildContext context, CatalogUsage entry) async {
    final TextEditingController name = TextEditingController(text: entry.name);
    final TextEditingController label = TextEditingController(text: entry.shortLabel ?? '');
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Rinomina'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Nome')),
            if (kind == CatalogKind.console) ...<Widget>[
              const SizedBox(height: 12),
              TextField(controller: label, maxLength: 10, decoration: const InputDecoration(labelText: 'Sigla')),
            ],
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annulla')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Salva')),
        ],
      ),
    );
    final (String, String?) result = (name.text, kind == CatalogKind.console ? label.text : null);
    name.dispose();
    label.dispose();
    return ok == true ? result : null;
  }
}
