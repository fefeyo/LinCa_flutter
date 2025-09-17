import 'package:freezed_annotation/freezed_annotation.dart';

import '../../utils/date_extension.dart';

part 'event.freezed.dart';

part 'event.g.dart';

@freezed
abstract class Event with _$Event {
  const factory Event({
    @Default('') String id,
    @Default('') String title,
    @Default('') String kana,
    @Default('') String organizer,
    @Default('') String venueId,
    @JsonKey(fromJson: fromJsonDate, toJson: toJsonDate) DateTime? date,
    @Default('') String status,
    @Default('') String url,
    @Default(<String>[]) List<String> tagIds,
    @Default('') String createdBy,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
