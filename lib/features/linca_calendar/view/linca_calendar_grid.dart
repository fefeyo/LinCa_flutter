import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';
import 'package:linca_otaku_support/features/linca_calendar/view/linca_calendar_day_cell.dart';
import 'package:linca_otaku_support/features/linca_calendar/view_model/linca_calendar_view_model.dart';

class LincaCalendarGrid extends HookConsumerWidget {
  const LincaCalendarGrid({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.onSelect,
  });

  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<DateTime?> days = _buildDays();
    final LincaCalendarViewModel viewModel =
        ref.read(lincaCalendarViewModelProvider.notifier);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: days.length,
      itemBuilder: (BuildContext context, int index) {
        final DateTime? date = days[index];
        if (date == null) {
          return const SizedBox.shrink();
        }

        final DateTime now = DateTime.now();
        final bool isToday = date.isSameDate(now);
        final bool isHoliday = viewModel.isHoliday(date);
        final bool hasEvent = viewModel.hasEvent(date);
        final bool hasAnniversary = viewModel.hasAnniversary(date);
        final bool isSelected =
            selectedDate != null && date.isSameDate(selectedDate!);

        return LincaCalendarDayCell(
          date: date,
          isToday: isToday,
          isHoliday: isHoliday,
          hasEvent: hasEvent,
          hasAnniversary: hasAnniversary,
          isSelected: isSelected,
          onTap: () => onSelect(date),
        );
      },
    );
  }

  List<DateTime?> _buildDays() {
    final DateTime firstDay =
        DateTime(focusedMonth.year, focusedMonth.month, 1);
    final int offset = firstDay.weekday % 7;
    final int daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;

    final List<DateTime?> result = <DateTime?>[];

    for (int i = 0; i < offset; i++) {
      result.add(null);
    }
    for (int day = 1; day <= daysInMonth; day++) {
      result.add(DateTime(focusedMonth.year, focusedMonth.month, day));
    }
    return result;
  }
}
