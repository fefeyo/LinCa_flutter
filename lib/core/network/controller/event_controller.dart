import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import 'package:linca_otaku_support/core/utils/sort_items_extension.dart';

import '../../models/linca_event.dart';
import '../model/event.dart';
import '../model/group.dart';
import '../model/tag.dart';
import '../model/venue.dart';
import '../providers.dart';
import '../repository/event_repository.dart';
import '../repository/group_repository.dart';
import '../repository/tag_repository.dart';
import '../repository/venue_repository.dart';

class EventController extends AsyncNotifier<List<LincaEvent>> {
  late EventRepository eventRepository;
  late TagRepository tagRepository;
  late VenueRepository venueRepository;
  late GroupRepository groupRepository;

  @override
  FutureOr<List<LincaEvent>> build() async {
    eventRepository = ref.read(eventRepositoryProvider);
    tagRepository = ref.read(tagRepositoryProvider);
    venueRepository = ref.read(venueRepositoryProvider);
    groupRepository = ref.read(groupRepositortyProvider);
    final List<Event> events = await fetchEvents();
    // 一旦イベント一覧は毎回取得
    // if (preferences.getString(AppConstants.eventVersionKey) !=
    //         packageInfo.version ||
    //     events.isEmpty) {
    //   events = await fetchEvents();
    //   await preferences.setString(
    //       AppConstants.eventVersionKey, packageInfo.version);
    // }

    final List<LincaEvent> lincaEvents = await Future.wait(events.map((Event event) async {
      // タグ一覧を取得
      final List<Tag> tags = await Future.wait(
        event.tagIds.map((String tagId) => tagRepository.getTagById(tagId)),
      );

      // 会場情報を取得
      final Venue venue = await venueRepository.getVenueById(event.venueId);

      final Group group = await groupRepository.getGroupBySlug(event.organizer);

      return LincaEvent(
        event: event,
        tags: tags,
        venue: venue,
        group: group,
      );
    }).toList());

    return lincaEvents.sortWithDisplayOrder(DisplayOrder.newest);
  }

<<<<<<< Updated upstream
  Future<List<Event>> fetchEvents() => eventRepository.fetchEvents();

  Future<List<Event>> getEvents() => eventRepository.getEvents();
=======
  Future<void> _refreshInBackground() async {
    try {
      final List<OfficialEvent> updated = await eventRepository.fetch();
      if (updated.isEmpty) return;

      final Map<String, Venue> venuesMap = {
        for (final Venue venue
            in ref.read(venueControllerProvider).value ?? <Venue>[])
          venue.id: venue,
      };
      final Map<String, Tag> tagsMap = {
        for (final Tag tag in ref.read(tagControllerProvider).value ?? <Tag>[])
          tag.id: tag,
      };
      final Map<String, Group> groupsMap = {
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
>>>>>>> Stashed changes
}
