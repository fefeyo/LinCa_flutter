import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/utils/notification/linca_notification_service.dart';
import 'package:linca_otaku_support/core/utils/notification/providers.dart';
import 'package:linca_otaku_support/core/utils/providers.dart';

class LincaNotificationController {
  LincaNotificationController(this.ref);

  final Ref ref;

  Future<bool> get notificationsEnabled async =>
      await ref.watch(preferencesServiceProvider).isEventNotificationEnabled();

  LincaNotificationService get _notificationService =>
      ref.read(localNotificationServiceProvider);

  Future<void> scheduleEventDayNotification({
    required String eventId,
    required String title,
    required String body,
    required DateTime eventDate,
  }) async {
    // アプリ設定チェック
    if (!await notificationsEnabled) return;

    final DateTime notifyAt = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      9,
    );

    if (notifyAt.isBefore(DateTime.now())) return;

    _notificationService.schedule(
      id: eventId.hashCode,
      title: title,
      body: body,
      scheduledAt: notifyAt,
    );
  }

  Future<void> scheduleDummy() async {
    // アプリ設定チェック
    if (!await notificationsEnabled) return;

    final DateTime notifyAt =
        DateTime.now().add(const Duration(milliseconds: 1000));

    if (notifyAt.isBefore(DateTime.now())) return;

    _notificationService.schedule(
      id: 100000,
      title: 'イベント当日です',
      body: '会場付近でチェックインを忘れずに！',
      scheduledAt: notifyAt,
    );
  }

  Future<void> cancelEventNotification(String eventId) async {
    await _notificationService.cancel(eventId.hashCode);
  }
}
