import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/enums.dart';

/// Le tre grafiche selezionabili in Impostazioni.
enum AppSkin {
  /// Material 3, con tema chiaro e scuro.
  originale('Originale', 'Moderno, scelta tra chiaro e scuro'),

  /// iPhone 2007: righine, barre blu lucide, pulsanti in vetro.
  ///
  /// Il nome visibile è «Apple», ma il nome tecnico resta `ios1`: è quello
  /// salvato in `settings`, e cambiarlo farebbe perdere la scelta a chi ce l'ha.
  ios1('Apple', "Rivivi l'era di Jobs"),

  /// Windows Vista / 7: sfondo blu e pannelli di vetro smerigliato.
  aero('Aero', 'Colorato e vivace');

  const AppSkin(this.label, this.description);

  final String label;
  final String description;

  static AppSkin fromName(String? value) =>
      AppSkin.values.firstWhere((AppSkin s) => s.name == value, orElse: () => AppSkin.originale);

  /// Solo l'originale segue l'interruttore chiaro/scuro: gli altri due sono nati
  /// chiari e scurirli tradirebbe lo stile.
  bool get followsThemeMode => this == AppSkin.originale;
}

/// Come si disegnano sfondo, barre, pannelli e pulsanti nella grafica scelta.
///
/// Sta in un'estensione del tema, così ogni widget lo legge da `Theme.of` senza
/// che le schermate debbano sapere quale grafica è attiva.
@immutable
class SkinTokens extends ThemeExtension<SkinTokens> {
  const SkinTokens({
    required this.skin,
    required this.panelColor,
    required this.panelBorder,
    required this.panelShadow,
    required this.panelRadius,
    required this.panelGloss,
    required this.onPanel,
    required this.backdropBase,
    required this.onBackdrop,
    required this.onBackdropMuted,
    required this.backdropAccent,
    required this.backdropShadows,
    required this.barGradient,
    required this.onBar,
    required this.barBorder,
    required this.buttonGradient,
    required this.onButton,
    required this.buttonBorder,
    required this.buttonRadius,
    required this.glossyCovers,
    required this.barShadow,
  });

  final AppSkin skin;
  final Color panelColor;
  final Color? panelBorder;
  final List<BoxShadow> panelShadow;
  final double panelRadius;

  /// Riflesso chiaro sulla metà superiore di pannelli e pulsanti.
  final bool panelGloss;
  final Color onPanel;

  /// Colore di base dello sfondo della grafica: serve a far morire dentro lo
  /// sfondo una sfumatura (l'intestazione della scheda) senza stacchi netti.
  final Color backdropBase;

  /// Testo e icone appoggiati direttamente sullo sfondo della grafica, cioè
  /// fuori da pannelli e barre: titoli della libreria, schermate vuote, note.
  ///
  /// Non è `onPanel`: su Aero lo sfondo è blu profondo e il blu notte dei
  /// pannelli ci sparisce dentro.
  final Color onBackdrop;

  /// Variante attenuata di [onBackdrop] per le righe secondarie (l'anno di
  /// uscita, i messaggi di cortesia): deve restare leggibile, non svanire.
  final Color onBackdropMuted;

  /// Colore vivo sopra lo sfondo: rotelle di caricamento e titoli di sezione.
  final Color backdropAccent;

  /// Ombra sotto al testo appoggiato sullo sfondo: su Aero stacca le lettere
  /// chiare dalle zone più chiare della sfumatura.
  final List<Shadow> backdropShadows;

  /// Sfondo delle barre in alto e in basso; `null` per la grafica originale,
  /// che usa una tinta piatta.
  final Gradient? barGradient;
  final Color onBar;
  final Color? barBorder;
  final List<BoxShadow> barShadow;
  final Gradient? buttonGradient;
  final Color onButton;
  final Color? buttonBorder;
  final double buttonRadius;

  /// Copertine con il riflesso delle icone del primo iPhone.
  final bool glossyCovers;

  BoxDecoration get panelDecoration => BoxDecoration(
    color: panelColor,
    borderRadius: BorderRadius.circular(panelRadius),
    border: panelBorder == null ? null : Border.all(color: panelBorder!),
    boxShadow: panelShadow,
  );

  BoxDecoration get barDecoration => BoxDecoration(
    gradient: barGradient,
    border: barBorder == null ? null : Border(bottom: BorderSide(color: barBorder!)),
    boxShadow: barShadow,
  );

