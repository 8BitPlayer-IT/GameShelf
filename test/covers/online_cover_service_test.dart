import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/data/cover_cropper.dart';
import 'package:gameshelf/data/covers/online_cover_service.dart';
import 'package:image/image.dart' as img;

/// Una rete finta: nessun test tocca internet.
class FakeNet {
  FakeNet(this.replies);

  /// Da sottostringa dell'URL alla risposta da dare.
  final Map<String, CoverResponse> replies;
  final List<Uri> requested = <Uri>[];

  /// Se vero, ogni richiesta fallisce come se non ci fosse rete.
  bool offline = false;

  Future<CoverResponse> call(Uri url) async {
    requested.add(url);
    if (offline) throw const SocketException('nessuna rete');
    for (final MapEntry<String, CoverResponse> e in replies.entries) {
      if (url.toString().contains(e.key)) return e.value;
    }
    return CoverResponse(404, Uint8List(0));
  }
}

CoverResponse _json(Object body) =>
    CoverResponse(200, Uint8List.fromList(utf8.encode(jsonEncode(body))), contentType: 'application/json');

/// Un PNG vero e minuscolo, con la firma che il servizio controlla.
Uint8List _png({int width = 60, int height = 80}) {
  final img.Image image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(20, 80, 160));
  return Uint8List.fromList(img.encodePng(image));
}

CoverResponse _image({int width = 60, int height = 80}) =>
    CoverResponse(200, _png(width: width, height: height), contentType: 'image/png');

Future<Uint8List> _fromDisk(String assetPath) async => File(assetPath).readAsBytes();

