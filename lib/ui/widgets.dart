import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/theme.dart';
import '../domain/enums.dart';
import 'console_icons.dart';

/// Copertina da percorso relativo, con un segnaposto elegante quando manca.
class CoverImage extends ConsumerWidget {
  const CoverImage({
    super.key,
    required this.path,
    required this.title,
    this.borderRadius = 16,
    this.cacheWidth,
  });

  final String? path;
  final String title;
  final double borderRadius;

  /// Larghezza di decodifica: in griglia evita di tenere in memoria immagini
  /// da 1000 pixel per miniature da 170.
  final int? cacheWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? relative = path;
    final Widget placeholder = _Placeholder(title: title);
    final SkinTokens tokens = skinOf(context);
    final Widget image = relative == null
        ? placeholder
        : Image.file(
            ref.watch(coverServiceProvider).fileFor(relative),
            fit: BoxFit.cover,
            cacheWidth: cacheWidth,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => placeholder,
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      // Il riflesso bombato delle icone del primo iPhone, solo in quella grafica.
      child: tokens.glossyCovers
          ? Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                image,
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 52,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[Color(0x80FFFFFF), Color(0x18FFFFFF)],
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(borderRadius),
                          bottom: Radius.elliptical(borderRadius * 6, borderRadius * 2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : image,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<String> words = title.trim().split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).toList();
    final String initials = words.take(2).map((String w) => w.characters.first.toUpperCase()).join();
    final int hue = title.codeUnits.fold<int>(0, (int a, int b) => (a + b) % 360);
    final Color base = HSLColor.fromAHSL(1, hue.toDouble(), 0.45, 0.45).toColor();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color.lerp(base, scheme.primary, 0.3)!, Color.lerp(base, Colors.black, 0.35)!],
        ),
      ),
      child: Center(
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              initials.isEmpty ? '?' : initials,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.dense = false, this.onTap});

  final GameStatus status;
  final bool dense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final StatusVisual visual = statusVisual(status, Theme.of(context).brightness);
    final Widget content = Padding(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 12, vertical: dense ? 3 : 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(visual.icon, size: dense ? 14 : 18, color: visual.color),
          SizedBox(width: dense ? 4 : 6),
          Text(
            visual.label,
            style: TextStyle(
              fontSize: dense ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: visual.color,
            ),
          ),
          if (onTap != null) ...<Widget>[
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 18, color: visual.color),
          ],
        ],
      ),
    );
    return Material(
      color: visual.color.withValues(alpha: 0.14),
      shape: const StadiumBorder(),
      child: onTap == null ? content : InkWell(customBorder: const StadiumBorder(), onTap: onTap, child: content),
    );
  }
}

/// Sigle delle console: al massimo [max] badge più un «+N».
class ConsoleBadges extends StatelessWidget {
  const ConsoleBadges({
    super.key,
    required this.labels,
    this.max = 2,
    this.onImage = false,
    this.trailing,
    this.iconsOnly = false,
    this.showMore = true,
  });

  /// Solo il disegno della console, senza sigla: per le griglie fitte.
  final bool iconsOnly;

  /// Mostra «+N» quando le console sono più di [max].
  final bool showMore;

  final List<String> labels;
  final int max;

  /// Badge in coda con stile diverso, usato per l'anno di uscita.
  final String? trailing;

