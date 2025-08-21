import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:flutter/material.dart';

enum DisplayOrder {
  newest, // 最新順
  oldest, // 古い順
  title, // イベント名順
}

enum ParticipationFilter {
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
        DisplayOrder.newest => context.l10n.app_name,
        DisplayOrder.oldest => context.l10n.app_name,
        DisplayOrder.title => context.l10n.app_name,
      };
}

extension ParticipationFilterExtension on ParticipationFilter {
  String label(BuildContext context) => switch (this) {
        ParticipationFilter.onSite => context.l10n.app_name,
        ParticipationFilter.streaming => context.l10n.app_name,
        ParticipationFilter.liveViewing => context.l10n.app_name,
        ParticipationFilter.absent => context.l10n.app_name,
      };
}

extension SeriesTagExtension on SeriesTag {
  String label(BuildContext context) => switch (this) {
        SeriesTag.muse => context.l10n.app_name,
        SeriesTag.aqours => context.l10n.app_name,
        SeriesTag.nijigasaki => context.l10n.app_name,
        SeriesTag.liella => context.l10n.app_name,
        SeriesTag.hasunosora => context.l10n.app_name,
        SeriesTag.ikizulive => context.l10n.app_name,
        SeriesTag.collaborative => context.l10n.app_name,
      };
}
