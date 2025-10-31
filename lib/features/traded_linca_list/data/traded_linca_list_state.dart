import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';

part 'traded_linca_list_state.freezed.dart';

@freezed
abstract class TradedLincaListState with _$TradedLincaListState {
  const factory TradedLincaListState({
    @Default(<LincaUser>[]) List<LincaUser> friends,
  }) = _TradedLincaListState;
}
