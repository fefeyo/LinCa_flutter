import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_detail_state.freezed.dart';
part 'event_detail_state.g.dart';

@freezed
abstract class EventDetailState with _$EventDetailState {
  const factory EventDetailState({
    @Default('') String name,
  }) = _EventDetailState;

  factory EventDetailState.fromJson(Map<String, dynamic> json) =>
      _$EventDetailStateFromJson(json);
}
