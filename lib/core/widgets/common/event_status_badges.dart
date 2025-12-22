import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';
import 'package:linca_otaku_support/core/utils/event_base_extension.dart';
import 'package:linca_otaku_support/core/utils/participation_type_extension.dart';
import 'package:linca_otaku_support/core/widgets/event/participation_status_badge.dart';

import '../../constants/participation_type.dart';

class EventStatusBadges extends StatelessWidget {
  const EventStatusBadges({
    super.key,
    required this.lincaEvent,
    required this.participationInfo,
  });

  final LincaEvent lincaEvent;
  final ParticipationInfo? participationInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ..._generateCanceledBadgeIfNeeded(context),
        ..._generateScheduledBadgeIfNeeded(context),
        ..._generateTodayBadgeIfNeeded(context),
        ..._generateParticipationStatusBadgeIfNeeded(context),
      ],
    );
  }

  // 中止バッジを生成
  List<Widget> _generateCanceledBadgeIfNeeded(BuildContext context) {
    if (!lincaEvent.event.isCanceled) {
      return <Widget>[const SizedBox.shrink()];
    }

    return <Widget>[
      ParticipationStatusBadge(
        color: Colors.black,
        text: context.l10n.event_canceled,
      ),
      const SizedBox(width: 4),
    ];
  }

  // 参加予定バッジを生成
  // イベントが未来日かつ不参加でない場合に表示
  List<Widget> _generateScheduledBadgeIfNeeded(BuildContext context) {
    final bool isAfterToday =
        lincaEvent.event.date?.isAfter(DateTime.now()) == true;
    final bool isAbsent =
        participationInfo?.participationType == ParticipationType.absent;
    if (!isAfterToday || participationInfo == null || isAbsent) {
      return <Widget>[const SizedBox.shrink()];
    }

    return <Widget>[
      ParticipationStatusBadge(
        color: Colors.green,
        text: context.l10n.participation_planned,
      ),
      const SizedBox(width: 4),
    ];
  }

  // 当日バッジを生成
  List<Widget> _generateTodayBadgeIfNeeded(BuildContext context) {
    final bool isOnTheDay = lincaEvent.event.date?.isToday == true;
    if (!isOnTheDay) {
      return <Widget>[const SizedBox.shrink()];
    }

    return <Widget>[
      ParticipationStatusBadge(
        color: Colors.red,
        text: context.l10n.on_the_day_event,
      ),
      const SizedBox(width: 4),
    ];
  }

  // 参加状況バッジを生成
  List<Widget> _generateParticipationStatusBadgeIfNeeded(BuildContext context) {
    final ParticipationType? participationType =
        participationInfo?.participationType;
    if (lincaEvent.event.isCanceled || participationType == null) {
      return <Widget>[const SizedBox.shrink()];
    }

    return <Widget>[
      ParticipationStatusBadge(
        color: participationType.badgeColor(context),
        text: participationType.label(context),
      ),
      const SizedBox(width: 4),
    ];
  }
}
