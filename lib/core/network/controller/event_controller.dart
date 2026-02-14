import 'dart:async';

import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/controller/linca_controller.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';

import '../../models/linca_event.dart';
import '../model/event_base.dart';
import '../model/group.dart';
import '../model/tag.dart';
import '../model/venue.dart';
import '../providers.dart';
import '../repository/event_repository.dart';
import '../repository/group_repository.dart';
import '../repository/tag_repository.dart';
import '../repository/venue_repository.dart';

class EventController extends LincaController<List<LincaEvent>> {
  late EventRepository eventRepository;
  late TagRepository tagRepository;
  late VenueRepository venueRepository;
  late GroupRepository groupRepository;

  @override
  FutureOr<List<LincaEvent>> buildImpl() async {
    eventRepository = ref.read(eventRepositoryProvider);
    tagRepository = ref.read(tagRepositoryProvider);
    venueRepository = ref.read(venueRepositoryProvider);
    groupRepository = ref.read(groupRepositoryProvider);
    final List<OfficialEvent> events = await eventRepository.get();
    final Map<String, Venue> venuesMap = <String, Venue>{
      for (final Venue venue
          in ref.watch(venueControllerProvider).value ?? <Venue>[])
        venue.id: venue
    };
    final Map<String, Tag> tagsMap = <String, Tag>{
      for (final Tag tag in ref.watch(tagControllerProvider).value ?? <Tag>[])
        tag.id: tag
    };
    final Map<String, Group> groupsMap = <String, Group>{
      for (final Group group
          in ref.watch(groupControllerProvider).value ?? <Group>[])
        group.slug: group
    };

    if (events.isNotEmpty) {
      await refreshInBackground();
    } else {
      events.addAll(await eventRepository.fetch());
    }

    final List<LincaEvent> lincaEvents =
        await Future.wait(events.map((OfficialEvent event) async {
      return LincaEvent(
        event: event,
        tags: event.tagIds
            .map((String id) => tagsMap[id])
            .whereType<Tag>()
            .sorted((Tag a, Tag b) => a.order.compareTo(b.order))
            .toList(),
        venue: venuesMap[event.venueId] ?? const Venue(),
        group: groupsMap[event.organizer] ?? const Group(),
      );
    }).toList());

    return lincaEvents.sortWithDisplayOrder();
  }

  Future<void> refreshInBackground() async {
    try {
      final List<OfficialEvent> updated = await eventRepository.fetch();
      if (updated.isEmpty) return;

      final Map<String, Venue> venuesMap = <String, Venue>{
        for (final Venue venue
            in ref.read(venueControllerProvider).value ?? <Venue>[])
          venue.id: venue,
      };
      final Map<String, Tag> tagsMap = <String, Tag>{
        for (final Tag tag in ref.read(tagControllerProvider).value ?? <Tag>[])
          tag.id: tag,
      };
      final Map<String, Group> groupsMap = <String, Group>{
        for (final Group group
            in ref.read(groupControllerProvider).value ?? <Group>[])
          group.slug: group,
      };

      final List<LincaEvent> refreshed =
          await Future.wait(updated.map((OfficialEvent event) async {
        return LincaEvent(
          event: event,
          tags: event.tagIds
              .map((String id) => tagsMap[id])
              .whereType<Tag>()
              .toList(),
          venue: venuesMap[event.venueId] ?? const Venue(),
          group: groupsMap[event.organizer] ?? const Group(),
        );
      }));

      final Map<String, LincaEvent> merged = <String, LincaEvent>{
        for (final LincaEvent event in state.value ?? <LincaEvent>[])
          event.event.id: event,
        for (final LincaEvent event in refreshed) event.event.id: event,
      };

      state = AsyncValue<List<LincaEvent>>.data(
        merged.values.toList().sortWithDisplayOrder(),
      );
    } catch (error, stackTrace) {
      state = AsyncValue<List<LincaEvent>>.error(error, stackTrace);
    }
  }
}
