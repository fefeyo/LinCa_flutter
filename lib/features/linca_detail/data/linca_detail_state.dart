import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';

part 'linca_detail_state.freezed.dart';

@freezed
abstract class LincaDetailState with _$LincaDetailState {
  const factory LincaDetailState({
    @Default(<LincaEvent>[]) List<LincaEvent> participationEvents,
    @Default(<LincaEvent>[]) List<LincaEvent> upcomingEvents,
  }) = _LincaDetailState;
}
