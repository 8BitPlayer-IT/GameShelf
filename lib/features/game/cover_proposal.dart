/// Il riquadro che propone una copertina trovata online.
///
/// La proposta è **una sola, o nessuna**: non c'è un elenco di candidati fra cui
/// scegliere, perché sceglierne uno fra quattro somiglianti è il momento in cui
/// si sbaglia. Se la corrispondenza non è certa non si propone niente.
///
/// L'immagine viene scaricata *prima* di mostrare il riquadro, e tenuta in
/// memoria: così quello che si vede è esattamente quello che si salva, e
/// premendo «Usa questa» non c'è una seconda attesa.
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../data/covers/online_cover_service.dart';

/// Una copertina trovata e già scaricata.
class CoverProposal {
  const CoverProposal(this.candidate, this.bytes);

  final CoverCandidate candidate;
  final Uint8List bytes;
}

/// Esito della ricerca, con l'informazione se vale la pena dirlo all'utente.
class CoverLookup {
  const CoverLookup({this.proposal, this.worthTelling = false});

  final CoverProposal? proposal;

  /// Vero solo quando la rete c'era, la ricerca è avvenuta e non ha dato
  /// niente: allora si avvisa. Se mancava la rete si tace, come deciso.
  final bool worthTelling;
}

/// Cerca una copertina per [title] sulle fonti di [consoles] e la scarica.
Future<CoverLookup> lookupCover(
  OnlineCoverService service, {
  required String title,
  required List<String> consoles,
}) async {
  final CoverSearchResult result = await service.search(title, consoles: consoles);
  final CoverCandidate? candidate = result.candidate;
  if (candidate == null) return CoverLookup(worthTelling: result.worthTelling);

  final Uint8List? bytes = await service.download(candidate);
  // Trovata ma non scaricabile: si tace, perché non è colpa di una mancata
  // corrispondenza ed è un caso che l'utente non può risolvere.
  if (bytes == null) return const CoverLookup();
  return CoverLookup(proposal: CoverProposal(candidate, bytes));
}

/// Mostra la proposta. Restituisce `true` se l'utente la accetta.
Future<bool> showCoverProposal(BuildContext context, CoverProposal proposal) async {
  final bool? accepted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (BuildContext context) => _CoverProposalSheet(proposal: proposal),
  );
  return accepted ?? false;
}

class _CoverProposalSheet extends StatelessWidget {
  const _CoverProposalSheet({required this.proposal});

  final CoverProposal proposal;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int kb = (proposal.bytes.length / 1024).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Copertina trovata', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Lo sfondo del riquadro fa vedere com'è l'incorniciatura in 3:4
              // che verrà applicata salvando.
              Container(
                width: 108,
                height: 144,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.memory(
                  proposal.bytes,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Il nome con cui la fonte conosce il gioco: se è un altro
                    // gioco, si vede subito.
                    Text(proposal.candidate.matchedTitle, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text(
                      'da ${proposal.candidate.source} · $kb kB',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Usa questa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No, grazie'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
