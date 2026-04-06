import '../constants/app_constants.dart';
import '../../data/models/prayer_record.dart';

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
}
