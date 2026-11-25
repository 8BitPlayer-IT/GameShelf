/// Ricerca della copertina online: una GET per la ricerca, una per l'immagine.
///
/// Nessuna chiave, nessun token, nessun account, nessun server nostro. L'unica
/// cosa che esce dal telefono è il titolo del gioco (e per Nintendo il nome
/// della console), verso il negozio che corrisponde a quella console.
///
/// Per le console fuori commercio non esce nemmeno quello: l'indice dei nomi di
/// Libretro viaggia dentro l'APK, quindi la corrispondenza si calcola in locale
/// e la rete serve solo a scaricare l'immagine già individuata.
///
/// Regola unica e non negoziabile: **nel dubbio nessuna copertina**. Ogni fonte
/// deve restituire un titolo confrontabile, e se il confronto non convince si
/// passa alla fonte dopo o si rinuncia. Vedi `title_match.dart`.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import 'cover_routes.dart';
import 'libretro_index.dart';
import 'title_match.dart';

/// Una copertina trovata, pronta da proporre.
class CoverCandidate {
  const CoverCandidate({
    required this.imageUrl,
    required this.matchedTitle,
    required this.source,
    this.fallbackUrl,
  });

  /// Da dove si scarica l'immagine.
  final Uri imageUrl;

  /// Indirizzo alternativo per la stessa immagine, quando la fonte ne offre più
  /// di uno (Steam serve la stessa copertina da tre host).
  final Uri? fallbackUrl;

  /// Il nome con cui la fonte conosce il gioco: è quello che si mostra
  /// all'utente, così può accorgersi al volo se è un altro gioco.
  final String matchedTitle;

  /// Nome della fonte da scrivere nel riquadro della proposta.
  final String source;
}

/// Quanto si aspetta una singola richiesta. Oltre, si rinuncia in silenzio:
/// meglio nessuna proposta che un'app ferma a girare.
const Duration coverRequestTimeout = Duration(seconds: 4);

/// Oltre questa dimensione l'immagine non viene nemmeno scaricata: una
/// copertina sta in pochi centinaia di kB, e un file più grande è un errore
/// della fonte, non una copertina.
const int maxCoverDownloadBytes = 6 * 1024 * 1024;

/// Come si fa una richiesta. L'implementazione vera usa `dart:io`; i test ne
/// passano una finta, così la suite non tocca la rete.
typedef CoverFetch = Future<CoverResponse> Function(Uri url);

class CoverResponse {
  const CoverResponse(this.statusCode, this.bytes, {this.contentType});

  final int statusCode;
  final Uint8List bytes;
  final String? contentType;

  bool get ok => statusCode == 200 && bytes.isNotEmpty;
  String get text => utf8.decode(bytes, allowMalformed: true);
}

/// Richiesta vera, con `dart:io`: nessun pacchetto in più da mantenere.
Future<CoverResponse> httpFetch(Uri url) async {
  final HttpClient client = HttpClient()
    ..connectionTimeout = coverRequestTimeout
    ..userAgent = 'GameShelf (+https://github.com/8BitPlayer-IT/GameShelf)';
  try {
    final HttpClientRequest request = await client.getUrl(url);
    final HttpClientResponse response = await request.close();
    if (response.contentLength > maxCoverDownloadBytes) {
      return CoverResponse(response.statusCode, Uint8List(0));
    }
    final List<int> body = <int>[];
    await for (final List<int> chunk in response) {
      body.addAll(chunk);
      if (body.length > maxCoverDownloadBytes) {
        return CoverResponse(response.statusCode, Uint8List(0));
      }
    }
    return CoverResponse(
      response.statusCode,
      Uint8List.fromList(body),
      contentType: response.headers.contentType?.mimeType,
    );
  } finally {
    client.close(force: true);
  }
}

Future<Uint8List> _assetLoader(String path) async =>
    (await rootBundle.load(path)).buffer.asUint8List();

class OnlineCoverService {
  OnlineCoverService({CoverFetch? fetch, IndexLoader? indexLoader})
    : _fetch = fetch ?? httpFetch,
      _indexLoader = indexLoader ?? _assetLoader;

  final CoverFetch _fetch;
  final IndexLoader _indexLoader;

  /// Gli indici già letti. Conta per la ricerca in blocco: 500 giochi dello
  /// stesso sistema leggono e decomprimono l'indice una volta sola.
  final Map<String, LibretroIndex?> _indexes = <String, LibretroIndex?>{};

  Future<CoverResponse?> _try(Uri url, _Ctx ctx) async {
    try {
      return await _fetch(url).timeout(coverRequestTimeout);
    } on TimeoutException {
      ctx.networkFailed = true;
      return null;
    } on SocketException {
      // Nessuna rete: si rinuncia in silenzio, come deciso.
      ctx.networkFailed = true;
      return null;
    } on HttpException {
      ctx.networkFailed = true;
      return null;
    } on HandshakeException {
      ctx.networkFailed = true;
      return null;
    }
  }

