import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/event_detail_state.dart';

final StateNotifierProvider<EventDetailViewModel, EventDetailState>
    eventDetailViewModelProvider =
    StateNotifierProvider<EventDetailViewModel, EventDetailState>(
        (Ref ref) => EventDetailViewModel());

class EventDetailViewModel extends StateNotifier<EventDetailState> {
  EventDetailViewModel() : super(const EventDetailState());
}
