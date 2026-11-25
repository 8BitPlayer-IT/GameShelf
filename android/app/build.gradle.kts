import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firma di release: dove sta la chiave lo dice android/key.properties, che non è nel
// repository. Senza quel file (per esempio sul PC di un amico) si firma con la chiave di
// debug di quel computer: la build funziona, ma non può aggiornare copie firmate altrove.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) FileInputStream(keystorePropertiesFile).use { load(it) }
}

android {
    namespace = "io.github.eightbitplayer.gameshelf"
    compileSdk = flutter.compileSdkVersion

    // NDK 28.2.13676358, installato da Gradle al primo build. Se l'installazione
    // automatica fallisce (sdkmanager è deprecato e può andare in crash), si può
    // puntare temporaneamente a una versione già presente: da r28 in poi le librerie
    // native sono allineate a 16 KB, requisito dei telefoni Android 15+.
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Identificativo dell'app per Android. Cambiarlo significa, per il telefono, un'app
        // diversa: installazione separata, dati non condivisi e firma da riaccettare.
        applicationId = "io.github.eightbitplayer.gameshelf"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Schemi di firma: v2 sempre, e anche v3. Da Android 9 il v3 ha la precedenza, ed e'
            // la premessa per poter un giorno sostituire la chiave senza costringere tutti a
            // disinstallare. Gli Android precedenti ignorano il blocco v3 e verificano il v2.
            enableV2Signing = true
            enableV3Signing = true

            if (keystorePropertiesFile.exists()) {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
