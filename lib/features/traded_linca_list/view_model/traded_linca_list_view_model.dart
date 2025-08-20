import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/traded_linca_list_state.dart';

final StateNotifierProvider<TradedLincaListViewModel, TradedLincaListState>
    tradedLincaListViewModelProvider =
    StateNotifierProvider<TradedLincaListViewModel, TradedLincaListState>(
        (Ref ref) => TradedLincaListViewModel());

class TradedLincaListViewModel extends StateNotifier<TradedLincaListState> {
  TradedLincaListViewModel() : super(const TradedLincaListState());
}
