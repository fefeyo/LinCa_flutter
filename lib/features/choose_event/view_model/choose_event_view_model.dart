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
  final List<ParticipationInfo> participations =
      ref.read(participationControllerProvider).value ?? <ParticipationInfo>[];

  final ChooseEventViewModel viewModel = ChooseEventViewModel(
    ref,
    <LincaEvent>[
      ...events,
      ...userEvents,
    ],
    participations,
  );

  ref.listen(participationControllerProvider,
      (_, AsyncValue<List<ParticipationInfo>> next) {
    final List<ParticipationInfo> newParticipations =
        next.value ?? <ParticipationInfo>[];
    viewModel.updateParticipations(newParticipations);
  });

  ref.listen(eventControllerProvider, (_, AsyncValue<List<LincaEvent>> next) {
    final List<LincaEvent>? events = next.value;
    if (events != null) {
      viewModel.updateEvents(events);
    }
  });

  ref.listen(userEventControllerProvider,
      (_, AsyncValue<List<LincaEvent>> next) {
    final List<LincaEvent>? events = next.value;
    if (events != null) {
      viewModel.updateEvents(
        events
            .where((LincaEvent event) =>
                (event.event as UnOfficialEvent).visibility == true)
            .toList(),
      );
    }
  });

  return viewModel;
});

class ChooseEventViewModel extends StateNotifier<ChooseEventState> {
  ChooseEventViewModel(
    this.ref,
    List<LincaEvent> initialEvents,
    final List<ParticipationInfo> participations,
  ) : super(
          ChooseEventState(
            initialEvents: initialEvents,
            sortedEvents: initialEvents.sortWithDisplayOrder(),
            participations: participations,
          ),
        );

  final Ref ref;

  void setEventType(EventType eventType) {
    final List<LincaEvent> events =
        state.initialEvents.where((LincaEvent event) {
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
      sortedEvents: sortEvents(state.initialEvents, filterSettings),
    );
  }

  void setFilterSettings(FilterSettings filterSettings) {
    state = state.copyWith(
      filterSettings: filterSettings,
      sortedEvents: sortEvents(state.initialEvents, filterSettings),
    );
  }

  List<LincaEvent> sortEvents(
      List<LincaEvent> initialEvents, FilterSettings filterSettings) {
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
      sortedEvents = sortedEvents.filterOnlyNotPaticipationEvent(
        allEvents: initialEvents,
        participations: state.participations,
      );
    }

    sortedEvents = sortedEvents
        .filterWithPeriod(
          startDate: filterSettings.startDate,
          endDate: filterSettings.endDate,
        )
        .filterWithTag(filterSettings.typeTags)
        .filterWithTag(filterSettings.seriesTags)
        .filterWithKeyword(filterSettings.keyword)
        .sortWithDisplayOrder(displayOrder: filterSettings.displayOrder);

    return sortedEvents;
  }

  void updateParticipations(List<ParticipationInfo> newParticipations) {
    List<LincaEvent> sortedEvents = state.sortedEvents;
    if (state.filterSettings.isHiddenParticipationEvent) {
      sortedEvents = sortedEvents.filterOnlyNotPaticipationEvent(
        allEvents: state.initialEvents,
        participations: newParticipations,
      );
    }
    state = state.copyWith(
      participations: newParticipations,
      sortedEvents: sortedEvents,
    );
  }

  void updateEvents(List<LincaEvent> events) {
    state = state.copyWith(
      initialEvents: events,
      sortedEvents: sortEvents(events, state.filterSettings),
    );
  }

  Future<void> refresh(EventType eventType) async {
    switch (eventType) {
      case EventType.official:
        await ref.read(eventControllerProvider.notifier).refreshInBackground();
      case EventType.unofficial:
        await ref
            .read(userEventControllerProvider.notifier)
            .refreshInBackground();
    }
  }
}
