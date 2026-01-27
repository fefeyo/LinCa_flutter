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
import 'package:linca_otaku_support/core/utils/participation_extension.dart';
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
    final List<ParticipationInfo> participations =
        ref.watch(participationControllerProvider).value ??
            <ParticipationInfo>[];
    final ParticipationController participationController =
        ref.read(participationControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.created_events_title,
          style: context.textTheme.titleMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: state.events.isNotEmpty
            ? ListView.separated(
                itemCount: state.events.length,
                itemBuilder: (BuildContext context, int index) {
                  final LincaEvent lincaEvent = state.events[index];
                  final ParticipationInfo? participation =
                      participations.getByEventId(lincaEvent.event.id);
                  return _buildEventCardWithDelete(
                    context: context,
                    event: lincaEvent,
                    participationInfo: participation,
                    onDelete: () {
                      userEventController.deleteEvent(event: lincaEvent);
                      if (participation != null) {
                        participationController
                            .deleteParticipation(participation);
                      }
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 12),
              )
            : Center(
                child: Text(
                  context.l10n.created_events_empty,
                  style: context.textTheme.titleMedium,
                ),
              ),
      ),
    );
  }

  Widget _buildEventCardWithDelete({
    required BuildContext context,
    required LincaEvent event,
    required ParticipationInfo? participationInfo,
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
                  participationInfo: participationInfo,
                ),
              );
            }),
        Positioned(
          bottom: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              logEvent(
                event: AnalyticsEvent.createdDeleteClick,
                params: <String, Object>{'lincaEvent': event},
              );

              final bool? confirmed = await CommonSimpleDialog.show(
                context: context,
                title: context.l10n.created_event_delete_event_title,
                content: context.l10n.created_event_delete_event_description,
                cancelText: context.l10n.common_cancel,
                onClickCancel: () => <dynamic, dynamic>{},
                okText: context.l10n.created_event_delete_event_confirm,
              );

              if (confirmed == true) {
                onDelete();
                if (!context.mounted) return;
                context.showSuccessSnackBar(
                    message: context.l10n.original_event_deleted);
              }
            },
          ),
        ),
      ],
    );
  }
}
