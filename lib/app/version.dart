/// Versione dell'app, scritta in un posto solo.
///
/// Lo schema è `x.y.z`:
/// - **x** è la versione dello schema del database (oggi 5). Cambia quando
///   cambia il database, così si capisce a colpo d'occhio se due installazioni
///   o un backup parlano la stessa lingua.
/// - **y** conta le serie di modifiche pubblicate dopo l'ultimo cambio di `x`.
///   La 5.0 è lo schema nuovo da solo, mai installato; questa è la prima serie
///   di modifiche arrivata dopo.
/// - **z** sono i ritocchi: correzioni e messe a punto che non aggiungono
///   niente di nuovo. Riparte da zero ogni volta che cresce `y`.
///
/// `pubspec.yaml` va tenuto allineato a mano, nella forma
/// `version: <questa stringa>+<numero di build>`: il numero di build deve
/// crescere a ogni APK, altrimenti Android rifiuta l'aggiornamento.
/// Se i due si scostano, `test/app/version_test.dart` diventa rosso.
const String appVersion = '5.5.0';
