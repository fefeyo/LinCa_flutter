import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import '../../../core/constants/event_type.dart';
import '../../../core/models/filter_settings.dart';
import '../../../core/models/linca_event.dart';
import '../../../core/network/model/event_base.dart';
import '../../../core/network/model/participation_info.dart';
import '../../../core/network/providers.dart';
import '../data/choose_event_state.dart';

final AutoDisposeStateNotifierProvider<ChooseEventViewModel, ChooseEventState>
    chooseEventViewModelProvider =
    StateNotifierProvider.autoDispose<ChooseEventViewModel, ChooseEventState>(
        (Ref ref) {
  final List<LincaEvent> events =
      ref.read(eventControllerProvider).value ?? <LincaEvent>[];
  final List<LincaEvent> userEvents = ref
          .read(userEventControllerProvider)
          .value
          ?.where((LincaEvent event) =>
              (event.event as UnOfficialEvent).visibility == true)
          .toList() ??
      <LincaEvent>[];
  final Map<LincaEvent, ParticipationInfo> participations =
      ref.read(participationControllerProvider).value ??
          <LincaEvent, ParticipationInfo>{};

  final ChooseEventViewModel viewModel = ChooseEventViewModel(
    ref,
    <LincaEvent>[
      ...events,
      ...userEvents,
    ],
    participations,
  );

  ref.listen(participationControllerProvider,
      (_, AsyncValue<Map<LincaEvent, ParticipationInfo>> next) {
    final Map<LincaEvent, ParticipationInfo>? newParticipations = next.value;
    if (newParticipations != null) {
      viewModel.updateParticipations(newParticipations);
    }
  });

  return viewModel;
});

class ChooseEventViewModel extends StateNotifier<ChooseEventState> {
  ChooseEventViewModel(
      this.ref,
    this.initialEvents,
    final Map<LincaEvent, ParticipationInfo> participations,
  ) : super(
          ChooseEventState(
            sortedEvents: initialEvents.sortWithDisplayOrder(),
            participations: participations,
          ),
        );

  final Ref ref;
  final List<LincaEvent> initialEvents;

  void setEventType(EventType eventType) {
    final List<LincaEvent> events = initialEvents.where((LincaEvent event) {
      if (eventType == EventType.official) {
        return event.event is OfficialEvent;
      }
      if (eventType == EventType.unofficial) {
        return event.event is UnOfficialEvent;
      }
      return true;
    }).toList();
    state = state.copyWith(
      sortedEvents: events,
      eventType: eventType,
    );
  }

  void setKeyword(String keyword) {
    final FilterSettings filterSettings =
        state.filterSettings.copyWith(keyword: keyword);

    state = state.copyWith(
      filterSettings: filterSettings,
      sortedEvents: sortEvents(filterSettings),
    );
  }

  void setFilterSettings(FilterSettings filterSettings) {
    state = state.copyWith(
      filterSettings: filterSettings,
      sortedEvents: sortEvents(filterSettings),
    );
  }

  List<LincaEvent> sortEvents(FilterSettings filterSettings) {
    List<LincaEvent> sortedEvents = initialEvents.where((LincaEvent event) {
      if (state.eventType == EventType.official) {
        return event.event is OfficialEvent;
      }
      if (state.eventType == EventType.unofficial) {
        return event.event is UnOfficialEvent;
      }
      return true;
    }).toList();

    if (filterSettings.isHiddenParticipationEvent) {
      sortedEvents =
          sortedEvents.filterOnlyNotPaticipationEvent(state.participations);
    }

    sortedEvents = sortedEvents
        .filterWithKeyword(filterSettings.keyword)
        .filterWithTag(filterSettings.typeTags)
        .filterWithTag(filterSettings.seriesTags)
        .sortWithDisplayOrder(displayOrder: filterSettings.displayOrder);

    return sortedEvents;
  }

  void updateParticipations(
    Map<LincaEvent, ParticipationInfo> newParticipations,
  ) {
    List<LincaEvent> sortedEvents = state.sortedEvents;
    if (state.filterSettings.isHiddenParticipationEvent) {
      sortedEvents =
          sortedEvents.filterOnlyNotPaticipationEvent(newParticipations);
    }
    state = state.copyWith(
      participations: newParticipations,
      sortedEvents: sortedEvents,
    );
  }

  Future<void> refresh(EventType eventType) async {
    switch (eventType) {
      case EventType.official:
        await ref.read(eventControllerProvider.notifier).refreshInBackground();
      case EventType.unofficial:
        await ref.read(userEventControllerProvider.notifier).refreshInBackground();
    }
  }
}
