import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';
part 'login_state.g.dart';

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default('') String name,
  }) = _LoginState;

  factory LoginState.fromJson(Map<String, dynamic> json) =>
      _$LoginStateFromJson(json);
}
