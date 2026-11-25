# Segnalare un problema di sicurezza

GameShelf gira sul telefono, non ha un server, non ha account e non accede a internet. La superficie di
attacco è piccola, ma non è zero: il file di backup contiene l'intera libreria, e l'APK delle release è
firmato con una chiave che deve restare al sicuro.

## Come segnalare

Usa la segnalazione privata di GitHub: scheda **Security → Report a vulnerability**. Così il problema
resta riservato finché non c'è una versione corretta.

**Non aprire una issue pubblica** per un problema di sicurezza.

Nella segnalazione servono: cosa hai trovato, come riprodurlo e quale versione dell'app hai provato.

Il progetto è portato avanti da una persona sola nel tempo libero: la risposta può richiedere qualche
giorno. Verrà data comunque.

## Verificare un APK prima di installarlo

Ogni release pubblica l'impronta SHA-256 dei file. Prima di installare puoi controllare che il file che
hai scaricato sia quello:

```powershell
Get-FileHash .\app-arm64-v8a-release.apk -Algorithm SHA256
```

Se l'impronta non coincide con quella scritta nella release, **non installare quel file**.

### Chi ha firmato l'APK

L'impronta del file dice che hai scaricato quello giusto; il certificato dice **chi l'ha
firmato**, ed è quello che Android confronta a ogni aggiornamento. Tutte le release di
GameShelf sono firmate con questa chiave:

```
CN=8BitPlayer-IT, OU=GameShelf, O=GameShelf, C=IT
SHA-256: eedef01307665c840af8ca0ae5d96e6569851c65d0c529a3d5545560674a9a6e
RSA 4096 bit, schemi di firma v2 e v3
```

Per leggerla da un APK serve `apksigner`, che arriva con l'SDK di Android:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\build-tools\36.0.0\apksigner.bat" verify --print-certs .\app-arm64-v8a-release.apk
```

Se l'impronta non è questa, quell'APK **non** l'ha pubblicato questo progetto, anche se il
nome del file è identico. In quel caso Android rifiuterebbe comunque di installarlo sopra una
copia autentica, ma su un telefono dove GameShelf non c'è si installerebbe senza un fiato.

Le release ufficiali escono solo da questo repository. Un APK di GameShelf trovato altrove non è
controllato da nessuno.
