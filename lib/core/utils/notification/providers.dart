import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'linca_notification_controller.dart';
import 'linca_notification_service.dart';

final Provider<FlutterLocalNotificationsPlugin>
    localNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((Ref ref) {
  return FlutterLocalNotificationsPlugin();
});

final Provider<LincaNotificationService> localNotificationServiceProvider =
    Provider<LincaNotificationService>((Ref ref) {
  return LincaNotificationService(ref.read(localNotificationsPluginProvider));
});

final Provider<LincaNotificationController>
    eventNotificationControllerProvider =
    Provider<LincaNotificationController>((Ref ref) {
  return LincaNotificationController(ref);
});
