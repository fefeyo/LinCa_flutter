import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/created_event_list_state.dart';

final StateNotifierProvider<CreatedEventListViewModel, CreatedEventListState>
    createdEventListViewModelProvider =
    StateNotifierProvider<CreatedEventListViewModel, CreatedEventListState>(
        (Ref ref) => CreatedEventListViewModel());

class CreatedEventListViewModel extends StateNotifier<CreatedEventListState> {
  CreatedEventListViewModel() : super(const CreatedEventListState());
}
