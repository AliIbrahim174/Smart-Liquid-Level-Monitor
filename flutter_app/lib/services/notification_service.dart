import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await plugin.initialize(settings);
  }

  static Future<void> showAlert(String title, String body) async {
    const details = AndroidNotificationDetails(
      'liquid_alerts',
      'Liquid Level Alerts',
      channelDescription: 'Alerts when monitored liquid levels are low',
      importance: Importance.high,
      priority: Priority.high,
    );

    await plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: details),
    );
  }
}
