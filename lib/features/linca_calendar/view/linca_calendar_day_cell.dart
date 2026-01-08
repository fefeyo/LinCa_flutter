import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/utils/color_extension.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';

class LincaCalendarDayCell extends StatelessWidget {
  const LincaCalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isHoliday,
    required this.isSelected,
    required this.hasEvent,
    required this.hasAnniversary,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isHoliday;
  final bool isSelected;
  final bool hasEvent;
  final bool hasAnniversary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color? background;
    Color textColor = date.isWeekEnd || isHoliday ? Colors.red : Colors.black87;
    final Color dotColor =
        hasEvent ? context.colorScheme.colorLovelive : Colors.blue;

    if (isSelected) {
      background = context.colorScheme.primary;
      textColor = Colors.white;
    } else if (isToday) {
      background = context.colorScheme.primary.withValues(alpha: 0.15);
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${date.day}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: textColor,
              ),
            ),
          ),
          if (hasEvent || hasAnniversary)
            Positioned(
              bottom: 9,
              left: 0,
              right: 0,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
