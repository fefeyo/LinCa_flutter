import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/network/repository/participation_repository.dart';

import '../../auth/providers.dart';
import '../../models/linca_event.dart';
import '../../utils/sort_items_extension.dart';
import '../model/event_base.dart';
import '../model/tag.dart';
import '../providers.dart';
import '../repository/tag_repository.dart';
import '../repository/user_event_repository.dart';
import '../../../core/utils/linca_event_extension.dart';

class UserEventController extends AsyncNotifier<List<LincaEvent>> {
  late UserEventRepository userEventRepository;
  late ParticipationRepository participationRepository;
  late TagRepository tagRepository;
  late String? uid;
  late LincaUser? user;

  @override
  FutureOr<List<LincaEvent>> build() async {
    userEventRepository = ref.read(userEventRepositoryProvider);
    participationRepository = ref.read(participationRepositoryProvider);
    tagRepository = ref.read(tagRepositoryProvider);
    uid = ref.watch(uidProvider);
    user = ref.read(userControllerProvider).value;
    if (uid == null) return <LincaEvent>[];

    final List<UnOfficialEvent> events =
        await userEventRepository.fetchEvents(uid!);
    final List<LincaEvent> lincaEvents =
        await Future.wait(events.map((UnOfficialEvent event) async {
      // タグ一覧を取得
      final List<Tag> tags = await Future.wait(
        event.tagIds.map((String tagId) => tagRepository.getTagById(tagId)),
      );

      return LincaEvent(
        event: event,
        tags: tags,
      );
    }).toList());

    return lincaEvents.sortWithDisplayOrder(DisplayOrder.newest);
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
      final List<Tag> tags = await Future.wait(
        event.tagIds.map((String tagId) => tagRepository.getTagById(tagId)),
      );
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
