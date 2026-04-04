import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/prayer_record.dart';
import '../data/repositories/prayer_repository.dart';
import '../core/utils/date_utils.dart';
import '../core/utils/calculation_utils.dart';
import 'prayer_provider.dart';

part 'stats_provider.g.dart';

// ── Stats state model ─────────────────────────────────────────────────────────

class StatsState {
  final int streak;
  final double todayPercent;
  final double weeklyPercent;
  final double monthlyPercent;
  final Map<String, int> weeklyAggregate;   // {onTime, qaza, missed, none}
  final Map<String, int> monthlyAggregate;
  final List<double> weeklyDailyPercents;   // 7 values for bar chart
  final List<String> weeklyLabels;

  const StatsState({
    this.streak = 0,
    this.todayPercent = 0,
    this.weeklyPercent = 0,
    this.monthlyPercent = 0,
    this.weeklyAggregate = const {},
    this.monthlyAggregate = const {},
    this.weeklyDailyPercents = const [],
    this.weeklyLabels = const [],
  });
}

// ── Provider ──────────────────────────────────────────────────────────────────

@riverpod
class Stats extends _$Stats {
  @override
  FutureOr<StatsState> build() async {
    final repo = ref.watch(prayerRepositoryProvider);
    return _computeStats(repo);
  }

  Future<StatsState> _computeStats(PrayerRepository repo) async {
    final today = DateTime.now();
    final todayKey = SalahDateUtils.toKey(today);

    // Get today's records
    final todayRecords = await repo.getDayRecords(todayKey);

    // Get weekly records (last 7 days)
    final weekDays = SalahDateUtils.lastNDays(7);
    final weekMap = await repo.getMultiDayRecords(weekDays);

    // Get monthly records
    final monthDays = SalahDateUtils.currentMonth();
    final monthMap = await repo.getMultiDayRecords(monthDays);

    // Streak: needs all records from local DB
    final allRecords = await repo.getAllRecords();
    final allGrouped = <String, List<PrayerRecord>>{};
    for (final r in allRecords) {
      allGrouped.putIfAbsent(r.date, () => []).add(r);
    }

    final streak = CalcUtils.calculateStreak(allGrouped);
    final todayPct = CalcUtils.dailyCompletionPercent(todayRecords);
    final weekPct = CalcUtils.overallPercent(weekMap);
    final monthPct = CalcUtils.overallPercent(monthMap);
    final weekAgg = CalcUtils.aggregateStatus(weekMap);
    final monthAgg = CalcUtils.aggregateStatus(monthMap);

    final weekKeys = weekDays.map(SalahDateUtils.toKey).toList();
    final weekDailyPcts = CalcUtils.dailyPercents(weekKeys, weekMap);
    final weekLabels = weekDays.map((d) => SalahDateUtils.dayAbbr(d)).toList();

    return StatsState(
      streak: streak,
      todayPercent: todayPct,
      weeklyPercent: weekPct,
      monthlyPercent: monthPct,
      weeklyAggregate: weekAgg,
      monthlyAggregate: monthAgg,
      weeklyDailyPercents: weekDailyPcts,
      weeklyLabels: weekLabels,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
