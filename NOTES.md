# Invarianti e regole di modifica

Regole che il codice deve rispettare e che non si vedono leggendo una sola tabella.
Lo schema è in `lib/data/sql/schema.drift` (versione 5), i passi di migrazione in
`lib/data/database.dart` e `lib/data/database.steps.dart`.

## Raccolte

- L'appartenenza sta in `collection_items`: un gioco può stare in **più raccolte** e
  possedere **comunque copie proprie**, restando una voce sola con un voto solo. Le
  vecchie `games.parent_id` e `detached_copies` non esistono più dalla v3 (la
  migrazione che le converte sta in `database.dart`: non toccarla).
- Cinque trigger tengono in piedi le regole che i CHECK non possono esprimere: si può
  contenere solo dentro una raccolta vera, niente raccolte dentro raccolte, una
  raccolta con contenuti non può tornare gioco normale (va prima sciolta) e un gioco
  contenuto non può diventare raccolta (va prima tolto dalla raccolta).
- I trigger usano `COALESCE` di proposito: durante il ripristino le chiavi esterne sono
  rinviate e una sottoquery su righe non ancora inserite darebbe NULL, cioè confronti
  sempre falsi e controlli che lasciano passare tutto.

## Copie e statistiche

- `effective_copies` = copie proprie + copie delle raccolte a cui il gioco appartiene,
  con `UNION` e non `UNION ALL`: la stessa coppia console/formato conta una volta.
- `game_consoles` aggiunge a quelle la **console di uscita** (`game_platforms`), che ha
  `format` NULL perché è un'informazione sul gioco, non una copia posseduta.
- `stat_games` esclude le raccolte che contengono qualcosa: contano attraverso i loro
  giochi, altrimenti un cofanetto da 3 verrebbe contato 4 volte. Una raccolta vuota
  resta un gioco a tutti gli effetti.

## Eliminazione con ANNULLA

- `ON DELETE CASCADE` porta via anche copie, generi, console di uscita e appartenenze:
  lo snapshot in `DeletedGameSnapshot` le salva tutte. Se nasce un'altra tabella legata
  al gioco va aggiunta là, o ANNULLA la perde senza dirlo.

## Ripristino da backup

- Tutto in una transazione e copertine scambiate solo dopo: se qualcosa non torna la
  libreria attuale resta intatta.
- `PRAGMA defer_foreign_keys = ON` per la pulizia, e le appartenenze si inseriscono
  **dopo** i giochi: il trigger rifiuta una raccolta che ancora non esiste.
- Le colonne derivate (`title_norm`, `sort_title`, `name_norm`, `overall_rating`) non si
  esportano: si ricalcolano in importazione, così un cambio di `normalize()` non lascia
  in giro chiavi vecchie.
- L'elenco delle colonne in `backup_service.dart` è anche la lista bianca
  dell'importazione: una tabella nuova che non compare lì non viene né salvata né letta.
- I backup del formato v1 (con `parent_id` e copie messe da parte) restano importabili:
  quel ramo serve ancora.

## Unire due voci di catalogo

- Rifiutare sorgente == destinazione e le collection.
- Per ogni tabella a chiave composta prima si **eliminano** le righe che diventerebbero
  doppioni, poi si spostano le altre: un semplice UPDATE sbatterebbe sulla chiave.
- I voti si prendono dall'altra voce solo in blocco e solo se quella tenuta non ne ha
  nessuno: mescolarli darebbe una media che non ha mai dato nessuno.

## Se cambia lo schema o `normalize()`

- Ricalcolare le chiavi derivate in una sola transazione.
- Un nuovo passo di migrazione vuole anche lo schema esportato in `drift_schemas/` e un
  test in `test/db/`, come `migration_v3_test.dart`.
