import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/local/models/calendar_event.dart';
import 'package:linca_otaku_support/core/local/models/calendar_event_type.dart';
import 'package:linca_otaku_support/core/utils/calendar_event_type_extension.dart';
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
    @Default(<CalendarEvent>[]) List<CalendarEvent> calendarEvents,
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

  List<CalendarEvent> get selectedDateCalendarEvents {
    if (selectedDate == null) {
      return <CalendarEvent>[];
    }

    return calendarEvents
    .where((CalendarEvent calendarEvent) => !calendarEvent.type.isHoliday)
        .where((CalendarEvent calendarEvent) {
      // ① 年月日まで完全一致
      final bool sameDate =
      calendarEvent.date.isSameDate(selectedDate!);

      // ② variableHoliday 以外で月日一致
      final bool sameMonthDayButNotVariableHoliday =
          calendarEvent.type != CalendarEventType.variableHoliday &&
              calendarEvent.date.isSameMonthDay(selectedDate!);

      return sameDate || sameMonthDayButNotVariableHoliday;
    })
        .toList();
  }
}
