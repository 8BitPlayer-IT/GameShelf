/// I valori di dominio dell'app.
///
/// Ogni enum porta con sé la stringa con cui viene salvato nel database: è la
/// stessa che finisce nel file di backup, quindi non va cambiata alla leggera
/// (servirebbe una migrazione, e i backup vecchi diventerebbero illeggibili).
///
/// Dart puro: nessun import di Flutter, così resta testabile sul PC.
library;

/// Stato di completamento di un gioco. L'ordine è quello in cui compaiono
/// nell'interfaccia e nei grafici.
enum GameStatus {
  /// Ancora da iniziare.
  backlog('backlog'),

  /// Gioco infinito, senza un finale da raggiungere.
  arcade('arcade'),

  /// Iniziato, ma non ci sto più giocando.
  abbandonato('abbandonato'),

  /// Lo sto giocando adesso.
  inCorso('in_corso'),

  /// Campagna principale completata.
  finito('finito'),

  /// Finite anche tutte le parti opzionali.
  completato('completato');

  const GameStatus(this.dbValue);

  /// Valore salvato nella colonna `games.status`.
  final String dbValue;

  /// Converte il valore letto dal database.
  ///
  /// Lancia [ArgumentError] su un valore sconosciuto: se succede significa che
  /// il database contiene qualcosa che il CHECK non avrebbe dovuto accettare
  /// (per esempio un backup manomesso), e fallire subito è meglio che mostrare
  /// una libreria con stati inventati.
  static GameStatus fromDb(String value) {
    for (final GameStatus status in GameStatus.values) {
      if (status.dbValue == value) return status;
    }
    throw ArgumentError.value(value, 'value', 'Stato di completamento sconosciuto');
  }

  /// Stati che indicano una partita portata a termine, usati per la percentuale
  /// «finiti o completati» nelle statistiche.
  bool get isCompleted => this == GameStatus.finito || this == GameStatus.completato;

  /// Un gioco arcade non ha un finale: non entra nel conto dei «finiti», né qui
  /// né nella percentuale delle statistiche (stats_repository.dart, completable).
  bool get isCompletable => this != GameStatus.arcade;
}

/// Formato di una copia posseduta.
enum CopyFormat {
  /// Cartuccia, disco o cartuccia di scheda: qualcosa che sta su uno scaffale.
  fisico('fisico'),

  /// Acquistato sullo store della console.
  digitale('digitale');

  const CopyFormat(this.dbValue);

  final String dbValue;

  static CopyFormat fromDb(String value) {
    for (final CopyFormat format in CopyFormat.values) {
      if (format.dbValue == value) return format;
    }
    throw ArgumentError.value(value, 'value', 'Formato sconosciuto');
  }
}

/// Criteri di ordinamento della libreria.
enum SortCriterion {
  /// Alfabetico sulla chiave di ordinamento (vedi `sortKey`).
  titolo,

  /// Anno di uscita; i giochi senza anno restano in fondo.
  anno,

  /// Voto complessivo; i giochi non valutati restano in fondo.
  voto,

  /// Data di inserimento in libreria.
  aggiunta,
}

/// Modalità di visualizzazione della libreria.
enum LibraryViewMode { griglia, lista }
