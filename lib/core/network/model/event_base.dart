import 'package:freezed_annotation/freezed_annotation.dart';

import '../../utils/date_extension.dart';

part 'event_base.freezed.dart';

part 'event_base.g.dart';

@freezed
sealed class EventBase with _$EventBase {
  @FreezedUnionValue('official')
  const factory EventBase.official({
    @JsonKey(includeToJson: false) @Default('') String id,
    @Default('') String title,
    @Default('') String kana,
    @Default('') String organizer,
    @Default('') String venueId,
    @JsonKey(fromJson: fromJsonDate, toJson: toJsonDate) DateTime? date,
    @Default('') String status,
    @Default('') String url,
    @Default('') String imageUrl,
    @Default(<String>[]) List<String> tagIds,
    @Default(true) bool visibility,
    @JsonKey(fromJson: fromJsonDate, toJson: toJsonDate) DateTime? updatedAt,
  }) = OfficialEvent;

  @FreezedUnionValue('unofficial')
  const factory EventBase.unofficial({
    @JsonKey(includeToJson: false) @Default('') String id,
    @Default('') String title,
    @Default('') String desrcription,
    @Default('') String venueName,
    @JsonKey(fromJson: fromJsonDate, toJson: toJsonDate) DateTime? date,
    @Default('') String url,
    @Default(<String>[]) List<String> tagIds,
    @Default('') String createdBy,
    @Default(false) bool visibility,
  }) = UnOfficialEvent;

  factory EventBase.fromJson(Map<String, dynamic> json) =>
      _$EventBaseFromJson(json);
}