  /// Stile per un testo appoggiato sullo sfondo della grafica.
  TextStyle? backdrop(TextStyle? style, {bool muted = false}) =>
      style?.copyWith(color: muted ? onBackdropMuted : onBackdrop, shadows: backdropShadows);

  /// Velo chiaro da sovrapporre per ottenere l'effetto lucido.
  static const LinearGradient gloss = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0x66FFFFFF), Color(0x14FFFFFF), Color(0x00FFFFFF)],
    stops: <double>[0, 0.5, 0.52],
  );

  @override
  SkinTokens copyWith({
    AppSkin? skin,
    Color? panelColor,
    Color? panelBorder,
    List<BoxShadow>? panelShadow,
    double? panelRadius,
    bool? panelGloss,
    Color? onPanel,
    Color? backdropBase,
    Color? onBackdrop,
    Color? onBackdropMuted,
    Color? backdropAccent,
    List<Shadow>? backdropShadows,
    Gradient? barGradient,
    Color? onBar,
    Color? barBorder,
    List<BoxShadow>? barShadow,
    Gradient? buttonGradient,
    Color? onButton,
    Color? buttonBorder,
    double? buttonRadius,
    bool? glossyCovers,
  }) => SkinTokens(
    skin: skin ?? this.skin,
    panelColor: panelColor ?? this.panelColor,
    panelBorder: panelBorder ?? this.panelBorder,
    panelShadow: panelShadow ?? this.panelShadow,
    panelRadius: panelRadius ?? this.panelRadius,
    panelGloss: panelGloss ?? this.panelGloss,
    onPanel: onPanel ?? this.onPanel,
    backdropBase: backdropBase ?? this.backdropBase,
    onBackdrop: onBackdrop ?? this.onBackdrop,
    onBackdropMuted: onBackdropMuted ?? this.onBackdropMuted,
    backdropAccent: backdropAccent ?? this.backdropAccent,
    backdropShadows: backdropShadows ?? this.backdropShadows,
    barGradient: barGradient ?? this.barGradient,
    onBar: onBar ?? this.onBar,
    barBorder: barBorder ?? this.barBorder,
    barShadow: barShadow ?? this.barShadow,
    buttonGradient: buttonGradient ?? this.buttonGradient,
    onButton: onButton ?? this.onButton,
    buttonBorder: buttonBorder ?? this.buttonBorder,
    buttonRadius: buttonRadius ?? this.buttonRadius,
    glossyCovers: glossyCovers ?? this.glossyCovers,
  );

  /// Interpolazione vera: cambiando grafica i colori si sfumano insieme a quelli
  /// della `ColorScheme`. Prima questa funzione scattava a metà strada, e per un
  /// fotogramma testo, pannelli e barre erano di due grafiche diverse.
  @override
  SkinTokens lerp(ThemeExtension<SkinTokens>? other, double t) {
    if (other is! SkinTokens) return this;
    // Quello che non si può sfumare (la grafica, il riflesso acceso o spento)
    // cambia a metà strada, quando la dissolvenza lo nasconde meglio.
    final bool second = t >= 0.5;
    return SkinTokens(
      skin: second ? other.skin : skin,
      panelColor: Color.lerp(panelColor, other.panelColor, t)!,
      panelBorder: Color.lerp(panelBorder, other.panelBorder, t),
      panelShadow: BoxShadow.lerpList(panelShadow, other.panelShadow, t)!,
      panelRadius: panelRadius + (other.panelRadius - panelRadius) * t,
      panelGloss: second ? other.panelGloss : panelGloss,
      onPanel: Color.lerp(onPanel, other.onPanel, t)!,
      backdropBase: Color.lerp(backdropBase, other.backdropBase, t)!,
      onBackdrop: Color.lerp(onBackdrop, other.onBackdrop, t)!,
      onBackdropMuted: Color.lerp(onBackdropMuted, other.onBackdropMuted, t)!,
      backdropAccent: Color.lerp(backdropAccent, other.backdropAccent, t)!,
      backdropShadows: Shadow.lerpList(backdropShadows, other.backdropShadows, t)!,
      barGradient: Gradient.lerp(barGradient, other.barGradient, t),
      onBar: Color.lerp(onBar, other.onBar, t)!,
      barBorder: Color.lerp(barBorder, other.barBorder, t),
      barShadow: BoxShadow.lerpList(barShadow, other.barShadow, t)!,
      buttonGradient: Gradient.lerp(buttonGradient, other.buttonGradient, t),
      onButton: Color.lerp(onButton, other.onButton, t)!,
      buttonBorder: Color.lerp(buttonBorder, other.buttonBorder, t),
      buttonRadius: buttonRadius + (other.buttonRadius - buttonRadius) * t,
      glossyCovers: second ? other.glossyCovers : glossyCovers,
    );
  }
}

