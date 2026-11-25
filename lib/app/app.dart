import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/native_bridge.dart';
import '../features/library/library_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stats/stats_screen.dart';
import '../ui/widgets.dart';
import 'providers.dart';
import 'theme.dart';

class GameShelfApp extends ConsumerWidget {
  const GameShelfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSkin skin = ref.watch(appSkinProvider).value ?? AppSkin.originale;
    return MaterialApp(
      title: 'GameShelf',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(skin),
      darkTheme: AppTheme.dark(skin),
      // Lucido e Vetro sono nati chiari: l'interruttore vale solo per Semplice.
      themeMode: skin.followsThemeMode ? (ref.watch(themeModeProvider).value ?? ThemeMode.system) : ThemeMode.light,
      // Lo sfondo della grafica sta dietro ogni schermata, che resta trasparente.
      builder: (BuildContext context, Widget? child) => SkinBackground(child: child ?? const SizedBox.shrink()),
      // Italiano forzato: anche selettori di date e menu di sistema restano in
      // italiano se il telefono è impostato in un'altra lingua.
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('it')],
      locale: const Locale('it'),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Tocco sul widget della schermata home: apre la scheda di quel gioco.
    NativeBridge.onOpenGame(_openGame);
    NativeBridge.takeLaunchGameId().then((int? id) {
      if (id != null) _openGame(id);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Il widget legge il database da solo: uscendo dall'app gli si chiede di
    // aggiornarsi, così mostra subito copertine aggiunte, cambiate o eliminate.
    if (state == AppLifecycleState.paused) NativeBridge.refreshWidgets();
  }

  void _openGame(int gameId) {
    if (!mounted) return;
    setState(() => _index = 0);
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
    openGameDetail(context, gameId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack: ogni scheda conserva scorrimento e filtri quando si cambia.
      body: IndexedStack(
        index: _index,
        children: const <Widget>[LibraryScreen(), StatsScreen(), SettingsScreen()],
      ),
      bottomNavigationBar: Stack(
        children: <Widget>[
          const Positioned.fill(child: SkinBarBackground(bottom: true)),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (int i) => setState(() => _index = i),
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Libreria',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: 'Statistiche',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Impostazioni',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
