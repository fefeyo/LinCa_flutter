import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/my_page_state.dart';

final StateNotifierProvider<MyPageViewModel, MyPageState>
    myPageViewModelProvider =
    StateNotifierProvider<MyPageViewModel, MyPageState>(
        (Ref ref) => MyPageViewModel());

class MyPageViewModel extends StateNotifier<MyPageState> {
  MyPageViewModel() : super(const MyPageState());
}
