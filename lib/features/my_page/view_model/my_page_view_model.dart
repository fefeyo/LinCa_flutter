import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/user_profile.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/network/model/linca_badge.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import '../../../core/network/model/user.dart';
import '../data/my_page_state.dart';

final StateNotifierProvider<MyPageViewModel, MyPageState>
    myPageViewModelProvider =
    StateNotifierProvider<MyPageViewModel, MyPageState>((Ref ref) {
  final User user = ref.watch(userControllerProvider).value!;
  final List<Group> groups =
      ref.watch(groupControllerProvider).value ?? <Group>[];
  final List<LincaBadge> badges =
      ref.watch(badgeControllerProvider).value ?? <LincaBadge>[];
  return MyPageViewModel(
    UserProfile(
      user: user,
      favoriteGroups: groups
          .where((Group group) => user.favoriteGroups.contains(group.slug))
          .toList(),
      favoriteBadges: badges
          .where((LincaBadge badge) => user.favoriteBadges.contains(badge.slug))
          .toList(),
    ),
  );
});

class MyPageViewModel extends StateNotifier<MyPageState> {
  MyPageViewModel(UserProfile userProfile)
      : super(MyPageState(userProfile: userProfile));
}
