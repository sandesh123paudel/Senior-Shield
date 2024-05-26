import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationHeleper{
  static final _notification=FlutterLocalNotificationsPlugin();
  static bool _initialized = false;



  static Future<void> init() async {
    if (!_initialized) {
      _initialized = true;

      const initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _notification.initialize(initializationSettings);
      tz.initializeTimeZones();
    }
  }

  static Future<void> scheduledNotification(String title, String body, DateTime scheduledTime) async {
    var androidDetails = const AndroidNotificationDetails(
      'my_channel_id', // Use the channel ID you created
      'My Channel', // Channel name
      channelDescription: 'For Showing Message Notification',
      importance: Importance.max,
      priority: Priority.high,
      autoCancel: false,
      playSound: true,
      ticker: 'ticker',
      sound: RawResourceAndroidNotificationSound('alarm'),

    );

    var iosDetails = const DarwinNotificationDetails(
    );

    var notificationDetails = NotificationDetails(
      iOS: iosDetails,
      android: androidDetails,
    );

    await _notification.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }


}