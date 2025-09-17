import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/home_state.dart';

final StateNotifierProvider<HomeViewModel, HomeState> homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((Ref ref) {
  return HomeViewModel();
});

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel() : super(const HomeState());
}
