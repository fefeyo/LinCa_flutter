import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';

import '../../../core/models/linca_event.dart';
import '../../../core/network/model/participation_info.dart';

part 'linca_calendar_state.freezed.dart';

@freezed
abstract class LincaCalendarState with _$LincaCalendarState {
  const factory LincaCalendarState({
    required DateTime focusedMonth,
    DateTime? selectedDate,
    @Default(<LincaEvent>[]) List<LincaEvent> events,
    @Default(<LincaEvent, ParticipationInfo>{})
    Map<LincaEvent, ParticipationInfo> myEvents,
  }) = _LincaCalendarState;

  const LincaCalendarState._();

  /// 選択日のイベントを
  /// - 参加済み → ParticipationInfoあり
  /// - 未参加 → null
  Map<LincaEvent, ParticipationInfo?> get selectedDateEventMap {
    if (selectedDate == null) {
      return <LincaEvent, ParticipationInfo?>{};
    }

    final DateTime targetDate = selectedDate!;

    return <LincaEvent, ParticipationInfo?>{
      for (final LincaEvent event in events)
        if (event.event.date?.isSameDate(targetDate) == true)
          event: myEvents[event],
    };
  }
}
