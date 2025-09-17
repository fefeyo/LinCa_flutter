import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/filter_settings.dart';
import '../../../core/models/linca_event.dart';

part 'choose_event_state.freezed.dart';

@freezed
abstract class ChooseEventState with _$ChooseEventState {
  const factory ChooseEventState({
    @Default(<LincaEvent>[]) List<LincaEvent> sortedEvents,
    @Default(FilterSettings()) FilterSettings filterSettings,
  }) = _ChooseEventState;
}
