import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

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

/// Proporzione di tutte le copertine dell'app.
const double coverAspect = 3 / 4;

/// Scarto entro il quale un'immagine si considera già 3:4 e non viene incorniciata.
const double _aspectTolerance = 0.02;

/// Salva in [targetPath] un JPEG 3:4 ricavato da [bytes], che arriva da internet.
///
/// Le fonti danno forme diverse: 2:3 da Steam, circa 3:5 i packshot di Nintendo,
/// quadrate le icone dell'App Store, e da Libretro la forma della scatola vera,
/// che per certi sistemi è perfino orizzontale. L'app invece mostra copertine
/// 3:4 in tutta la libreria.
///
/// Ritagliare sarebbe la via facile ma su un'immagine orizzontale taglierebbe
/// via il titolo del gioco, cioè la parte che serve. Quindi l'immagine viene
/// messa intera dentro una tela 3:4, e il vuoto attorno è l'immagine stessa
/// ingrandita, sfocata e scurita: lo stesso trucco dei lanciatori di giochi.
/// Così il database e tutta l'interfaccia continuano a vedere solo 3:4.
///
/// Pensata per `Isolate.run`: sfocatura e codifica JPEG costano qualche decimo
/// di secondo e non devono stare sul thread dell'interfaccia.
void frameDownloadedCover({required Uint8List bytes, required String targetPath}) {
  final img.Image? decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('Immagine scaricata non leggibile');
  final img.Image source = img.bakeOrientation(decoded);

  final double ratio = source.width / source.height;
  if ((ratio - coverAspect).abs() < _aspectTolerance) {
    final img.Image plain = source.width > maxCoverWidth
        ? img.copyResize(source, width: maxCoverWidth, interpolation: img.Interpolation.average)
        : source;
    File(targetPath).writeAsBytesSync(img.encodeJpg(plain, quality: 88));
    return;
  }

  // La tela non ingrandisce mai l'immagine: si parte dal lato che deve restare
  // intero, così una copertina di Steam da 300x450 non viene gonfiata a 900
  // pixel di larghezza diventando sfocata. Partire da un lato solo evita anche
  // di arrotondare due volte, che faceva uscire 451 pixel invece di 450.
  int width;
  int height;
  if (ratio < coverAspect) {
    height = source.height;
    width = (height * coverAspect).round();
  } else {
    width = source.width;
    height = (width / coverAspect).round();
  }
  if (width > maxCoverWidth) {
    width = maxCoverWidth;
    height = (width / coverAspect).round();
  }

  // Sfondo: si sfoca una miniatura e poi si ingrandisce. Sfocare a piena
  // risoluzione costerebbe secondi, e il risultato a occhio è lo stesso.
  img.Image backdrop = _fillCrop(source, math.max(width ~/ 8, 16), math.max(height ~/ 8, 16));
  backdrop = img.gaussianBlur(backdrop, radius: 4);
  backdrop = img.copyResize(backdrop, width: width, height: height, interpolation: img.Interpolation.cubic);
  backdrop = img.adjustColor(backdrop, brightness: 0.72, saturation: 1.2);

  final double fit = math.min(width / source.width, height / source.height);
  final img.Image art = img.copyResize(
    source,
    width: math.max((source.width * fit).round(), 1),
    height: math.max((source.height * fit).round(), 1),
    interpolation: img.Interpolation.average,
  );

  img.compositeImage(
    backdrop,
    art,
    dstX: ((width - art.width) / 2).round(),
    dstY: ((height - art.height) / 2).round(),
  );
  File(targetPath).writeAsBytesSync(img.encodeJpg(backdrop, quality: 88));
}

/// Riempie una tela [width]x[height] con [src] ingrandita quanto serve e
/// ritagliata al centro.
img.Image _fillCrop(img.Image src, int width, int height) {
  final double scale = math.max(width / src.width, height / src.height);
  final img.Image scaled = img.copyResize(
    src,
    width: math.max((src.width * scale).ceil(), width),
    height: math.max((src.height * scale).ceil(), height),
    interpolation: img.Interpolation.average,
  );
  return img.copyCrop(
    scaled,
    x: ((scaled.width - width) / 2).round().clamp(0, scaled.width - width),
    y: ((scaled.height - height) / 2).round().clamp(0, scaled.height - height),
    width: width,
    height: height,
  );
}
