import 'package:flutter/services.dart';

/// Canale verso il codice Android nativo (MainActivity.kt).
abstract final class NativeBridge {
  static const MethodChannel _channel = MethodChannel('gameshelf/native');

  /// Selettore di file di sistema che si apre nella cartella dell'ultima copertina
  /// scelta. Restituisce un JPEG nella cache, già ridimensionato a 1600 pixel sul
  /// lato lungo e con l'orientamento corretto, oppure `null` se l'utente annulla.
  static Future<String?> pickCoverImage() => _channel.invokeMethod<String>('pickCoverImage');

  /// Salva un file dove sceglie l'utente, copiandolo a blocchi: nessun limite di
  /// dimensione, a differenza del salvataggio offerto dai plugin Flutter.
  /// Restituisce l'indirizzo scelto, o `null` se l'utente annulla.
  static Future<String?> exportFile({required String path, required String fileName}) =>
      _channel.invokeMethod<String>('exportFile', <String, String>{'path': path, 'fileName': fileName});

  /// Apre un indirizzo con l'app di sistema che lo gestisce: un link di YouTube
  /// finisce nell'app di YouTube se c'è, altrimenti nel browser.
  ///
  /// Non è una chiamata di rete dell'app: l'indirizzo viene consegnato ad
  /// Android, che se ne occupa. È il motivo per cui GameShelf continua a non
  /// avere il permesso INTERNET.
  ///
  /// Restituisce `false` se non c'è niente che sappia aprire quell'indirizzo.
  static Future<bool> openLink(String url) async {
    try {
      return await _channel.invokeMethod<bool>('openLink', url) ?? false;
    } on MissingPluginException {
      // Nei test non c'è il lato Android.
      return false;
    }
  }

  /// Chiede ai widget della schermata home di rileggere la libreria.
  static Future<void> refreshWidgets() async {
    try {
      await _channel.invokeMethod<void>('refreshWidgets');
    } on MissingPluginException {
      // Nei test non c'è il lato Android.
    }
  }

  /// Id del gioco da aprire se l'app è stata avviata toccando il widget.
  static Future<int?> takeLaunchGameId() async {
    try {
      return await _channel.invokeMethod<int>('takeLaunchGameId');
    } on MissingPluginException {
      return null;
    }
  }

  /// Chiamato quando si tocca il widget con l'app già aperta.
  static void onOpenGame(void Function(int gameId) handler) {
    _channel.setMethodCallHandler((MethodCall call) async {
      final Object? id = call.arguments;
      if (call.method == 'openGame' && id is int) handler(id);
    });
  }
}
