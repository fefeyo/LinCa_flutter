import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import '../../../core/models/linca_event.dart';
import '../../../core/network/model/participation_info.dart';
import '../../../core/network/providers.dart';
import '../data/highlight_state.dart';

final StateNotifierProvider<HighlightViewModel, HighlightState>
    highlightViewModelProvider =
    StateNotifierProvider<HighlightViewModel, HighlightState>((Ref ref) {
  final Map<LincaEvent, ParticipationInfo> myEvents =
      ref.watch(participationControllerProvider).value ??
          <LincaEvent, ParticipationInfo>{};

  return HighlightViewModel(myEvents);
});

class HighlightViewModel extends StateNotifier<HighlightState> {
  HighlightViewModel(this.myEvents) : super(HighlightState(myEvents: myEvents));

  final Map<LincaEvent, ParticipationInfo> myEvents;

  void setSelectedYear(String year) {
    final int targetYear = int.parse(year);
    final Map<LincaEvent, ParticipationInfo> filteredMyEvents = state
        .myEvents.entries
        .where((MapEntry<LincaEvent, ParticipationInfo> entry) {
      if (entry.value.participationType == ParticipationType.absent) {
        return false;
      }
      final DateTime? eventDate = entry.key.event.date;
      if (eventDate == null) return false;

      return eventDate.year == targetYear;
    }).fold<Map<LincaEvent, ParticipationInfo>>(
      <LincaEvent, ParticipationInfo>{},
      (Map<LincaEvent, ParticipationInfo> map,
          MapEntry<LincaEvent, ParticipationInfo> entry) {
        map[entry.key] = entry.value;
        return map;
      },
    );
    state = state.copyWith(
      filteredMyEvents: filteredMyEvents,
      selectedYear: year,
    );
  }
}
