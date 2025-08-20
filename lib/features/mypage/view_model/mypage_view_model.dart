import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/mypage_state.dart';

final StateNotifierProvider<MypageViewModel, MypageState>
    mypageViewModelProvider =
    StateNotifierProvider<MypageViewModel, MypageState>(
        (Ref ref) => MypageViewModel());

class MypageViewModel extends StateNotifier<MypageState> {
  MypageViewModel() : super(const MypageState());
}
