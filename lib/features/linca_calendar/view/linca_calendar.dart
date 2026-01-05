import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/local/controller/calendar_event_controller.dart';
import 'package:linca_otaku_support/core/local/models/calendar_event.dart';
import 'package:linca_otaku_support/features/linca_calendar/data/linca_calendar_state.dart';
import 'package:linca_otaku_support/features/linca_calendar/view/linca_calendar_grid.dart';
import 'package:linca_otaku_support/features/linca_calendar/view/linca_calendar_header.dart';
import 'package:linca_otaku_support/features/linca_calendar/view/linca_calendar_weekly_row.dart';
import 'package:linca_otaku_support/features/linca_calendar/view_model/linca_calendar_view_model.dart';

import 'selected_event_day_section.dart';

class LincaCalendar extends HookConsumerWidget {
  const LincaCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LincaCalendarState state = ref.watch(lincaCalendarViewModelProvider);
    final LincaCalendarViewModel viewModel =
        ref.read(lincaCalendarViewModelProvider.notifier);
    final AsyncValue<List<CalendarEvent>> calendarEventsAsync =
        ref.watch(calendarEventsProvider);

    useEffect(() {
      Future<void>.microtask(() async {
        calendarEventsAsync.whenData((List<CalendarEvent> events) {
          viewModel.updateCalendarEvents(events);
        });
      });

      return null;
    }, <Object?>[calendarEventsAsync]);

    return Column(
      children: <Widget>[
        LincaCalendarHeader(
          focusedMonth: state.focusedMonth,
          onPrev: viewModel.canGoPrevMonth ? () {
            viewModel.updateFocusedMonth(
              DateTime(
                state.focusedMonth.year,
                state.focusedMonth.month - 1,
              ),
            );
          } : null,
          onNext: viewModel.canGoNextMonth ? () {
            viewModel.updateFocusedMonth(
              DateTime(
                state.focusedMonth.year,
                state.focusedMonth.month + 1,
              ),
            );
          } : null,
        ),
        const SizedBox(height: 8),
        const LincaCalendarWeeklyRow(),
        const SizedBox(height: 8),
        LincaCalendarGrid(
          focusedMonth: state.focusedMonth,
          selectedDate: state.selectedDate,
          onSelect: (DateTime date) {
            viewModel.updateSelectedDate(date);
          },
        ),
        Expanded(
          child: SelectedDayEventSection(
            key: ValueKey<DateTime?>(state.selectedDate),
            selectedDate: state.selectedDate,
            events: state.selectedDateEventMap,
            calendarEvents: state.selectedDateCalendarEvents,
          ),
        ),
      ],
    );
  }
}
