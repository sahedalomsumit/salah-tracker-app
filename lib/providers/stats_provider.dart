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
  
  // Weekly section
  final Map<String, int> weeklyAggregate;
  final List<Map<String, int>> weeklyDailyStatusCounts;
  final List<String> weeklyLabels;
  final int weeklyOffset;
  final String weeklyRangeLabel;

  // Monthly section
  final Map<String, int> monthlyAggregate;
  final int monthlyOffset;
  final String monthlyLabel;
  final String monthlyRangeLabel;

  // Yearly section
  final Map<String, int> yearlyAggregate;
  final List<double> yearlyMonthlyPercents;
  final int yearlyOffset;
  final String yearlyLabel;

  const StatsState({
    this.streak = 0,
    this.todayPercent = 0,
    this.weeklyPercent = 0,
    this.monthlyPercent = 0,
    this.weeklyAggregate = const {},
    this.weeklyDailyStatusCounts = const [],
    this.weeklyLabels = const [],
    this.weeklyOffset = 0,
    this.weeklyRangeLabel = '',
    this.monthlyAggregate = const {},
    this.monthlyOffset = 0,
    this.monthlyLabel = '',
    this.monthlyRangeLabel = '',
    this.yearlyAggregate = const {},
    this.yearlyMonthlyPercents = const [],
    this.yearlyOffset = 0,
    this.yearlyLabel = '',
  });

  StatsState copyWith({
    int? streak,
    double? todayPercent,
    double? weeklyPercent,
    double? monthlyPercent,
    Map<String, int>? weeklyAggregate,
    List<Map<String, int>>? weeklyDailyStatusCounts,
    List<String>? weeklyLabels,
    int? weeklyOffset,
    String? weeklyRangeLabel,
    Map<String, int>? monthlyAggregate,
    int? monthlyOffset,
    String? monthlyLabel,
    String? monthlyRangeLabel,
    Map<String, int>? yearlyAggregate,
    List<double>? yearlyMonthlyPercents,
    int? yearlyOffset,
    String? yearlyLabel,
  }) {
    return StatsState(
      streak: streak ?? this.streak,
      todayPercent: todayPercent ?? this.todayPercent,
      weeklyPercent: weeklyPercent ?? this.weeklyPercent,
      monthlyPercent: monthlyPercent ?? this.monthlyPercent,
      weeklyAggregate: weeklyAggregate ?? this.weeklyAggregate,
      weeklyDailyStatusCounts: weeklyDailyStatusCounts ?? this.weeklyDailyStatusCounts,
      weeklyLabels: weeklyLabels ?? this.weeklyLabels,
      weeklyOffset: weeklyOffset ?? this.weeklyOffset,
      weeklyRangeLabel: weeklyRangeLabel ?? this.weeklyRangeLabel,
      monthlyAggregate: monthlyAggregate ?? this.monthlyAggregate,
      monthlyOffset: monthlyOffset ?? this.monthlyOffset,
      monthlyLabel: monthlyLabel ?? this.monthlyLabel,
      monthlyRangeLabel: monthlyRangeLabel ?? this.monthlyRangeLabel,
      yearlyAggregate: yearlyAggregate ?? this.yearlyAggregate,
      yearlyMonthlyPercents: yearlyMonthlyPercents ?? this.yearlyMonthlyPercents,
      yearlyOffset: yearlyOffset ?? this.yearlyOffset,
      yearlyLabel: yearlyLabel ?? this.yearlyLabel,
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

@riverpod
class Stats extends _$Stats {
  int _weeklyOffset = 0;
  int _monthlyOffset = 0;
  int _yearlyOffset = 0;

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

    // Get weekly records (with offset)
    final weekDays = SalahDateUtils.getWeekDays(weeksAgo: _weeklyOffset);
    final weekMap = await repo.getMultiDayRecords(weekDays);
    final weekKeys = weekDays.map(SalahDateUtils.toKey).toList();
    final weekAgg = CalcUtils.aggregateStatus(weekMap);
    final weekDailyCounts = CalcUtils.dailyStatusCounts(weekKeys, weekMap);
    final weekLabels = weekDays.map((d) => SalahDateUtils.dayAbbr(d)).toList();
    
    final weekStart = SalahDateUtils.shortDate(weekDays.first);
    final weekEnd = SalahDateUtils.shortDate(weekDays.last);
    final weekRangeLabel = '$weekStart - $weekEnd';

    // Get monthly records (with offset)
    final monthDays = SalahDateUtils.getMonthDays(monthsAgo: _monthlyOffset);
    final monthMap = await repo.getMultiDayRecords(monthDays);
    final monthAgg = CalcUtils.aggregateStatusWithUnused(monthDays, monthMap);
    final monthLabel = SalahDateUtils.monthLabel(monthDays.first);
    
    final monthStart = SalahDateUtils.shortDate(monthDays.first);
    final monthEnd = SalahDateUtils.shortDate(monthDays.last);
    final monthRangeLabel = '$monthStart - $monthEnd';

    // Get yearly records (with offset)
    final yearDays = SalahDateUtils.getYearDays(yearsAgo: _yearlyOffset);
    final yearMap = await repo.getMultiDayRecords(yearDays);
    final yearAgg = CalcUtils.aggregateStatusWithUnused(yearDays, yearMap);
    final targetYear = today.year - _yearlyOffset;
    final yearlyPercents = CalcUtils.monthlyPercentages(targetYear, yearMap);
    final yearlyLabel = '$targetYear';

    // Overall stats (always based on current week/month for the mini cards)
    final currentWeekDays = SalahDateUtils.getWeekDays(weeksAgo: 0);
    final currentWeekMap = await repo.getMultiDayRecords(currentWeekDays);
    final weekPct = CalcUtils.overallPercentWithUnused(currentWeekDays, currentWeekMap);

    final currentMonthDays = SalahDateUtils.getMonthDays(monthsAgo: 0);
    final currentMonthMap = await repo.getMultiDayRecords(currentMonthDays);
    final monthPct = CalcUtils.overallPercentWithUnused(currentMonthDays, currentMonthMap);

    // Streak: needs all records
    final allRecords = await repo.getAllRecords();
    final allGrouped = <String, List<PrayerRecord>>{};
    for (final r in allRecords) {
      allGrouped.putIfAbsent(r.date, () => []).add(r);
    }

    final streak = CalcUtils.calculateStreak(allGrouped);
    final todayPct = CalcUtils.dailyCompletionPercent(todayRecords);

    return StatsState(
      streak: streak,
      todayPercent: todayPct,
      weeklyPercent: weekPct,
      monthlyPercent: monthPct,
      
      weeklyAggregate: weekAgg,
      weeklyDailyStatusCounts: weekDailyCounts,
      weeklyLabels: weekLabels,
      weeklyOffset: _weeklyOffset,
      weeklyRangeLabel: weekRangeLabel,

      monthlyAggregate: monthAgg,
      monthlyOffset: _monthlyOffset,
      monthlyLabel: monthLabel,
      monthlyRangeLabel: monthRangeLabel,

      yearlyAggregate: yearAgg,
      yearlyMonthlyPercents: yearlyPercents,
      yearlyOffset: _yearlyOffset,
      yearlyLabel: yearlyLabel,
    );
  }

  void changeWeeklyOffset(int delta) {
    _weeklyOffset += delta;
    if (_weeklyOffset < 0) _weeklyOffset = 0;
    ref.invalidateSelf();
  }

  void changeMonthlyOffset(int delta) {
    _monthlyOffset += delta;
    if (_monthlyOffset < 0) _monthlyOffset = 0;
    ref.invalidateSelf();
  }

  void changeYearlyOffset(int delta) {
    _yearlyOffset += delta;
    if (_yearlyOffset < 0) _yearlyOffset = 0;
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
