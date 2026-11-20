import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/local/controller/calendar_event_controller.dart';
import '../core/network/providers.dart';

/// Preserve the dependency order: reference data, user, events, calendar.
Future<void> loadInitialData(ProviderContainer container) async {
  await Future.wait(<Future<List<Object>>>[
    container.read(badgeControllerProvider.future),
    container.read(groupControllerProvider.future),
    container.read(tagControllerProvider.future),
    container.read(venueControllerProvider.future),
  ]);
  await container.read(userControllerProvider.future);
  await Future.wait(<Future<List<Object>>>[
    container.read(eventControllerProvider.future),
    container.read(userEventControllerProvider.future),
    container.read(participationControllerProvider.future),
  ]);
  await container.read(calendarEventsProvider.future);
}
