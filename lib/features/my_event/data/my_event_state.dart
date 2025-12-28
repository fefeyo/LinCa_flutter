import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';

import '../../../core/models/filter_settings.dart';
import '../../../core/models/linca_event.dart';

part 'my_event_state.freezed.dart';

@freezed
abstract class MyEventState with _$MyEventState {
  const factory MyEventState({
    @Default(<LincaEvent, ParticipationInfo>{})
    Map<LincaEvent, ParticipationInfo> initialEvents,
    @Default(<LincaEvent, ParticipationInfo>{})
    Map<LincaEvent, ParticipationInfo> sortedEvents,
    @Default(FilterSettings()) FilterSettings filterSettings,
  }) = _MyEventState;
}
