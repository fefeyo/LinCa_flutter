import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/choose_event_state.dart';

final StateNotifierProvider<ChooseEventViewModel, ChooseEventState>
    chooseEventViewModelProvider =
    StateNotifierProvider<ChooseEventViewModel, ChooseEventState>(
        (Ref ref) => ChooseEventViewModel());

class ChooseEventViewModel extends StateNotifier<ChooseEventState> {
  ChooseEventViewModel() : super(const ChooseEventState());
}
