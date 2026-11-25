// Il ritaglio delle copertine sostituisce uCrop, che andava in errore sulle
// scansioni larghe con il riquadro sul bordo destro («x + width must be <=
// bitmap.width()»). Questi test coprono proprio quel caso.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/data/cover_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

void main() {
  group('area di ritaglio in pixel', () {
    test('sul bordo destro, anche con errori di arrotondamento, non esce dall\'immagine', () {
      final CropBox box = cropBox(left: 0.5320000001, top: -0.0000001, right: 1.0000002, bottom: 1.0000001, imageWidth: 1600, imageHeight: 998);
      expect(box.x + box.width, lessThanOrEqualTo(1600));
      expect(box.y + box.height, lessThanOrEqualTo(998));
      expect(box.x, greaterThanOrEqualTo(0));
      expect(box.y, 0);
    });

    test('un\'area degenere resta comunque larga almeno un pixel', () {
      final CropBox box = cropBox(left: 1, top: 1, right: 1, bottom: 1, imageWidth: 100, imageHeight: 100);
      expect(box.width, greaterThanOrEqualTo(1));
      expect(box.height, greaterThanOrEqualTo(1));
      expect(box.x + box.width, lessThanOrEqualTo(100));
    });
  });

  test('ritaglia il fronte a destra di una scansione larga e salva un JPEG 3:4', () async {
    final Directory dir = await Directory.systemTemp.createTemp('gameshelf_cover');
    addTearDown(() => dir.delete(recursive: true));

    // Una «scansione» 2000 x 1248 come quella di Starwing: fronte sulla destra.
    final String source = p.join(dir.path, 'scansione.jpg');
    File(source).writeAsBytesSync(img.encodeJpg(img.Image(width: 2000, height: 1248)));
    final String target = p.join(dir.path, 'copertina.jpg');

    const double frontWidth = 1248 * 3 / 4 / 2000; // frazione di larghezza di un'area 3:4 alta quanto l'immagine
    cropCoverFile(
      sourcePath: source,
      targetPath: target,
      left: 1 - frontWidth,
      top: 0,
      right: 1.0000003,
      bottom: 1,
    );

    final img.Image cover = img.decodeJpg(File(target).readAsBytesSync())!;
    expect(cover.width, lessThanOrEqualTo(maxCoverWidth));
    expect(cover.width / cover.height, closeTo(0.75, 0.01));
  });
}
