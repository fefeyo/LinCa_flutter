import 'dart:async';

import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/network/controller/linca_controller.dart';
import 'package:linca_otaku_support/core/network/repository/participation_repository.dart';

import '../../auth/providers.dart';
import '../../models/linca_event.dart';
import '../model/event_base.dart';
import '../model/tag.dart';
import '../providers.dart';
import '../repository/tag_repository.dart';
import '../repository/user_event_repository.dart';
import '../../../core/utils/linca_event_extension.dart';

class UserEventController extends LincaController<List<LincaEvent>> {
  late UserEventRepository userEventRepository;
  late ParticipationRepository participationRepository;
  late TagRepository tagRepository;
  late String? uid;
  late LincaUser? user;

  @override
  FutureOr<List<LincaEvent>> buildImpl() async {
    uid = ref.watch(uidProvider);
    if (uid == null) return <LincaEvent>[];

    userEventRepository = ref.read(userEventRepositoryProvider);
    participationRepository = ref.read(participationRepositoryProvider);
    tagRepository = ref.read(tagRepositoryProvider);
    user = ref.read(userControllerProvider).value;
    final List<Tag> allTags = ref.watch(tagControllerProvider).value ?? <Tag>[];

    final List<UnOfficialEvent> events = await userEventRepository.get();
    if (events.isNotEmpty) {
      final List<UnOfficialEvent> unofficialEvents = state.value
              ?.map((LincaEvent event) => event.event as UnOfficialEvent)
              .toList() ??
          <UnOfficialEvent>[];
      userEventRepository.refreshInBackground(
          current: unofficialEvents,
          onChanged: (List<UnOfficialEvent> updatedEvents) async {
            final List<LincaEvent> lincaEvents =
                await Future.wait(events.map((UnOfficialEvent event) async {
              // タグ一覧を取得
              final List<Tag> tags = event.tagIds
                  .map((String tagId) =>
                      allTags.firstWhereOrNull((Tag tag) => tag.id == tagId))
                  .whereType<Tag>()
                  .toList();

              return LincaEvent(
                event: event,
                tags: tags,
              );
            }).toList());
            state = AsyncValue<List<LincaEvent>>.data(lincaEvents);
          });
    } else {
      events.addAll(await userEventRepository.fetch());
    }
    final List<LincaEvent> lincaEvents =
        await Future.wait(events.map((UnOfficialEvent event) async {
      // タグ一覧を取得
      final List<Tag> tags = event.tagIds
          .map((String tagId) =>
              allTags.firstWhereOrNull((Tag tag) => tag.id == tagId))
          .whereType<Tag>()
          .toList();

      return LincaEvent(
        event: event,
        tags: tags,
      );
    }).toList());

    return lincaEvents.sortWithDisplayOrder();
  }

  Future<void> registerEvent({
    required UnOfficialEvent event,
    required String eventId,
  }) async {
    if (uid != null && user != null) {
      final UnOfficialEvent createdEvent = event.copyWith(
        id: eventId,
        createdBy: uid!,
        availableParticipationTypes: <ParticipationType>[
          ParticipationType.onSite,
        ],
      );
      await userEventRepository.registerEvent(
        event: createdEvent,
        user: user!.user,
        documentId: eventId,
      );
      final List<LincaEvent> events = state.value ?? <LincaEvent>[];
      final List<Tag> allTags =
          ref.read(tagControllerProvider).value ?? <Tag>[];
      // タグ一覧を取得
      final List<Tag> tags = event.tagIds
          .map((String tagId) =>
              allTags.firstWhere((Tag tag) => tag.id == tagId))
          .toList();
      state = AsyncData<List<LincaEvent>>(<LincaEvent>[
        ...events,
        LincaEvent(
          event: createdEvent,
          tags: tags,
        ),
      ]);
    }
  }

  Future<void> deleteEvent({
    required LincaEvent event,
  }) async {
    await userEventRepository.deleteEvent(
        event: event.event as UnOfficialEvent);
    final List<LincaEvent> events = state.value ?? <LincaEvent>[];
    events.remove(event);
    state = AsyncData<List<LincaEvent>>(events);
  }
}
