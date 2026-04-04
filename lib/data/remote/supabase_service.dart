import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prayer_record.dart';
import '../../core/constants/app_constants.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  /// Sync a single record to Supabase (upsert equivalent)
  Future<void> upsertRecord(PrayerRecord record) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      final existing = await _client
          .from('prayers')
          .select('id')
          .eq('user_id', user.id)
          .eq('date', record.date)
          .eq('prayer_name', record.prayerName)
          .maybeSingle();

      if (existing != null) {
        await _client.from('prayers').update({
          'status': record.status.key,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', existing['id']);
      } else {
        await _client.from('prayers').insert({
          'user_id': user.id,
          'date': record.date,
          'prayer_name': record.prayerName,
          'status': record.status.key,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // Silently fail — offline-first, local is source of truth
      // ignore: avoid_print
      print('[Supabase] upsert failed: $e');
    }
  }

  /// Fetch all records from Supabase for a given date
  Future<List<PrayerRecord>> fetchByDate(String date) async {
    try {
      final res = await _client
          .from('prayers')
          .select()
          .eq('date', date);
      return (res as List)
          .map((m) => PrayerRecord(
                id: m['id']?.toString(),
                date: m['date'] as String,
                prayerName: m['prayer_name'] as String,
                status: statusFromKey(m['status'] as String?),
              ))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('[Supabase] fetchByDate failed: $e');
      return [];
    }
  }

  /// Fetch records since a given date (for sync on app start)
  Future<List<PrayerRecord>> fetchSince(String fromDate) async {
    try {
      final res = await _client
          .from('prayers')
          .select()
          .gte('date', fromDate)
          .order('date');
      return (res as List)
          .map((m) => PrayerRecord(
                id: m['id']?.toString(),
                date: m['date'] as String,
                prayerName: m['prayer_name'] as String,
                status: statusFromKey(m['status'] as String?),
              ))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('[Supabase] fetchSince failed: $e');
      return [];
    }
  }
}
