import 'dart:async';

import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/controller/linca_controller.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';

import '../providers.dart';
import '../repository/participation_repository.dart';

class ParticipationController
    extends LincaController<Map<LincaEvent, ParticipationInfo>> {
  late ParticipationRepository participationRepository;

  @override
  Future<Map<LincaEvent, ParticipationInfo>> buildImpl() async {
    participationRepository = ref.read(participationRepositoryProvider);
    final List<LincaEvent> events =
        ref.read(eventControllerProvider).value ?? <LincaEvent>[];
    final List<LincaEvent> userEvents =
        ref.read(userEventControllerProvider).value ?? <LincaEvent>[];

    List<ParticipationInfo> participationInfos =
        await participationRepository.get();
    Map<LincaEvent, ParticipationInfo> myEvents = _generateLincaEvent(
      participationInfos: participationInfos,
      events: events,
      userEvents: userEvents,
    );

    if (participationInfos.isNotEmpty) {
      unawaited(_refreshInBackground());
    } else {
      participationInfos = await participationRepository.fetch();
      myEvents = _generateLincaEvent(
        participationInfos: participationInfos,
        events: events,
        userEvents: userEvents,
      );
    }

    return myEvents.sort();
  }

  Future<void> createParticipation({
    required LincaEvent lincaEvent,
    required ParticipationInfo participation,
    bool needsRefresh = false,
  }) async {
    await participationRepository.update(participation);

    if (needsRefresh) {
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
  }

  Future<void> deleteParticipation(
      LincaEvent lincaEvent, ParticipationInfo participationInfo) async {
    await participationRepository.delete(participationInfo.eventId);

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

  Future<void> _refreshInBackground() async {
    final Map<LincaEvent, ParticipationInfo> lincaEvents =
        state.value ?? <LincaEvent, ParticipationInfo>{};

    try {
      final List<ParticipationInfo> updated =
          await participationRepository.fetch();

      if (updated.isNotEmpty) {
        final List<LincaEvent> events =
            ref.watch(eventControllerProvider).value ?? <LincaEvent>[];
        final List<LincaEvent> userEvents =
            ref.watch(userEventControllerProvider).value ?? <LincaEvent>[];

        final Map<LincaEvent, ParticipationInfo> current =
            state.value ?? <LincaEvent, ParticipationInfo>{};

        final Map<LincaEvent, ParticipationInfo> merged =
            _mergeParticipationMap(
          current: current,
          updated: updated,
          events: events,
          userEvents: userEvents,
        );

        state = AsyncValue<Map<LincaEvent, ParticipationInfo>>.data(merged);
      }
    } catch (_) {
      state = AsyncValue<Map<LincaEvent, ParticipationInfo>>.data(lincaEvents);
    }
  }

  Map<LincaEvent, ParticipationInfo> _mergeParticipationMap({
    required Map<LincaEvent, ParticipationInfo> current,
    required List<ParticipationInfo> updated,
    required List<LincaEvent> events,
    required List<LincaEvent> userEvents,
  }) {
    // eventId → ParticipationInfo の形に変換
    final Map<String, ParticipationInfo> updatedMap =
        <String, ParticipationInfo>{
      for (final ParticipationInfo participation in updated)
        participation.eventId: participation,
    };

    final Map<LincaEvent, ParticipationInfo> newMap =
        <LincaEvent, ParticipationInfo>{};

    for (final LincaEvent event in <LincaEvent>[...events, ...userEvents]) {
      if (updatedMap.containsKey(event.event.id)) {
        newMap[event] = updatedMap[event.event.id]!;
      } else if (current.containsKey(event)) {
        newMap[event] = current[event]!;
      }
    }

    return newMap;
  }

  Map<LincaEvent, ParticipationInfo> _generateLincaEvent({
    required List<ParticipationInfo> participationInfos,
    required List<LincaEvent> events,
    required List<LincaEvent> userEvents,
  }) {
    final Map<LincaEvent, ParticipationInfo> lincaEvents =
        <LincaEvent, ParticipationInfo>{};
    for (ParticipationInfo participationInfo in participationInfos) {
      LincaEvent? event = events.firstWhereOrNull(
          (LincaEvent event) => event.event.id == participationInfo.eventId);
      event ??= userEvents.firstWhereOrNull(
          (LincaEvent event) => event.event.id == participationInfo.eventId);
      if (event != null) {
        lincaEvents[event] = participationInfo;
      }
    }

    return lincaEvents;
  }

  Future<void> updateParticipationMemory({
    required ParticipationInfo? participationInfo,
    required int index,
    required String photoUrl,
  }) async {
    if (participationInfo == null) return;

    final AsyncValue<Map<LincaEvent, ParticipationInfo>> currentState = state;
    state = const AsyncValue<Map<LincaEvent, ParticipationInfo>>.loading();
    if (currentState is! AsyncData<Map<LincaEvent, ParticipationInfo>>) return;

    final LincaEvent? targetEvent = currentState.value.keys.firstWhereOrNull(
      (LincaEvent event) => event.event.id == participationInfo.eventId,
    );
    if (targetEvent == null) return;

    final ParticipationInfo existingInfo = currentState.value[targetEvent]!;

    final List<String> newImageUrls;
    if (index < 0) {
      newImageUrls = <String>[...existingInfo.imageUrls, photoUrl];
    } else if (index < existingInfo.imageUrls.length) {
      newImageUrls = <String>[...existingInfo.imageUrls];
      newImageUrls[index] = photoUrl;
    } else {
      return;
    }

    final ParticipationInfo newInfo =
        existingInfo.copyWith(imageUrls: newImageUrls);

    await participationRepository.update(newInfo);

    final Map<LincaEvent, ParticipationInfo> rebuilt =
        <LincaEvent, ParticipationInfo>{
      for (final MapEntry<LincaEvent, ParticipationInfo> entry
          in currentState.value.entries)
        entry.key == targetEvent ? entry.key : entry.key:
            entry.key == targetEvent ? newInfo : entry.value,
    };

    state = AsyncData<Map<LincaEvent, ParticipationInfo>>(rebuilt);
  }
}
