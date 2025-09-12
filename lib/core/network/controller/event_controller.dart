import 'dart:async';

import 'package:fefeyo_flutter_template/core/models/linca_event.dart';
import 'package:fefeyo_flutter_template/core/network/model/tag.dart';
import 'package:fefeyo_flutter_template/core/network/model/venue.dart';
import 'package:fefeyo_flutter_template/core/network/repository/tag_repository.dart';
import 'package:fefeyo_flutter_template/core/network/repository/venue_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../model/event.dart';
import '../providers.dart';
import '../repository/event_repository.dart';

class EventController extends AsyncNotifier<List<LincaEvent>> {
  late EventRepository eventRepository;
  late TagRepository tagRepository;
  late VenueRepository venueRepository;

  @override
  FutureOr<List<LincaEvent>> build() async {
    eventRepository = ref.read(eventRepositoryProvider);
    tagRepository = ref.read(tagRepositoryProvider);
    venueRepository = ref.read(venueRepositoryProvider);
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    List<Event> events = await fetchEvents();
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

      return LincaEvent(
        event: event,
        tags: tags,
        venue: venue,
      );
    }).toList());
  }

  Future<List<Event>> fetchEvents() => eventRepository.fetchEvents();

  Future<List<Event>> getEvents() => eventRepository.getEvents();
}
