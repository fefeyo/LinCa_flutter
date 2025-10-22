import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/user_profile.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import '../../../core/models/linca_user.dart';
import '../../../core/network/model/group.dart';
import '../../../core/network/model/linca_badge.dart';
import '../../../core/network/model/user.dart';
import '../data/traded_linca_list_state.dart';

final StateNotifierProvider<TradedLincaListViewModel, TradedLincaListState>
    tradedLincaListViewModelProvider =
    StateNotifierProvider<TradedLincaListViewModel, TradedLincaListState>(
        (Ref ref) {
  final LincaUser lincaUser = ref.watch(userControllerProvider).value!;
  final List<Group> groups =
      ref.watch(groupControllerProvider).value ?? <Group>[];
  final List<LincaBadge> badges =
      ref.watch(badgeControllerProvider).value ?? <LincaBadge>[];

  return TradedLincaListViewModel(lincaUser.friends.map((User user) {
    return UserProfile(
      user: user,
      favoriteGroups: groups
          .where((Group group) => user.favoriteGroups.contains(group.slug))
          .toList(),
      favoriteBadges: badges
          .where((LincaBadge badge) => user.favoriteBadges.contains(badge.slug))
          .toList(),
    );
  }).toList());
});

class TradedLincaListViewModel extends StateNotifier<TradedLincaListState> {
  TradedLincaListViewModel(this.friends)
      : super(TradedLincaListState(friends: friends));

  final List<UserProfile> friends;
}
