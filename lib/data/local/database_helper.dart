import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/prayer_record.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  final String userId;
  DatabaseHelper(this.userId);

  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'salah_$userId.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE prayers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        prayerName TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'none',
        updatedAt TEXT NOT NULL DEFAULT (datetime('now')),
        UNIQUE(date, prayerName)
      )
    ''');
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Upsert: insert or replace on conflict (date, prayerName)
  Future<void> upsertRecord(PrayerRecord record) async {
    final d = await db;
    await d.rawInsert('''
      INSERT INTO prayers (date, prayerName, status, updatedAt)
      VALUES (?, ?, ?, datetime('now'))
      ON CONFLICT(date, prayerName) DO UPDATE SET
        status = excluded.status,
        updatedAt = excluded.updatedAt
    ''', [record.date, record.prayerName, record.status.key]);
  }

  /// Get all records for a specific date
  Future<List<PrayerRecord>> getByDate(String date) async {
    final d = await db;
    final maps = await d.query(
      'prayers',
      where: 'date = ?',
      whereArgs: [date],
    );
    return maps.map(PrayerRecord.fromMap).toList();
  }

  /// Get records for a range of dates
  Future<List<PrayerRecord>> getByDateRange(
      String startDate, String endDate) async {
    final d = await db;
    final maps = await d.query(
      'prayers',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );
    return maps.map(PrayerRecord.fromMap).toList();
  }

  /// Get all records (for streak calculation etc.)
  Future<List<PrayerRecord>> getAll() async {
    final d = await db;
    final maps = await d.query('prayers', orderBy: 'date ASC');
    return maps.map(PrayerRecord.fromMap).toList();
  }

  /// Delete records for a specific date (debug helper)
  Future<void> deleteByDate(String date) async {
    final d = await db;
    await d.delete('prayers', where: 'date = ?', whereArgs: [date]);
  }
}
