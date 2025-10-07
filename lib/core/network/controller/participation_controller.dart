import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';

import '../../auth/providers.dart';
import '../providers.dart';
import '../repository/participation_repository.dart';

class ParticipationController
    extends AsyncNotifier<Map<LincaEvent, ParticipationInfo>> {
  late String? uid;
  late ParticipationRepository participationRepository;

  @override
  Future<Map<LincaEvent, ParticipationInfo>> build() async {
    uid = ref.watch(uidProvider);
    participationRepository = ref.read(participationRepositoryProvider);
    final List<LincaEvent> events =
        ref.watch(eventControllerProvider).value ?? <LincaEvent>[];
    final List<ParticipationInfo> participationInfos =
        await fetchParticipations();
    final Map<LincaEvent, ParticipationInfo> myEvents =
        <LincaEvent, ParticipationInfo>{};
    for (final ParticipationInfo participation in participationInfos) {
      final LincaEvent event = events.firstWhere(
        (LincaEvent event) => event.event.id == participation.eventId,
        orElse: () => const LincaEvent(),
      );
      if (event.event.id.isNotEmpty) {
        myEvents[event] = participation;
      }
    }

    return myEvents.sort();
  }

  Future<void> createParticipation(
      LincaEvent lincaEvent, ParticipationInfo participation) async {
    if (uid == null) return;
    await participationRepository.create(uid!, participation);

    // 現在のstateが読み込み済みなら更新
    final AsyncValue<Map<LincaEvent, ParticipationInfo>> currentState = state;
    if (currentState is AsyncData<Map<LincaEvent, ParticipationInfo>>) {
      final Map<LincaEvent, ParticipationInfo> updated =
          Map<LincaEvent, ParticipationInfo>.of(currentState.value);
      updated[lincaEvent] = participation;

      state = AsyncValue<Map<LincaEvent, ParticipationInfo>>.data(updated);
    } else {
      // fallback：強制再読み込み
      ref.invalidateSelf();
    }
  }

  Future<void> deleteParticipation(
      LincaEvent lincaEvent, ParticipationInfo participationInfo) async {
    if (uid == null) return;
    await participationRepository.delete(uid!, participationInfo.eventId);

    // 現在のstateが読み込み済みなら更新
    final AsyncValue<Map<LincaEvent, ParticipationInfo>> currentState = state;
    if (currentState is AsyncData<Map<LincaEvent, ParticipationInfo>>) {
      final Map<LincaEvent, ParticipationInfo> updated =
          Map<LincaEvent, ParticipationInfo>.of(currentState.value);
      updated.remove(lincaEvent);

      state = AsyncValue<Map<LincaEvent, ParticipationInfo>>.data(updated);
    } else {
      // fallback：強制再読み込み
      ref.invalidateSelf();
    }
  }

  Future<List<ParticipationInfo>> fetchParticipations() {
    if (uid == null) {
      return Future<List<ParticipationInfo>>.value(<ParticipationInfo>[]);
    }

    return participationRepository.fetchParticipations(uid!);
  }

  Future<List<ParticipationInfo>> getParticipations() {
    if (uid == null) {
      return Future<List<ParticipationInfo>>.value(<ParticipationInfo>[]);
    }

    return participationRepository.getParticipations(uid!);
  }
}
