import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/network/model/user.dart';
import '../data/event_detail_state.dart';

final StateNotifierProvider<EventDetailViewModel, EventDetailState>
    eventDetailViewModelProvider =
    StateNotifierProvider<EventDetailViewModel, EventDetailState>(
        (Ref ref) => EventDetailViewModel());

class EventDetailViewModel extends StateNotifier<EventDetailState> {
  EventDetailViewModel() : super(const EventDetailState());

  void updateOrganizerUser(User organizerUser) {
    state = state.copyWith(organizerUser: organizerUser);
  }
}