  /// Cerca una copertina per [title], seguendo le fonti della prima console di
  /// [consoles] che ne ha. Senza console si prova solo Steam.
  ///
  /// Restituisce `null` se non c'è niente di certo: è l'esito normale, non un
  /// errore.
  Future<CoverSearchResult> search(String title, {List<String> consoles = const <String>[]}) async {
    final _Ctx ctx = _Ctx();
    if (title.trim().isEmpty) return const CoverSearchResult(null);

    final List<CoverRoute> routes = <CoverRoute>[
      for (final String c in consoles)
        if (coverRoutes[c] != null) coverRoutes[c]!,
    ];

    // Solo l'assenza di console fa ripiegare su Steam. Se le console ci sono ma
    // nessuna ha una fonte (un gioco solo Android), non si cerca: provare Steam
    // comunque significherebbe proporre la versione PC di un gioco che l'utente
    // ha detto di avere altrove, ed è il genere di copertina sbagliata che
    // vogliamo evitare.
    if (consoles.isEmpty) routes.add(coverRouteWithoutConsole);
    if (routes.isEmpty) return CoverSearchResult(null, networkFailed: ctx.networkFailed);

    for (final CoverRoute route in routes) {
      for (final CoverSource source in route.sources) {
        final CoverCandidate? found = switch (source) {
          CoverSource.libretro => await _fromLibretro(title, route.libretroSystem),
          CoverSource.steam => await _fromSteam(title, ctx),
          CoverSource.nintendoEshop => await _fromNintendo(title, ctx),
          CoverSource.itunes => await _fromItunes(title, ctx),
        };
        if (found != null) return CoverSearchResult(found);
      }
    }
    return CoverSearchResult(null, networkFailed: ctx.networkFailed);
  }

  // --------------------------------------------------------------- Libretro --

  Future<LibretroIndex?> _index(String system) async {
    if (_indexes.containsKey(system)) return _indexes[system];
    LibretroIndex? index;
    try {
      index = await LibretroIndex.load(system, _indexLoader);
    } catch (_) {
      // Indice mancante o illeggibile: quella console resta senza copertine,
      // ma l'app non si ferma.
      index = null;
    }
    _indexes[system] = index;
    return index;
  }

  Future<CoverCandidate?> _fromLibretro(String title, String? system) async {
    if (system == null) return null;
    final LibretroIndex? index = await _index(system);
    final String? name = index?.match(title);
    if (name == null) return null;
    return CoverCandidate(
      imageUrl: libretroBoxartUrl(system, name),
      matchedTitle: name,
      source: 'Libretro',
    );
  }

  // ------------------------------------------------------------------ Steam --

  Future<CoverCandidate?> _fromSteam(String title, _Ctx ctx) async {
    final Uri search = Uri.https('store.steampowered.com', '/api/storesearch/', <String, String>{
      'term': title,
      'l': 'english',
      'cc': 'us',
    });
    final CoverResponse? response = await _try(search, ctx);
    if (response == null || !response.ok) return null;

    final Object? decoded = _json(response.text);
    if (decoded is! Map<String, Object?>) return null;
    final Object? items = decoded['items'];
    if (items is! List<Object?>) return null;

    for (final Object? raw in items) {
      if (raw is! Map<String, Object?>) continue;
      // Solo i giochi: «app». I pacchetti e i contenuti aggiuntivi hanno un
      // titolo simile al gioco ma una copertina diversa o assente.
      if (raw['type'] != 'app') continue;
      final Object? name = raw['name'];
      final Object? id = raw['id'];
      if (name is! String || id is! num) continue;
      if (!titlesMatch(title, name)) continue;
      return CoverCandidate(
        imageUrl: Uri.parse(
          'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/${id.toInt()}/library_600x900.jpg',
        ),
        fallbackUrl: Uri.parse(
          'https://cdn.cloudflare.steamstatic.com/steam/apps/${id.toInt()}/library_600x900.jpg',
        ),
        matchedTitle: name,
        source: 'Steam',
      );
    }
    return null;
  }

  // --------------------------------------------------------------- Nintendo --

  Future<CoverCandidate?> _fromNintendo(String title, _Ctx ctx) async {
    final Uri search = Uri.https('search.nintendo-europe.com', '/it/select', <String, String>{
      'q': title,
      'fq': 'type:GAME',
      'wt': 'json',
      'rows': '10',
    });
    final CoverResponse? response = await _try(search, ctx);
    if (response == null || !response.ok) return null;

    final Object? decoded = _json(response.text);
    if (decoded is! Map<String, Object?>) return null;
    final Object? body = decoded['response'];
    if (body is! Map<String, Object?>) return null;
    final Object? docs = body['docs'];
    if (docs is! List<Object?>) return null;

    for (final Object? raw in docs) {
      if (raw is! Map<String, Object?>) continue;
      final Object? name = raw['title'];
      // `image_url` è il packshot, cioè la scatola. `image_url_h2x1_s` è il
      // banner orizzontale e `image_url_sq_s` l'icona quadrata: non si usano.
      final Object? image = raw['image_url'];
      if (name is! String || image is! String || image.isEmpty) continue;
      if (!titlesMatch(title, name)) continue;
      final Uri? url = Uri.tryParse(image);
      if (url == null || !url.isScheme('https')) continue;
      return CoverCandidate(imageUrl: url, matchedTitle: name, source: 'eShop Nintendo');
    }
    return null;
  }

