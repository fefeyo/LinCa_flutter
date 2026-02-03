import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/notification/linca_notification_controller.dart';
import 'package:linca_otaku_support/core/utils/notification/providers.dart';
import 'package:linca_otaku_support/core/utils/participation_extension.dart';
import 'package:linca_otaku_support/core/utils/preferences_service.dart';

import '../../core/utils/providers.dart';
import '../my_page/view/my_page_item.dart';

@RoutePage()
class AppSettingsPage extends HookConsumerWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PreferencesService preferencesService =
        ref.read(preferencesServiceProvider);
    final ValueNotifier<bool> isNotificationEnabled = useState(false);
    final LincaNotificationController notificationController =
        ref.refresh(eventNotificationControllerProvider);
    final List<ParticipationInfo> participations =
        ref.watch(participationControllerProvider).value ??
            <ParticipationInfo>[];
    final List<LincaEvent> officialEvents =
        ref.watch(eventControllerProvider).value ?? <LincaEvent>[];
    final List<LincaEvent> unofficialEvents =
        ref.watch(userEventControllerProvider).value ?? <LincaEvent>[];
    final List<LincaEvent> participatedEvents = <LincaEvent>[
      ...officialEvents,
      ...unofficialEvents
    ]
        .where((LincaEvent event) => participations.hasEventId(event.event.id))
        .toList();

    useEffect(() {
      Future<void>.microtask(() async {
        isNotificationEnabled.value =
            await preferencesService.isEventNotificationEnabled();
      });

      return null;
    }, <Object?>[]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '設定',
          style: context.textTheme.titleMedium,
        ),
      ),
      body: Column(
        children: <Widget>[
          SwitchListTile(
            title: const Text('イベント当日に通知する'),
            subtitle: const Text('参加したイベントの当日に通知します'),
            value: isNotificationEnabled.value,
            onChanged: (bool value) {
              isNotificationEnabled.value = value;
              preferencesService.switchEventNotificationEnabled(value);
              if (value) {
                for (final LincaEvent participatedEvent in participatedEvents) {
                  final DateTime? eventDate = participatedEvent.event.date;
                  if (eventDate != null) {
                    notificationController.scheduleEventDayNotification(
                      eventId: participatedEvent.event.id,
                      title: 'イベント当日です',
                      body: '今日は${participatedEvent.event.title}の開催日です',
                      eventDate: eventDate,
                    );
                  }
                }
              } else {
                for (final ParticipationInfo participation in participations) {
                  notificationController
                      .cancelEventNotification(participation.eventId);
                }
              }
            },
          ),
          MyPageItem(
            title: '通知テスト',
            onClickItem: () {
              notificationController.scheduleDummy();
            },
          ),
        ],
      ),
    );
  }
}
