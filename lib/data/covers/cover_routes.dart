/// Da quale fonte si cerca la copertina di un gioco, console per console.
///
/// Tutte le fonti qui elencate rispondono senza chiave, senza token e senza
/// account: la app fa una GET e basta. Le regole, decise insieme:
///
/// - si cerca **in base alla console** indicata dall'utente;
/// - se non c'è nessuna console si prova **solo Steam**, senza tirare a indovinare;
/// - se non c'è una corrispondenza **certa** non si propone niente: meglio nessuna
///   copertina che la copertina di un altro gioco.
///
/// Le fonti sono in ordine: la prima che risponde con una corrispondenza certa
/// vince, le altre non vengono nemmeno interrogate.
///
/// La mappa dei depositi di Libretro è stata verificata contro l'elenco reale
/// dell'organizzazione `libretro-thumbnails` il 25/11/2026: un nome sbagliato qui
/// vale zero copertine per quella console, e i nomi non si indovinano (il Master
/// System sta sotto `Sega_-_Master_System_-_Mark_III`, l'Atari 400 sotto
/// `Atari_-_8-bit_Family`).
library;

/// Le fonti disponibili, in ordine di «fiducia» generale.
enum CoverSource {
  /// Ricerca su Steam e copertina verticale `library_600x900.jpg` dedotta
  /// dall'appid. Immagine 300x450, sempre verticale.
  steam,

  /// Ricerca sull'eShop europeo di Nintendo. Il campo `image_url` è il
  /// *packshot*, cioè la scatola vera (500x809), non il banner orizzontale.
  nintendoEshop,

  /// Ricerca di iTunes, solo per iOS. Attenzione: restituisce l'**icona**
  /// dell'app, quadrata (512x512), non una copertina verticale.
  itunes,

  /// Copertine di `libretro-thumbnails`. È la sola fonte possibile per le
  /// console fuori commercio, e copre 29 delle console di GameShelf.
  /// Le proporzioni seguono la scatola reale e cambiano da sistema a sistema.
  libretro,
}

/// Come si cerca la copertina per una console.
class CoverRoute {
  const CoverRoute(this.sources, {this.libretroSystem});

  /// Fonti da provare, in ordine.
  final List<CoverSource> sources;

  /// Nome del deposito in `libretro-thumbnails`, quando fra le fonti c'è
  /// [CoverSource.libretro]. È anche la chiave dell'indice dei nomi spedito
  /// negli assets (`assets/copertine/<sistema>.txt.gz`).
  final String? libretroSystem;
}

/// Quando l'utente non ha indicato nessuna console: solo Steam.
///
/// Provare tutte le fonti «nel dubbio» moltiplicherebbe le occasioni di
/// proporre la copertina sbagliata, che è l'unico esito davvero da evitare.
const CoverRoute coverRouteWithoutConsole = CoverRoute(<CoverSource>[CoverSource.steam]);


