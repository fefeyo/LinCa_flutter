import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';
import '../../../core/network/model/event_base.dart';
import '../../../core/network/model/participation_info.dart';
import '../../../core/network/providers.dart';
import '../data/linca_calendar_state.dart';

final StateNotifierProvider<LincaCalendarViewModel, LincaCalendarState>
    lincaCalendarViewModelProvider =
    StateNotifierProvider<LincaCalendarViewModel, LincaCalendarState>(
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
    final Map<LincaEvent, ParticipationInfo> participations =
        ref.read(participationControllerProvider).value ??
            <LincaEvent, ParticipationInfo>{};

    final LincaCalendarViewModel viewModel = LincaCalendarViewModel(
      events: <LincaEvent>[
        ...events,
        ...userEvents,
      ],
      myEvents: participations,
    );

    ref.listen(
      participationControllerProvider,
      (_, AsyncValue<Map<LincaEvent, ParticipationInfo>> next) {
        final Map<LincaEvent, ParticipationInfo>? newParticipations =
            next.value;
        if (newParticipations != null) {
          viewModel.updateParticipations(newParticipations);
        }
      },
    );

    return viewModel;
  },
);

class LincaCalendarViewModel extends StateNotifier<LincaCalendarState> {
  LincaCalendarViewModel({
    required List<LincaEvent> events,
    required Map<LincaEvent, ParticipationInfo> myEvents,
  }) : super(
          LincaCalendarState(
            selectedDate: DateTime.now(),
            focusedMonth: DateTime.now(),
            events: events,
            myEvents: myEvents,
          ),
        );

  void updateFocusedMonth(DateTime dateTime) {
    state = state.copyWith(
      focusedMonth: dateTime,
    );
  }

  void updateSelectedDate(DateTime dateTime) {
    state = state.copyWith(
      selectedDate: dateTime,
    );
  }

  bool hasEvent(DateTime dateTime) {
    return state.events.any((LincaEvent lincaEvent) =>
        lincaEvent.event.date?.isSameDate(dateTime) == true);
  }

  void updateParticipations(Map<LincaEvent, ParticipationInfo> participations) {
    state = state.copyWith(myEvents: participations);
  }
}
