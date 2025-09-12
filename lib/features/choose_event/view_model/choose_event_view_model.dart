import 'package:fefeyo_flutter_template/core/models/linca_event.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/models/filter_settings.dart';
import '../../../core/network/providers.dart';
import '../../../core/utils/sort_items_extension.dart';
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
      : super(ChooseEventState(sortedEvents: initialEvents));

  final List<LincaEvent> initialEvents;

  void setKeyword(String keyword) {
    final FilterSettings filterSettings =
        state.filterSettings.copyWith(keyword: keyword);

    state = state.copyWith(
      filterSettings: filterSettings,
      sortedEvents: sortEvents(filterSettings),
    );
  }

  void setDisplayOrder(DisplayOrder? displayOrder) {
    final FilterSettings filterSettings =
        state.filterSettings.copyWith(displayOrder: displayOrder);

    state = state.copyWith(
      filterSettings: filterSettings,
      sortedEvents: sortEvents(filterSettings),
    );
  }

  void setParticipationFilter(Participation? participationFilter) {
    final FilterSettings filterSettings =
        state.filterSettings.copyWith(participationFilter: participationFilter);

    state = state.copyWith(
        filterSettings: filterSettings,
        sortedEvents: sortEvents(
          filterSettings,
        ));
  }

  void setSeriesTag(SeriesTag? seriesTag) {
    final FilterSettings filterSettings =
        state.filterSettings.copyWith(seriesTag: seriesTag);

    state = state.copyWith(
      filterSettings: filterSettings,
      sortedEvents: sortEvents(filterSettings),
    );
  }

  List<LincaEvent> sortEvents(FilterSettings filterSettings) {
    List<LincaEvent> sortedEvents = <LincaEvent>[];
    final List<String> keywords = filterSettings.keyword.split(' ');
    sortedEvents = initialEvents.where((LincaEvent event) {
      return keywords.any((String keyword) =>
          event.event.title.contains(keyword) ||
          event.event.kana.contains(keyword));
    }).toList();

    return sortedEvents;
  }
}
