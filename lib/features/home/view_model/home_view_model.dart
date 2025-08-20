import 'package:fefeyo_flutter_template/features/home/data/home_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final StateNotifierProvider<HomeViewModel, HomeState> homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((Ref ref) {
  return HomeViewModel();
});

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel() : super(const HomeState());
}
