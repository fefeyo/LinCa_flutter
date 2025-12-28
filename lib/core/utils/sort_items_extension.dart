import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/constants/event_type.dart';

import '../../core/utils/context_extension.dart';
import '../constants/participation_type.dart';

enum DisplayOrder {
  newest, // 最新順
  oldest, // 古い順
}

extension DisplayOrderExtension on DisplayOrder {
  String label(BuildContext context) => switch (this) {
        DisplayOrder.newest => context.l10n.displayOrder_newest,
        DisplayOrder.oldest => context.l10n.displayOrder_oldest,
      };
}

extension ParticipationFilterExtension on ParticipationType {
  String label(BuildContext context) => switch (this) {
        ParticipationType.onSite => context.l10n.participationFilter_onSite,
        ParticipationType.streaming =>
          context.l10n.participationFilter_streaming,
        ParticipationType.liveViewing =>
          context.l10n.participationFilter_liveViewing,
        ParticipationType.absent => context.l10n.participationFilter_absent,
      };
}

extension EventTypeExtension on EventType {
  String label(BuildContext context) => switch (this) {
        EventType.official => '公式イベント',
        EventType.unofficial => 'オリジナルイベント',
      };
}
