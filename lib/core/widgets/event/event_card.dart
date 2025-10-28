import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';
import 'package:linca_otaku_support/core/utils/group_extension.dart';

import '../../../core/utils/participation_type_extension.dart';
import '../../models/linca_event.dart';
import '../../network/model/participation_info.dart';
import '../../network/model/tag.dart';
import '../../router/app_router.gr.dart';
import 'participation_status_badge.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.lincaEvent,
    this.participationInfo,
  });

  final LincaEvent lincaEvent;
  final ParticipationInfo? participationInfo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  lincaEvent.event.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  lincaEvent.event.date!.simpleDateFormat(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Wrap(
                        spacing: 4,
                        children: lincaEvent.tags.map((Tag tag) {
                          return Chip(
                            label: Text(
                              tag.name,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: lincaEvent.group.getLogoWidget(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.router.push(
                  EventDetailRoute(
                    lincaEvent: lincaEvent,
                    participationInfo: participationInfo,
                  ),
                ),
              ),
            ),
          ),
          if (participationInfo != null)
            Positioned(
              right: 0,
              top: -12,
              child: Row(
                children: <Widget>[
                  ..._getScheduledBadgeIfNeeded(participationInfo!),
                  ..._getTodayBadgeIfNeeded(),
                  ParticipationStatusBadge(
                    text: participationInfo!.participationType!.label(context),
                    color: participationInfo!.participationType!
                        .badgeColor(context),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _getScheduledBadgeIfNeeded(ParticipationInfo participationInfo) {
    if (lincaEvent.event.date?.isAfter(DateTime.now()) == false ||
        participationInfo.participationType == ParticipationType.absent) {
      return <Widget>[const SizedBox.shrink()];
    }

    return <Widget>[
      const ParticipationStatusBadge(
        text: '参加予定',
        color: Colors.green,
      ),
      const SizedBox(
        width: 4,
      ),
    ];
  }

  List<Widget> _getTodayBadgeIfNeeded() {
    if (lincaEvent.event.date?.isToday == false) {
      return <Widget>[const SizedBox.shrink()];
    }

    return <Widget>[
      const ParticipationStatusBadge(
        text: 'イベント当日',
        color: Colors.red,
      ),
      const SizedBox(
        width: 4,
      ),
    ];
  }
}
