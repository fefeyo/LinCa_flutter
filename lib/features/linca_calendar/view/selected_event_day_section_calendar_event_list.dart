import 'package:flutter/cupertino.dart';
import 'package:linca_otaku_support/core/local/models/calendar_event.dart';
import 'package:linca_otaku_support/core/local/models/calendar_event_type.dart';
import 'package:linca_otaku_support/core/utils/color_extension.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';

class SelectedEventDaySectionCalendarEventList extends StatelessWidget {
  const SelectedEventDaySectionCalendarEventList({
    super.key,
    required this.calendarEvents,
  });

  final List<CalendarEvent> calendarEvents;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: calendarEvents.map((CalendarEvent calendarEvent) {
        final String text;
        switch (calendarEvent.type) {
          case CalendarEventType.holiday:
          case CalendarEventType.variableHoliday:
            text = calendarEvent.name;
          case CalendarEventType.characterBirthday:
          case CalendarEventType.castBirthday:
            text = '${calendarEvent.name} 誕生日';
        }

        return Row(
          children: <Widget>[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorFromHex(calendarEvent.color),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: context.textTheme.bodyMedium,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