  // ----------------------------------------------------------------- iTunes --

  Future<CoverCandidate?> _fromItunes(String title, _Ctx ctx) async {
    final Uri search = Uri.https('itunes.apple.com', '/search', <String, String>{
      'term': title,
      'entity': 'software',
      'limit': '10',
      'country': 'it',
    });
    final CoverResponse? response = await _try(search, ctx);
    if (response == null || !response.ok) return null;

    final Object? decoded = _json(response.text);
    if (decoded is! Map<String, Object?>) return null;
    final Object? results = decoded['results'];
    if (results is! List<Object?>) return null;

    for (final Object? raw in results) {
      if (raw is! Map<String, Object?>) continue;
      final Object? name = raw['trackName'];
      final Object? art = raw['artworkUrl512'] ?? raw['artworkUrl100'];
      if (name is! String || art is! String) continue;
      if (!titlesMatch(title, name)) continue;
      final Uri? url = Uri.tryParse(art);
      if (url == null || !url.isScheme('https')) continue;
      // L'icona di una app è quadrata: viene incorniciata in 3:4 al salvataggio.
      return CoverCandidate(imageUrl: url, matchedTitle: name, source: 'App Store');
    }
    return null;
  }

  // ------------------------------------------------------------- download ----

  /// Scarica l'immagine di [candidate]. Restituisce i byte, o `null`.
  ///
  /// Gestisce due casi che capitano davvero: l'host alternativo quando il primo
  /// non ha quell'immagine (Steam), e i file di Libretro che sono collegamenti
  /// simbolici, cioè scaricati danno un pezzo di testo col nome del file vero
  /// invece dell'immagine.
  Future<Uint8List?> download(CoverCandidate candidate) async {
    final _Ctx ctx = _Ctx();
    for (final Uri url in <Uri>[candidate.imageUrl, ?candidate.fallbackUrl]) {
      final CoverResponse? response = await _try(url, ctx);
      if (response == null || !response.ok) continue;

      if (_looksLikeImage(response)) return response.bytes;

      final Uri? linked = _symlinkTarget(url, response);
      if (linked != null) {
        final CoverResponse? second = await _try(linked, ctx);
        if (second != null && second.ok && _looksLikeImage(second)) return second.bytes;
      }
    }
    return null;
  }

  bool _looksLikeImage(CoverResponse r) {
    final String? type = r.contentType;
    if (type != null && type.startsWith('image/')) return true;
    if (r.bytes.length < 8) return false;
    // PNG e JPEG dalla firma, perché raw.githubusercontent.com serve i file
    // come testo semplice e il tipo dichiarato non è affidabile.
    final bool png = r.bytes[0] == 0x89 && r.bytes[1] == 0x50;
    final bool jpeg = r.bytes[0] == 0xFF && r.bytes[1] == 0xD8;
    return png || jpeg;
  }

  /// Un file di Libretro che è un collegamento simbolico: il corpo è una riga
  /// sola col nome del file vero, nella stessa cartella.
  Uri? _symlinkTarget(Uri original, CoverResponse r) {
    if (r.bytes.length > 300) return null;
    final String body = r.text.trim();
    if (body.isEmpty || body.contains('\n') || !body.toLowerCase().endsWith('.png')) return null;
    final List<String> segments = List<String>.of(original.pathSegments);
    if (segments.isEmpty) return null;
    segments[segments.length - 1] = body.split('/').last;
    return original.replace(pathSegments: segments);
  }

  Object? _json(String source) {
    try {
      return jsonDecode(source);
    } catch (_) {
      return null;
    }
  }
}

/// L'indirizzo di una copertina di Libretro. `Uri.https` codifica da sé gli
/// spazi e le parentesi dei nomi canonici.
Uri libretroBoxartUrl(String system, String name) => Uri.https(
  'raw.githubusercontent.com',
  '/libretro-thumbnails/$system/master/Named_Boxarts/$name.png',
);

/// Esito di una ricerca.
///
/// Serve a distinguere due cose che all'utente vanno dette in modo diverso:
/// «ho guardato e non c'è niente di sicuro» merita un avviso, «non ho potuto
/// guardare perché non c'era rete» no, come deciso.
class CoverSearchResult {
  const CoverSearchResult(this.candidate, {this.networkFailed = false});

  final CoverCandidate? candidate;
  final bool networkFailed;

  bool get found => candidate != null;

  /// Vero quando vale la pena dirlo: la rete c'era, la ricerca è avvenuta e non
  /// ha dato niente.
  bool get worthTelling => candidate == null && !networkFailed;
}

/// Stato di una singola ricerca, passato alle fonti. Non è un campo della
/// classe perché la ricerca in blocco ne fa centinaia di seguito.
class _Ctx {
  bool networkFailed = false;
}
