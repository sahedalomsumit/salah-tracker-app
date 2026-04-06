import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'dart:io';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    // Set Bangladesh Timezone (UTC +6)
    // Note: 'Asia/Dhaka' is the standard for Bangladesh
    
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click if needed
      },
    );
    
    // Request permissions on initialization
    await requestPermissions();
    
    // Schedule the daily reminder
    await scheduleDailyReminder();
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      // Request notifications permission (required for Android 13+)
      await androidImplementation?.requestNotificationsPermission();
      
      // Request exact alarm permission (required for exact scheduling for Android 13+)
      await androidImplementation?.requestExactAlarmsPermission();
    } else if (Platform.isIOS) {
      await _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> scheduleDailyReminder() async {
    // Bangladesh is UTC+6. Using 'Asia/Dhaka' location.
    final dhaka = tz.getLocation('Asia/Dhaka');
    final now = tz.TZDateTime.now(dhaka);
    
    var scheduledDate = tz.TZDateTime(
      dhaka,
      now.year,
      now.month,
      now.day,
      22, // 10 PM
      0,
    );

    // If it's already past 10 PM today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'salah_daily_reminder',
        'Daily Reminders',
        channelDescription: 'Daily reminder to log your prayers at 10 PM',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    // Cancel existing reminders first to avoid duplicates
    await _notifications.cancel(id: 100);

    // In v21.0.0, everything in zonedSchedule is a named parameter
    // and uiLocalNotificationDateInterpretation is removed.
    await _notifications.zonedSchedule(
      id: 100,
      title: 'Salah Tracker',
      body: 'Don\'t forget to log your prayers for today!',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    
    debugPrint('Daily reminder scheduled for: $scheduledDate (BD Time)');
  }

  Future<void> showReminder({required String title, required String body}) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails('salah_channel', 'Salah Reminders'),
      iOS: DarwinNotificationDetails(),
    );
    
    await _notifications.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
