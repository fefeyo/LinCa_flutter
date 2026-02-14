import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/src/flutter_local_notifications_plugin.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/models/app_settings.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/notification/linca_notification_controller.dart';
import 'package:linca_otaku_support/core/utils/notification/providers.dart';
import 'package:linca_otaku_support/core/utils/participation_extension.dart';
import 'package:linca_otaku_support/core/utils/preferences_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/network/model/event_base.dart';
import '../../core/utils/providers.dart';
import '../my_page/view/my_page_item.dart';

@RoutePage()
class AppSettingsPage extends HookConsumerWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PreferencesService preferencesService =
        ref.read(preferencesServiceProvider);
    final ValueNotifier<AppSettings?> appSettings =
        useState(preferencesService.getAppSettings());

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final LincaNotificationController notificationController =
        ref.watch(eventNotificationControllerProvider);
    final List<ParticipationInfo> participations =
        ref.watch(participationControllerProvider).value ??
            <ParticipationInfo>[];
    final FlutterLocalNotificationsPlugin notificationPlugin =
        ref.watch(localNotificationsPluginProvider);
    final List<LincaEvent> events =
        ref.watch(eventControllerProvider).value ?? <LincaEvent>[];
    final List<LincaEvent> upcomingEvents = events.where((LincaEvent event) {
      final DateTime? date = event.event.date;
      if (date == null) return false;
      return !date.isBefore(today);
    }).toList();
    // 今日以降の現地参加予定のイベント
    final List<LincaEvent> onSiteAndHasCheckInParticipateEvents =
        upcomingEvents.where((LincaEvent event) {
      final ParticipationInfo? participation =
          participations.getByEventId(event.event.id);
      final OfficialEvent officialEvent = event.event as OfficialEvent;
      return participation?.participationType == ParticipationType.onSite &&
          officialEvent.checkInId.isNotEmpty;
    }).toList();
    // 今日以降の参加予定のイベント
    final List<LincaEvent> participateEvents =
        upcomingEvents.where((LincaEvent event) {
      final ParticipationInfo? participation =
          participations.getByEventId(event.event.id);
      return participations.hasEventId(event.event.id) &&
          participation?.participationType != ParticipationType.absent;
    }).toList();
    // 今日以降の参加予定じゃないイベント
    final List<LincaEvent> notParticipateEvents = upcomingEvents
        .where((LincaEvent event) => !participations.hasEventId(event.event.id))
        .toList();
    final Future<List<PendingNotificationRequest>> currentNotifications =
        notificationPlugin.pendingNotificationRequests();
    final ValueNotifier<List<PendingNotificationRequest>> notificationEvents =
        useState(<PendingNotificationRequest>[]);

    useEffect(() {
      final AppSettings? mutableAppSettings = appSettings.value;
      if (mutableAppSettings == null) return;
      for (final LincaEvent event in upcomingEvents) {
        notificationController.cancelEventNotification(event.event.id);
      }
      if (!mutableAppSettings.isNotificationEnabled) return;
      List<LincaEvent> targetEvents = <LincaEvent>[];
      if (mutableAppSettings.isMyEventNotificationEnabled) {
        switch (mutableAppSettings.eventNotificationType) {
          case EventNotificationType.allParticipation:
            targetEvents.addAll(participateEvents);
            break;
          case EventNotificationType.onlyHasCheckedIn:
            targetEvents.addAll(onSiteAndHasCheckInParticipateEvents);
            break;
        }
      }
      if (mutableAppSettings.isAllEventNotificationEnabled) {
        if (mutableAppSettings.isLoveLiveNotificationEnabled) {
          targetEvents.addAll(notParticipateEvents.where((LincaEvent event) =>
              event.event.tagIds.contains(AppConstants.seriesTagLovelive)));
        }
        if (mutableAppSettings.isSunshineNotificationEnabled) {
          targetEvents.addAll(notParticipateEvents.where((LincaEvent event) =>
              event.event.tagIds.contains(AppConstants.seriesTagSunshine)));
        }
        if (mutableAppSettings.isNijigasakiNotificationEnabled) {
          targetEvents.addAll(notParticipateEvents.where((LincaEvent event) =>
              event.event.tagIds.contains(AppConstants.seriesTagNijigasaki)));
        }
        if (mutableAppSettings.isSuperstarNotificationEnabled) {
          targetEvents.addAll(notParticipateEvents.where((LincaEvent event) =>
              event.event.tagIds.contains(AppConstants.seriesTagSuperstar)));
        }
        if (mutableAppSettings.isHasunosoraNotificationEnabled) {
          targetEvents.addAll(notParticipateEvents.where((LincaEvent event) =>
              event.event.tagIds.contains(AppConstants.seriesTagHasunosora)));
        }
        if (mutableAppSettings.isIkizuliveNotificationEnabled) {
          targetEvents.addAll(notParticipateEvents.where((LincaEvent event) =>
              event.event.tagIds.contains(AppConstants.seriesTagIkizulive)));
        }
        if (mutableAppSettings.isMusicalNotificationEnabled) {
          targetEvents.addAll(notParticipateEvents.where((LincaEvent event) =>
              event.event.tagIds.contains(AppConstants.seriesTagMusical)));
        }
        if (mutableAppSettings.isYohaneNotificationEnabled) {
          targetEvents.addAll(notParticipateEvents.where((LincaEvent event) =>
              event.event.tagIds.contains(AppConstants.seriesTagYohane)));
        }
      }
      targetEvents = targetEvents.toSet().toList();
      for (final LincaEvent event in targetEvents) {
        if (onSiteAndHasCheckInParticipateEvents.contains(event)) {
          notificationController.scheduleEventDayNotification(
            eventId: event.event.id,
            title: 'イベント当日です',
            body: '${event.event.title}のイベント当日です。会場付近でのチェックインを忘れずに！',
            eventDate: event.event.date!,
          );
        } else {
          notificationController.scheduleEventDayNotification(
            eventId: event.event.id,
            title: 'イベント当日です',
            body: '${event.event.title}のイベント当日です。会場付近でのチェックインを忘れずに！',
            eventDate: event.event.date!,
          );
        }
      }

      print(
          'Target events for notifications: ${targetEvents.map((e) => e.event.title).toList()}');

      preferencesService.updateAppSettings(mutableAppSettings);

      return null;
    }, <Object?>[appSettings.value?.toJson().toString()]);

    List<Widget> generateGroupNotificationTiles() {
      return <Widget>[
        CheckboxListTile.adaptive(
          title: const Text('ラブライブ！'),
          value: appSettings.value?.isLoveLiveNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isLoveLiveNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: const Text('ラブライブ！サンシャイン!!'),
          value: appSettings.value?.isSunshineNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isSunshineNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: const Text('ラブライブ！虹ヶ咲学園スクールアイドル同好会'),
          value: appSettings.value?.isNijigasakiNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isNijigasakiNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: const Text('ラブライブ！スーパースター!!'),
          value: appSettings.value?.isSuperstarNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isSuperstarNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: const Text('ラブライブ！蓮ノ空女学院スクールアイドルクラブ'),
          value: appSettings.value?.isHasunosoraNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isHasunosoraNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: const Text('イキヅライブ！LOVELIVE!BLUEBIRD'),
          value: appSettings.value?.isIkizuliveNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isIkizuliveNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: const Text('スクールアイドルミュージカル'),
          value: appSettings.value?.isMusicalNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isMusicalNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: const Text('幻日のヨハネ'),
          value: appSettings.value?.isYohaneNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isYohaneNotificationEnabled: value ?? false,
            );
          },
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '設定',
          style: context.textTheme.titleMedium,
        ),
        actions: <Widget>[
          Switch(
            value: appSettings.value?.isNotificationEnabled ?? false,
            onChanged: (bool value) async {
              if (value) {
                final bool isEnable = await requestNotificationPermission();
                if (!isEnable) return;
                appSettings.value =
                    appSettings.value?.copyWith(isNotificationEnabled: true);
              } else {
                appSettings.value =
                    appSettings.value?.copyWith(isNotificationEnabled: false);
                final AppSettings? mutableAppSettings = appSettings.value;
                if (mutableAppSettings == null) return;
                preferencesService.updateAppSettings(mutableAppSettings);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Opacity(
          opacity:
              appSettings.value?.isNotificationEnabled ?? false ? 1.0 : 0.4,
          child: IgnorePointer(
            ignoring: appSettings.value?.isNotificationEnabled == false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SwitchListTile(
                    title: const Text('マイイベントに登録済みのイベントを通知する'),
                    value: appSettings.value?.isMyEventNotificationEnabled ??
                        false,
                    onChanged: (bool value) {
                      appSettings.value = appSettings.value?.copyWith(
                        isMyEventNotificationEnabled: value,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: context.colorScheme.surfaceContainerHighest,
                    child: Opacity(
                      opacity:
                      appSettings.value?.isMyEventNotificationEnabled ??
                          false
                          ? 1.0
                          : 0.4,
                      child: IgnorePointer(
                        ignoring:
                        appSettings.value?.isMyEventNotificationEnabled ==
                            false,
                        child: RadioGroup<EventNotificationType?>(
                          onChanged: (EventNotificationType? value) {
                            if (value == null) return;
                            appSettings.value = appSettings.value?.copyWith(
                              eventNotificationType: value,
                            );
                          },
                          groupValue: appSettings.value?.eventNotificationType,
                          child: const Column(
                            children: [
                              RadioListTile<EventNotificationType?>(
                                title: Text('登録済みの全てのイベント'),
                                value: EventNotificationType.allParticipation,
                                controlAffinity:
                                ListTileControlAffinity.trailing,
                              ),
                              Divider(),
                              RadioListTile<EventNotificationType?>(
                                title: Text('現地チェックインができるイベントのみ'),
                                value: EventNotificationType.onlyHasCheckedIn,
                                controlAffinity:
                                ListTileControlAffinity.trailing,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('マイイベントに未登録のイベントを通知する'),
                    value: appSettings.value?.isAllEventNotificationEnabled ??
                        false,
                    onChanged: (bool value) {
                      appSettings.value = appSettings.value?.copyWith(
                        isAllEventNotificationEnabled: value,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '対象シリーズを選択',
                    style: context.textTheme.titleMedium,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: appSettings.value?.isAllEventNotificationEnabled ??
                            false
                        ? 1.0
                        : 0.4,
                    child: IgnorePointer(
                      ignoring:
                          appSettings.value?.isAllEventNotificationEnabled ==
                              false,
                      child: Card(
                        color: context.colorScheme.surfaceContainerHighest,
                        child: Column(
                          children: generateGroupNotificationTiles(),
                        ),
                      )
                    ),
                  ),
                  for (final PendingNotificationRequest request
                      in notificationEvents.value)
                    ListTile(
                      title: Text('通知ID: ${request.id}'),
                      subtitle: Text(
                          'タイトル: ${request.title}\n本文: ${request.body}\nペイロード: ${request.payload}'),
                    ),
                  MyPageItem(
                    title: '通知予定一覧',
                    onClickItem: () async {
                      final result = await currentNotifications;
                      notificationEvents.value = result;
                      // openAppSettings();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> requestNotificationPermission() async {
    final PermissionStatus status = await Permission.notification.request();
    if (!status.isGranted) {
      debugPrint('通知権限が拒否されています');
    }
    return status.isGranted;
  }
}
