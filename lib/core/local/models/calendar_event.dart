import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linca_otaku_support/core/local/models/calendar_event_type.dart';

import '../../utils/local_date_converter.dart';

part 'calendar_event.freezed.dart';
part 'calendar_event.g.dart';

@freezed
abstract class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent({
    required String id,
    required String name,
    required CalendarEventType type,
    required String color,
    @LocalDateConverter()
    required DateTime date,
    required int priority,
  }) = _CalendarEvent;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);
}
