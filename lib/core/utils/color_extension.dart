import 'package:fefeyo_flutter_template/core/utils/sort_items_extension.dart';
import 'package:flutter/material.dart';

extension SeriesTagExtension on SeriesTag {
  Color color() => switch (this) {
        SeriesTag.muse => const Color(0xFFE4007F),
        SeriesTag.aqours => const Color(0xFF00BFFF),
        SeriesTag.nijigasaki => const Color(0xFFFCC800),
        SeriesTag.liella => const Color(0xFF9932CC),
        SeriesTag.hasunosora => const Color(0xFFFFC0CB),
        SeriesTag.ikizulive => const Color(0xFF87CEEB),
        SeriesTag.collaborative => const Color(0xFFFF5E5B),
      };
}
