import 'dart:async';

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
      unawaited(_refreshInBackground());
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
            .toList(),
        venue: venuesMap[event.venueId] ?? const Venue(),
        group: groupsMap[event.organizer] ?? const Group(),
      );
    }).toList());

    return lincaEvents.sortWithDisplayOrder();
  }

  Future<void> _refreshInBackground() async {
    try {
      final List<OfficialEvent> updated = await eventRepository.fetch();

      final Map<String, Venue> venuesMap = <String, Venue>{
        for (final Venue venue
            in ref.read(venueControllerProvider).value ?? <Venue>[])
          venue.id: venue
      };
      final Map<String, Tag> tagsMap = <String, Tag>{
        for (final Tag tag in ref.read(tagControllerProvider).value ?? <Tag>[])
          tag.id: tag
      };
      final Map<String, Group> groupsMap = <String, Group>{
        for (final Group group
            in ref.read(groupControllerProvider).value ?? <Group>[])
          group.slug: group
      };

      // 🔄 差分がある場合のみ state 更新
      if (updated.isNotEmpty) {
        final List<LincaEvent> lincaEvents =
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
        }).toList());

        // 🔄 差分がある場合のみ state 更新
        if (updated.isNotEmpty) {
          final List<LincaEvent> current = state.value ?? <LincaEvent>[];

          // 1. 既存イベントを Map にする（key: event.id）
          final Map<String, LincaEvent> map = <String, LincaEvent>{
            for (final LincaEvent ev in current) ev.event.id: ev,
          };

          // 2. updated のイベントで上書き（同じ id は置き換わる）
          for (final LincaEvent ev in lincaEvents) {
            map[ev.event.id] = ev;
          }

          // 3. List に戻して state 更新
          state = AsyncValue<List<LincaEvent>>.data(map.values.toList());
        }
        final List<LincaEvent> current = state.value ?? <LincaEvent>[];
        state = AsyncValue<List<LincaEvent>>.data(
            <LincaEvent>[...current, ...lincaEvents]);
      }
    } catch (error, stacktrace) {
      state = AsyncValue<List<LincaEvent>>.error(error, stacktrace);
    }
  }
}
