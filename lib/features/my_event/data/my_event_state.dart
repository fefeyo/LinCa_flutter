import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_event_state.freezed.dart';
part 'my_event_state.g.dart';

@freezed
abstract class MyEventState with _$MyEventState {
  const factory MyEventState({
    @Default('') String name,
  }) = _MyEventState;

  factory MyEventState.fromJson(Map<String, dynamic> json) =>
      _$MyEventStateFromJson(json);
}
