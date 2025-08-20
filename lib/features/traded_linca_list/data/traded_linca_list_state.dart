import 'package:freezed_annotation/freezed_annotation.dart';

part 'traded_linca_list_state.freezed.dart';
part 'traded_linca_list_state.g.dart';

@freezed
abstract class TradedLincaListState with _$TradedLincaListState {
  const factory TradedLincaListState({
    @Default('') String name,
  }) = _TradedLincaListState;

  factory TradedLincaListState.fromJson(Map<String, dynamic> json) =>
      _$TradedLincaListStateFromJson(json);
}