/// Instradamento per il nome esatto della console come sta nel catalogo
/// (`lib/data/seed_data.dart`). Una console che non è qui non viene cercata.
const Map<String, CoverRoute> coverRoutes = <String, CoverRoute>{
  // --- Nintendo ancora in vendita: il negozio ha il packshot aggiornato ------
  'Nintendo Switch': CoverRoute(<CoverSource>[CoverSource.nintendoEshop, CoverSource.steam]),
  'Nintendo Switch 2': CoverRoute(<CoverSource>[CoverSource.nintendoEshop, CoverSource.steam]),

  // --- Nintendo fuori commercio: prima Libretro, che è completo -------------
  'Nintendo Wii U': CoverRoute(
    <CoverSource>[CoverSource.libretro, CoverSource.nintendoEshop],
    libretroSystem: 'Nintendo_-_Wii_U',
  ),
  'Nintendo 3DS': CoverRoute(
    <CoverSource>[CoverSource.libretro, CoverSource.nintendoEshop],
    libretroSystem: 'Nintendo_-_Nintendo_3DS',
  ),
  'Nintendo Entertainment System': CoverRoute(
    <CoverSource>[CoverSource.libretro],
    libretroSystem: 'Nintendo_-_Nintendo_Entertainment_System',
  ),
  'Super Nintendo': CoverRoute(
    <CoverSource>[CoverSource.libretro],
    libretroSystem: 'Nintendo_-_Super_Nintendo_Entertainment_System',
  ),
  'Nintendo 64': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Nintendo_-_Nintendo_64'),
  'Nintendo GameCube': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Nintendo_-_GameCube'),
  'Nintendo Wii': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Nintendo_-_Wii'),
  'Game Boy': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Nintendo_-_Game_Boy'),
  'Game Boy Color': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Nintendo_-_Game_Boy_Color'),
  'Game Boy Advance': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Nintendo_-_Game_Boy_Advance'),
  'Nintendo DS': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Nintendo_-_Nintendo_DS'),

  // --- PlayStation ----------------------------------------------------------
  // Libretro ha anche PS3, PS4 e Vita, ma quei depositi sono quasi vuoti (PS4
  // sono 9 MB in tutto, Vita 4): restano in coda, e la riserva è Steam, dove
  // quasi ogni titolo multipiattaforma esiste con la stessa illustrazione.
  // La PS5 non ha nessun deposito: solo Steam.
  'PlayStation': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Sony_-_PlayStation'),
  'PlayStation 2': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Sony_-_PlayStation_2'),
  'PlayStation 3': CoverRoute(
    <CoverSource>[CoverSource.libretro, CoverSource.steam],
    libretroSystem: 'Sony_-_PlayStation_3',
  ),
  'PlayStation 4': CoverRoute(
    <CoverSource>[CoverSource.libretro, CoverSource.steam],
    libretroSystem: 'Sony_-_PlayStation_4',
  ),
  'PlayStation 5': CoverRoute(<CoverSource>[CoverSource.steam]),
  'PlayStation Portable': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Sony_-_PlayStation_Portable'),
  'PlayStation Vita': CoverRoute(
    <CoverSource>[CoverSource.libretro, CoverSource.steam],
    libretroSystem: 'Sony_-_PlayStation_Vita',
  ),

  // --- Xbox -----------------------------------------------------------------
  // Niente Microsoft Store: il suo endpoint di ricerca pretende un
  // identificativo di applicazione che non è nostro, e prestarsi la chiave di
  // qualcun altro è esattamente quello che non vogliamo fare. Steam copre la
  // quasi totalità dei titoli Xbox moderni, che Microsoft pubblica anche là.
  'Xbox': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Microsoft_-_Xbox'),
  'Xbox 360': CoverRoute(
    <CoverSource>[CoverSource.libretro, CoverSource.steam],
    libretroSystem: 'Microsoft_-_Xbox_360',
  ),
  'Xbox One': CoverRoute(<CoverSource>[CoverSource.steam]),
  'Xbox Series X|S': CoverRoute(<CoverSource>[CoverSource.steam]),

  // --- SEGA -----------------------------------------------------------------
  'Sega Master System': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Sega_-_Master_System_-_Mark_III'),
  'Sega Mega Drive': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Sega_-_Mega_Drive_-_Genesis'),
  'Sega Saturn': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Sega_-_Saturn'),
  'Sega Dreamcast': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Sega_-_Dreamcast'),
  'SEGA CD': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Sega_-_Mega-CD_-_Sega_CD'),
  'SEGA GameGear': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Sega_-_Game_Gear'),

  // --- Computer e microcomputer --------------------------------------------
  // «PC» è l'unico che va davvero su Steam: gli altri quattro sono macchine
  // degli anni Ottanta, e i loro giochi stanno in Libretro, non in un negozio.
  'PC': CoverRoute(<CoverSource>[CoverSource.steam]),
  'Commodore 64': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Commodore_-_64'),
  'Commodore VIC-20': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Commodore_-_VIC-20'),
  'Commodore Amiga 500': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Commodore_-_Amiga'),
  'Atari 400': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Atari_-_8-bit_Family'),

  // --- Altro ----------------------------------------------------------------
  'Atari 2600': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Atari_-_2600'),
  'Atari 7800': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Atari_-_7800'),
  'Neo Geo': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'SNK_-_Neo_Geo'),
  'IntelliVision': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'Mattel_-_Intellivision'),
  'Arcade': CoverRoute(<CoverSource>[CoverSource.libretro], libretroSystem: 'MAME'),

  // iOS dà l'icona dell'app, quadrata: viene incorniciata in 3:4 al momento
  // del salvataggio, come tutte le immagini che non sono già verticali.
  'iOS': CoverRoute(<CoverSource>[CoverSource.itunes]),

  // Android non ha nessuna fonte pubblica senza chiave: Google Play non
  // espone una ricerca. Volutamente assente, così non si cerca a vuoto.
};


/// I sistemi Libretro effettivamente usati, cioè gli indici dei nomi che
/// `tool/genera_indici_copertine.dart` deve produrre.
Set<String> get libretroSystemsInUse => <String>{
  for (final CoverRoute r in coverRoutes.values)
    if (r.libretroSystem != null) r.libretroSystem!,
};
