import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/router/app_router.gr.dart';
import 'package:linca_otaku_support/core/widgets/event/event_card.dart';

class SelectedEventDaySectionEventList extends StatelessWidget {
  const SelectedEventDaySectionEventList({
    super.key,
    required this.events,
  });

  final Map<LincaEvent, ParticipationInfo?> events;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: events.length,
      itemBuilder: (BuildContext context, int index) {
        final LincaEvent event = events.keys.elementAt(index);
        final ParticipationInfo? participationInfo =
            events.values.elementAt(index);

        return EventCard(
          lincaEvent: event,
          participationInfo: participationInfo,
          onClick: () => context.router.push(
            EventDetailRoute(
              lincaEvent: event,
              participationInfo: participationInfo,
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(
          height: 12,
        );
      },
    );
  }
}
