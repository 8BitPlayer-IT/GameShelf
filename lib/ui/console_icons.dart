import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../domain/normalizer.dart';

/// Icone disponibili in assets/consoles, generate dai due fogli di riferimento con
/// tool/slice_console_icons.dart e tool/slice_console_icons2.dart.
const Set<String> _iconKeys = <String>{
  'nes', 'snes', 'n64', 'gamecube', 'wii', 'wiiu', 'switch', 'switch2',
  'gb', 'gbc', 'gba', 'ds', '3ds', 'ps1', 'ps2', 'ps3',
  'ps4', 'ps5', 'psp', 'psvita', 'xbox', 'xbox360', 'xboxone', 'xboxxs',
  'sms', 'megadrive', 'saturn', 'dreamcast', 'pc', 'atari2600', 'neogeo', 'mobile',
  'arcade', 'atari7800', 'intellivision', 'segacd', 'gamegear',
  'c64', 'vic20', 'atari400', 'amiga',
};

/// Sigle diverse che indicano la stessa console.
const Map<String, String> _aliases = <String, String>{
  'android': 'mobile',
  'ios': 'mobile',
  'intv': 'intellivision',
  'sgg': 'gamegear',
  'segagamegear': 'gamegear',
  'gg': 'gamegear',
  'megacd': 'segacd',
  'commodore64': 'c64',
  'commodorevic20': 'vic20',
  'vic': 'vic20',
  'amiga500': 'amiga',
  'commodoreamiga500': 'amiga',
  'a500': 'amiga',
};

/// Asset dell'icona per la sigla di una console (`PS Vita` → `psvita`), o `null`
/// per una console senza icona dedicata (per esempio una aggiunta dall'utente).
String? consoleIconAsset(String shortLabel) {
  final String key = normalize(shortLabel).replaceAll(' ', '');
  final String resolved = _aliases[key] ?? key;
  return _iconKeys.contains(resolved) ? 'assets/consoles/$resolved.png' : null;
}

/// Disegno della console, colorato come un'icona normale.
class ConsoleIcon extends StatelessWidget {
  const ConsoleIcon({super.key, required this.label, this.family, this.size = 24, this.color});

  final String label;

  /// Famiglia usata per l'icona generica quando la console non ha un disegno.
  final String? family;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color tint = color ?? IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final String? asset = consoleIconAsset(label);
    if (asset == null) return Icon(familyIcon(family ?? 'altro'), size: size, color: tint);
    return Image.asset(
      asset,
      width: size,
      height: size,
      color: tint,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
    );
  }
}
