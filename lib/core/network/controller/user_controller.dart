import 'dart:async';

import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/favorite_badges.dart';
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
      acquiredBadges: badges
          .where((LincaBadge badge) => acquiredBadgeIds.contains(badge.slug))
          .sorted((LincaBadge a, LincaBadge b) => a.order.compareTo(b.order))
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
    final FavoriteBadges favoriteBadges = FavoriteBadges(
      badge01: badges.firstWhereOrNull(
          (LincaBadge badge) => badge.slug == user.favoriteBadges[0]),
      badge02: badges.firstWhereOrNull(
          (LincaBadge badge) => badge.slug == user.favoriteBadges[1]),
      badge03: badges.firstWhereOrNull(
          (LincaBadge badge) => badge.slug == user.favoriteBadges[2]),
    );
    final List<Group> groups = await groupRepository.loadGroups();
    final List<Group> favoriteGroups =
        user.favoriteGroups.map((String groupSlug) {
      return groups.firstWhere((Group group) => group.slug == groupSlug);
    }).toList();
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
        .sorted((LincaBadge a, LincaBadge b) => a.order.compareTo(b.order))
        .toList();

    // 現在の状態が null の場合は何もしない
    if (state.value == null) return;

    // 状態を更新
    state = AsyncValue<LincaUser>.data(
      state.value!.copyWith(acquiredBadges: acquiredBadges),
    );
  }

  Future<void> updateFriends() async {
    if (uid == null) return;
    final List<User> friends = await friendRepository.fetchFriends(uid!);
    state = AsyncValue<LincaUser>.data(
      state.value!.copyWith(friends: friends),
    );
  }

  Future<void> acquireBadge(String badgeId) async {
    if (uid == null) return;
    await badgeRepository.acquireBadge(uid!, badgeId);
    final List<LincaBadge> acquiredBadges =
        List<LincaBadge>.of(state.value?.acquiredBadges ?? <LincaBadge>[]);
    final List<LincaBadge> badges = await badgeRepository.loadBadges();
    final LincaBadge? addedBadge =
        badges.firstWhereOrNull((LincaBadge badge) => badge.id == badgeId);
    if (addedBadge != null) {
      acquiredBadges.add(addedBadge);
      state = AsyncValue<LincaUser>.data(
        state.value!.copyWith(acquiredBadges: acquiredBadges),
      );
    }
  }
}
