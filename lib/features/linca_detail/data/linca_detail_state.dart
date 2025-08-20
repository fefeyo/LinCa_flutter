import 'package:freezed_annotation/freezed_annotation.dart';

part 'linca_detail_state.freezed.dart';
part 'linca_detail_state.g.dart';

@freezed
abstract class LincaDetailState with _$LincaDetailState {
  const factory LincaDetailState({
    @Default('') String name,
  }) = _LincaDetailState;

  factory LincaDetailState.fromJson(Map<String, dynamic> json) =>
      _$LincaDetailStateFromJson(json);
}
