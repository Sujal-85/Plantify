import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'database_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    RepeatInterval? interval,
  }) async {

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'plant_care_reminders',
      'Plant Care Reminders',
      channelDescription: 'Notifications for watering, fertilizing, and more.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    if (interval == null) {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        details,
      );
    } else {
      // For simplicity in this demo, we'll use periodNotifications if possible, 
      // or just schedule the first instance. Real repeat logic often requires 
      // custom timezone math for "every 3 days" etc.
      await _notificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        interval,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    // Persist to Database for In-App History
    await DatabaseService().saveNotification(
      title: title,
      description: body,
      icon: 'calendar', // Default icon for scheduled items
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String iconName = 'info',
  }) async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails('test_channel', 'Test Channel'),
      iOS: DarwinNotificationDetails(),
    );
    await _notificationsPlugin.show(id, title, body, details);

    // Persist to Database
    await DatabaseService().saveNotification(
      title: title,
      description: body,
      icon: iconName,
    );
  }
}
