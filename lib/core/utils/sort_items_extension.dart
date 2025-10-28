import 'package:flutter/material.dart';

import '../../core/utils/context_extension.dart';
import '../constants/participation_type.dart';

enum DisplayOrder {
  newest, // 最新順
  oldest, // 古い順
}

enum SeriesTag {
  muse, // μ's
  aqours, // Aqours
  nijigasaki, // 虹ヶ咲学園スクールアイドル同好会
  liella, // Liella!
  hasunosora, // 蓮ノ空学院スクールアイドルクラブ
  ikizulive, // イキヅライブ！
  collaborative, // 合同イベント
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

extension SeriesTagExtension on SeriesTag {
  String label(BuildContext context) => switch (this) {
        SeriesTag.muse => context.l10n.seriesTag_muse,
        SeriesTag.aqours => context.l10n.seriesTag_aqours,
        SeriesTag.nijigasaki => context.l10n.seriesTag_nijigasaki,
        SeriesTag.liella => context.l10n.seriesTag_liella,
        SeriesTag.hasunosora => context.l10n.seriesTag_hasunosora,
        SeriesTag.ikizulive => context.l10n.seriesTag_ikizulive,
        SeriesTag.collaborative => context.l10n.seriesTag_collaborative,
      };
}
