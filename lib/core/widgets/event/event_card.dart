import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';
import 'package:linca_otaku_support/core/utils/color_extension.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';
import 'package:linca_otaku_support/core/utils/group_extension.dart';
import 'package:linca_otaku_support/core/utils/tag_extension.dart';

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
    final String? tagName = lincaEvent.event is OfficialEvent
        ? lincaEvent.tags.priorityTypeTag?.name
        : '有志イベント';

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
                              Chip(
                                label: Text(
                                  '$tagName',
                                  style: context.textTheme.labelSmall,
                                ),
                              ),
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
