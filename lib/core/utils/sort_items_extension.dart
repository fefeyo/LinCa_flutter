import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:flutter/material.dart';

enum DisplayOrder {
  newest, // 最新順
  oldest, // 古い順
  title, // イベント名順
}

enum Participation {
  onSite, // 現地参加
  streaming, // 配信参加
  liveViewing, // ライブビューイング参加
  absent, // 不参加
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
        DisplayOrder.title => context.l10n.displayOrder_title,
      };
}

extension ParticipationFilterExtension on Participation {
  String label(BuildContext context) => switch (this) {
        Participation.onSite => context.l10n.participationFilter_onSite,
        Participation.streaming =>
          context.l10n.participationFilter_streaming,
        Participation.liveViewing =>
          context.l10n.participationFilter_liveViewing,
        Participation.absent => context.l10n.participationFilter_absent,
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
