# Toolchain di GameShelf (bloccata)

Queste versioni sono verificate insieme. **Non eseguire `flutter upgrade` prima della 1.0** e non
accettare la proposta di Android Studio di aggiornare AGP o Gradle: Flutter 3.47 non conosce AGP oltre
la 9.2 né Gradle oltre la 9.3.1, e la build fallirebbe.

| Componente | Versione | Dove è scritta |
|---|---|---|
| Flutter | 3.47.3 (stable) | SDK installato sulla macchina |
| Dart | 3.13.3 | incluso in Flutter |
| Gradle | 9.3.1 | `android/gradle/wrapper/gradle-wrapper.properties` |
| Android Gradle Plugin | 9.1.0 | `android/settings.gradle.kts` |
| Kotlin Gradle Plugin | 2.4.0 | `android/settings.gradle.kts` |
| JDK | JetBrains Runtime di Android Studio (>= 17) | `flutter doctor -v` |
| compileSdk / targetSdk | 36 | default di Flutter |
| minSdk | 24 | default di Flutter |
| NDK | 28.2.13676358 | default di Flutter |

Altre regole:

- `pubspec.lock` è committato: le versioni dei pacchetti sono riproducibili.
- `file_picker` è fissato a una versione **esatta** (cambia API a ogni major).
- `android.builtInKotlin` resta `false` finché tutti i plugin compilano con il Kotlin integrato di AGP 9.
- La migrazione da `package:flutter/material.dart` a `material_ui` è un ramo dedicato **dopo** la 1.0
  (`flutter pub add material_ui` + `dart fix --apply --code=migrate_design_widgets`).

## Comandi ricorrenti

```powershell
dart run build_runner build           # dopo ogni modifica a tabelle o annotazioni
flutter analyze                       # deve restare a zero problemi
flutter test                          # suite completa (gira sul PC, senza emulatore)
dart run drift_dev make-migrations    # dopo ogni modifica di schema; committare drift_schemas/
flutter run -d <telefono>             # prova sul dispositivo reale
```

## Compilare un APK

```powershell
flutter build apk --release --split-per-abi
```

Sempre con `--split-per-abi`: Gradle somma al numero di build un valore diverso per architettura
(2000 per arm64), quindi un APK universale porta un numero più basso di quelli già installati e Android
lo rifiuta come retrocessione.

## Firma dell'app

Android installa solo APK firmati e accetta un aggiornamento solo se la firma è **identica** a quella
della versione già installata. Cambiare chiave obbliga a disinstallare, quindi a perdere i dati se non
si è fatto prima un backup.

- La configurazione di firma sta in `android/key.properties`, che **non è nel repository** insieme al
  file della chiave: i percorsi e le password restano sulla macchina di chi compila.
- Chi compila il progetto senza quel file firma con la chiave di debug del proprio computer: l'app
  funziona benissimo sul suo telefono, ma quell'APK non può aggiornare una copia firmata con un'altra
  chiave.
- Chi pubblica le release tiene **una copia della chiave fuori dal computer**: perderla significa non
  poter più aggiornare le installazioni esistenti.
