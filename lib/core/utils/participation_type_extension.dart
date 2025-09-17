import 'package:flutter/material.dart';

import '../../core/utils/context_extension.dart';
import '../constants/participation_type.dart';

extension ParticipationTypeExtension on ParticipationType {
  String label(BuildContext context) {
    switch (this) {
      case ParticipationType.none:
        return '';
      case ParticipationType.onSite:
        return context.l10n.participation_on_site; // 現地参加
      case ParticipationType.streaming:
        return context.l10n.participation_streaming; // 配信参加
      case ParticipationType.liveViewing:
        return context.l10n.participation_live_viewing; // ライブビューイング参加
      case ParticipationType.absent:
        return context.l10n.participation_absent; // 不参加
    }
  }

  Color badgeColor(BuildContext context) {
    switch (this) {
      case ParticipationType.none:
        return Colors.transparent;
      case ParticipationType.onSite:
        return Colors.red;
      case ParticipationType.streaming:
        return Colors.blue;
      case ParticipationType.liveViewing:
        return Colors.orange;
      case ParticipationType.absent:
        return Colors.purple;
    }
  }
}
