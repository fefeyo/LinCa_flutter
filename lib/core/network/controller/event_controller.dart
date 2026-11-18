import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/controller/linca_controller.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';

import '../../models/event_details_mapper.dart';
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
    final List<OfficialEvent> events = await eventRepository.getLatest(
      getId: (OfficialEvent event) => event.id,
    );
    final EventDetailsMapper mapper = EventDetailsMapper(
      venues: ref.watch(venueControllerProvider).value ?? <Venue>[],
      tags: ref.watch(tagControllerProvider).value ?? <Tag>[],
      groups: ref.watch(groupControllerProvider).value ?? <Group>[],
    );
    final List<LincaEvent> lincaEvents = events
        .map((OfficialEvent event) => mapper.official(event, sortTags: true))
        .toList();

    return lincaEvents.sortWithDisplayOrder();
  }

  Future<void> refreshInBackground() async {
    try {
      final List<OfficialEvent> updated = await eventRepository.fetch();
      if (updated.isEmpty) return;

      final EventDetailsMapper mapper = EventDetailsMapper(
        venues: ref.read(venueControllerProvider).value ?? <Venue>[],
        tags: ref.read(tagControllerProvider).value ?? <Tag>[],
        groups: ref.read(groupControllerProvider).value ?? <Group>[],
      );
      // Refresh keeps the event's declared tag order, as before.
      final List<LincaEvent> refreshed =
          updated.map((OfficialEvent event) => mapper.official(event)).toList();

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
