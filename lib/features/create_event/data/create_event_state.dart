import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_event_state.freezed.dart';
part 'create_event_state.g.dart';

@freezed
abstract class CreateEventState with _$CreateEventState {
  const factory CreateEventState({
    @Default('') String name,
  }) = _CreateEventState;

  factory CreateEventState.fromJson(Map<String, dynamic> json) =>
      _$CreateEventStateFromJson(json);
}
