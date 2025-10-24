import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import '../data/my_page_state.dart';

final StateNotifierProvider<MyPageViewModel, MyPageState>
    myPageViewModelProvider =
    StateNotifierProvider<MyPageViewModel, MyPageState>((Ref ref) {
  final LincaUser lincaUser = ref.watch(userControllerProvider).value!;

  return MyPageViewModel(lincaUser);
});

class MyPageViewModel extends StateNotifier<MyPageState> {
  MyPageViewModel(LincaUser lincaUser)
      : super(MyPageState(lincaUser: lincaUser));
}
