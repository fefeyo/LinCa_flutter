import 'package:freezed_annotation/freezed_annotation.dart';

part 'choose_event_state.freezed.dart';
part 'choose_event_state.g.dart';

@freezed
abstract class ChooseEventState with _$ChooseEventState {
  const factory ChooseEventState({
    @Default('') String name,
  }) = _ChooseEventState;

  factory ChooseEventState.fromJson(Map<String, dynamic> json) =>
      _$ChooseEventStateFromJson(json);
}
