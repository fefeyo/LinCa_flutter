import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LincaNotificationService {
  const LincaNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledAt, tz.getLocation('Asia/Tokyo')),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_day',
          'Event Day',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
