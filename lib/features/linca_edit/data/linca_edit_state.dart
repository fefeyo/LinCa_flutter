import 'package:freezed_annotation/freezed_annotation.dart';

part 'linca_edit_state.freezed.dart';
part 'linca_edit_state.g.dart';

@freezed
abstract class LincaEditState with _$LincaEditState {
  const factory LincaEditState({
    @Default('') String name,
  }) = _LincaEditState;

  factory LincaEditState.fromJson(Map<String, dynamic> json) =>
      _$LincaEditStateFromJson(json);
}
