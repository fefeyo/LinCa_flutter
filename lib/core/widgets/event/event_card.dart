import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/utils/color_extension.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';
import 'package:linca_otaku_support/core/utils/event_analytics_manager.dart';
import 'package:linca_otaku_support/core/utils/group_extension.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import 'package:linca_otaku_support/core/widgets/common/event_status_badges.dart';

import '../../constants/analytics_event.dart';
import '../../models/linca_event.dart';
import '../../network/model/participation_info.dart';

class EventCard extends StatelessWidget with EventAnalyticsManager {
  const EventCard({
    super.key,
    required this.lincaEvent,
    required this.onClick,
    this.participationInfo,
  });

  final LincaEvent lincaEvent;
  final VoidCallback onClick;
  final ParticipationInfo? participationInfo;

  @override
  Widget build(BuildContext context) {
    final String? tagName = lincaEvent.displayTagLabel;

    return Card(
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Container(
                  width: 30,
                  decoration: BoxDecoration(
                    color: lincaEvent.group.getSeriesColor(context),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          lincaEvent.event.title,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: context.colorScheme.textGrey,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lincaEvent.event.date!.simpleDateFormat(),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.colorScheme.textGrey,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        IntrinsicHeight(
                          child: Row(
                            children: <Widget>[
                              if (tagName != null)
                                Chip(
                                  label: Text(
                                    tagName,
                                    style: context.textTheme.labelSmall,
                                  ),
                                ),
                              if (tagName == null) const SizedBox.shrink(),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: lincaEvent.group.getLogoWidget(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {
                  logEvent(
                    event: AnalyticsEvent.eventCardClick,
                    params: <String, Object>{
                      'eventId': lincaEvent.event.id,
                      'eventName': lincaEvent.event.title,
                      'eventDate': lincaEvent.event.date?.simpleDateFormat() ?? 'no date',
                      'participationInfo':
                          participationInfo ?? 'no participation',
                    },
                  );

                  onClick();
                },
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: -12,
            child: EventStatusBadges(
              lincaEvent: lincaEvent,
              participationInfo: participationInfo,
            ),
          ),
        ],
      ),
    );
  }
}
