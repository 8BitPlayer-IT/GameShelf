import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/app/theme.dart';

/// Rapporto di contrasto fra due colori (WCAG): 1 = identici, 21 = bianco su nero.
double _contrast(Color a, Color b) {
  final double first = a.computeLuminance();
  final double second = b.computeLuminance();
  final double light = first > second ? first : second;
  final double dark = first > second ? second : first;
  return (light + 0.05) / (dark + 0.05);
}

void main() {
  test('la grafica si legge e si salva per nome', () {
    expect(AppSkin.fromName(null), AppSkin.originale);
    expect(AppSkin.fromName('ios1'), AppSkin.ios1);
    expect(AppSkin.fromName('aero'), AppSkin.aero);
    expect(AppSkin.fromName('inventata'), AppSkin.originale, reason: 'valore sconosciuto: si torna a Semplice');
  });

  test('il nome tecnico resta ios1 anche se la grafica si chiama Lucido', () {
    // È il valore salvato nella tabella `settings`: cambiarlo farebbe perdere
    // la scelta a chi ha già l'app installata.
    expect(AppSkin.ios1.name, 'ios1');
    expect(AppSkin.ios1.label, 'Lucido');
  });

  test('solo Semplice segue l\'interruttore chiaro/scuro', () {
    expect(AppSkin.originale.followsThemeMode, isTrue);
    expect(AppSkin.ios1.followsThemeMode, isFalse);
    expect(AppSkin.aero.followsThemeMode, isFalse);
  });

  test('ogni grafica porta i propri token nel tema', () {
    for (final AppSkin skin in AppSkin.values) {
      final ThemeData theme = AppTheme.light(skin);
      final SkinTokens? tokens = theme.extension<SkinTokens>();
      expect(tokens, isNotNull, reason: '${skin.label}: token mancanti');
      expect(tokens!.skin, skin);
      expect(theme.scaffoldBackgroundColor, Colors.transparent, reason: 'lo sfondo lo dipinge SkinBackground');
    }
  });

  test('Lucido e Vetro hanno barre sfumate e pannelli chiari, Semplice no', () {
    final SkinTokens ios = AppTheme.light(AppSkin.ios1).extension<SkinTokens>()!;
    final SkinTokens aero = AppTheme.light(AppSkin.aero).extension<SkinTokens>()!;
    final SkinTokens base = AppTheme.light(AppSkin.originale).extension<SkinTokens>()!;

    expect(base.barGradient, isNull);
    expect(base.glossyCovers, isFalse);
    expect(ios.barGradient, isNotNull);
    expect(ios.glossyCovers, isTrue, reason: 'le copertine hanno il riflesso del primo iPhone');
    expect(aero.barGradient, isNotNull);
    expect(aero.panelGloss, isTrue);
    // Il testo dei pannelli deve restare scuro su vetro chiaro, altrimenti al
    // sole non si legge.
    expect(aero.onPanel.computeLuminance(), lessThan(0.3));
    expect(ios.onPanel.computeLuminance(), lessThan(0.3));
  });

  group('testo appoggiato sullo sfondo della grafica', () {
    test('su Vetro è chiaro, su Lucido è scuro: segue il suo sfondo', () {
      final SkinTokens aero = AppTheme.light(AppSkin.aero).extension<SkinTokens>()!;
      final SkinTokens ios = AppTheme.light(AppSkin.ios1).extension<SkinTokens>()!;
      // Il blu notte dei pannelli sul blu dello sfondo era il difetto: su Vetro
      // fuori dai pannelli il testo va chiaro.
      expect(aero.onBackdrop.computeLuminance(), greaterThan(0.8));
      expect(aero.onBackdrop.computeLuminance(), greaterThan(aero.onPanel.computeLuminance()));
      // Lucido ha lo sfondo a righine chiare: lì il testo resta scuro.
      expect(ios.onBackdrop.computeLuminance(), lessThan(0.3));
    });

    test('il contrasto con lo sfondo regge', () {
      for (final AppSkin skin in AppSkin.values) {
        final SkinTokens t = AppTheme.light(skin).extension<SkinTokens>()!;
        expect(
          _contrast(t.onBackdrop, t.backdropBase),
          greaterThanOrEqualTo(4.5),
          reason: '${skin.label}: il testo principale sullo sfondo',
        );
        expect(
          _contrast(t.onBackdropMuted, t.backdropBase),
          greaterThanOrEqualTo(3),
          reason: '${skin.label}: le righe secondarie, tipo l\'anno di uscita',
        );
      }
    });

    test('dove lo sfondo si schiarisce il testo ha un\'ombra che lo stacca', () {
      final SkinTokens aero = AppTheme.light(AppSkin.aero).extension<SkinTokens>()!;
      // L'angolo più chiaro della sfumatura di Vetro (widgets.dart, SkinBackground).
      const Color chiaro = Color(0xFF5AA6E8);
      expect(
        _contrast(aero.onBackdrop, chiaro),
        lessThan(4.5),
        reason: 'se un giorno il contrasto bastasse da solo, l\'ombra si può togliere',
      );
      expect(aero.backdropShadows, isNotEmpty, reason: 'è l\'ombra a reggere la zona chiara');
    });
  });

  test('ogni grafica ha la sua transizione, e nessuna dipinge un fondo opaco', () {
    final Map<AppSkin, Type> attese = <AppSkin, Type>{
      AppSkin.originale: PredictiveBackPageTransitionsBuilder,
      AppSkin.ios1: CupertinoPageTransitionsBuilder,
      AppSkin.aero: AeroPageTransitionsBuilder,
    };
    for (final AppSkin skin in AppSkin.values) {
      final PageTransitionsTheme transitions = AppTheme.light(skin).pageTransitionsTheme;
      for (final TargetPlatform platform in TargetPlatform.values) {
        expect(
          transitions.builders[platform].runtimeType,
          attese[skin],
          reason: '${skin.label} su $platform: una voce mancante ricadrebbe in silenzio sullo zoom di serie',
        );
      }
    }
    // Era questo il «taglio netto»: un rettangolo color superficie, a tutto
    // schermo, acceso di colpo dietro la pagina che esce.
    final PageTransitionsBuilder originale =
        AppTheme.light(AppSkin.originale).pageTransitionsTheme.builders[TargetPlatform.android]!;
    expect((originale as PredictiveBackPageTransitionsBuilder).fallbackColor, Colors.transparent);
  });

  test('cambiando grafica i token si sfumano invece di scattare a metà', () {
    final SkinTokens aero = AppTheme.light(AppSkin.aero).extension<SkinTokens>()!;
    final SkinTokens ios = AppTheme.light(AppSkin.ios1).extension<SkinTokens>()!;
    final SkinTokens mezzo = aero.lerp(ios, 0.5);

    expect(mezzo.onBackdrop, isNot(aero.onBackdrop));
    expect(mezzo.onBackdrop, isNot(ios.onBackdrop));
    expect(mezzo.panelRadius, closeTo((aero.panelRadius + ios.panelRadius) / 2, 0.001));
    expect(mezzo.panelColor, Color.lerp(aero.panelColor, ios.panelColor, 0.5));
  });

  test('copyWith copia davvero', () {
    final SkinTokens aero = AppTheme.light(AppSkin.aero).extension<SkinTokens>()!;
    expect(aero.copyWith(skin: AppSkin.originale).skin, AppSkin.originale);
    expect(aero.copyWith(skin: AppSkin.originale).panelColor, aero.panelColor);
    expect(aero.copyWith().onBackdrop, aero.onBackdrop);
  });

  test('anche in tema scuro Lucido e Vetro restano chiari', () {
    expect(AppTheme.dark(AppSkin.ios1).colorScheme.brightness, Brightness.light);
    expect(AppTheme.dark(AppSkin.aero).colorScheme.brightness, Brightness.light);
    expect(AppTheme.dark(AppSkin.originale).colorScheme.brightness, Brightness.dark);
  });

  test('le etichette delle grafiche non usano marchi altrui ne nomi di persone', () {
    // Descrivere a cosa somiglia una grafica è lecito, e nei commenti del codice
    // lo si fa. Usare il nome di un'azienda come nome di una funzione dell'app, o
    // il nome di una persona reale per darle colore, è un'altra cosa: suggerisce
    // un rapporto che non esiste. Le etichette descrivono l'aspetto e basta.
    const List<String> vietati = <String>[
      'apple', 'iphone', 'ios', 'mac', 'jobs',
      'windows', 'microsoft', 'vista', 'aero',
      'google', 'android', 'nintendo', 'sony', 'playstation', 'xbox', 'sega',
    ];
    for (final AppSkin skin in AppSkin.values) {
      final String visibile = '${skin.label} ${skin.description}'.toLowerCase();
      for (final String parola in vietati) {
        expect(
          visibile.contains(parola),
          isFalse,
          reason: 'la grafica «${skin.label}» cita «$parola» in un testo che l\'utente vede',
        );
      }
    }
  });
}
