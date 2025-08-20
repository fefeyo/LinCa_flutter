import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/linca_detail_state.dart';

final StateNotifierProvider<LincaDetailViewModel, LincaDetailState>
    lincaDetailViewModelProvider =
    StateNotifierProvider<LincaDetailViewModel, LincaDetailState>(
        (Ref ref) => LincaDetailViewModel());

class LincaDetailViewModel extends StateNotifier<LincaDetailState> {
  LincaDetailViewModel() : super(const LincaDetailState());
}
