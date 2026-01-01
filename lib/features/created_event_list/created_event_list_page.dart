import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/analytics_event.dart';
import 'package:linca_otaku_support/core/constants/analytics_screen.dart';
import 'package:linca_otaku_support/core/network/controller/participation_controller.dart';
import 'package:linca_otaku_support/core/network/controller/user_event_controller.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/event_analytics_manager.dart';
import 'package:linca_otaku_support/core/utils/screen_analytics_manager.dart';
import 'package:linca_otaku_support/core/widgets/common/common_simple_dialog.dart';

import '../../core/models/linca_event.dart';
import '../../core/network/model/event_base.dart';
import '../../core/router/app_router.gr.dart';
import '../../core/widgets/event/event_card.dart';
import '../create_event/data/create_event_type.dart';
import 'data/created_event_list_state.dart';
import 'view_model/created_event_list_view_model.dart';

@RoutePage()
class CreatedEventListPage extends HookConsumerWidget
    with ScreenAnalyticsManager, EventAnalyticsManager {
  const CreatedEventListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logScreen(AnalyticsScreen.createdEventList);

    final CreatedEventListState state =
        ref.watch(createdEventListViewModelProvider);
    final UserEventController userEventController =
        ref.read(userEventControllerProvider.notifier);
    final Map<LincaEvent, ParticipationInfo> participations =
        ref.watch(participationControllerProvider).value ??
            <LincaEvent, ParticipationInfo>{};
    final ParticipationController participationController =
        ref.read(participationControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '作成済みイベント一覧',
          style: context.textTheme.titleMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: state.events.isNotEmpty
            ? ListView.separated(
                itemCount: state.events.length,
                itemBuilder: (BuildContext context, int index) {
                  final LincaEvent event = state.events[index];
                  return _buildEventCardWithDelete(
                    context: context,
                    event: event,
                    onDelete: () {
                      userEventController.deleteEvent(event: event);
                      final ParticipationInfo? participation =
                          participations[event];
                      if (participation != null) {
                        participationController.deleteParticipation(
                            event, participation);
                      }
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 12),
              )
            : Center(
                child: Text(
                  '作成したイベントがありません',
                  style: context.textTheme.titleMedium,
                ),
              ),
      ),
    );
  }

  Widget _buildEventCardWithDelete({
    required BuildContext context,
    required LincaEvent event,
    required Function() onDelete,
  }) {
    return Stack(
      children: <Widget>[
        EventCard(
            lincaEvent: event,
            onClick: () {
              logEvent(event: AnalyticsEvent.createdCardClick);

              final UnOfficialEvent unOfficialEvent =
                  event.event as UnOfficialEvent;
              context.router.push(
                CreateEventRoute(
                  createEventType: unOfficialEvent.visibility
                      ? CreateEventType.public
                      : CreateEventType.private,
                  isEditMode: true,
                  unOfficialEvent: unOfficialEvent,
                ),
              );
            }),
        Positioned(
          bottom: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'イベントを削除',
            onPressed: () async {
              logEvent(
                event: AnalyticsEvent.createdDeleteClick,
                params: <String, Object>{'lincaEvent': event},
              );

              final bool? confirmed = await CommonSimpleDialog.show(
                context: context,
                title: '削除の確認',
                content: 'このイベントを削除しますか？',
                cancelText: context.l10n.common_cancel,
                onClickCancel: () => <dynamic, dynamic>{},
                okText: '削除する',
              );

              if (confirmed == true) {
                onDelete();
              }
            },
          ),
        ),
      ],
    );
  }
}
