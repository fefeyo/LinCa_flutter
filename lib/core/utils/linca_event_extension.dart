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
  // キーワードフィルタリング
  List<LincaEvent> filterWithKeyword(String keyword) {
    List<LincaEvent> sortedEvents = this;
    final List<String> keywords = keyword.split(' ');
    sortedEvents = where((LincaEvent event) {
      return keywords.any((String keyword) =>
              event.event.title.contains(keyword) ||
              event.event.displayKana.contains(keyword)) ||
          event.event.id == keyword;
    }).toList();

    return sortedEvents;
  }

  // 表示順ソート
  List<LincaEvent> sortWithDisplayOrder({
    DisplayOrder displayOrder = DisplayOrder.newest,
  }) {
    final List<LincaEvent> sortedEvents = this;
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

  List<LincaEvent> filterOnlyNotPaticipationEvent(
      Map<LincaEvent, ParticipationInfo> participations) {
    List<LincaEvent> sortedEvents = this;
    if (participations.isNotEmpty) {
      sortedEvents =
          where((LincaEvent event) => !participations.containsKey(event))
              .toList();
    }

    return sortedEvents;
  }

  List<LincaEvent> getTodayEvents() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    // final DateTime today = DateTime(2025, 10, 4); // 横長
    // final DateTime today = DateTime(2025, 11, 1); // 縦長
    return where((LincaEvent event) {
      final DateTime? date = event.event.date;
      if (date == null) return false;

      final DateTime eventDate = DateTime(date.year, date.month, date.day);
      return eventDate == today;
    }).toList().sortWithDisplayOrder(displayOrder: DisplayOrder.oldest);
  }
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

  int get eventCount => length;

  int get officialEventCount => keys
      .map((LincaEvent lincaEvent) => lincaEvent.event)
      .whereType<OfficialEvent>()
      .length;

  int get unofficialEventCount => keys
      .map((LincaEvent lincaEvent) => lincaEvent.event)
      .whereType<UnOfficialEvent>()
      .length;

  String get mostParticipatedSeries {
    final Map<String, int> seriesCount = <String, int>{};

    for (final LincaEvent event in keys) {
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

  Map<String, int> get seriesParticipationCounts {
    final Map<String, int> seriesCount = <String, int>{};

    for (final LincaEvent event in keys) {
      final String seriesTag = event.group.seriesTag;
      seriesCount[seriesTag] = (seriesCount[seriesTag] ?? 0) + 1;
    }

    return seriesCount;
  }

  List<String> get selectableYears {
    final Set<String> years = <String>{};
    final int nowYear = DateTime.now().year;

    for (final LincaEvent event in keys) {
      final DateTime? date = event.event.date;
      if (date != null && date.year <= nowYear) {
        years.add(date.year.toString());
      }
    }

    final List<String> sortedYears = years.toList()
      ..sort((String a, String b) => b.compareTo(a));

    return sortedYears;
  }
}
