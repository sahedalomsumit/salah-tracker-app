import '../constants/app_constants.dart';
import '../../data/models/prayer_record.dart';
import 'date_utils.dart';

class CalcUtils {
  CalcUtils._();

  /// Daily completion % — counts onTime + qaza out of 5
  static double dailyCompletionPercent(List<PrayerRecord> records) {
    if (records.isEmpty) return 0;
    final doneCount = records
        .where((r) => r.status == PrayerStatus.onTime || r.status == PrayerStatus.qaza)
        .length;
    return (doneCount / 5) * 100;
  }

  /// Full completion = all 5 on time (no missed, no qaza)
  static bool isDayFullyComplete(List<PrayerRecord> records) {
    if (records.length < 5) return false;
    return records.every((r) => r.status == PrayerStatus.onTime);
  }

  /// Whether a day is fully completed (onTime + qaza = 5) for streak calculation
  static bool isDayCompletedForStreak(List<PrayerRecord> records) {
    if (records.isEmpty) return false;
    final doneCount = records
        .where((r) => r.status == PrayerStatus.onTime || r.status == PrayerStatus.qaza)
        .length;
    return doneCount == 5;
  }

  /// Count current streak: consecutive days (backwards from today) with all 5 prayers done (onTime / qaza).
  /// dayRecords: map of dateKey → list of PrayerRecord
  static int calculateStreak(Map<String, List<PrayerRecord>> dayRecords) {
    final keys = dayRecords.keys.toList()..sort((a, b) => b.compareTo(a));
    int streak = 0;
    for (final key in keys) {
      final records = dayRecords[key]!;
      if (!isDayCompletedForStreak(records)) break;
      streak++;
    }
    return streak;
  }

  /// Aggregate stats over a list of days' records
  static Map<String, int> aggregateStatus(
      Map<String, List<PrayerRecord>> dayRecords) {
    int onTime = 0, qaza = 0, missed = 0, none = 0;
    for (final records in dayRecords.values) {
      for (final r in records) {
        switch (r.status) {
          case PrayerStatus.onTime:
            onTime++;
            break;
          case PrayerStatus.qaza:
            qaza++;
            break;
          case PrayerStatus.missed:
            missed++;
            break;
          case PrayerStatus.none:
            none++;
            break;
        }
      }
    }
    return {
      'onTime': onTime,
      'qaza': qaza,
      'missed': missed,
      'none': none,
    };
  }

  /// Aggregate stats including "not added" (empty slots) up to today
  static Map<String, int> aggregateStatusWithUnused(
      List<DateTime> days, Map<String, List<PrayerRecord>> dayRecords) {
    int onTime = 0, qaza = 0, missed = 0;
    int totalExpected = 0;
    final now = DateTime.now();

    for (final date in days) {
      // Only count expected prayers for days that are NOT in the future
      if (date.isAfter(now) && !SalahDateUtils.isSameDay(date, now)) {
        continue;
      }
      
      totalExpected += 5;
      final key = SalahDateUtils.toKey(date);
      final records = dayRecords[key] ?? [];

      for (final r in records) {
        switch (r.status) {
          case PrayerStatus.onTime:
            onTime++;
            break;
          case PrayerStatus.qaza:
            qaza++;
            break;
          case PrayerStatus.missed:
            missed++;
            break;
          default:
            break;
        }
      }
    }

    final notAdded = (totalExpected - (onTime + qaza + missed)).clamp(0, 999999);

    return {
      'onTime': onTime,
      'qaza': qaza,
      'missed': missed,
      'notAdded': notAdded,
    };
  }

  /// Per-day completion % (for chart bars)
  static List<double> dailyPercents(
      List<String> dateKeys, Map<String, List<PrayerRecord>> dayRecords) {
    return dateKeys.map((key) {
      final records = dayRecords[key] ?? [];
      return dailyCompletionPercent(records);
    }).toList();
  }

  /// Get status breakdown for each day for the stacked bar chart
  static List<Map<String, int>> dailyStatusCounts(
      List<String> dateKeys, Map<String, List<PrayerRecord>> dayRecords) {
    return dateKeys.map((key) {
      final records = dayRecords[key] ?? [];
      int onTime = 0, qaza = 0, missed = 0;
      for (final r in records) {
        if (r.status == PrayerStatus.onTime) onTime++;
        if (r.status == PrayerStatus.qaza) qaza++;
        if (r.status == PrayerStatus.missed) missed++;
      }
      return {
        'onTime': onTime,
        'qaza': qaza,
        'missed': missed,
      };
    }).toList();
  }

  /// Overall completion % across multiple days (logged prayers only)
  static double overallPercent(Map<String, List<PrayerRecord>> dayRecords) {
    int done = 0, total = 0;
    for (final records in dayRecords.values) {
      for (final r in records) {
        if (r.status != PrayerStatus.none) total++;
        if (r.status == PrayerStatus.onTime || r.status == PrayerStatus.qaza) done++;
      }
    }
    if (total == 0) return 0;
    return (done / total) * 100;
  }

  /// Overall completion % including unlogged slots (up to today)
  static double overallPercentWithUnused(List<DateTime> days, Map<String, List<PrayerRecord>> dayRecords) {
    int done = 0;
    int totalExpected = 0;
    final now = DateTime.now();

    for (final date in days) {
      if (date.isAfter(now) && !SalahDateUtils.isSameDay(date, now)) continue;
      
      totalExpected += 5;
      final key = SalahDateUtils.toKey(date);
      final records = dayRecords[key] ?? [];
      
      done += records.where((r) => r.status == PrayerStatus.onTime || r.status == PrayerStatus.qaza).length;
    }
    
    if (totalExpected == 0) return 0;
    return (done / totalExpected) * 100;
  }

  /// Get completion % for each month of the year (1-12)
  static List<double> monthlyPercentages(
      int year, Map<String, List<PrayerRecord>> yearRecords) {
    final List<double> results = [];
    for (int month = 1; month <= 12; month++) {
      int done = 0, total = 0;
      final monthEnd = DateTime(year, month + 1, 1).subtract(const Duration(days: 1));
      
      for (int day = 1; day <= monthEnd.day; day++) {
        final date = DateTime(year, month, day);
        // Only count days up to today if it's the current year
        if (date.isAfter(DateTime.now())) continue;

        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final records = yearRecords[key] ?? [];
        
        // Each day has 5 prayers
        total += 5;
        done += records.where((r) => r.status == PrayerStatus.onTime || r.status == PrayerStatus.qaza).length;
      }
      
      if (total == 0) {
        results.add(0);
      } else {
        results.add((done / total) * 100);
      }
    }
    return results;
  }
}