  /// Sopra una copertina: fondo scuro semitrasparente per restare leggibile.
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty && trailing == null) return const SizedBox.shrink();
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color foreground = onImage ? Colors.white : scheme.onSurfaceVariant;
    final BoxDecoration chip = BoxDecoration(
      color: onImage ? Colors.black.withValues(alpha: 0.6) : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(6),
    );
    final TextStyle text = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: foreground);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: <Widget>[
        for (final String label in labels.take(max))
          Container(
            padding: EdgeInsets.symmetric(horizontal: iconsOnly ? 4 : 5, vertical: 2),
            decoration: chip,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ConsoleIcon(label: label, size: 15, color: foreground),
                if (!iconsOnly) ...<Widget>[const SizedBox(width: 3), Text(label, style: text)],
              ],
            ),
          ),
        if (showMore && labels.length > max)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: chip,
            child: Text('+${labels.length - max}', style: text),
          ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: onImage ? Colors.black.withValues(alpha: 0.6) : null,
              border: Border.all(color: onImage ? Colors.white54 : scheme.outlineVariant),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              trailing!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: onImage ? Colors.white : scheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.onImage = false, this.size = 40});

  final double? rating;
  final bool onImage;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double? value = rating;
    final RatingTier tier = ratingTier(value);
    final bool crystal = tier == RatingTier.platino;
    // Sopra una copertina il fondo è sempre scuro: si usano i toni del tema scuro.
    final Color color = tier == RatingTier.nessuno
        ? (onImage ? Colors.white70 : scheme.onSurfaceVariant)
        : ratingColor(value, onImage ? Brightness.dark : Theme.of(context).brightness);
    final Color textColor = crystal ? const Color(0xFF08475A) : color;
    return Container(
      constraints: BoxConstraints(minWidth: size, minHeight: size * 0.6),
      padding: EdgeInsets.symmetric(horizontal: size * 0.16, vertical: 3),
      decoration: BoxDecoration(
        color: crystal ? null : (onImage ? Colors.black.withValues(alpha: 0.65) : color.withValues(alpha: 0.14)),
        // Il 10 ha l'effetto platino/cristallo.
        gradient: crystal
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFFF7FEFF), Color(0xFFA9DDEC), Color(0xFFEAFAFF), Color(0xFF86CCE0)],
              )
            : null,
        borderRadius: BorderRadius.circular(10),
        border: crystal
            ? Border.all(color: Colors.white, width: 1.5)
            : onImage
            ? Border.all(color: color.withValues(alpha: 0.9), width: 1.5)
            : null,
        boxShadow: crystal ? const <BoxShadow>[BoxShadow(color: Color(0x8080DEEA), blurRadius: 8)] : null,
      ),
      // Niente `alignment`: un Container allineato si allarga a tutto lo spazio
      // disponibile, e dentro una ListTile schiacciava il titolo fino a zero.
      child: Text(
        formatRating(value),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
          color: textColor,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action});

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(36),
              ),
              child: Icon(icon, size: 48, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 20),
            Text(title, style: skinOf(context).backdrop(theme.textTheme.titleLarge), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
              style: skinOf(context).backdrop(theme.textTheme.bodyMedium, muted: true),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...<Widget>[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

/// Riquadro di sezione con titolo, usato in scheda e modulo.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SkinPanel(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Sfondo della grafica attiva: le righine di Apple, la sfumatura blu di Aero,
/// la tinta piatta dell'originale.
///
/// Sta sia dietro tutta l'app sia dentro ogni rotta aperta con [skinnedRoute]:
/// una pagina che porta con sé il proprio sfondo è opaca, quindi durante le
/// transizioni non si vede in trasparenza quella sotto, e il vetro smerigliato
/// delle barre ha qualcosa da sfocare anche mentre la pagina si muove.
class SkinBackground extends StatelessWidget {
  const SkinBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final SkinTokens tokens = skinOf(context);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Cambiando grafica lo sfondo si dissolve invece di scattare, e si
        // dissolve solo il disegno: il contenuto sta sopra, fuori
        // dall'AnimatedSwitcher, quindi non viene ricostruito e non perde né
        // lo scorrimento né quello che si sta scrivendo.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          child: SizedBox.expand(
            key: ValueKey<AppSkin>(tokens.skin),
            child: _paint(tokens.skin, Theme.of(context).colorScheme.surface),
          ),
        ),
        child,
      ],
    );
  }

  static Widget _paint(AppSkin skin, Color surface) => switch (skin) {
    AppSkin.originale => ColoredBox(color: surface),
    AppSkin.ios1 => const CustomPaint(painter: _PinstripePainter()),
    AppSkin.aero => const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.6, -1),
          radius: 1.6,
          colors: <Color>[Color(0xFF5AA6E8), Color(0xFF1C5C9E), Color(0xFF0A2F5C)],
          stops: <double>[0, 0.45, 1],
        ),
      ),
    ),
  };
}

/// Apre una schermata con lo sfondo della grafica dentro la rotta.
///
/// Tutte le aperture dell'app passano di qui: è quello che rende la pagina
/// opaca durante la transizione scelta dalla grafica.
Route<T> skinnedRoute<T>(WidgetBuilder builder, {bool fullscreenDialog = false}) => MaterialPageRoute<T>(
  fullscreenDialog: fullscreenDialog,
  builder: (BuildContext context) => SkinBackground(child: builder(context)),
);

/// Le righine orizzontali del primo iPhone, disegnate invece che caricate come
/// immagine: non pesano sull'APK e restano nitide a ogni densità.
class _PinstripePainter extends CustomPainter {
  const _PinstripePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFC3CAD4));
    final Paint line = Paint()..color = const Color(0xFFCED5DE);
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), line);
    }
  }

  @override
  bool shouldRepaint(_PinstripePainter oldDelegate) => false;
}

/// Sfondo delle barre in alto e in basso. Su Aero è vetro smerigliato vero:
/// sfoca ciò che ci passa sotto.
class SkinBarBackground extends StatelessWidget {
  const SkinBarBackground({super.key, this.bottom = false});

  /// Barra in basso: il bordo chiaro va sopra invece che sotto.
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    final SkinTokens tokens = skinOf(context);
    if (tokens.barGradient == null) return const SizedBox.shrink();
    final BorderSide side = BorderSide(color: tokens.barBorder ?? Colors.transparent);
    final Widget painted = DecoratedBox(
      decoration: BoxDecoration(
        gradient: tokens.barGradient,
        border: Border(top: bottom ? side : BorderSide.none, bottom: bottom ? BorderSide.none : side),
      ),
      child: const SizedBox.expand(),
    );
    if (tokens.skin != AppSkin.aero) return painted;
    return ClipRect(
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14), child: painted),
    );
  }
}

/// Riquadro nello stile della grafica attiva: bianco bordato in iOS 1, vetro in
/// Aero, superficie piatta nell'originale.
class SkinPanel extends StatelessWidget {
  const SkinPanel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final SkinTokens tokens = skinOf(context);
    final Widget content = Padding(padding: padding ?? EdgeInsets.zero, child: child);
    return DecoratedBox(
      decoration: tokens.panelDecoration,
      child: tokens.panelGloss
          ? Stack(
              children: <Widget>[
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 36,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: SkinTokens.gloss,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.panelRadius)),
                      ),
                    ),
                  ),
                ),
                content,
              ],
            )
          : content,
    );
  }
}
