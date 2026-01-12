import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/controller/linca_controller.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';

import '../../models/event_memory.dart';
import '../providers.dart';
import '../repository/participation_repository.dart';

class ParticipationController extends LincaController<List<ParticipationInfo>> {
  late ParticipationRepository participationRepository;

  @override
  Future<List<ParticipationInfo>> buildImpl() async {
    participationRepository = ref.read(participationRepositoryProvider);

    List<ParticipationInfo> participationInfos =
        await participationRepository.get();

    if (participationInfos.isNotEmpty) {
      unawaited(_refreshInBackground());
    } else {
      participationInfos = await participationRepository.fetch();
    }

    return participationInfos;
  }

  Future<void> createParticipation({
    required LincaEvent lincaEvent,
    required ParticipationInfo participation,
  }) async {
    await participationRepository.update(participation);

    final AsyncValue<List<ParticipationInfo>> currentState = state;
    if (currentState is AsyncData<List<ParticipationInfo>>) {
      final List<ParticipationInfo> updated =
          List<ParticipationInfo>.of(currentState.value);
      updated.add(participation);

      state = AsyncValue<List<ParticipationInfo>>.data(updated);
    } else {
      // fallback：強制再読み込み
      ref.invalidateSelf();
    }
  }

  Future<void> deleteParticipation(ParticipationInfo participationInfo) async {
    for (final EventMemory memory in participationInfo.eventMemories) {
      removeImageFromStorage(memory.path);
    }
    await participationRepository.delete(participationInfo.eventId);

    // 現在のstateが読み込み済みなら更新
    final AsyncValue<List<ParticipationInfo>> currentState = state;
    if (currentState is AsyncData<List<ParticipationInfo>>) {
      final List<ParticipationInfo> updated =
          List<ParticipationInfo>.of(currentState.value);
      updated.remove(participationInfo);

      state = AsyncValue<List<ParticipationInfo>>.data(updated);
    } else {
      // fallback：強制再読み込み
      ref.invalidateSelf();
    }
  }

  Future<void> _refreshInBackground() async {
    final List<ParticipationInfo> participations =
        state.value ?? <ParticipationInfo>[];

    try {
      final List<ParticipationInfo> updated =
          await participationRepository.fetch();

      if (updated.isNotEmpty) {
        state = AsyncValue<List<ParticipationInfo>>.data(updated);
      }
    } catch (_) {
      state = AsyncValue<List<ParticipationInfo>>.data(participations);
    }
  }

  Future<List<EventMemory>> updateParticipationMemory({
    required ParticipationInfo? targetParticipationInfo,
    required EventMemory eventMemory,
    bool isEdit = false,
  }) async {
    if (targetParticipationInfo == null) return <EventMemory>[];

    final AsyncValue<List<ParticipationInfo>> currentState = state;
    if (currentState is! AsyncData<List<ParticipationInfo>>) {
      return <EventMemory>[];
    }

    final List<ParticipationInfo> participations = currentState.value;

    final ParticipationInfo existingInfo = participations.firstWhere(
      (ParticipationInfo participationInfo) =>
          participationInfo.eventId == targetParticipationInfo.eventId,
    );

    final List<EventMemory> newEventMemories;
    if (isEdit) {
      newEventMemories = existingInfo.eventMemories.map((EventMemory memory) {
        if (memory.path == eventMemory.path) {
          return eventMemory;
        }
        return memory;
      }).toList();
    } else {
      newEventMemories = <EventMemory>[
        ...existingInfo.eventMemories,
        eventMemory,
      ];
    }

    final ParticipationInfo newInfo =
        existingInfo.copyWith(eventMemories: newEventMemories);

    await participationRepository.update(newInfo);

    final List<ParticipationInfo> rebuilt = <ParticipationInfo>[
      for (final ParticipationInfo info in participations)
        if (info.eventId == newInfo.eventId) newInfo else info,
    ];

    state = AsyncData<List<ParticipationInfo>>(rebuilt);

    return newEventMemories;
  }

  Future<List<EventMemory>> deleteParticipationMemory({
    required ParticipationInfo? targetParticipationInfo,
    required EventMemory eventMemory,
  }) async {
    if (targetParticipationInfo == null) return <EventMemory>[];

    final AsyncValue<List<ParticipationInfo>> currentState = state;
    if (currentState is! AsyncData<List<ParticipationInfo>>) {
      return <EventMemory>[];
    }

    final List<ParticipationInfo> participations = currentState.value;

    final ParticipationInfo existingInfo = participations.firstWhere(
      (ParticipationInfo participationInfo) =>
          participationInfo.eventId == targetParticipationInfo.eventId,
    );

    final List<EventMemory> newEventMemories =
        List<EventMemory>.of(existingInfo.eventMemories);
    newEventMemories.remove(eventMemory);

    final ParticipationInfo newInfo =
        existingInfo.copyWith(eventMemories: newEventMemories);

    removeImageFromStorage(eventMemory.path);

    await participationRepository.update(newInfo);

    final List<ParticipationInfo> rebuilt = <ParticipationInfo>[
      for (final ParticipationInfo info in participations)
        if (info.eventId == newInfo.eventId) newInfo else info,
    ];

    state = AsyncData<List<ParticipationInfo>>(rebuilt);

    return newEventMemories;
  }

  void removeImageFromStorage(String imagePath) {
    final Reference storageRef =
        FirebaseStorage.instance.ref().child(imagePath);
    storageRef.delete();
  }
}
