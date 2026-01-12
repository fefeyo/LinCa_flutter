import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';

import '../../../core/models/filter_settings.dart';
import '../../../core/models/linca_event.dart';

part 'my_event_state.freezed.dart';

@freezed
abstract class MyEventState with _$MyEventState {
  const factory MyEventState({
    @Default(<LincaEvent>[]) List<LincaEvent> allEvents,
    @Default(<LincaEvent>[]) List<LincaEvent> sortedEvents,
    @Default(<ParticipationInfo>[]) List<ParticipationInfo> participations,
    @Default(FilterSettings()) FilterSettings filterSettings,
  }) = _MyEventState;
}
