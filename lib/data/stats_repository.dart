import 'package:drift/drift.dart';

import '../domain/enums.dart';
import 'database.dart';

/// Una fetta o una barra: etichetta e conteggio.
class CountEntry {
  const CountEntry(this.label, this.count);

  final String label;
  final int count;
}

/// Tutti i numeri della sezione Statistiche.
///
/// Unità scelta dall'utente («supporti reali»): console e fisico/digitale contano
/// le COPIE possedute, dove una raccolta è una copia sola; tutto il resto conta i
/// GIOCHI, dove contano i giochi contenuti e non il cofanetto che li contiene, e
/// un gioco presente in più raccolte conta una volta sola.
class StatsSnapshot {
  const StatsSnapshot({
    required this.games,
    required this.copies,
    required this.averageRating,
    required this.completed,
    required this.arcade,
    required this.unrated,
    required this.byStatus,
    required this.byConsole,
    required this.physicalCopies,
    required this.digitalCopies,
    required this.byGenre,
    required this.byDecade,
    required this.ratingTiers,
    required this.topDevelopers,
    required this.topPublishers,
    required this.topSeries,
  });

  final int games;
  final int copies;
  final double? averageRating;
  final int completed;

  /// Giochi infiniti, senza un finale: restano fuori dalla percentuale dei finiti.
  final int arcade;
  final int unrated;
  final Map<GameStatus, int> byStatus;
  final List<CountEntry> byConsole;
  final int physicalCopies;
  final int digitalCopies;
  final List<CountEntry> byGenre;
  final List<CountEntry> byDecade;

  /// Giochi valutati per fascia di voto, nell'ordine: sotto il 5, 5-6,9, 7-7,9,
  /// 8-8,9, 9-9,9, 10.
  final List<int> ratingTiers;
  final List<CountEntry> topDevelopers;
  final List<CountEntry> topPublishers;
  final List<CountEntry> topSeries;

  /// Giochi su cui ha senso parlare di «finito»: tutti tranne gli arcade.
  int get completable => games - arcade;

  /// Percentuale di giochi finiti o completati, esclusi gli arcade.
  int get completedPercent => completable <= 0 ? 0 : (completed * 100 / completable).round();
}

class StatsRepository {
  StatsRepository(this.db);

  final AppDatabase db;

  static const String _counted = 'JOIN stat_games sg ON sg.game_id = g.id';

  Stream<StatsSnapshot> watchStats() {
    return db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            db.games,
            db.gameCopies,
            db.gameGenres,
            db.collectionItems,
            db.consoles,
            db.genres,
            db.series,
            db.companies,
          },
        )
        .watch()
        .asyncMap((_) => load());
  }

  Future<StatsSnapshot> load() async {
    Future<List<CountEntry>> entries(String sql) async => <CountEntry>[
      for (final QueryRow r in await db.customSelect(sql).get())
        CountEntry(r.read<String>('label'), r.read<int>('n')),
    ];

    final QueryRow totals = await db
        .customSelect(
          'SELECT '
          '(SELECT count(*) FROM stat_games) AS games, '
          '(SELECT count(*) FROM game_copies) AS copies, '
          "(SELECT count(*) FROM game_copies WHERE format = 'fisico') AS physical, "
          "(SELECT count(*) FROM game_copies WHERE format = 'digitale') AS digital, "
          '(SELECT avg(g.overall_rating) FROM games g $_counted) AS average, '
          '(SELECT count(*) FROM games g $_counted WHERE g.overall_rating IS NULL) AS unrated',
        )
        .getSingle();

    final Map<GameStatus, int> byStatus = <GameStatus, int>{for (final GameStatus s in GameStatus.values) s: 0};
    for (final QueryRow r in await db
        .customSelect('SELECT g.status, count(*) AS n FROM games g $_counted GROUP BY g.status')
        .get()) {
      byStatus[GameStatus.fromDb(r.read<String>('status'))] = r.read<int>('n');
    }

    // Fascia decisa sul voto arrotondato a una decimale, lo stesso che si legge
    // nell'app: un 8,96 si mostra come «9,0» e sta fra gli ori.
    final List<int> tiers = List<int>.filled(6, 0);
    for (final QueryRow r in await db
        .customSelect(
          'SELECT CASE '
          'WHEN round(g.overall_rating, 1) >= 10 THEN 5 '
          'WHEN round(g.overall_rating, 1) >= 9 THEN 4 '
          'WHEN round(g.overall_rating, 1) >= 8 THEN 3 '
          'WHEN round(g.overall_rating, 1) >= 7 THEN 2 '
          'WHEN round(g.overall_rating, 1) >= 5 THEN 1 '
          'ELSE 0 END AS tier, count(*) AS n '
          'FROM games g $_counted WHERE g.overall_rating IS NOT NULL GROUP BY tier',
        )
        .get()) {
      tiers[r.read<int>('tier')] = r.read<int>('n');
    }

    String top(String column, String table) =>
        'SELECT x.name AS label, count(*) AS n FROM games g $_counted JOIN $table x ON x.id = g.$column '
        'GROUP BY x.id ORDER BY n DESC, x.name_norm LIMIT 5';

    return StatsSnapshot(
      games: totals.read<int>('games'),
      copies: totals.read<int>('copies'),
      physicalCopies: totals.read<int>('physical'),
      digitalCopies: totals.read<int>('digital'),
      averageRating: totals.readNullable<double>('average'),
      unrated: totals.read<int>('unrated'),
      arcade: byStatus[GameStatus.arcade]!,
      completed: byStatus[GameStatus.finito]! + byStatus[GameStatus.completato]!,
      byStatus: byStatus,
      byConsole: await entries(
        'SELECT c.short_label AS label, count(*) AS n FROM game_copies gc JOIN consoles c ON c.id = gc.console_id '
        'GROUP BY c.id ORDER BY n DESC, c.name_norm',
      ),
      byGenre: await entries(
        'SELECT ge.name AS label, count(*) AS n FROM game_genres gg JOIN stat_games sg ON sg.game_id = gg.game_id '
        'JOIN genres ge ON ge.id = gg.genre_id GROUP BY ge.id ORDER BY n DESC, ge.name_norm LIMIT 10',
      ),
      byDecade: await entries(
        "SELECT ((g.release_year / 10) * 10) || '' AS label, count(*) AS n FROM games g $_counted "
        'WHERE g.release_year IS NOT NULL GROUP BY g.release_year / 10 ORDER BY g.release_year / 10',
      ),
      ratingTiers: tiers,
      topDevelopers: await entries(top('developer_id', 'companies')),
      topPublishers: await entries(top('publisher_id', 'companies')),
      topSeries: await entries(top('series_id', 'series')),
    );
  }
}
