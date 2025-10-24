import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/utils/event_base_extension.dart';
import 'package:linca_otaku_support/core/utils/sort_items_extension.dart';

extension LincaEventExtension on LincaEvent {
  String get venueName => event is OfficialEvent
      ? venue.name
      : (event as UnOfficialEvent).venueName;

  String get organizerName =>
      event is OfficialEvent ? (event as OfficialEvent).organizer : '';
}

extension LincaEventsExtension on List<LincaEvent> {
  // キーワードフィルタリング
  List<LincaEvent> filterWithKeyword(String keyword) {
    List<LincaEvent> sortedEvents = this;
    final List<String> keywords = keyword.split(' ');
    sortedEvents = where((LincaEvent event) {
      return keywords.any((String keyword) =>
              event.event.title.contains(keyword) ||
              event.event.kanaIfOfficial.contains(keyword)) ||
          event.event.id == keyword;
    }).toList();

    return sortedEvents;
  }

  // 表示順ソート
  List<LincaEvent> sortWithDisplayOrder(DisplayOrder displayOrder) {
    final List<LincaEvent> sortedEvents = this;
    switch (displayOrder) {
      case DisplayOrder.newest:
        sortedEvents.sort((LincaEvent a, LincaEvent b) {
          final DateTime? dateA = a.event.date;
          final DateTime? dateB = b.event.date;

          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1; // null は後ろ
          if (dateB == null) return -1;
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
          return dateA.compareTo(dateB); // 古い順
        });
        break;
      case DisplayOrder.title:
        sortedEvents.sort((LincaEvent a, LincaEvent b) =>
            a.event.title.compareTo(b.event.title));
        break;
    }

    return sortedEvents;
  }

  // グループフィルタリング
  List<LincaEvent> filterWithGroup(List<Group> groups) {
    List<LincaEvent> sortedEvents = this;
    if (groups.isNotEmpty) {
      sortedEvents = where((LincaEvent event) {
        return groups.contains(event.group);
      }).toList();
    }

    return sortedEvents;
  }
}

extension LincaParticipationEventExtension
    on Map<LincaEvent, ParticipationInfo> {
  Map<LincaEvent, ParticipationInfo> sort() {
    List<LincaEvent> events = keys.toList();
    events = events.sortWithDisplayOrder(DisplayOrder.newest);

    return <LincaEvent, ParticipationInfo>{
      for (final LincaEvent event in events) event: this[event]!,
    };
  }
}
