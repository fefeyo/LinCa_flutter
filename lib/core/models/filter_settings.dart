import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/sort_items_extension.dart';

part 'filter_settings.freezed.dart';

@freezed
abstract class FilterSettings with _$FilterSettings {
  const factory FilterSettings({
    @Default('') String keyword,
    DisplayOrder? displayOrder,
    Participation? participationFilter,
    SeriesTag? seriesTag,
  }) = _FilterSettings;
}
