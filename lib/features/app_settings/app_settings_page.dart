import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/models/app_settings.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/event_base_extension.dart';
import 'package:linca_otaku_support/core/utils/notification/linca_notification_controller.dart';
import 'package:linca_otaku_support/core/utils/notification/providers.dart';
import 'package:linca_otaku_support/core/utils/participation_extension.dart';
import 'package:linca_otaku_support/core/utils/preferences_service.dart';
import 'package:linca_otaku_support/l10n/app_localizations.dart';
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
      if (event.event.isCanceled) return false;
      final ParticipationInfo? participation =
          participations.getByEventId(event.event.id);
      final OfficialEvent officialEvent = event.event as OfficialEvent;
      return participation?.participationType == ParticipationType.onSite &&
          officialEvent.checkInId.isNotEmpty;
    }).toList();
    // 今日以降の参加予定のイベント
    final List<LincaEvent> participateEvents =
        upcomingEvents.where((LincaEvent event) {
      if (event.event.isCanceled) return false;
      final ParticipationInfo? participation =
          participations.getByEventId(event.event.id);
      return participations.hasEventId(event.event.id) &&
          participation?.participationType != ParticipationType.absent;
    }).toList();
    // 今日以降の参加予定じゃないイベント
    final List<LincaEvent> notParticipateEvents = upcomingEvents
        .where((LincaEvent event) =>
            !participations.hasEventId(event.event.id) &&
            !event.event.isCanceled)
        .toList();
    final Future<List<PendingNotificationRequest>> currentNotifications =
        notificationPlugin.pendingNotificationRequests();
    final ValueNotifier<List<PendingNotificationRequest>> notificationEvents =
        useState(<PendingNotificationRequest>[]);
    final AppLocalizations l10n = context.l10n;

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
        if (mutableAppSettings.isCollaborativeNotificationEnabled) {
          targetEvents.addAll(notParticipateEvents.where((LincaEvent event) =>
              event.event.tagIds
                  .contains(AppConstants.seriesTagCollaborative)));
        }
      }
      targetEvents = targetEvents.toSet().toList();
      for (final LincaEvent event in targetEvents) {
        if (onSiteAndHasCheckInParticipateEvents.contains(event)) {
          notificationController.scheduleEventDayNotification(
            eventId: event.event.id,
            title: l10n.push_notifications_title_check_in,
            body: event.event.title,
            eventDate: event.event.date!,
          );
        } else {
          notificationController.scheduleEventDayNotification(
            eventId: event.event.id,
            title: l10n.push_notifications_title_check_in,
            body: event.event.title,
            eventDate: event.event.date!,
          );
        }
      }

      preferencesService.updateAppSettings(mutableAppSettings);

      return null;
    }, <Object?>[appSettings.value?.toJson().toString()]);

    List<Widget> generateGroupNotificationTiles() {
      return <Widget>[
        CheckboxListTile.adaptive(
          title: Text(context.l10n.common_series_lovelive),
          value: appSettings.value?.isLoveLiveNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isLoveLiveNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: Text(context.l10n.common_series_sunshine),
          value: appSettings.value?.isSunshineNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isSunshineNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: Text(context.l10n.common_series_nijigasaki),
          value: appSettings.value?.isNijigasakiNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isNijigasakiNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: Text(context.l10n.common_series_superstar),
          value: appSettings.value?.isSuperstarNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isSuperstarNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: Text(context.l10n.common_series_hasunosora),
          value: appSettings.value?.isHasunosoraNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isHasunosoraNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: Text(context.l10n.common_series_ikizulive),
          value: appSettings.value?.isIkizuliveNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isIkizuliveNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: Text(context.l10n.common_series_musical),
          value: appSettings.value?.isMusicalNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isMusicalNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: Text(context.l10n.common_series_yohane),
          value: appSettings.value?.isYohaneNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isYohaneNotificationEnabled: value ?? false,
            );
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          title: Text(context.l10n.common_series_collaborative),
          value: appSettings.value?.isCollaborativeNotificationEnabled ?? false,
          onChanged: (bool? value) {
            appSettings.value = appSettings.value?.copyWith(
              isCollaborativeNotificationEnabled: value ?? false,
            );
          },
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.notification_title,
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
                  Center(
                    child: Text(
                      context.l10n.notification_description,
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  SwitchListTile(
                    title: Text(context.l10n.notification_my_event),
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
                          child: Column(
                            children: <Widget>[
                              RadioListTile<EventNotificationType?>(
                                title: Text(
                                    context.l10n.notification_my_event_all),
                                value: EventNotificationType.allParticipation,
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                              ),
                              const Divider(),
                              RadioListTile<EventNotificationType?>(
                                title: Text(context
                                    .l10n.notification_my_event_check_in_only),
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
                    title: Text(context.l10n.notification_not_registered_event),
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
                    context.l10n.notification_series_filter,
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
                      ),
                    ),
                  ),
                  // 通知の予定一覧表示（デバッグ用）
                  // for (final PendingNotificationRequest request
                  //     in notificationEvents.value)
                  //   ListTile(
                  //     title: Text('通知ID: ${request.id}'),
                  //     subtitle:
                  //         Text('タイトル: ${request.title}\n本文: ${request.body}'),
                  //   ),
                  // MyPageItem(
                  //   title: '通知予定一覧',
                  //   onClickItem: () async {
                  //     final List<PendingNotificationRequest> result =
                  //         await currentNotifications;
                  //     notificationEvents.value = result;
                  //   },
                  // ),
                  const SizedBox(height: 64),
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
