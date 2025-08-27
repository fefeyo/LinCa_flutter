import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  factory AuthState({
    @Default(false) bool isSignedIn,
    @Default(false) bool isGoogleLinked,
    @Default(false) bool isTwitterLinked,
  }) = _AuthState;
}
