import '../local/database_helper.dart';
import '../remote/supabase_service.dart';
import '../models/prayer_record.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';

class PrayerRepository {
  final String userId;
  final DatabaseHelper _local;
  final _remote = SupabaseService.instance;

  PrayerRepository(this.userId) : _local = DatabaseHelper(userId);

  /// Upsert a prayer status — writes locally first, then syncs to Supabase
  Future<void> updateStatus({
    required String date,
    required String prayerName,
    required PrayerStatus status,
  }) async {
    final record = PrayerRecord(
      date: date,
      prayerName: prayerName,
      status: status,
    );
    await _local.upsertRecord(record);
    // Fire-and-forget remote sync
    _remote.upsertRecord(record);
  }

  /// Get all 5 prayer records for a specific date.
  /// Returns records with 'none' status for prayers not yet logged.
  Future<List<PrayerRecord>> getDayRecords(String date) async {
    final existing = await _local.getByDate(date);
    final existingMap = {for (final r in existing) r.prayerName: r};

    return kPrayerNames.map((name) {
      return existingMap[name] ??
          PrayerRecord(
            date: date,
            prayerName: name,
            status: PrayerStatus.none,
          );
    }).toList();
  }

  /// Get records grouped by date for a list of dates
  Future<Map<String, List<PrayerRecord>>> getMultiDayRecords(
      List<DateTime> dates) async {
    if (dates.isEmpty) return {};
    final keys = dates.map(SalahDateUtils.toKey).toList();
    final start = keys.first;
    final end = keys.last;

    final allRecords = await _local.getByDateRange(start, end);
    final grouped = <String, List<PrayerRecord>>{};
    for (final key in keys) {
      grouped[key] = [];
    }
    for (final r in allRecords) {
      grouped[r.date]?.add(r);
    }
    return grouped;
  }

  /// Get all records from local DB (for streak calculation)
  Future<List<PrayerRecord>> getAllRecords() => _local.getAll();

  /// Pull remote data and merge into local DB (called on app start / refresh)
  Future<void> syncFromRemote() async {
    final thirtyDaysAgo = SalahDateUtils.toKey(
      DateTime.now().subtract(const Duration(days: 30)),
    );
    final remoteRecords = await _remote.fetchSince(thirtyDaysAgo);
    for (final record in remoteRecords) {
      await _local.upsertRecord(record);
    }
  }

  /// Push all local records to remote
  Future<void> syncToRemote() async {
    final localRecords = await _local.getAll();
    for (final record in localRecords) {
      await _remote.upsertRecord(record);
    }
  }
}
