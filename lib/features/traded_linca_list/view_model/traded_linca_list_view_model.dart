import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import '../../../core/models/favorite_badges.dart';
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
    final FavoriteBadges favoriteBadges = FavoriteBadges(
      badge01: badges.firstWhereOrNull(
          (LincaBadge badge) => badge.slug == user.favoriteBadges[0]),
      badge02: badges.firstWhereOrNull(
          (LincaBadge badge) => badge.slug == user.favoriteBadges[1]),
      badge03: badges.firstWhereOrNull(
          (LincaBadge badge) => badge.slug == user.favoriteBadges[2]),
    );

    return LincaUser(
      user: user,
      favoriteGroups: user.favoriteGroups
          .map((String tagId) =>
          groups.firstWhereOrNull((Group group) => group.slug == tagId))
          .whereType<Group>()
          .toList(),
      favoriteBadges: favoriteBadges,
    );
  }).toList());
});

class TradedLincaListViewModel extends StateNotifier<TradedLincaListState> {
  TradedLincaListViewModel(this.friends)
      : super(TradedLincaListState(friends: friends));

  final List<LincaUser> friends;
}
