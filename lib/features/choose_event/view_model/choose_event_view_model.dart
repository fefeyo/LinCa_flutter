import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import 'package:linca_otaku_support/core/utils/sort_items_extension.dart';
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
      ref.watch(eventControllerProvider).value ?? <LincaEvent>[];
  final List<LincaEvent> userEvents =
      ref.watch(userEventControllerProvider).value ?? <LincaEvent>[];
  final Map<LincaEvent, ParticipationInfo> participations =
      ref.watch(participationControllerProvider).value ??
          <LincaEvent, ParticipationInfo>{};

  return ChooseEventViewModel(
    <LincaEvent>[
      ...events,
      ...userEvents,
    ],
    participations,
  );
});

class ChooseEventViewModel extends StateNotifier<ChooseEventState> {
  ChooseEventViewModel(
    this.initialEvents,
    this.participations,
  ) : super(
          ChooseEventState(
            sortedEvents:
                initialEvents.sortWithDisplayOrder(DisplayOrder.newest),
            participations: participations,
          ),
        );

  final List<LincaEvent> initialEvents;
  final Map<LincaEvent, ParticipationInfo> participations;

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
        .sortWithDisplayOrder(filterSettings.displayOrder)
        .filterWithTag(filterSettings.typeTags)
        .filterWithTag(filterSettings.seriesTags);

    return sortedEvents;
  }
}
