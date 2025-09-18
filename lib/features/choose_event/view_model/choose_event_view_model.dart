import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import 'package:linca_otaku_support/core/utils/sort_items_extension.dart';
import '../../../core/models/filter_settings.dart';
import '../../../core/models/linca_event.dart';
import '../../../core/network/providers.dart';
import '../data/choose_event_state.dart';

final StateNotifierProvider<ChooseEventViewModel, ChooseEventState>
    chooseEventViewModelProvider =
    StateNotifierProvider<ChooseEventViewModel, ChooseEventState>((Ref ref) {
  final AsyncValue<List<LincaEvent>> eventAsync =
      ref.watch(eventControllerProvider);

  return eventAsync.when(
    data: (List<LincaEvent> events) => ChooseEventViewModel(events),
    loading: () => ChooseEventViewModel(<LincaEvent>[]),
    error: (_, __) => ChooseEventViewModel(<LincaEvent>[]),
  );
});

class ChooseEventViewModel extends StateNotifier<ChooseEventState> {
  ChooseEventViewModel(this.initialEvents)
      : super(
          ChooseEventState(
            sortedEvents:
                initialEvents.sortWithDisplayOrder(DisplayOrder.newest),
          ),
        );

  final List<LincaEvent> initialEvents;

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
    List<LincaEvent> sortedEvents = initialEvents;

    sortedEvents = sortedEvents
        .filterWithKeyword(filterSettings.keyword)
        .sortWithDisplayOrder(filterSettings.displayOrder)
        .filterWithGroup(filterSettings.groups);

    return sortedEvents;
  }
}
