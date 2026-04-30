import 'package:collection/collection.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';
import 'package:linca_otaku_support/core/utils/event_base_extension.dart';
import 'package:linca_otaku_support/core/utils/sort_items_extension.dart';
import 'package:linca_otaku_support/core/utils/tag_extension.dart';

import '../network/model/tag.dart';

extension LincaEventExtension on LincaEvent {
  String get venueName => event is OfficialEvent
      ? venue.name
      : (event as UnOfficialEvent).venueName;

  String get organizer =>
      event is OfficialEvent ? (event as OfficialEvent).organizer : '';

  String get organizerName =>
      event is UnOfficialEvent ? (event as UnOfficialEvent).organizerName : '';

  String? get displayTagLabel {
    if (event is OfficialEvent) {
      final Tag? tag = tags.typeTags
          .where((Tag tag) => tag.slug != 'type_other')
          .sorted((Tag a, Tag b) => b.order.compareTo(a.order))
          .firstOrNull;
      return tag?.name;
    }

    if (event is UnOfficialEvent) {
      final UnOfficialEvent unOfficialEvent = event as UnOfficialEvent;
      return unOfficialEvent.visibility ? '公開イベント' : '非公開イベント';
    }

    return null;
  }
}

extension LincaEventsExtension on List<LincaEvent> {
  int get officialEventCount => map((LincaEvent lincaEvent) => lincaEvent.event)
      .whereType<OfficialEvent>()
      .length;

  int get unofficialEventCount =>
      map((LincaEvent lincaEvent) => lincaEvent.event)
          .whereType<UnOfficialEvent>()
          .length;

  Map<String, int> get seriesParticipationCounts {
    final Map<String, int> seriesCount = <String, int>{};

    for (final LincaEvent event in this) {
      final String seriesTag = event.group.seriesTag;
      seriesCount[seriesTag] = (seriesCount[seriesTag] ?? 0) + 1;
    }

    return seriesCount;
  }

  List<String> get selectableYears {
    final Set<String> years = <String>{};
    final int nowYear = DateTime.now().year;

    for (final LincaEvent event in this) {
      final DateTime? date = event.event.date;
      if (date != null && date.year <= nowYear) {
        years.add(date.year.toString());
      }
    }

    final List<String> sortedYears = years.toList()
      ..sort((String a, String b) => b.compareTo(a));

    return sortedYears;
  }

  String get mostParticipatedSeries {
    final Map<String, int> seriesCount = <String, int>{};

    for (final LincaEvent event in this) {
      final String seriesTag = event.group.seriesTag;
      seriesCount[seriesTag] = (seriesCount[seriesTag] ?? 0) + 1;
    }

    String mostParticipatedSeries = '';
    int maxCount = 0;

    seriesCount.forEach((String seriesTag, int count) {
      if (count > maxCount) {
        maxCount = count;
        mostParticipatedSeries = seriesTag;
      }
    });

    return mostParticipatedSeries;
  }

  // キーワードフィルタリング
  List<LincaEvent> filterWithKeyword(String keyword) {
    if (keyword.isEmpty) return this;

    final List<String> keywords = keyword
        .toLowerCase()
        .split(' ')
        .where((String word) => word.isNotEmpty)
        .toList();

    return where((LincaEvent event) {
      final String title = event.event.title.toLowerCase();
      final String kana = event.event.displayKana.toLowerCase();
      final String id = event.event.id.toLowerCase();

      return keywords
          .any((String k) => title.contains(k) || kana.contains(k) || id == k);
    }).toList();
  }

  // 表示順ソート
  List<LincaEvent> sortWithDisplayOrder({
    DisplayOrder displayOrder = DisplayOrder.newest,
  }) {
    final List<LincaEvent> sortedEvents = List<LincaEvent>.of(this);
    switch (displayOrder) {
      case DisplayOrder.newest:
        sortedEvents.sort((LincaEvent a, LincaEvent b) {
          final DateTime? dateA = a.event.date;
          final DateTime? dateB = b.event.date;

          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1; // null は後ろ
          if (dateB == null) return -1;

          if (dateA.isSameDate(dateB)) {
            return b.event.id.compareTo(a.event.id);
          }

          return dateB.compareTo(dateA); // 新しい順
        });
        break;
      case DisplayOrder.oldest:
        sortedEvents.sort((LincaEvent a, LincaEvent b) {
          final DateTime? dateA = a.event.date;
          final DateTime? dateB = b.event.date;

          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;

          if (dateA.isSameDate(dateB)) {
            return a.event.id.compareTo(b.event.id);
          }

          return dateA.compareTo(dateB); // 古い順
        });
        break;
    }

    return sortedEvents;
  }

// タグフィルタリング
  List<LincaEvent> filterWithTag(List<Tag> tags) {
    List<LincaEvent> sortedEvents = this;
    if (tags.isNotEmpty) {
      sortedEvents = where((LincaEvent event) {
        return tags.any((Tag tag) => event.tags.contains(tag));
      }).toList();
    }

    return sortedEvents;
  }

  List<LincaEvent> filterOnlyNotPaticipationEvent({
    required List<LincaEvent> allEvents,
    required List<ParticipationInfo> participations,
  }) {
    List<LincaEvent> sortedEvents = List<LincaEvent>.of(this);
    if (participations.isNotEmpty) {
      sortedEvents = where(
        (LincaEvent event) => !allEvents.any(
          (LincaEvent lincaEvent) => participations.any(
            (ParticipationInfo participationInfo) =>
                participationInfo.eventId == lincaEvent.event.id,
          ),
        ),
      ).toList();
    }

    return sortedEvents;
  }

  List<LincaEvent> filterWithPeriod({
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    List<LincaEvent> filteredEvents = this;

    if (startDate != null) {
      filteredEvents = filteredEvents.where((LincaEvent event) {
        final DateTime? date = event.event.date;
        if (date == null) return false;
        return !date.isBefore(startDate);
      }).toList();
    }

    if (endDate != null) {
      filteredEvents = filteredEvents.where((LincaEvent event) {
        final DateTime? date = event.event.date;
        if (date == null) return false;
        return !date.isAfter(endDate);
      }).toList();
    }

    return filteredEvents;
  }

  List<LincaEvent> getTodayEvents() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return where((LincaEvent event) {
      if (event.event.isCanceled) return false;
      final DateTime? date = event.event.date;
      if (date == null) return false;

      final DateTime eventDate = DateTime(date.year, date.month, date.day);
      return eventDate == today;
    })
        .toList()
        .sortWithDisplayOrder(displayOrder: DisplayOrder.oldest);
  }

  LincaEvent? getEventById(String eventId) =>
      firstWhereOrNull((LincaEvent event) => event.event.id == eventId);
}

extension LincaParticipationEventExtension
    on Map<LincaEvent, ParticipationInfo> {
  Map<LincaEvent, ParticipationInfo> sort() {
    List<LincaEvent> events = keys.toList();
    events = events.sortWithDisplayOrder();

    return <LincaEvent, ParticipationInfo>{
      for (final LincaEvent event in events) event: this[event]!,
    };
  }
}
