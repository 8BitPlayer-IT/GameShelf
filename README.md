# GameShelf

Un catalogo dei videogiochi che possiedi, per Android. Nessun account, nessuna registrazione, nessuna
pubblicità: la tua libreria resta sul tuo telefono.

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
- **Copertine da internet**: salvando un gioco senza copertina l'app ne cerca una sui negozi
  (Steam, eShop Nintendo, App Store) e fra le copertine di Libretro per le console fuori
  commercio, e te la propone. Dalle impostazioni si possono cercare in blocco per tutta la
  libreria. Viene proposta solo una corrispondenza certa: nel dubbio nessuna copertina.
- **Backup e ripristino** in un unico file ZIP che contiene database e copertine, da salvare dove vuoi.
- **Tre grafiche**: Originale (Material 3, con tema chiaro e scuro), Apple (come il primo iPhone) e
  Aero (come Windows Vista e 7).
- **Widget per la schermata home** che mostra la copertina di un gioco a caso e cambia ogni ora.

## Privacy

Nessun account, nessuna registrazione, nessuna raccolta di dati, nessuna statistica d'uso
inviata a nessuno. La libreria vive nel telefono e nel file di backup che fai tu.

L'app dichiara un solo permesso che le dia accesso a qualcosa, `INTERNET`, e lo usa **solo** per la ricerca delle
copertine. Quando quella ricerca parte, esce dal telefono il titolo del gioco (e il nome della
console), e va al negozio che corrisponde a quella console: Steam, l'eShop di Nintendo,
l'App Store, oppure `raw.githubusercontent.com` per le copertine di Libretro. Niente
identificativi, niente cronologia, nessun server del progetto in mezzo: le richieste vanno
dal tuo telefono al negozio, senza passare da nessun server del progetto.

Per le console fuori commercio non esce nemmeno il titolo: l'elenco dei nomi delle copertine di
Libretro viaggia dentro l'APK, quindi la corrispondenza si calcola nel telefono e la rete serve
solo a scaricare l'immagine già individuata.

Se non cerchi copertine, l'app non contatta nessuno. Senza connessione la ricerca viene saltata
in silenzio e tutto il resto funziona come sempre.

L'altra funzione che esce dall'app è il pulsante «Cerca su YouTube» nella scheda di un gioco:
passa il titolo all'app di YouTube o al browser, che fanno il resto. GameShelf non scarica nulla.

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

## Licenza e autore

GameShelf è stato progettato e scritto da **Andrea Piva (8BitPlayer-IT)**.

Copyright (C) 2026 Andrea Piva (8BitPlayer-IT)

Licenza: **GPL-3.0-or-later**. Il testo completo è nel file [LICENSE](LICENSE).

In breve: puoi usare, studiare e modificare questa app liberamente, e puoi ridistribuirla —
anche modificata — a patto di pubblicare a tua volta il codice sorgente sotto la stessa licenza.

### Termine aggiuntivo sull'attribuzione

L'**articolo 7(b)** della GPL-3.0 permette di richiedere che le attribuzioni all'autore vengano
conservate. Questo programma è distribuito con il seguente termine aggiuntivo:

> Chi ridistribuisce GameShelf, modificato o no, in forma di codice sorgente o di programma
> compilato, deve conservare l'attribuzione all'autore originale — «di Andrea Piva
> (8BitPlayer-IT)», oppure «basato su GameShelf, di Andrea Piva (8BitPlayer-IT)» se l'opera
> viene rinominata — nella schermata delle impostazioni dell'applicazione e in questo file.

Non toglie niente alla libertà del software: puoi forkare, cambiare, rinominare, vendere e
ridistribuire quello che vuoi. Devi solo non cancellare chi l'ha scritto.

## Crediti e marchi

Le icone delle console e l'icona dell'app sono **originali, generate con ChatGPT** e distribuite con la
stessa licenza del progetto. I fogli di partenza sono in `assets/source/`, e le icone ritagliate si
rigenerano con gli script in `tool/`.

I nomi, i loghi e le forme delle console appartengono ai rispettivi proprietari. Questo progetto non è
affiliato né approvato da Nintendo, Sony, Microsoft, SEGA, Atari o da chiunque altro: le icone servono
soltanto a riconoscere a colpo d'occhio la piattaforma di un gioco.

Le copertine restano sul tuo telefono: nel repository e nell'APK non ce n'è nessuna. Quelle che
arrivano dalla ricerca online appartengono ai rispettivi editori, e l'app le mostra per
riconoscere un gioco, non le ridistribuisce.

Gli indici in `assets/copertine/` sono elenchi di **nomi** ricavati dai depositi di
[libretro-thumbnails](https://github.com/libretro-thumbnails): solo testo, nessuna immagine. Si
rigenerano con `dart run tool/genera_indici_copertine.dart`.

## Lingua

L'interfaccia è **solo in italiano**, per scelta: è un'app nata per uso personale e la traduzione
richiederebbe di rifare i testi scritti dentro le schermate.

---

*GameShelf is a video game collection manager for Android. The user interface is in Italian
only. No account and no tracking: your library stays on your phone. The only network use is fetching
a game's cover art when you ask for it.*
