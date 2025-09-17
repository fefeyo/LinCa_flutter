import 'package:freezed_annotation/freezed_annotation.dart';

import '../network/model/group.dart';
import '../utils/sort_items_extension.dart';

part 'filter_settings.freezed.dart';

@freezed
abstract class FilterSettings with _$FilterSettings {
  const factory FilterSettings({
    @Default('') String keyword,
    @Default(DisplayOrder.newest) DisplayOrder displayOrder,
    @Default(<Participation>[]) List<Participation> participationFilters,
    @Default(<Group>[]) List<Group> groups,
  }) = _FilterSettings;
}
