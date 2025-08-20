import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/linca_edit_state.dart';

final StateNotifierProvider<LincaEditViewModel, LincaEditState>
    lincaEditViewModelProvider =
    StateNotifierProvider<LincaEditViewModel, LincaEditState>(
        (Ref ref) => LincaEditViewModel());

class LincaEditViewModel extends StateNotifier<LincaEditState> {
  LincaEditViewModel() : super(const LincaEditState());
}
