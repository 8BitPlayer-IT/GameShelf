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

Le release ufficiali escono solo da questo repository. Un APK di GameShelf trovato altrove non è
controllato da nessuno.
