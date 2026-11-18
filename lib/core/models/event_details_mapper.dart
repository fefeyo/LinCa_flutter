import 'package:collection/collection.dart';

import '../network/model/event_base.dart';
import '../network/model/group.dart';
import '../network/model/tag.dart';
import '../network/model/venue.dart';
import 'linca_event.dart';

/// Joins already-loaded reference data without issuing any repository reads.
class EventDetailsMapper {
  EventDetailsMapper({
    required List<Tag> tags,
    required List<Venue> venues,
    required List<Group> groups,
  })  : _tags = <String, Tag>{for (final Tag tag in tags) tag.id: tag},
        _venues = <String, Venue>{
          for (final Venue venue in venues) venue.id: venue,
        },
        _groups = <String, Group>{
          for (final Group group in groups) group.slug: group,
        };

  final Map<String, Tag> _tags;
  final Map<String, Venue> _venues;
  final Map<String, Group> _groups;

  LincaEvent official(OfficialEvent event, {bool sortTags = false}) {
    final List<Tag> tags =
        event.tagIds.map((String id) => _tags[id]).whereType<Tag>().toList();
    return LincaEvent(
      event: event,
      tags: sortTags
          ? tags.sorted((Tag a, Tag b) => a.order.compareTo(b.order))
          : tags,
      venue: _venues[event.venueId] ?? const Venue(),
      group: _groups[event.organizer] ?? const Group(),
    );
  }

  /// User events preserve tag-ID order and use the first matching reference.
  static LincaEvent unofficial(UnOfficialEvent event, List<Tag> tags) =>
      LincaEvent(
        event: event,
        tags: event.tagIds
            .map(
                (String id) => tags.firstWhereOrNull((Tag tag) => tag.id == id))
            .whereType<Tag>()
            .toList(),
      );
}
