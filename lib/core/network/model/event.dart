import 'package:fefeyo_flutter_template/core/constants/participation_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';

part 'event.g.dart';

@freezed
abstract class Event with _$Event {
  const factory Event({
    @Default(0) int id,
    @Default('') String organizer,
    @Default(ParticipationType.none) ParticipationType type,
    @Default('') String title,
    @Default(null) DateTime? startAt,
    @Default(null) DateTime? endAt,
    @Default('') String venue,
    @Default('') String url,
    @Default(<String>[]) List<String> tags,
    @Default('') String memo,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