- Una migrazione che **ricrea** una tabella deve partire dalla forma congelata di quella
  versione — le classi `SchemaN` in `lib/data/database.steps.dart` — e non dalla definizione
  attuale: altrimenti il giorno che lo schema cambia di nuovo, chi si aggiorna da una versione
  vecchia si ritrova la tabella di oggi al posto di quella di allora. È il motivo per cui il
  passo della v3 usa `Schema3` invece della tabella `games` generata.

## Grafiche (lib/app/theme.dart, lib/ui/widgets.dart)

- Il testo che finisce **sopra lo sfondo** della grafica (titoli della libreria,
  schermate vuote, note, rotelle) usa `onBackdrop` / `onBackdropMuted` /
  `backdropAccent` e le ombre `backdropShadows`, non `onSurface`: su Aero lo sfondo
  è blu profondo e il blu notte dei pannelli ci sparisce dentro. Dentro un pannello
  o una Card vale il contrario: lì il colore giusto resta `onPanel`.
- `backdropBase` è il colore con cui una sfumatura può **morire dentro** lo sfondo.
  Si sfuma sempre verso lo stesso colore con alpha 0, mai verso `Colors.transparent`
  (che è nero trasparente e lascia una banda grigia a metà strada).
- Ogni apertura di schermata passa da `skinnedRoute`: la pagina porta con sé il
  proprio `SkinBackground`. Serve perché sia **opaca** durante la transizione (se no
  si vede in trasparenza la pagina sotto) e perché il vetro smerigliato delle barre
  abbia qualcosa da sfocare anche mentre la pagina si muove.
- Le transizioni stanno in `AppTheme.transitionsFor`, una per grafica, registrate su
  tutte le piattaforme: una voce mancante ricadrebbe in silenzio sullo zoom di serie,
  che ridipinge mezzo schermo color superficie. Il «taglio netto» di colore che si
  vedeva aprendo un gioco era esattamente quello, nella forma del `fallbackColor`
  della transizione di sistema.
- L'intestazione della scheda gioco non è opaca: niente `backgroundColor`,
  `forceMaterialTransparency: true`, e la coda sfuma con una maschera unica su
  copertina sfocata e velo. La tinta della barra richiusa la rimette `_CollapsedBar`
  leggendo `FlexibleSpaceBarSettings`.
- `GameDetailScreen` vuole titolo e copertina già noti al chiamante: senza, nel
  fotogramma in cui la rotta nasce la scheda non contiene nessuna copertina e il volo
  dalla libreria non parte affatto.
- La versione dell'app sta in `lib/app/version.dart` (`x` = schema del database,
  `y` = serie di modifiche dall'ultimo cambio di `x`, `z` = ritocchi) e va tenuta
  allineata a mano con `pubspec.yaml`; `test/app/version_test.dart` lo controlla.

## Identità dell'app (`applicationId` e firma)

- L'`applicationId` è `io.github.eightbitplayer.gameshelf` (in `android/app/build.gradle.kts`,
  insieme al `namespace`). Per Android è **il nome dell'app**: cambiarlo crea un'app diversa,
  con i suoi dati e la sua icona, quindi chi aggiorna deve disinstallare e ripristinare un
  backup. Non va più toccato.
- Vale lo stesso per la chiave di firma: Android accetta un aggiornamento solo se la firma
  è identica. Chiave e `applicationId` insieme sono l'identità dell'app; vedi
  [TOOLCHAIN.md](TOOLCHAIN.md).
- Il package Kotlin segue l'`applicationId` (`android/app/src/main/kotlin/io/github/...`).
  Il manifest nomina le classi in forma relativa (`.MainActivity`, `.CoverWidgetProvider`),
  quindi segue da sé. Il canale verso il nativo si chiama `gameshelf/native` e **non**
  contiene il nome del pacchetto: non va rinominato per sbaglio insieme a questo.
- I percorsi delle copertine nel database sono relativi (`covers/<nome>.jpg`) e si risolvono
  a runtime sulla cartella dei documenti: per questo un backup resta valido anche dopo un
  cambio di `applicationId`, che quella cartella la sposta.
