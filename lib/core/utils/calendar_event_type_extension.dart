import 'package:linca_otaku_support/core/local/models/calendar_event_type.dart';

extension CalendarEventTypeExtension on CalendarEventType {
  bool get isHoliday =>
      this == CalendarEventType.holiday ||
      this == CalendarEventType.variableHoliday;
}
