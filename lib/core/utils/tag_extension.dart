import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:linca_otaku_support/core/utils/color_extension.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';

import '../network/model/tag.dart';

extension TagExtension on Tag {
  Color getSeriesColor(BuildContext context) {
    final Map<String, Color> seriesColorMap = <String, Color>{
      'series_lovelive': context.colorScheme.colorLovelive,
      'series_sunshine': context.colorScheme.colorSunshine,
      'series_nijigasaki': context.colorScheme.colorNijigasaki,
      'series_superstar': context.colorScheme.colorSuperstar,
      'series_hasunosora': context.colorScheme.colorHasunosora,
      'series_ikizulive': context.colorScheme.colorIkizulive,
      'series_yohane': context.colorScheme.colorYohane,
      'series_musical': context.colorScheme.colorMusical,
    };

    return seriesColorMap.entries
        .firstWhere(
          (MapEntry<String, Color> entry) => slug.startsWith(entry.key),
          orElse: () => MapEntry<String, Color>(
            'default',
            context.colorScheme.colorLovelive,
          ),
        )
        .value;
  }
}

extension TagListExtension on List<Tag> {
  List<Tag> get typeTags => where((Tag tag) => tag.slug.startsWith('type_'))
      .sorted((Tag a, Tag b) => a.order.compareTo(b.order))
      .toList();

  List<Tag> get seriesTags => where((Tag tag) => tag.slug.startsWith('series_'))
      .sorted((Tag a, Tag b) => a.order.compareTo(b.order))
      .toList();

  List<Tag> get displayTags =>
      where((Tag tag) => tag.slug != 'type_other').toList();
}
