import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/event_list_state.dart';

final StateNotifierProvider<EventListViewModel, EventListState>
    eventListViewModelProvider =
    StateNotifierProvider<EventListViewModel, EventListState>(
        (Ref ref) => EventListViewModel());

class EventListViewModel extends StateNotifier<EventListState> {
  EventListViewModel() : super(const EventListState());
}
