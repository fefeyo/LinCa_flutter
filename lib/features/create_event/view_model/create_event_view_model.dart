import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/create_event_state.dart';

final StateNotifierProvider<CreateEventViewModel, CreateEventState>
    createEventViewModelProvider =
    StateNotifierProvider<CreateEventViewModel, CreateEventState>(
        (Ref ref) => CreateEventViewModel());

class CreateEventViewModel extends StateNotifier<CreateEventState> {
  CreateEventViewModel() : super(const CreateEventState());
}
