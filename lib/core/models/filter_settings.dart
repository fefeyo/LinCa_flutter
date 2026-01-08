import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/network/model/tag.dart';

import '../constants/participation_type.dart';
import '../utils/sort_items_extension.dart';

part 'filter_settings.freezed.dart';

@freezed
abstract class FilterSettings with _$FilterSettings {
  const factory FilterSettings({
    @Default('') String keyword,
    @Default(DisplayOrder.newest) DisplayOrder displayOrder,
    @Default(<ParticipationType>[])
    List<ParticipationType> participationFilters,
    @Default(<Tag>[]) List<Tag> typeTags,
    @Default(<Tag>[]) List<Tag> seriesTags,
    @Default(false) bool isHiddenParticipationEvent,
    @Default(false) bool isHiddenOriginalEvent,
    @Default(false) bool isShowOfficialEvent,
    @Default(false) bool isShowOriginalEvent,
    DateTime? startDate,
    DateTime? endDate,
  }) = _FilterSettings;
}