/// Dissolvenza con una leggera scala, senza traslazione: le due pagine non
/// scorrono, quindi i loro sfondi restano sovrapposti e non si vede nessuna
/// giunzione. È la transizione della grafica Aero.
class AeroPageTransitionsBuilder extends PageTransitionsBuilder {
  const AeroPageTransitionsBuilder();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 340);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // `drive` invece di CurvedAnimation: non c'è nessun oggetto da liberare.
    final Animation<double> fade = animation.drive(CurveTween(curve: Curves.easeOut));
    final Animation<double> scale = animation.drive(
      Tween<double>(begin: 0.965, end: 1).chain(CurveTween(curve: Curves.easeOutCubic)),
    );
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(scale: scale, child: child),
    );
  }
}

abstract final class AppTheme {
  static const Color _seed = Color(0xFF5B5BD6);

  static ThemeData light(AppSkin skin) => _build(skin, Brightness.light);

  static ThemeData dark(AppSkin skin) => _build(skin, Brightness.dark);

  /// Come entra una schermata nuova, grafica per grafica.
  ///
  /// L'originale tiene la transizione di sistema (compreso il gesto «indietro»
  /// di Android), ma con lo scrim trasparente: quel rettangolo colorato a tutto
  /// schermo era il taglio netto che si vedeva aprendo un gioco.
  static PageTransitionsBuilder transitionsFor(AppSkin skin) => switch (skin) {
    AppSkin.originale => const PredictiveBackPageTransitionsBuilder(fallbackColor: Colors.transparent),
    AppSkin.ios1 => const CupertinoPageTransitionsBuilder(),
    AppSkin.aero => const AeroPageTransitionsBuilder(),
  };

  static ThemeData _build(AppSkin skin, Brightness brightness) {
    final bool dark = brightness == Brightness.dark && skin.followsThemeMode;
    final ColorScheme scheme = switch (skin) {
      AppSkin.originale => ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
      AppSkin.ios1 => ColorScheme.fromSeed(
        seedColor: const Color(0xFF3F6CA4),
        surface: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF1C2430),
      ),
      AppSkin.aero => ColorScheme.fromSeed(
        seedColor: const Color(0xFF2B7EC1),
        surface: const Color(0xFFF2F8FD),
        onSurface: const Color(0xFF10263D),
      ),
    };
    final SkinTokens tokens = _tokensFor(skin, scheme, dark: dark);

