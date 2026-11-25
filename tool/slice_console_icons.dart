// Genera le icone delle console dal foglio di riferimento assets/source/console.png:
// 8 colonne x 4 righe di disegni chiari su fondo scuro, ognuno con il nome sotto.
//
// Uso: dart run tool/slice_console_icons.dart
//
// Ogni disegno viene isolato cercando nella sua colonna le fasce verticali con
// «inchiostro» (le scritte sotto sono basse e vengono scartate), ritagliato, reso
// quadrato e salvato come maschera bianca con trasparenza: nell'app viene colorata
// con il colore del tema. Scrive anche build/console_sheet.png per un controllo a vista.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

const List<String> keys = <String>[
  'nes', 'snes', 'n64', 'gamecube', 'wii', 'wiiu', 'switch', 'switch2',
  'gb', 'gbc', 'gba', 'ds', '3ds', 'ps1', 'ps2', 'ps3',
  'ps4', 'ps5', 'psp', 'psvita', 'xbox', 'xbox360', 'xboxone', 'xboxxs',
  'sms', 'megadrive', 'saturn', 'dreamcast', 'pc', 'atari2600', 'neogeo', 'mobile',
];

const int columns = 8;
const int rows = 4;
const int outputSize = 128;
const double inkThreshold = 0.3;

void main() {
  final img.Image sheet = img.decodeImage(File('assets/source/console.png').readAsBytesSync())!;
  final int w = sheet.width;
  final int h = sheet.height;
  stdout.writeln('Foglio: ${w}x$h');

  final Float32List lum = Float32List(w * h);
  for (final img.Pixel p in sheet) {
    lum[p.y * w + p.x] = (0.299 * p.rNormalized + 0.587 * p.gNormalized + 0.114 * p.bNormalized).toDouble();
  }
  double at(int x, int y) => lum[y * w + x];

  Directory('assets/consoles').createSync(recursive: true);
  Directory('build').createSync(recursive: true);
  const int cell = outputSize + 12;
  final img.Image preview = img.Image(width: columns * cell, height: rows * cell);
  img.fill(preview, color: img.ColorRgb8(40, 40, 48));

  for (int c = 0; c < columns; c++) {
    final int x0 = (c * w / columns).round();
    final int x1 = ((c + 1) * w / columns).round();

    // Fasce verticali con inchiostro; interruzioni fino a 4 pixel restano unite.
    final List<(int, int)> bands = <(int, int)>[];
    int? start;
    int lastInk = -100;
    for (int y = 0; y < h; y++) {
      bool ink = false;
      for (int x = x0; x < x1 && !ink; x++) {
        if (at(x, y) > inkThreshold) ink = true;
      }
      if (!ink) continue;
      if (start == null || y - lastInk > 4) {
        if (start != null) bands.add((start, lastInk));
        start = y;
      }
      lastInk = y;
    }
    if (start != null) bands.add((start, lastInk));

    final List<(int, int)> drawings = bands.where(((int, int) b) => b.$2 - b.$1 >= 45).toList();
    stdout.writeln('Colonna $c: ${bands.map(((int, int) b) => '${b.$1}-${b.$2}').join('  ')}');
    if (drawings.length != rows) {
      stderr.writeln('Colonna $c: attesi $rows disegni, trovati ${drawings.length}');
      exitCode = 1;
      return;
    }

    for (int r = 0; r < rows; r++) {
      final (int y0, int y1) = drawings[r];
      // Estensione orizzontale del disegno: nelle sue righe si cercano i tratti con
      // inchiostro anche un po' oltre la colonna e si tiene quello che la occupa di
      // più. Così un disegno che sborda resta intero e il bordo del vicino non entra.
      // Buchi fino a 14 pixel restano uniti (monitor e case del PC), mentre fra due
      // disegni vicini ce ne sono sempre più di 30.
      final int wx0 = math.max(0, x0 - 60);
      final int wx1 = math.min(w, x1 + 60);
      final List<(int, int)> runs = <(int, int)>[];
      int? runStart;
      int lastX = -100;
      for (int x = wx0; x < wx1; x++) {
        bool ink = false;
        for (int y = y0; y <= y1 && !ink; y++) {
          if (at(x, y) > inkThreshold) ink = true;
        }
        if (!ink) continue;
        if (runStart == null || x - lastX > 14) {
          if (runStart != null) runs.add((runStart, lastX));
          runStart = x;
        }
        lastX = x;
      }
      if (runStart != null) runs.add((runStart, lastX));
      int overlap((int, int) run) => math.max(0, math.min(run.$2, x1 - 1) - math.max(run.$1, x0) + 1).toInt();
      runs.sort(((int, int) a, (int, int) b) => overlap(b).compareTo(overlap(a)));
      final int minX = runs.first.$1;
      final int maxX = runs.first.$2;

      final int side = math.max(maxX - minX, y1 - y0) + 16;
      final int left = (minX + maxX) ~/ 2 - side ~/ 2;
      final int top = (y0 + y1) ~/ 2 - side ~/ 2;
      final img.Image mask = img.Image(width: side, height: side, numChannels: 4);
      for (int y = 0; y < side; y++) {
        for (int x = 0; x < side; x++) {
          double v = 0;
          // Dilatazione 3x3: le linee sottili restano visibili anche a 14-16 dp.
          for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
              final int px = left + x + dx;
              final int py = top + y + dy;
              if (px >= minX && px <= maxX && py >= y0 && py <= y1) v = math.max(v, at(px, py));
            }
          }
          mask.setPixelRgba(x, y, 255, 255, 255, (v * 255).round());
        }
      }

      final img.Image icon = img.copyResize(
        mask,
        width: outputSize,
        height: outputSize,
        interpolation: img.Interpolation.average,
      );
      for (final img.Pixel p in icon) {
        p.a = math.min(255, p.a * 1.7);
      }
      final String key = keys[r * columns + c];
      File('assets/consoles/$key.png').writeAsBytesSync(img.encodePng(icon));
      img.compositeImage(preview, icon, dstX: c * cell + 6, dstY: r * cell + 6);
    }
  }

  File('build/console_sheet.png').writeAsBytesSync(img.encodePng(preview));
  stdout.writeln('Scritte ${keys.length} icone in assets/consoles');
}
