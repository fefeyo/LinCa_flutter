import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/local/models/calendar_event.dart';
import 'package:linca_otaku_support/core/local/models/calendar_event_type.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/utils/calendar_event_type_extension.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';
import '../../../core/network/model/participation_info.dart';
import '../../../core/network/providers.dart';
import '../data/linca_calendar_state.dart';

final StateNotifierProvider<LincaCalendarViewModel, LincaCalendarState>
    lincaCalendarViewModelProvider =
    StateNotifierProvider<LincaCalendarViewModel, LincaCalendarState>(
  (Ref ref) {
    final List<LincaEvent> events =
        ref.read(eventControllerProvider).value ?? <LincaEvent>[];
    final List<ParticipationInfo> participations =
        ref.read(participationControllerProvider).value ??
            <ParticipationInfo>[];

    final LincaCalendarViewModel viewModel = LincaCalendarViewModel(
      events: <LincaEvent>[
        ...events,
      ],
      participations: participations,
    );

    ref.listen(eventControllerProvider, (_, AsyncValue<List<LincaEvent>> next) {
      final List<LincaEvent> events = next.value ?? <LincaEvent>[];
      viewModel.updateEvents(events);
    });

    ref.listen(
      participationControllerProvider,
      (_, AsyncValue<List<ParticipationInfo>> next) {
        final List<ParticipationInfo> newParticipations =
            next.value ?? <ParticipationInfo>[];
        viewModel.updateParticipations(newParticipations);
      },
    );

    return viewModel;
  },
);

class LincaCalendarViewModel extends StateNotifier<LincaCalendarState> {
  LincaCalendarViewModel({
    required List<LincaEvent> events,
    required List<ParticipationInfo> participations,
  }) : super(
          LincaCalendarState(
            selectedDate: DateTime.now(),
            focusedMonth: DateTime.now(),
            events: events,
            participations: participations,
          ),
        );

  final int calendarMinYear = 2012;
  final int calendarMaxYear = 2028;

  DateTime get calendarMinMonth => DateTime(calendarMinYear, 1);

  DateTime get calendarMaxMonth => DateTime(calendarMaxYear, 12);

  bool get canGoPrevMonth => state.focusedMonth.isAfter(calendarMinMonth);

  bool get canGoNextMonth => state.focusedMonth.isBefore(calendarMaxMonth);

  void updateFocusedMonth(DateTime newMonth) {
    if (newMonth.isBefore(calendarMinMonth)) {
      state = state.copyWith(focusedMonth: calendarMinMonth);
      return;
    }

    if (newMonth.isAfter(calendarMaxMonth)) {
      state = state.copyWith(focusedMonth: calendarMaxMonth);
      return;
    }

    state = state.copyWith(focusedMonth: newMonth);
  }

  void updateSelectedDate(DateTime dateTime) {
    state = state.copyWith(
      selectedDate: dateTime,
    );
  }

  bool hasEvent(DateTime dateTime) {
    return state.events.any((LincaEvent lincaEvent) =>
        lincaEvent.event.date?.isSameDate(dateTime) == true);
  }

  bool hasAnniversary(DateTime dateTime) {
    return state.calendarEvents.any((CalendarEvent calendarEvent) {
      if (calendarEvent.type.isHoliday) {
        return false;
      }

      return calendarEvent.date.isSameMonthDay(dateTime);
    });
  }

  bool isHoliday(DateTime dateTime) {
    return state.calendarEvents.any((CalendarEvent calendarEvent) {
      if (!calendarEvent.type.isHoliday) {
        return false;
      }

      if (calendarEvent.date.isSameDate(dateTime)) {
        return true;
      }

      return calendarEvent.date.isSameMonthDay(dateTime) &&
          calendarEvent.type != CalendarEventType.variableHoliday;
    });
  }

  void updateParticipations(List<ParticipationInfo> participations) {
    state = state.copyWith(participations: participations);
  }

  void updateCalendarEvents(List<CalendarEvent> calendarEvents) {
    state = state.copyWith(calendarEvents: calendarEvents);
  }

  void updateEvents(List<LincaEvent> events) {
    state = state.copyWith(events: events);
  }

  void resetCalendar() {
    final DateTime now = DateTime.now();
    updateSelectedDate(now);
    updateFocusedMonth(now);
  }
}
