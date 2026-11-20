import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/utils/sort_items_extension.dart';
import '../../../core/utils/event_filter.dart';
import '../../../core/models/filter_settings.dart';
import '../../../core/models/linca_event.dart';
import '../../../core/network/model/participation_info.dart';
import '../../../core/network/providers.dart';
import '../data/output_participate_events_state.dart';

final AutoDisposeStateNotifierProvider<OutputParticipateEventsViewModel,
        OutputParticipateEventsState> outputParticipateEventsViewModelProvider =
    StateNotifierProvider.autoDispose<OutputParticipateEventsViewModel,
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
    setFilterSettings(state.filterSettings.copyWith(keyword: keyword));
  }

  List<LincaEvent> sortEvents(FilterSettings filterSettings) {
    return state.allEvents
        .filterWithEventVisibility(filterSettings)
        .applyFilterSettings(filterSettings);
  }
}
