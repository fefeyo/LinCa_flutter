import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/network/repository/friend_repository.dart';
import 'package:linca_otaku_support/core/network/repository/group_repository.dart';
import 'package:linca_otaku_support/core/network/repository/participation_repository.dart';

import '../../auth/providers.dart';
import '../model/linca_badge.dart';
import '../model/user.dart';
import '../providers.dart';
import '../repository/badge_repository.dart';
import '../repository/user_repository.dart';

class UserController extends AsyncNotifier<LincaUser> {
  late String? uid;
  late UserRepository userRepository;
  late BadgeRepository badgeRepository;
  late FriendRepository friendRepository;
  late ParticipationRepository participationRepository;
  late GroupRepository groupRepository;

  @override
  FutureOr<LincaUser> build() async {
    uid = ref.watch(uidProvider);
    if (uid == null) return const LincaUser();
    userRepository = ref.read(userRepositoryProvider);
    badgeRepository = ref.read(badgeRepositoryProvider);
    friendRepository = ref.read(friendRepositoryProvider);
    participationRepository = ref.read(participationRepositoryProvider);
    groupRepository = ref.read(groupRepositoryProvider);

    final User user = await userRepository.fetchUserData(uid!);
    final List<Group> groups = await groupRepository.loadGroups();
    final List<LincaBadge> badges = await badgeRepository.loadBadges();
    final List<String> acquiredBadgeIds =
        await badgeRepository.acuqiredBadgeIds(uid!);
    final List<User> friends = await friendRepository.fetchFriends(uid!);

    return LincaUser(
      user: user,
      favoriteGroups: groups
          .where(
            (Group group) => user.favoriteGroups.contains(group.slug),
          )
          .toList(),
      favoriteBadges: badges
          .where(
            (LincaBadge badge) => user.favoriteBadges.contains(badge.slug),
          )
          .toList(),
      acquiredBadges: badges
          .where(
            (LincaBadge badge) => acquiredBadgeIds.contains(badge.slug),
          )
          .toList(),
      friends: friends,
    );
  }

  Future<User> fetchUserData({required String userId}) async {
    return await userRepository.fetchUserData(userId);
  }

  Future<void> updateDisplayName(String displayName) async {
    displayName = displayName.isNotEmpty ? displayName : '幻の学院生';
    if (uid == null) return;
    await userRepository.updateDisplayName(uid!, displayName);
    final User user = state.value?.user ?? const User();
    state = AsyncValue<LincaUser>.data(
        state.value?.copyWith(user: user.copyWith(displayName: displayName)) ??
            const LincaUser());
  }

  Future<void> updateUserPhoto(String photoUrl) async {
    if (uid == null) return;
    await userRepository.updateUserPhoto(uid!, photoUrl);
    final User user = state.value?.user ?? const User();
    state = AsyncValue<LincaUser>.data(
        state.value?.copyWith(user: user.copyWith(photoUrl: photoUrl)) ??
            const LincaUser());
  }

  Future<void> updateUserData(User user) async {
    if (uid == null) return Future<void>.value();
    await userRepository.updateUserData(uid!, user);
    final List<LincaBadge> badges = await badgeRepository.loadBadges();
    final List<LincaBadge> favoriteBadges = badges
        .where(
          (LincaBadge badge) => user.favoriteBadges.contains(badge.slug),
        )
        .toList();
    final List<Group> groups = await groupRepository.loadGroups();
    final List<Group> favoriteGroups = groups
        .where(
          (Group group) => user.favoriteGroups.contains(group.slug),
        )
        .toList();
    state = AsyncValue<LincaUser>.data(state.value?.copyWith(
          user: user,
          favoriteBadges: favoriteBadges,
          favoriteGroups: favoriteGroups,
        ) ??
        const LincaUser());
  }

  Future<void> updateAcquiredBadges() async {
    if (uid == null) return;

    // バッジ一覧と取得済みバッジIDを取得
    final List<LincaBadge> allBadges = await badgeRepository.loadBadges();
    final List<String> acquiredBadgeIds =
        await badgeRepository.acuqiredBadgeIds(uid!);

    // 取得済みバッジを抽出
    final List<LincaBadge> acquiredBadges = allBadges
        .where((LincaBadge badge) => acquiredBadgeIds.contains(badge.slug))
        .toList();

    // 現在の状態が null の場合は何もしない
    if (state.value == null) return;

    // 状態を更新
    state = AsyncValue<LincaUser>.data(
      state.value!.copyWith(acquiredBadges: acquiredBadges),
    );
  }
}
