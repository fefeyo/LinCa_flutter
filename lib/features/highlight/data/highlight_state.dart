import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';

part 'highlight_state.freezed.dart';

@freezed
abstract class HighlightState with _$HighlightState {
  const factory HighlightState({
    @Default(<LincaEvent>[]) List<LincaEvent> allEvents,
    @Default(<LincaEvent>[]) List<LincaEvent> filteredMyEvents,
    @Default(<ParticipationInfo>[]) List<ParticipationInfo> participations,
    @Default('') String selectedYear,
  }) = _HighlightState;
}
