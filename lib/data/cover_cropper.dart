import 'dart:io';

import 'package:image/image.dart' as img;

/// Larghezza massima di una copertina salvata: basta per la scheda di dettaglio e
/// tiene piccolo il file di backup.
const int maxCoverWidth = 1200;

typedef CropBox = ({int x, int y, int width, int height});

/// Converte l'area scelta (in frazioni dell'immagine, 0..1) in pixel.
///
/// L'area non può mai uscire dall'immagine: inizio arrotondato per difetto, fine
/// per eccesso, poi entrambi limitati ai bordi. È esattamente il calcolo che uCrop
/// sbagliava: arrotondando separatamente posizione e larghezza, con il riquadro sul
/// bordo destro la somma superava la larghezza dell'immagine di un pixel.
CropBox cropBox({
  required double left,
  required double top,
  required double right,
  required double bottom,
  required int imageWidth,
  required int imageHeight,
}) {
  final int x0 = (left * imageWidth).floor().clamp(0, imageWidth - 1);
  final int y0 = (top * imageHeight).floor().clamp(0, imageHeight - 1);
  final int x1 = (right * imageWidth).ceil().clamp(x0 + 1, imageWidth);
  final int y1 = (bottom * imageHeight).ceil().clamp(y0 + 1, imageHeight);
  return (x: x0, y: y0, width: x1 - x0, height: y1 - y0);
}

/// Ritaglia [sourcePath] nell'area indicata e salva un JPEG in [targetPath].
///
/// Pensata per girare in `Isolate.run`: usa solo `dart:io` e il pacchetto `image`,
/// nessun plugin. L'orientamento EXIF viene applicato prima del ritaglio, come fa
/// Flutter quando mostra l'immagine nella schermata di ritaglio.
void cropCoverFile({
  required String sourcePath,
  required String targetPath,
  required double left,
  required double top,
  required double right,
  required double bottom,
}) {
  final img.Image? decoded = img.decodeImage(File(sourcePath).readAsBytesSync());
  if (decoded == null) throw const FormatException('Immagine non leggibile');
  final img.Image image = img.bakeOrientation(decoded);

  final CropBox box = cropBox(
    left: left,
    top: top,
    right: right,
    bottom: bottom,
    imageWidth: image.width,
    imageHeight: image.height,
  );
  img.Image cover = img.copyCrop(image, x: box.x, y: box.y, width: box.width, height: box.height);
  if (cover.width > maxCoverWidth) {
    cover = img.copyResize(cover, width: maxCoverWidth, interpolation: img.Interpolation.average);
  }
  File(targetPath).writeAsBytesSync(img.encodeJpg(cover, quality: 88));
}
