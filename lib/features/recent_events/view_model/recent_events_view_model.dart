import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/recent_events_state.dart';

final StateNotifierProvider<RecentEventsViewModel, RecentEventsState>
    recentEventsViewModelProvider =
    StateNotifierProvider<RecentEventsViewModel, RecentEventsState>(
        (Ref ref) => RecentEventsViewModel());

class RecentEventsViewModel extends StateNotifier<RecentEventsState> {
  RecentEventsViewModel() : super(const RecentEventsState());
}
