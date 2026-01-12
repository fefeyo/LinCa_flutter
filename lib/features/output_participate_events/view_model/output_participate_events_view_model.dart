import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import 'package:linca_otaku_support/core/utils/sort_items_extension.dart';
import '../../../core/models/filter_settings.dart';
import '../../../core/models/linca_event.dart';
import '../../../core/network/model/event_base.dart';
import '../../../core/network/model/participation_info.dart';
import '../../../core/network/providers.dart';
import '../data/output_participate_events_state.dart';

final StateNotifierProvider<OutputParticipateEventsViewModel,
        OutputParticipateEventsState> outputParticipateEventsViewModelProvider =
    StateNotifierProvider<OutputParticipateEventsViewModel,
        OutputParticipateEventsState>((Ref ref) {
  final List<LincaEvent> officialEvents =
      ref.read(eventControllerProvider).value ?? <LincaEvent>[];
  final List<LincaEvent> originalEvents =
      ref.read(userEventControllerProvider).value ?? <LincaEvent>[];
  final List<ParticipationInfo> participations =
      ref.read(participationControllerProvider).value ?? <ParticipationInfo>[];

  return OutputParticipateEventsViewModel(
    <LincaEvent>[...officialEvents, ...originalEvents],
    participations,
  );
});

class OutputParticipateEventsViewModel
    extends StateNotifier<OutputParticipateEventsState> {
  OutputParticipateEventsViewModel(
    List<LincaEvent> allEvents,
    List<ParticipationInfo> participations,
  ) : super(
          OutputParticipateEventsState(
            allEvents: allEvents,
            sortedEvents: allEvents,
            participations: participations,
            filterSettings: const FilterSettings(
              displayOrder: DisplayOrder.oldest,
            ),
          ),
        ) {
    state = state.copyWith(
      sortedEvents: sortEvents(state.filterSettings),
    );
  }

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

  List<LincaEvent> sortEvents(FilterSettings filterSettings) {
    List<LincaEvent> events = List<LincaEvent>.of(state.allEvents);

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
        .filterWithKeyword(filterSettings.keyword)
        .filterWithTag(filterSettings.typeTags)
        .filterWithTag(filterSettings.seriesTags)
        .sortWithDisplayOrder(displayOrder: filterSettings.displayOrder);

    return events;
  }
}
