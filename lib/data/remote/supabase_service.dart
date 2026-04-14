import 'package:flutter/foundation.dart';
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
      debugPrint('[Supabase] upsert failed: $e');
    }
  }

  /// Fetch all records from Supabase for a given date (for the current user)
  Future<List<PrayerRecord>> fetchByDate(String date) async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final res = await _client
          .from('prayers')
          .select()
          .eq('user_id', user.id)
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
      debugPrint('[Supabase] fetchByDate failed: $e');
      return [];
    }
  }

  /// Fetch records since a given date (for the current user)
  Future<List<PrayerRecord>> fetchSince(String fromDate) async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final res = await _client
          .from('prayers')
          .select()
          .eq('user_id', user.id)
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
      debugPrint('[Supabase] fetchSince failed: $e');
      return [];
    }
  }

  /// Get user role from auth metadata (no DB call needed)
  String getRole() {
    final user = _client.auth.currentUser;
    if (user == null) return 'user';
    return user.appMetadata['role']?.toString() ?? 'user';
  }

  /// Admin: Fetch all records for a specific user
  Future<List<PrayerRecord>> fetchByUserId(String userId) async {
    try {
      final res = await _client
          .from('prayers')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
      return (res as List)
          .map((m) => PrayerRecord(
                id: m['id']?.toString(),
                date: m['date'] as String,
                prayerName: m['prayer_name'] as String,
                status: statusFromKey(m['status'] as String?),
              ))
          .toList();
    } catch (e) {
      debugPrint('[Supabase] fetchByUserId failed: $e');
      return [];
    }
  }

  /// Admin: Fetch all registered users (from the secure view)
  Future<List<Map<String, dynamic>>> fetchAllProfiles() async {
    try {
      final res = await _client
          .from('admin_users_view')
          .select('id, full_name, avatar_url, role, email');
      return List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      debugPrint('[Supabase] fetchAllProfiles failed: $e');
      return [];
    }
  }

  /// Admin/User: Delete a record
  Future<void> deleteRecord(String recordId) async {
    try {
      await _client.from('prayers').delete().eq('id', recordId);
    } catch (e) {
      debugPrint('[Supabase] deleteRecord failed: $e');
    }
  }
}