    ButtonStyle glossy({required bool filled}) {
      final Color foreground = filled ? tokens.onButton : scheme.primary;
      return ButtonStyle(
        foregroundColor: WidgetStatePropertyAll<Color>(foreground),
        iconColor: WidgetStatePropertyAll<Color>(foreground),
        overlayColor: WidgetStatePropertyAll<Color>(foreground.withValues(alpha: 0.1)),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.buttonRadius)),
        ),
        textStyle: const WidgetStatePropertyAll<TextStyle>(TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        // Il gradiente lucido si dipinge dietro il contenuto del pulsante:
        // ButtonStyle da solo non sa fare sfumature.
        backgroundBuilder: (BuildContext context, Set<WidgetState> states, Widget? child) {
          final bool pressed = states.contains(WidgetState.pressed);
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: filled
                  ? tokens.buttonGradient
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0xFFFFFFFF), Color(0xFFE8EDF3), Color(0xFFDCE3EB), Color(0xFFF0F3F7)],
                      stops: <double>[0, 0.48, 0.52, 1],
                    ),
              borderRadius: BorderRadius.circular(tokens.buttonRadius),
              border: tokens.buttonBorder == null ? null : Border.all(color: tokens.buttonBorder!),
              boxShadow: pressed
                  ? null
                  : const <BoxShadow>[BoxShadow(color: Color(0x40000000), blurRadius: 2, offset: Offset(0, 1))],
            ),
            child: Opacity(opacity: pressed ? 0.75 : 1, child: child),
          );
        },
      );
    }

    final bool skinned = skin != AppSkin.originale;
    final PageTransitionsBuilder transitions = transitionsFor(skin);
    return ThemeData(
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[tokens],
      // Lo sfondo lo disegna SkinBackground dietro a tutte le schermate.
      scaffoldBackgroundColor: Colors.transparent,
      // La stessa transizione su ogni piattaforma: l'app gira solo su Android,
      // e una mappa senza la voce giusta ricadrebbe in silenzio sullo zoom di
      // serie, che ridipinge mezzo schermo color superficie.
      pageTransitionsTheme: PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          for (final TargetPlatform platform in TargetPlatform.values) platform: transitions,
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: skin == AppSkin.ios1,
        backgroundColor: skinned ? Colors.transparent : scheme.surface,
        foregroundColor: skinned ? tokens.onBar : scheme.onSurface,
        scrolledUnderElevation: 0,
        elevation: 0,
        // Con la barra trasparente Flutter dedurrebbe icone scure dalla
        // luminanza zero: sotto c'è il vetro blu, le icone vanno chiare.
        systemOverlayStyle: skinned ? SystemUiOverlayStyle.light : null,
        titleTextStyle: TextStyle(
          fontSize: skin == AppSkin.ios1 ? 20 : 24,
          fontWeight: FontWeight.w700,
          color: skinned ? tokens.onBar : scheme.onSurface,
          shadows: skinned
              ? const <Shadow>[Shadow(color: Color(0x80000000), offset: Offset(0, -1))]
              : null,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: tokens.panelColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.panelRadius),
          side: tokens.panelBorder == null ? BorderSide.none : BorderSide(color: tokens.panelBorder!),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: skinned
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.buttonRadius))
            : const StadiumBorder(),
        side: tokens.panelBorder == null ? null : BorderSide(color: tokens.panelBorder!),
        backgroundColor: skinned ? Colors.white.withValues(alpha: 0.85) : null,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: skinned ? Colors.white.withValues(alpha: 0.92) : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(skinned ? tokens.buttonRadius : 14),
          borderSide: tokens.panelBorder == null ? BorderSide.none : BorderSide(color: tokens.panelBorder!),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: skinned ? glossy(filled: true) : null),
      outlinedButtonTheme: OutlinedButtonThemeData(style: skinned ? glossy(filled: false) : null),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: skinned ? scheme.primary : scheme.primaryContainer,
        foregroundColor: skinned ? Colors.white : scheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(skinned ? 12 : 16)),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: skinned ? Colors.transparent : scheme.surfaceContainer,
        indicatorColor: skinned ? Colors.white.withValues(alpha: 0.22) : scheme.secondaryContainer,
        iconTheme: WidgetStatePropertyAll<IconThemeData>(
          IconThemeData(color: skinned ? tokens.onBar : scheme.onSurfaceVariant),
        ),
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(
          TextStyle(fontSize: 12, color: skinned ? tokens.onBar : scheme.onSurfaceVariant),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: skin == AppSkin.originale ? scheme.surfaceContainerLow : tokens.panelColor,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: skin == AppSkin.originale ? null : tokens.panelColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.panelRadius)),
      ),
      sliderTheme: const SliderThemeData(trackHeight: 6),
    );
  }

  static SkinTokens _tokensFor(AppSkin skin, ColorScheme scheme, {required bool dark}) {
    switch (skin) {
      case AppSkin.originale:
        return SkinTokens(
          skin: skin,
          panelColor: scheme.surfaceContainerLow,
          panelBorder: null,
          panelShadow: const <BoxShadow>[],
          panelRadius: 20,
          panelGloss: false,
          onPanel: scheme.onSurface,
          backdropBase: scheme.surface,
          // Qui lo sfondo È la superficie: testo e pannelli usano gli stessi
          // colori di sempre, la grafica originale non cambia di un pixel.
          onBackdrop: scheme.onSurface,
          onBackdropMuted: scheme.onSurfaceVariant,
          backdropAccent: scheme.primary,
          backdropShadows: const <Shadow>[],
          barGradient: null,
          onBar: scheme.onSurface,
          barBorder: null,
          barShadow: const <BoxShadow>[],
          buttonGradient: null,
          onButton: scheme.onPrimary,
          buttonBorder: null,
          buttonRadius: 20,
          glossyCovers: false,
        );
      case AppSkin.ios1:
        return const SkinTokens(
          skin: AppSkin.ios1,
          panelColor: Color(0xFFFFFFFF),
          panelBorder: Color(0xFFA6B0BD),
          panelShadow: <BoxShadow>[BoxShadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 1))],
          panelRadius: 10,
          panelGloss: true,
          onPanel: Color(0xFF1C2430),
          backdropBase: Color(0xFFC3CAD4),
          // Le righine sono grigio chiaro: sopra ci va testo scuro, come nei
          // pannelli. L'ombra chiara stacca appena le lettere dalla trama.
          onBackdrop: Color(0xFF1C2430),
          onBackdropMuted: Color(0xFF53606F),
          backdropAccent: Color(0xFF3F6093),
          backdropShadows: <Shadow>[Shadow(color: Color(0xCCFFFFFF), offset: Offset(0, 1))],
          barGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF8AA5C8), Color(0xFF4A6C9B), Color(0xFF3F6093), Color(0xFF5A7CAB)],
            stops: <double>[0, 0.48, 0.52, 1],
          ),
          onBar: Color(0xFFFFFFFF),
          barBorder: Color(0xFF2C466E),
          barShadow: <BoxShadow>[BoxShadow(color: Color(0x4D000000), blurRadius: 3)],
          buttonGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF7FA6D8), Color(0xFF3C6BA6), Color(0xFF335F99), Color(0xFF4D78B4)],
            stops: <double>[0, 0.48, 0.52, 1],
          ),
          onButton: Color(0xFFFFFFFF),
          buttonBorder: Color(0xFF2C466E),
          buttonRadius: 9,
          glossyCovers: true,
        );
      case AppSkin.aero:
        return const SkinTokens(
          skin: AppSkin.aero,
          // Vetro chiaro con testo scuro: in Vista e 7 il vetro stava sulle
          // cornici, mentre il contenuto restava su fondo chiaro. Così resta
          // leggibile anche al sole.
          panelColor: Color(0xE6FFFFFF),
          panelBorder: Color(0xCCFFFFFF),
          panelShadow: <BoxShadow>[BoxShadow(color: Color(0x44000000), blurRadius: 10, offset: Offset(0, 3))],
          panelRadius: 8,
          panelGloss: true,
          onPanel: Color(0xFF10263D),
          backdropBase: Color(0xFF2E6FAC),
          // Fuori dai pannelli c'è il blu profondo dello sfondo: lì il blu notte
          // dei pannelli sparisce, e il testo va bianco. L'ombra serve in alto a
          // sinistra, dove la sfumatura è molto più chiara.
          onBackdrop: Color(0xFFF4FAFF),
          onBackdropMuted: Color(0xFFCFE4F7),
          backdropAccent: Color(0xFFFFFFFF),
          backdropShadows: <Shadow>[
            Shadow(color: Color(0xB304203C), blurRadius: 6, offset: Offset(0, 1)),
          ],
          barGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0x5CFFFFFF), Color(0x1FFFFFFF), Color(0x0AFFFFFF), Color(0x33FFFFFF)],
            stops: <double>[0, 0.48, 0.52, 1],
          ),
          onBar: Color(0xFFFFFFFF),
          barBorder: Color(0x66FFFFFF),
          barShadow: <BoxShadow>[BoxShadow(color: Color(0x33000000), blurRadius: 8)],
          buttonGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFEAF6FF), Color(0xFFA9D6F5), Color(0xFF6CB6E8), Color(0xFFA4D4F4)],
            stops: <double>[0, 0.48, 0.52, 1],
          ),
          onButton: Color(0xFF0D3C63),
          buttonBorder: Color(0xFF4A90C4),
          buttonRadius: 6,
          glossyCovers: false,
        );
    }
  }
}

