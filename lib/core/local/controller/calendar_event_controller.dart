import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/local/models/calendar_event.dart';

final AsyncNotifierProvider<CalendarEventController, List<CalendarEvent>>
    calendarEventsProvider =
    AsyncNotifierProvider<CalendarEventController, List<CalendarEvent>>(
  CalendarEventController.new,
);

class CalendarEventController extends AsyncNotifier<List<CalendarEvent>> {
  @override
  FutureOr<List<CalendarEvent>> build() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/calendar_data.json');
    final List<dynamic> data = jsonDecode(jsonString);

    return data
        .map((dynamic calendarEvent) =>
            CalendarEvent.fromJson(calendarEvent as Map<String, dynamic>))
        .toList()
        .sortedBy<num>((CalendarEvent calendarEvent) => calendarEvent.priority);
  }
}
