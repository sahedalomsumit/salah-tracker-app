import 'package:intl/intl.dart';

class SalahDateUtils {
  SalahDateUtils._();

  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _displayFormat = DateFormat('EEEE, d MMMM yyyy');
  static final _shortFormat = DateFormat('EEE, d MMM');
  static final _monthFormat = DateFormat('MMMM yyyy');

  /// Convert DateTime → storage key (yyyy-MM-dd)
  static String toKey(DateTime date) => _dateFormat.format(date);

  /// Today's key
  static String todayKey() => toKey(DateTime.now());

  /// Parse storage key back to DateTime
  static DateTime fromKey(String key) => _dateFormat.parse(key);

  /// Human-readable full date
  static String displayDate(DateTime date) => _displayFormat.format(date);

  /// Human-readable short date
  static String shortDate(DateTime date) => _shortFormat.format(date);

  /// Month label
  static String monthLabel(DateTime date) => _monthFormat.format(date);

  /// Whether two DateTimes are on the same calendar day
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Whether a date key is today
  static bool isToday(String key) => key == todayKey();

  /// Get a list of [count] dates ending [offset] days ago (inclusive), oldest first
  static List<DateTime> lastNDays(int count, {int offset = 0}) {
    final today = DateTime.now().subtract(Duration(days: offset));
    return List.generate(
      count,
      (i) => today.subtract(Duration(days: count - 1 - i)),
    );
  }

  /// Get dates of a specific calendar week (Mon–Sun) relative to today
  static List<DateTime> getWeekDays({int weeksAgo = 0}) {
    final today = DateTime.now().subtract(Duration(days: weeksAgo * 7));
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// Get dates of a specific calendar month relative to today
  static List<DateTime> getMonthDays({int monthsAgo = 0}) {
    final now = DateTime.now();
    // Calculate the target month and year
    int targetMonth = now.month - monthsAgo;
    int targetYear = now.year;
    
    while (targetMonth <= 0) {
      targetMonth += 12;
      targetYear -= 1;
    }

    final first = DateTime(targetYear, targetMonth, 1);
    final nextMonthFirst = DateTime(targetYear, targetMonth + 1, 1);
    final last = nextMonthFirst.subtract(const Duration(days: 1));
    
    final count = last.day;
    return List.generate(count, (i) => first.add(Duration(days: i)));
  }

  /// Get all dates for a specific year relative to today
  static List<DateTime> getYearDays({int yearsAgo = 0}) {
    final targetYear = DateTime.now().year - yearsAgo;
    final first = DateTime(targetYear, 1, 1);
    final last = DateTime(targetYear, 12, 31);
    final count = last.difference(first).inDays + 1;
    return List.generate(count, (i) => first.add(Duration(days: i)));
  }

  /// Day-of-week abbreviations
  static String dayAbbr(DateTime date) => DateFormat('EEE').format(date);

  /// Month name (e.g., January)
  static String monthName(int month) => DateFormat('MMMM').format(DateTime(2024, month));

  /// Month abbreviation (e.g., Jan)
  static String monthAbbr(int month) => DateFormat('MMM').format(DateTime(2024, month));

  /// Year label (e.g., 2024)
  static String yearLabel(DateTime date) => DateFormat('yyyy').format(date);
}
