import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/utils/participation_extension.dart';
import '../../../core/models/linca_event.dart';
import '../../../core/network/model/participation_info.dart';
import '../../../core/network/providers.dart';
import '../data/highlight_state.dart';

final StateNotifierProvider<HighlightViewModel, HighlightState>
    highlightViewModelProvider =
    StateNotifierProvider<HighlightViewModel, HighlightState>((Ref ref) {
  final List<ParticipationInfo> participations =
      ref.watch(participationControllerProvider).value ?? <ParticipationInfo>[];
  final List<LincaEvent> officialEvents =
      ref.watch(eventControllerProvider).value ?? <LincaEvent>[];
  final List<LincaEvent> originalEvents =
      ref.watch(userEventControllerProvider).value ?? <LincaEvent>[];

  return HighlightViewModel(
    <LincaEvent>[...officialEvents, ...originalEvents],
    participations,
  );
});

class HighlightViewModel extends StateNotifier<HighlightState> {
  HighlightViewModel(this.allEvents, this.participations)
      : super(
          HighlightState(
            allEvents: allEvents,
            filteredMyEvents: allEvents,
            participations: participations,
          ),
        );

  final List<LincaEvent> allEvents;
  final List<ParticipationInfo> participations;

  void setSelectedYear(String year) {
    final int targetYear = int.parse(year);
    final List<LincaEvent> filteredMyEvents =
        state.allEvents.where((LincaEvent lincaEvent) {
      final ParticipationInfo? participationInfo =
          state.participations.getByEventId(lincaEvent.event.id);
      if (participationInfo?.participationType == ParticipationType.absent) {
        return false;
      }
      final DateTime? eventDate = lincaEvent.event.date;
      if (eventDate == null) return false;

      return eventDate.year == targetYear;
    }).toList();

    state = state.copyWith(
      filteredMyEvents: filteredMyEvents,
      selectedYear: year,
    );
  }
}