/// Token della grafica attiva.
SkinTokens skinOf(BuildContext context) =>
    Theme.of(context).extension<SkinTokens>() ?? AppTheme.light(AppSkin.originale).extension<SkinTokens>()!;

/// Aspetto di uno stato di completamento, identico in chip, schede e grafici.
class StatusVisual {
  const StatusVisual(this.label, this.description, this.icon, this.color);

  final String label;
  final String description;
  final IconData icon;
  final Color color;
}

StatusVisual statusVisual(GameStatus status, Brightness brightness) {
  final bool dark = brightness == Brightness.dark;
  return switch (status) {
    GameStatus.backlog => StatusVisual(
      'Backlog',
      'Ancora da iniziare',
      Icons.inventory_2_outlined,
      dark ? const Color(0xFFB0BEC5) : const Color(0xFF607D8B),
    ),
    GameStatus.arcade => StatusVisual(
      'Arcade',
      'Gioco infinito, senza un finale',
      Icons.all_inclusive,
      dark ? const Color(0xFFCE93D8) : const Color(0xFF8E24AA),
    ),
    GameStatus.abbandonato => StatusVisual(
      'Abbandonato',
      'Iniziato, ma non ci sto più giocando',
      Icons.pause_circle_outline,
      dark ? const Color(0xFFFFAB91) : const Color(0xFFD84315),
    ),
    GameStatus.inCorso => StatusVisual(
      'In corso',
      'Lo sto giocando adesso',
      Icons.play_circle_outline,
      dark ? const Color(0xFF90CAF9) : const Color(0xFF1E88E5),
    ),
    GameStatus.finito => StatusVisual(
      'Finito',
      'Campagna principale completata',
      Icons.flag_outlined,
      dark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32),
    ),
    GameStatus.completato => StatusVisual(
      'Completato',
      'Finite anche tutte le parti opzionali',
      Icons.emoji_events_outlined,
      dark ? const Color(0xFFFFE082) : const Color(0xFFF9A825),
    ),
  };
}

