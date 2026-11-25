import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Ritaglio della copertina in formato 3:4.
///
/// La cornice resta ferma e sotto si sposta e si ingrandisce l'immagine: la cornice
/// è sempre coperta, quindi l'area scelta non può uscire dall'immagine. Restituisce
/// l'area scelta in frazioni dell'immagine (0..1), oppure `null` se si annulla.
class CoverCropScreen extends StatefulWidget {
  const CoverCropScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<CoverCropScreen> createState() => _CoverCropScreenState();
}

class _CoverCropScreenState extends State<CoverCropScreen> {
  final TransformationController _controller = TransformationController();
  Size? _imageSize;
  bool _unreadable = false;
  Size? _frame;
  Size? _content;
  bool _viewerBuilt = false;

  @override
  void initState() {
    super.initState();
    _readSize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Dimensioni dell'immagine come la mostra Flutter, orientamento EXIF compreso.
  Future<void> _readSize() async {
    try {
      final ui.Codec codec = await ui.instantiateImageCodec(await File(widget.imagePath).readAsBytes());
      final ui.FrameInfo frame = await codec.getNextFrame();
      final Size size = Size(frame.image.width.toDouble(), frame.image.height.toDouble());
      frame.image.dispose();
      codec.dispose();
      if (mounted) setState(() => _imageSize = size);
    } catch (_) {
      if (mounted) setState(() => _unreadable = true);
    }
  }

  void _confirm() {
    final Size? frame = _frame;
    final Size? content = _content;
    if (frame == null || content == null) return;
    // La parte di immagine visibile nella cornice, riportata alle coordinate
    // dell'immagine con la trasformazione inversa.
    final Rect visible = MatrixUtils.transformRect(Matrix4.inverted(_controller.value), Offset.zero & frame);
    Navigator.of(context).pop(
      Rect.fromLTRB(
        visible.left / content.width,
        visible.top / content.height,
        visible.right / content.width,
        visible.bottom / content.height,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size? image = _imageSize;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        leading: IconButton(
          tooltip: 'Annulla',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Ritaglia la copertina'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(onPressed: image == null ? null : _confirm, child: const Text('Fatto')),
          ),
        ],
      ),
      body: _unreadable
          ? const Center(child: Text('Immagine non leggibile', style: TextStyle(color: Colors.white70)))
          : image == null
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double frameWidth = constraints.maxWidth - 48;
                double frameHeight = frameWidth * 4 / 3;
                final double maxHeight = constraints.maxHeight - 96;
                if (frameHeight > maxHeight) {
                  frameHeight = maxHeight;
                  frameWidth = frameHeight * 3 / 4;
                }
                final Size frame = Size(frameWidth, frameHeight);
                // L'immagine parte grande quanto basta a coprire tutta la cornice.
                final double scale = math.max(frameWidth / image.width, frameHeight / image.height);
                final Size content = Size(image.width * scale, image.height * scale);

                if (frame != _frame) {
                  // Prima disposizione o schermo ruotato: posizione iniziale. Le
                  // scansioni delle scatole sono larghe e hanno il fronte a destra.
                  final bool wideScan = image.width / image.height > 1.2;
                  final Matrix4 initial = Matrix4.translationValues(
                    wideScan ? frameWidth - content.width : (frameWidth - content.width) / 2,
                    (frameHeight - content.height) / 2,
                    0,
                  );
                  if (_viewerBuilt) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.value = initial);
                  } else {
                    _controller.value = initial;
                  }
                }
                _frame = frame;
                _content = content;
                _viewerBuilt = true;

                return Column(
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: Container(
                          width: frameWidth,
                          height: frameHeight,
                          foregroundDecoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2)),
                          child: ClipRect(
                            child: InteractiveViewer(
                              transformationController: _controller,
                              constrained: false,
                              minScale: 1,
                              maxScale: 6,
                              boundaryMargin: EdgeInsets.zero,
                              child: SizedBox(
                                width: content.width,
                                height: content.height,
                                child: Image.file(File(widget.imagePath), fit: BoxFit.fill, gaplessPlayback: true),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Text(
                        'Trascina e allarga con due dita per inquadrare la copertina.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
