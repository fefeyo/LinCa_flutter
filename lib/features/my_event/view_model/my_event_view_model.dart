import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/filter_settings.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import '../../../core/network/model/participation_info.dart';
import '../../../core/network/providers.dart';
import '../data/my_event_state.dart';

final StateNotifierProvider<MyEventViewModel, MyEventState>
    myEventViewModelProvider =
    StateNotifierProvider<MyEventViewModel, MyEventState>((Ref ref) {
  final List<LincaEvent> officialEvents =
      ref.read(eventControllerProvider).value ?? <LincaEvent>[];
  final List<LincaEvent> originalEvents =
      ref.read(userEventControllerProvider).value ?? <LincaEvent>[];
  final List<ParticipationInfo> participations =
      ref.read(participationControllerProvider).value ?? <ParticipationInfo>[];

  final MyEventViewModel viewModel = MyEventViewModel(
    <LincaEvent>[...officialEvents, ...originalEvents],
    participations,
  );

  ref.listen(userEventControllerProvider,
      (_, AsyncValue<List<LincaEvent>> next) {
    final List<LincaEvent> newOriginalEvents = next.value ?? <LincaEvent>[];
    final List<LincaEvent> allEvents = <LincaEvent>[
      ...officialEvents,
      ...newOriginalEvents
    ];
    viewModel.updateAllEvents(allEvents);
  });

  ref.listen(participationControllerProvider,
      (_, AsyncValue<List<ParticipationInfo>> next) {
    final List<ParticipationInfo> newParticipations =
        next.value ?? <ParticipationInfo>[];
    viewModel.updateParticipations(newParticipations);
  });

  return viewModel;
});

class MyEventViewModel extends StateNotifier<MyEventState> {
  MyEventViewModel(
      List<LincaEvent> allEvents, List<ParticipationInfo> participations)
      : super(
          MyEventState(
            allEvents: allEvents,
            sortedEvents: allEvents,
            participations: participations,
          ),
        );

  void setFilterSettings(FilterSettings filterSettings) {
    state = state.copyWith(
      filterSettings: filterSettings,
      sortedEvents: sortEvents(filterSettings: filterSettings),
    );
  }

  void setKeyword(String keyword) {
    final FilterSettings filterSettings =
        state.filterSettings.copyWith(keyword: keyword);
    state = state.copyWith(
      filterSettings: filterSettings,
      sortedEvents: sortEvents(filterSettings: filterSettings),
    );
  }

  List<LincaEvent> sortEvents({
    required FilterSettings filterSettings,
    List<LincaEvent> targetList = const <LincaEvent>[],
  }) {
    List<LincaEvent> events;
    if (targetList.isNotEmpty) {
      events = List<LincaEvent>.of(targetList);
    } else {
      events = List<LincaEvent>.of(state.allEvents);
    }

    if (filterSettings.isHiddenOriginalEvent) {
      events = events
          .where((LincaEvent event) => event.event is OfficialEvent)
          .toList();
    }

    if (filterSettings.isShowOfficialEvent) {
      events = events
          .where((LincaEvent lincaEvent) => lincaEvent.event is OfficialEvent)
          .toList();
    }

    if (filterSettings.isShowOriginalEvent) {
      events = events
          .where((LincaEvent lincaEvent) => lincaEvent.event is UnOfficialEvent)
          .toList();
    }

    if (!filterSettings.isShowOfficialEvent &&
        !filterSettings.isShowOriginalEvent) {
      events = state.allEvents;
    }

    events = events
        .filterWithPeriod(
          startDate: filterSettings.startDate,
          endDate: filterSettings.endDate,
        )
        .filterWithTag(filterSettings.typeTags)
        .filterWithTag(filterSettings.seriesTags)
        .filterWithKeyword(filterSettings.keyword)
        .sortWithDisplayOrder(displayOrder: filterSettings.displayOrder);

    return events;
  }

  void updateAllEvents(List<LincaEvent> newAllEvents) {
    final List<LincaEvent> allEvents = List<LincaEvent>.of(newAllEvents);

    state = state.copyWith(
      allEvents: allEvents,
      sortedEvents: sortEvents(
        filterSettings: state.filterSettings,
        targetList: newAllEvents,
      ),
    );
  }

  void updateParticipations(List<ParticipationInfo> newParticipations) {
    final List<ParticipationInfo> parcitipations =
        List<ParticipationInfo>.of(newParticipations);

    state = state.copyWith(
      participations: parcitipations,
      sortedEvents: sortEvents(filterSettings: state.filterSettings),
    );
  }
}
