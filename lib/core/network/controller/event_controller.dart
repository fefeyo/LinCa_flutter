import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    // final SharedPreferences preferences = await SharedPreferences.getInstance();
    // final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final List<Event> events = await fetchEvents();
    // 一旦イベント一覧は毎回取得
    // if (preferences.getString(AppConstants.eventVersionKey) !=
    //         packageInfo.version ||
    //     events.isEmpty) {
    //   events = await fetchEvents();
    //   await preferences.setString(
    //       AppConstants.eventVersionKey, packageInfo.version);
    // }

    return Future.wait(events.map((Event event) async {
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
  }

  Future<List<Event>> fetchEvents() => eventRepository.fetchEvents();

  Future<List<Event>> getEvents() => eventRepository.getEvents();

}
