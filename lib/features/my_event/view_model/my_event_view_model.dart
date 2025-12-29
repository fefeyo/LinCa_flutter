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
  final Map<LincaEvent, ParticipationInfo> myEvents =
      ref.read(participationControllerProvider).value ??
          <LincaEvent, ParticipationInfo>{};

  final MyEventViewModel viewModel = MyEventViewModel(myEvents.sort());

  ref.listen(participationControllerProvider,
      (_, AsyncValue<Map<LincaEvent, ParticipationInfo>> next) {
    final Map<LincaEvent, ParticipationInfo>? newParticipations = next.value;
    if (newParticipations != null) {
      viewModel.updateParticipations(newParticipations);
    }
  });

  return viewModel;
});

class MyEventViewModel extends StateNotifier<MyEventState> {
  MyEventViewModel(Map<LincaEvent, ParticipationInfo> myEvents)
      : super(MyEventState(initialEvents: myEvents));

  void setFilterSettings(FilterSettings filterSettings) {
    state = state.copyWith(
      filterSettings: filterSettings,
      sortedEvents: sortEvents(filterSettings),
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

  Map<LincaEvent, ParticipationInfo> sortEvents(FilterSettings filterSettings) {
    List<LincaEvent> events = state.initialEvents.keys.toList();

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
      events = state.initialEvents.keys.toList();
    }

    events = events
        .filterWithKeyword(filterSettings.keyword)
        .filterWithTag(filterSettings.typeTags)
        .filterWithTag(filterSettings.seriesTags)
        .sortWithDisplayOrder(displayOrder: filterSettings.displayOrder);

    final Map<LincaEvent, ParticipationInfo> sortedMap =
        <LincaEvent, ParticipationInfo>{};
    for (final LincaEvent event in events) {
      if (filterSettings.participationFilters.isNotEmpty &&
          !filterSettings.participationFilters
              .contains(state.initialEvents[event]!.participationType)) {
        continue;
      }
      sortedMap[event] = state.initialEvents[event]!;
    }

    return sortedMap;
  }

  void updateParticipations(
    Map<LincaEvent, ParticipationInfo> newParticipations,
  ) {
    final Map<LincaEvent, ParticipationInfo> updatedEvents =
        Map<LincaEvent, ParticipationInfo>.of(newParticipations);

    state = state.copyWith(
      initialEvents: updatedEvents,
    );

    state = state.copyWith(
      sortedEvents: sortEvents(state.filterSettings),
    );
  }
}
