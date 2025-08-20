import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_page_state.freezed.dart';
part 'my_page_state.g.dart';

@freezed
abstract class MyPageState with _$MyPageState {
  const factory MyPageState({
    @Default('') String name,
  }) = _MyPageState;

  factory MyPageState.fromJson(Map<String, dynamic> json) =>
      _$MyPageStateFromJson(json);
}