void main() {
  group('Steam', () {
    test('trova il gioco e costruisce l URL della copertina verticale', () async {
      final FakeNet net = FakeNet(<String, CoverResponse>{
        'storesearch': _json(<String, Object?>{
          'total': 2,
          'items': <Object?>[
            // Prima viene una colonna sonora col titolo simile: va scartata.
            <String, Object?>{'type': 'app', 'name': 'Hollow Knight: Silksong', 'id': 1030300},
            <String, Object?>{'type': 'app', 'name': 'Hollow Knight', 'id': 367520},
          ],
        }),
      });
      final OnlineCoverService service = OnlineCoverService(fetch: net.call, indexLoader: _fromDisk);

      final CoverSearchResult result = await service.search('Hollow Knight', consoles: <String>['PC']);
      expect(result.found, isTrue);
      expect(result.candidate!.source, 'Steam');
      expect(result.candidate!.matchedTitle, 'Hollow Knight');
      expect(result.candidate!.imageUrl.toString(), contains('/apps/367520/library_600x900.jpg'));
      expect(result.candidate!.fallbackUrl, isNotNull);
    });

    test('un titolo che non esiste non da nessuna copertina, ma vale dirlo', () async {
      final FakeNet net = FakeNet(<String, CoverResponse>{
        'storesearch': _json(<String, Object?>{'total': 0, 'items': <Object?>[]}),
      });
      final OnlineCoverService service = OnlineCoverService(fetch: net.call, indexLoader: _fromDisk);

      final CoverSearchResult result = await service.search('Zorblax Hyperdrive 9', consoles: <String>['PC']);
      expect(result.found, isFalse);
      expect(result.worthTelling, isTrue);
    });

    test('i contenuti aggiuntivi non sono giochi', () async {
      final FakeNet net = FakeNet(<String, CoverResponse>{
        'storesearch': _json(<String, Object?>{
          'items': <Object?>[
            <String, Object?>{'type': 'dlc', 'name': 'Cyberpunk 2077', 'id': 1},
          ],
        }),
      });
      final OnlineCoverService service = OnlineCoverService(fetch: net.call, indexLoader: _fromDisk);
      expect((await service.search('Cyberpunk 2077', consoles: <String>['PC'])).found, isFalse);
    });

    test('senza rete non si dice niente', () async {
      final FakeNet net = FakeNet(<String, CoverResponse>{})..offline = true;
      final OnlineCoverService service = OnlineCoverService(fetch: net.call, indexLoader: _fromDisk);

      final CoverSearchResult result = await service.search('Hollow Knight', consoles: <String>['PC']);
      expect(result.found, isFalse);
      expect(result.worthTelling, isFalse, reason: 'offline vuol dire «non ho potuto guardare»');
    });
  });

  group('instradamento', () {
    test('senza console si interroga solo Steam', () async {
      final FakeNet net = FakeNet(<String, CoverResponse>{
        'storesearch': _json(<String, Object?>{'items': <Object?>[]}),
      });
      final OnlineCoverService service = OnlineCoverService(fetch: net.call, indexLoader: _fromDisk);

      await service.search('Un gioco qualsiasi');
      expect(net.requested, hasLength(1));
      expect(net.requested.single.host, 'store.steampowered.com');
    });

    test('una console senza fonte non fa partire nessuna richiesta', () async {
      final FakeNet net = FakeNet(<String, CoverResponse>{});
      final OnlineCoverService service = OnlineCoverService(fetch: net.call, indexLoader: _fromDisk);

      final CoverSearchResult result = await service.search('Alto s Odyssey', consoles: <String>['Android']);
      expect(result.found, isFalse);
      expect(net.requested, isEmpty, reason: 'Google Play non ha una ricerca pubblica');
    });

    test('una console retro non interroga nessun negozio: l indice e in locale', () async {
      final FakeNet net = FakeNet(<String, CoverResponse>{});
      final OnlineCoverService service = OnlineCoverService(fetch: net.call, indexLoader: _fromDisk);

      final CoverSearchResult result = await service.search(
        'Super Mario World',
        consoles: <String>['Super Nintendo'],
      );
      expect(result.candidate?.source, 'Libretro');
      expect(result.candidate!.imageUrl.host, 'raw.githubusercontent.com');
      expect(result.candidate!.imageUrl.path, contains('Named_Boxarts'));
      expect(net.requested, isEmpty, reason: 'la corrispondenza si calcola senza rete');
    });

    test('PlayStation 5 non ha Libretro e ripiega su Steam', () async {
      final FakeNet net = FakeNet(<String, CoverResponse>{
        'storesearch': _json(<String, Object?>{
          'items': <Object?>[
            <String, Object?>{'type': 'app', 'name': 'Cyberpunk 2077', 'id': 1091500},
          ],
        }),
      });
      final OnlineCoverService service = OnlineCoverService(fetch: net.call, indexLoader: _fromDisk);

      final CoverSearchResult result = await service.search(
        'Cyberpunk 2077',
        consoles: <String>['PlayStation 5'],
      );
      expect(result.candidate?.source, 'Steam');
    });
  });

  group('Nintendo e App Store', () {
    test('si prende il packshot, non il banner ne l icona quadrata', () async {
      final FakeNet net = FakeNet(<String, CoverResponse>{
        'nintendo-europe': _json(<String, Object?>{
          'response': <String, Object?>{
            'docs': <Object?>[
              <String, Object?>{
                'title': 'Super Mario Odyssey',
                'image_url': 'https://www.nintendo.com/eu/media/images/05_packshots/PS_mario.jpg',
                'image_url_sq_s': 'https://www.nintendo.com/eu/media/images/11_square_images/SQ_mario.jpg',
                'image_url_h2x1_s': 'https://www.nintendo.com/eu/media/images/10_share_images/H2x1_mario.jpg',
              },
            ],
          },
        }),
      });
      final OnlineCoverService service = OnlineCoverService(fetch: net.call, indexLoader: _fromDisk);

      final CoverSearchResult result = await service.search(
        'Super Mario Odyssey',
        consoles: <String>['Nintendo Switch'],
      );
      expect(result.candidate?.source, 'eShop Nintendo');
      expect(result.candidate!.imageUrl.path, contains('05_packshots'));
    });

    test('iOS passa per l App Store', () async {
      final FakeNet net = FakeNet(<String, CoverResponse>{
        'itunes.apple.com': _json(<String, Object?>{
          'results': <Object?>[
            <String, Object?>{
              'trackName': 'Monument Valley',
              'artworkUrl512': 'https://is1-ssl.mzstatic.com/image/thumb/x/512x512bb.jpg',
            },
          ],
        }),
      });
      final OnlineCoverService service = OnlineCoverService(fetch: net.call, indexLoader: _fromDisk);

      final CoverSearchResult result = await service.search('Monument Valley', consoles: <String>['iOS']);
      expect(result.candidate?.source, 'App Store');
    });
  });

  group('scaricamento', () {
    test('se il primo host non ha l immagine si prova l altro', () async {
      final FakeNet net = FakeNet(<String, CoverResponse>{'cdn.cloudflare': _image()});
      final OnlineCoverService service = OnlineCoverService(fetch: net.call, indexLoader: _fromDisk);

      final Uint8List? bytes = await service.download(
        CoverCandidate(
          imageUrl: Uri.parse('https://shared.akamai.steamstatic.com/a.jpg'),
          fallbackUrl: Uri.parse('https://cdn.cloudflare.steamstatic.com/a.jpg'),
          matchedTitle: 'x',
          source: 'Steam',
        ),
      );
      expect(bytes, isNotNull);
      expect(net.requested, hasLength(2));
    });

    test('un collegamento simbolico di Libretro viene seguito', () async {
      // Certi file di libretro-thumbnails sono link: scaricati danno una riga di
      // testo col nome del file vero invece dell immagine.
      final FakeNet net = FakeNet(<String, CoverResponse>{
        'Alias': CoverResponse(
          200,
          Uint8List.fromList(utf8.encode('Gioco Vero (Europe).png')),
          contentType: 'text/plain',
        ),
        'Gioco%20Vero': _image(),
      });
      final OnlineCoverService service = OnlineCoverService(fetch: net.call, indexLoader: _fromDisk);

      final Uint8List? bytes = await service.download(
        CoverCandidate(
          imageUrl: Uri.https('raw.githubusercontent.com', '/x/master/Named_Boxarts/Alias (Europe).png'),
          matchedTitle: 'Alias (Europe)',
          source: 'Libretro',
        ),
      );
      expect(bytes, isNotNull);
      expect(img.decodePng(bytes!), isNotNull);
    });

    test('una risposta che non e un immagine non viene accettata', () async {
      final FakeNet net = FakeNet(<String, CoverResponse>{
        'x.png': CoverResponse(200, Uint8List.fromList(utf8.encode('<html>404</html>'))),
      });
      final OnlineCoverService service = OnlineCoverService(fetch: net.call, indexLoader: _fromDisk);

      expect(
        await service.download(
          CoverCandidate(imageUrl: Uri.parse('https://esempio.test/x.png'), matchedTitle: 'x', source: 'y'),
        ),
        isNull,
      );
    });
  });

  group('incorniciatura in 3:4', () {
    late Directory temp;

    setUp(() async => temp = await Directory.systemTemp.createTemp('gameshelf_cover'));
    tearDown(() async => temp.delete(recursive: true));

    Future<img.Image> frame(int width, int height) async {
      final String target = '${temp.path}${Platform.pathSeparator}out.jpg';
      frameDownloadedCover(bytes: _png(width: width, height: height), targetPath: target);
      final img.Image? out = img.decodeImage(File(target).readAsBytesSync());
      expect(out, isNotNull);
      return out!;
    }

    test('un icona quadrata diventa 3:4 senza perdere niente', () async {
      final img.Image out = await frame(512, 512);
      expect(out.width / out.height, closeTo(coverAspect, 0.01));
      expect(out.width, 512, reason: 'non si ingrandisce mai l originale');
    });

    test('un immagine orizzontale diventa 3:4', () async {
      final img.Image out = await frame(512, 357);
      expect(out.width / out.height, closeTo(coverAspect, 0.01));
    });

    test('una copertina 2:3 di Steam diventa 3:4', () async {
      final img.Image out = await frame(300, 450);
      expect(out.width / out.height, closeTo(coverAspect, 0.01));
      expect(out.height, 450);
    });

    test('un immagine gia 3:4 resta come e', () async {
      final img.Image out = await frame(600, 800);
      expect(out.width, 600);
      expect(out.height, 800);
    });

    test('un immagine illeggibile fa errore invece di salvare spazzatura', () {
      expect(
        () => frameDownloadedCover(
          bytes: Uint8List.fromList(utf8.encode('non sono una immagine')),
          targetPath: '${temp.path}${Platform.pathSeparator}no.jpg',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
