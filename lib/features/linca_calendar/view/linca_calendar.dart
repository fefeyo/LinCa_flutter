import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

    return Column(
      children: <Widget>[
        LincaCalendarHeader(
          focusedMonth: state.focusedMonth,
          onPrev: () {
            viewModel.updateFocusedMonth(
              DateTime(
                state.focusedMonth.year,
                state.focusedMonth.month - 1,
              ),
            );
          },
          onNext: () {
            viewModel.updateFocusedMonth(
              DateTime(
                state.focusedMonth.year,
                state.focusedMonth.month + 1,
              ),
            );
          },
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
          ),
        ),
      ],
    );
  }
}
