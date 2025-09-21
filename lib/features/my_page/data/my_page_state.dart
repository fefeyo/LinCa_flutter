import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/models/user_profile.dart';

part 'my_page_state.freezed.dart';

@freezed
abstract class MyPageState with _$MyPageState {
  const factory MyPageState({
    @Default(UserProfile()) UserProfile userProfile,
  }) = _MyPageState;
}
