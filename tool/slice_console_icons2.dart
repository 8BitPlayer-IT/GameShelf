// Genera le icone delle console dal secondo foglio di riferimento
// assets/source/console2.webp: due file con un numero diverso di disegni (5 e 4),
// ognuno con il nome sotto.
//
// Uso: dart run tool/slice_console_icons2.dart
//
// A differenza del primo foglio qui la griglia non è regolare, quindi i disegni si
// cercano così: prima le fasce orizzontali con «inchiostro» (le scritte sotto sono
// basse e vengono scartate), poi dentro ogni fascia i gruppi separati da spazi
// larghi. Ogni ritaglio diventa una maschera bianca con trasparenza, che nell'app
// viene colorata con il colore del tema. Scrive anche build/console_sheet2.png per
// un controllo a vista.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Chiavi nell'ordine di lettura: prima fila di 5, poi fila di 4.
const List<String> keys = <String>[
  'arcade', 'atari7800', 'intellivision', 'segacd', 'gamegear',
  'c64', 'vic20', 'atari400', 'amiga',
];

const int outputSize = 128;
const double inkThreshold = 0.3;

/// Spazio vuoto che separa due disegni affiancati; sotto questa soglia le parti di
/// uno stesso disegno (tastiera e monitor, cabinato e base) restano unite.
const int columnGap = 26;

void main() {
  final img.Image sheet = img.decodeImage(File('assets/source/console2.webp').readAsBytesSync())!;
  final int w = sheet.width;
  final int h = sheet.height;
  stdout.writeln('Foglio: ${w}x$h');

  final Float32List lum = Float32List(w * h);
  for (final img.Pixel p in sheet) {
    lum[p.y * w + p.x] = (0.299 * p.rNormalized + 0.587 * p.gNormalized + 0.114 * p.bNormalized).toDouble();
  }
  double at(int x, int y) => lum[y * w + x];

  /// Intervalli consecutivi con inchiostro lungo un asse.
  List<(int, int)> runs(int from, int to, int maxGap, bool Function(int) hasInk) {
    final List<(int, int)> found = <(int, int)>[];
    int? start;
    int last = -1000;
    for (int i = from; i < to; i++) {
      if (!hasInk(i)) continue;
      if (start == null || i - last > maxGap) {
        if (start != null) found.add((start, last));
        start = i;
      }
      last = i;
    }
    if (start != null) found.add((start, last));
    return found;
  }

  final List<(int, int)> bands = runs(0, h, 6, (int y) {
    for (int x = 0; x < w; x++) {
      if (at(x, y) > inkThreshold) return true;
    }
    return false;
  });
  // Le fasce alte sono i disegni, quelle basse i nomi scritti sotto.
  final List<(int, int)> rows = bands.where(((int, int) b) => b.$2 - b.$1 >= 45).toList();
  stdout.writeln('Fasce: ${bands.map(((int, int) b) => '${b.$1}-${b.$2}').join('  ')}');

  Directory('assets/consoles').createSync(recursive: true);
  Directory('build').createSync(recursive: true);
  const int cell = outputSize + 12;
  int written = 0;
  final List<List<(int, int)>> perRow = <List<(int, int)>>[];
  for (final (int y0, int y1) in rows) {
    perRow.add(
      runs(0, w, columnGap, (int x) {
        for (int y = y0; y <= y1; y++) {
          if (at(x, y) > inkThreshold) return true;
        }
        return false;
      }),
    );
  }
  final int columns = perRow.fold<int>(0, (int m, List<(int, int)> r) => math.max(m, r.length));
  final img.Image preview = img.Image(width: columns * cell, height: rows.length * cell);
  img.fill(preview, color: img.ColorRgb8(40, 40, 48));

  for (final (int rowIndex, (int y0, int y1)) in rows.indexed) {
    final List<(int, int)> columnsInRow = perRow[rowIndex];
    stdout.writeln('Fila ${rowIndex + 1}: ${columnsInRow.length} disegni');
    for (final (int i, (int x0, int x1)) in columnsInRow.indexed) {
      if (written >= keys.length) {
        stderr.writeln('Trovati più disegni dei nomi previsti (${keys.length})');
        exitCode = 1;
        return;
      }
      final int side = math.max(x1 - x0, y1 - y0) + 16;
      final int left = (x0 + x1) ~/ 2 - side ~/ 2;
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
              if (px >= x0 && px <= x1 && py >= y0 && py <= y1) v = math.max(v, at(px, py));
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
      File('assets/consoles/${keys[written]}.png').writeAsBytesSync(img.encodePng(icon));
      img.compositeImage(preview, icon, dstX: i * cell + 6, dstY: rowIndex * cell + 6);
      written++;
    }
  }

  File('build/console_sheet2.png').writeAsBytesSync(img.encodePng(preview));
  stdout.writeln('Scritte $written icone su ${keys.length} in assets/consoles');
  if (written != keys.length) exitCode = 1;
}