String formatLabel(CopyFormat format) => switch (format) {
  CopyFormat.fisico => 'Fisico',
  CopyFormat.digitale => 'Digitale',
};

IconData formatIcon(CopyFormat format) => switch (format) {
  CopyFormat.fisico => Icons.album_outlined,
  CopyFormat.digitale => Icons.cloud_download_outlined,
};

IconData familyIcon(String family) => switch (family) {
  'nintendo' => Icons.videogame_asset_outlined,
  'playstation' => Icons.sports_esports_outlined,
  'xbox' => Icons.gamepad_outlined,
  'sega' => Icons.blur_circular,
  'pc' => Icons.computer,
  _ => Icons.devices_other,
};

/// Voto arrotondato a una decimale, come viene mostrato.
double roundRating(double value) => (value * 10).round() / 10;

/// Voto complessivo con una decimale e la virgola: `8,4`. `—` se non valutato.
String formatRating(double? value) =>
    value == null ? '—' : roundRating(value).toStringAsFixed(1).replaceAll('.', ',');

/// Fasce di colore dei voti.
enum RatingTier { nessuno, insufficiente, sufficiente, buono, argento, oro, platino }

/// Fascia di un voto, decisa sul valore mostrato: un 8,96 si legge «9,0» e deve
/// essere oro, non argento.
RatingTier ratingTier(double? value) {
  if (value == null) return RatingTier.nessuno;
  final double shown = roundRating(value);
  if (shown >= 10) return RatingTier.platino;
  if (shown >= 9) return RatingTier.oro;
  if (shown >= 8) return RatingTier.argento;
  if (shown >= 7) return RatingTier.buono;
  if (shown >= 5) return RatingTier.sufficiente;
  return RatingTier.insufficiente;
}

/// Colore della fascia di un voto; i toni chiari servono sui fondi scuri.
Color ratingColor(double? value, Brightness brightness) {
  final bool dark = brightness == Brightness.dark;
  return switch (ratingTier(value)) {
    RatingTier.nessuno => dark ? const Color(0xFF9E9E9E) : const Color(0xFF757575),
    RatingTier.insufficiente => dark ? const Color(0xFFEF5350) : const Color(0xFFD32F2F),
    RatingTier.sufficiente => dark ? const Color(0xFFFFA726) : const Color(0xFFE65100),
    RatingTier.buono => dark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32),
    RatingTier.argento => dark ? const Color(0xFFD5DAE1) : const Color(0xFF6E757E),
    RatingTier.oro => dark ? const Color(0xFFFFD54F) : const Color(0xFFB07D0B),
    RatingTier.platino => dark ? const Color(0xFFB8F1FF) : const Color(0xFF2F8FAD),
  };
}

/// Voto di una categoria a mezzi punti: `8` oppure `7,5`.
String formatHalf(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(1).replaceAll('.', ',');
