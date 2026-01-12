import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/filter_settings.dart';
import '../../../core/models/linca_event.dart';
import '../../../core/network/model/participation_info.dart';

part 'output_participate_events_state.freezed.dart';

@freezed
abstract class OutputParticipateEventsState
    with _$OutputParticipateEventsState {
  const factory OutputParticipateEventsState({
    @Default(<LincaEvent>[]) List<LincaEvent> allEvents,
    @Default(<LincaEvent>[]) List<LincaEvent> sortedEvents,
    @Default(<ParticipationInfo>[]) List<ParticipationInfo> participations,
    @Default(FilterSettings()) FilterSettings filterSettings,
  }) = _OutputParticipateEventsState;
}
