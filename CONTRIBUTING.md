# Contribuire a GameShelf

Grazie per l'interesse. Qualche informazione onesta prima che tu ci spenda tempo.

## Com'è fatto questo progetto

È un'app nata per uso personale, portata avanti da una persona sola nel tempo libero. Non c'è un'azienda
dietro, non ci sono scadenze e non c'è nessuna garanzia sui tempi di risposta.

L'interfaccia è **solo in italiano** ed è una scelta, non una mancanza: i testi sono scritti dentro le
schermate e non in file di traduzione. Le segnalazioni possono essere in italiano o in inglese.

## Segnalare un problema

Apri una *issue* e scrivi:

- cosa ti aspettavi e cosa è successo;
- la versione dell'app (Impostazioni → Informazioni) e la versione di Android;
- se riesci, i passi per rifarlo succedere.

**Non allegare il tuo file di backup**: contiene tutta la tua libreria. Se serve per capire il problema,
verrà chiesto il minimo indispensabile.

## Proporre una funzione

Apri una issue e descrivi il *problema* prima della soluzione. Alcune cose sono state già valutate e
scartate di proposito, e le trovi scritte nelle note del progetto: wishlist, tempi di gioco, account,
sincronizzazione nel cloud. L'app deve continuare a funzionare interamente offline.

## Cambiare il codice

Prima di aprire una *pull request*:

1. leggi [TOOLCHAIN.md](TOOLCHAIN.md): le versioni sono bloccate e verificate insieme, non aggiornarle;
2. leggi [NOTES.md](NOTES.md): contiene le regole del database che non si vedono guardando una tabella
   sola, e che è facile rompere senza accorgersene;
3. `flutter analyze` deve restare a zero problemi e `flutter test` deve restare verde;
4. se tocchi lo schema del database servono anche il passo di migrazione, lo schema esportato in
   `drift_schemas/` e un test che verifichi l'aggiornamento;
5. commenti e messaggi di commit in italiano, come il resto del progetto.

Le modifiche piccole e mirate hanno molte più probabilità di essere accettate di una riscrittura.

## Cosa non verrà accettato

- Dipendenze nuove senza una ragione forte: ogni pacchetto è peso e manutenzione.
- Qualunque cosa richieda un account, un server o una chiave API per funzionare.
- Pubblicità, statistiche d'uso, telemetria.
