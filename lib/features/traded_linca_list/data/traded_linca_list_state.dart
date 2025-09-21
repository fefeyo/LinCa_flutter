import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/models/user_profile.dart';

part 'traded_linca_list_state.freezed.dart';

@freezed
abstract class TradedLincaListState with _$TradedLincaListState {
  const factory TradedLincaListState({
    @Default(<UserProfile>[]) List<UserProfile> friends,
  }) = _TradedLincaListState;
}
