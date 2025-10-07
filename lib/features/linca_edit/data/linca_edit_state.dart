import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/models/user_profile.dart';

part 'linca_edit_state.freezed.dart';

@freezed
abstract class LincaEditState with _$LincaEditState {
  const factory LincaEditState({
    UserProfile? userProfile,
  }) = _LincaEditState;
}
