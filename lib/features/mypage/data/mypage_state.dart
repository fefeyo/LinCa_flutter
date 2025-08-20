import 'package:freezed_annotation/freezed_annotation.dart';

part 'mypage_state.freezed.dart';
part 'mypage_state.g.dart';

@freezed
abstract class MypageState with _$MypageState {
  const factory MypageState({
    @Default('') String name,
  }) = _MypageState;

  factory MypageState.fromJson(Map<String, dynamic> json) =>
      _$MypageStateFromJson(json);
}
