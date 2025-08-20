import 'package:freezed_annotation/freezed_annotation.dart';

part 'created_event_list_state.freezed.dart';
part 'created_event_list_state.g.dart';

@freezed
abstract class CreatedEventListState with _$CreatedEventListState {
  const factory CreatedEventListState({
    @Default('') String name,
  }) = _CreatedEventListState;

  factory CreatedEventListState.fromJson(Map<String, dynamic> json) =>
      _$CreatedEventListStateFromJson(json);
}
