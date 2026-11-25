import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../core/native_bridge.dart';
import 'cover_cropper.dart';

/// Copertine: scelta dalla galleria e salvataggio del ritaglio 3:4 nella cartella
/// documenti dell'app. Il ritaglio si fa nella schermata `CoverCropScreen`.
///
/// Nel database finisce solo il percorso RELATIVO (`covers/<uuid>.jpg`): quello
/// assoluto cambierebbe dopo un ripristino o su un altro telefono. Ogni nuova
/// copertina ha un nome nuovo, così la cache delle immagini non mostra la vecchia.
class CoverService {
  CoverService(this.documentsDir);

  final String documentsDir;

  File fileFor(String relativePath) => File(p.joinAll(<String>[documentsDir, ...p.posix.split(relativePath)]));

  /// Apre il selettore di file di sistema nella cartella dell'ultima copertina
  /// scelta (il selettore «Foto» di Android non permette di indicare da dove
  /// partire). Restituisce il file scelto già ridimensionato, o `null`.
  Future<String?> pickImage() => NativeBridge.pickCoverImage();

  /// Ritaglia [sourcePath] nell'area [region] (frazioni dell'immagine, 0..1) e
  /// restituisce il percorso relativo della nuova copertina.
  Future<String> saveCrop(String sourcePath, Rect region) async {
    final String relative = p.posix.join('covers', '${const Uuid().v4()}.jpg');
    final File target = fileFor(relative);
    await target.parent.create(recursive: true);
    final String targetPath = target.path;
    final double left = region.left;
    final double top = region.top;
    final double right = region.right;
    final double bottom = region.bottom;
    // Decodifica e codifica JPEG richiedono qualche centinaio di millisecondi:
    // fuori dal thread dell'interfaccia.
    await Isolate.run(
      () => cropCoverFile(
        sourcePath: sourcePath,
        targetPath: targetPath,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
    );
    return relative;
  }

  /// Salva una copertina scaricata da internet e restituisce il percorso
  /// relativo. L'immagine viene incorniciata in 3:4 (vedi
  /// `frameDownloadedCover`), così nel database entra una copertina come tutte
  /// le altre: niente di speciale da ricordare per quelle venute da fuori.
  Future<String> saveDownloaded(Uint8List bytes) async {
    final String relative = p.posix.join('covers', '${const Uuid().v4()}.jpg');
    final File target = fileFor(relative);
    await target.parent.create(recursive: true);
    final String targetPath = target.path;
    await Isolate.run(() => frameDownloadedCover(bytes: bytes, targetPath: targetPath));
    return relative;
  }

  Future<void> delete(String? relativePath) async {
    if (relativePath == null) return;
    final File file = fileFor(relativePath);
    if (await file.exists()) await file.delete();
  }
}
