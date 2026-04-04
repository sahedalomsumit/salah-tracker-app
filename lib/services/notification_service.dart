import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    // Based on lint: settings is a required named parameter
    await _notifications.initialize(settings: initializationSettings); 
  }

  Future<void> showReminder(String title, String body) async {
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
