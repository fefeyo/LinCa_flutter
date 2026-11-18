import '../../constants/app_constants.dart';
import '../../constants/participation_type.dart';
import '../../models/app_settings.dart';
import '../../models/linca_event.dart';
import '../../network/model/event_base.dart';
import '../../network/model/participation_info.dart';
import '../event_base_extension.dart';
import '../participation_extension.dart';

/// Pure selection; scheduling and persistence remain with the caller.
class EventNotificationPlan {
  EventNotificationPlan({
    required List<LincaEvent> events,
    required List<ParticipationInfo> participations,
    required AppSettings settings,
    required DateTime now,
  }) {
    final DateTime today = DateTime(now.year, now.month, now.day);
    upcomingEvents = events.where((LincaEvent event) {
      final DateTime? date = event.event.date;
      return date != null && !date.isBefore(today);
    }).toList();

    if (!settings.isNotificationEnabled) {
      targetEvents = <LincaEvent>[];
      return;
    }

    final List<LincaEvent> activeEvents = upcomingEvents
        .where((LincaEvent event) => !event.event.isCanceled)
        .toList();
    final List<LincaEvent> selected = <LincaEvent>[];
    if (settings.isMyEventNotificationEnabled) {
      selected.addAll(activeEvents.where((LincaEvent event) {
        final ParticipationInfo? participation =
            participations.getByEventId(event.event.id);
        return switch (settings.eventNotificationType) {
          EventNotificationType.allParticipation =>
            participations.hasEventId(event.event.id) &&
                participation?.participationType != ParticipationType.absent,
          EventNotificationType.onlyHasCheckedIn =>
            participation?.participationType == ParticipationType.onSite &&
                (event.event as OfficialEvent).checkInId.isNotEmpty,
        };
      }));
    }
    if (settings.isAllEventNotificationEnabled) {
      final List<LincaEvent> unregisteredEvents = activeEvents
          .where(
              (LincaEvent event) => !participations.hasEventId(event.event.id))
          .toList();
      // Keep series priority before event order, including multi-series events.
      final List<String> series = <String>[
        if (settings.isLoveLiveNotificationEnabled)
          AppConstants.seriesTagLovelive,
        if (settings.isSunshineNotificationEnabled)
          AppConstants.seriesTagSunshine,
        if (settings.isNijigasakiNotificationEnabled)
          AppConstants.seriesTagNijigasaki,
        if (settings.isSuperstarNotificationEnabled)
          AppConstants.seriesTagSuperstar,
        if (settings.isHasunosoraNotificationEnabled)
          AppConstants.seriesTagHasunosora,
        if (settings.isIkizuliveNotificationEnabled)
          AppConstants.seriesTagIkizulive,
        if (settings.isMusicalNotificationEnabled)
          AppConstants.seriesTagMusical,
        if (settings.isYohaneNotificationEnabled) AppConstants.seriesTagYohane,
        if (settings.isCollaborativeNotificationEnabled)
          AppConstants.seriesTagCollaborative,
      ];
      for (final String seriesTag in series) {
        selected.addAll(unregisteredEvents.where(
            (LincaEvent event) => event.event.tagIds.contains(seriesTag)));
      }
    }
    targetEvents = selected.toSet().toList();
  }

  /// Includes canceled events so their old notifications are also canceled.
  late final List<LincaEvent> upcomingEvents;
  late final List<LincaEvent> targetEvents;
}
