import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/my_event_state.dart';

final StateNotifierProvider<MyEventViewModel, MyEventState>
    myEventViewModelProvider =
    StateNotifierProvider<MyEventViewModel, MyEventState>(
        (Ref ref) => MyEventViewModel());

class MyEventViewModel extends StateNotifier<MyEventState> {
  MyEventViewModel() : super(const MyEventState());
}
