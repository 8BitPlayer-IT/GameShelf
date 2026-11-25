# GameShelf

Un catalogo dei videogiochi che possiedi, per Android. Funziona **interamente offline**: nessun account,
nessuna registrazione, nessun dato che esce dal telefono.

Non è un'app per tenere una lista dei desideri né per seguire le novità: serve a sapere cosa hai, su
quale console, in che formato, e che voto gli daresti.

## Cosa fa

- **Libreria** in griglia da 2, 3 o 4 colonne oppure in elenco, con ricerca, filtri e ordinamenti;
  la vista scelta viene ricordata.
- **Copie reali**: ogni gioco può essere posseduto su più console, in formato fisico o digitale. Le
  statistiche contano le copie dove ha senso contarle e i giochi dove ha senso contare quelli.
- **Raccolte**: un cofanetto o una compilation contiene altri giochi, e un gioco può stare in più
  raccolte continuando ad avere le proprie copie. Il voto di una raccolta è la media dei contenuti.
- **Voti per categoria** (trama, giocabilità, grafica, musica) da 0 a 10 a mezzi punti, con i colori a
  fasce; ogni categoria può restare non valutata.
- **Statistiche**: console, anni, generi, voti, percentuale di giochi finiti (gli arcade non contano,
  non hanno un finale).
- **Copertine** dalla galleria del telefono, ritagliate in 3:4 con una schermata dell'app.
- **Backup e ripristino** in un unico file ZIP che contiene database e copertine, da salvare dove vuoi.
- **Tre grafiche**: Originale (Material 3, con tema chiaro e scuro), Apple (come il primo iPhone) e
  Aero (come Windows Vista e 7).
- **Widget per la schermata home** che mostra la copertina di un gioco a caso e cambia ogni ora.

## Privacy

L'app non ha il permesso di accedere a internet e non lo chiede. Non c'è nessun account, nessuna
raccolta di dati, nessuna statistica d'uso inviata a nessuno. L'unica cosa che esce dall'app è il file
di backup, quando sei tu a condividerlo.

L'unica funzione che apre qualcosa fuori dall'app è il pulsante «Cerca su YouTube» nella scheda di un
gioco: passa il titolo all'app di YouTube o al browser, che fanno il resto. GameShelf non scarica nulla.

## Requisiti

Android 7.0 o successivo (API 24). Non è sul Play Store: si installa a mano il file APK, e Android
chiederà di confermare perché arriva da fuori dallo store.

## Installare

Scarica l'APK dalla pagina [Releases](../../releases) e aprilo sul telefono. Se hai un telefono
recente, l'APK da prendere è quello **arm64**.

Gli aggiornamenti si installano sopra la versione precedente senza perdere i dati, purché l'APK sia
firmato con la stessa chiave. Un APK che compili tu ha una firma diversa: in quel caso fai prima un
backup, disinstalla, installa il tuo e ripristina.

Prima di installare puoi controllare che il file sia davvero quello pubblicato qui e che sia
firmato con la chiave del progetto: [SECURITY.md](SECURITY.md) spiega come, in due comandi.

## Numero di versione

La versione segue lo schema `x.y.z`:

- **x** è la versione dello schema del database: cambia quando cambia la struttura dei dati;
- **y** conta le serie di modifiche pubblicate dopo l'ultimo cambio di `x`;
- **z** sono le correzioni che non aggiungono niente di nuovo.

## Compilare il progetto

Le versioni della toolchain sono **bloccate e verificate insieme**: vedi [TOOLCHAIN.md](TOOLCHAIN.md)
prima di aggiornare qualcosa.

```
flutter pub get
flutter analyze
flutter test
flutter build apk --release --split-per-abi
```

Senza un file `android/key.properties` la build usa la chiave di debug del tuo computer: va benissimo
per provare l'app sul tuo telefono.

## Licenza

GPL-3.0-or-later. Vedi [LICENSE](LICENSE).

In breve: puoi usare, studiare e modificare questa app liberamente, e puoi ridistribuirla — anche
modificata — a patto di pubblicare a tua volta il codice sorgente sotto la stessa licenza.

## Crediti e marchi

Le icone delle console e l'icona dell'app sono **originali, generate con ChatGPT** e distribuite con la
stessa licenza del progetto. I fogli di partenza sono in `assets/source/`, e le icone ritagliate si
rigenerano con gli script in `tool/`.

I nomi, i loghi e le forme delle console appartengono ai rispettivi proprietari. Questo progetto non è
affiliato né approvato da Nintendo, Sony, Microsoft, SEGA, Atari o da chiunque altro: le icone servono
soltanto a riconoscere a colpo d'occhio la piattaforma di un gioco.

Le copertine dei giochi le aggiungi tu dal tuo telefono e restano sul tuo telefono: nel repository e
nell'APK non ce n'è nessuna.

## Lingua

L'interfaccia è **solo in italiano**, per scelta: è un'app nata per uso personale e la traduzione
richiederebbe di rifare i testi scritti dentro le schermate.

---

*GameShelf is an offline video game collection manager for Android. The user interface is in Italian
only. No account, no network access, no tracking: your library stays on your phone.*
