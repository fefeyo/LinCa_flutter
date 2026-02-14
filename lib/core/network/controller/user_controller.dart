import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/models/favorite_badges.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/network/controller/linca_controller.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';
import 'package:linca_otaku_support/core/network/repository/friend_repository.dart';
import 'package:linca_otaku_support/core/network/repository/group_repository.dart';

import '../../auth/providers.dart';
import '../model/linca_badge.dart';
import '../model/user.dart';
import '../providers.dart';
import '../repository/badge_repository.dart';
import '../repository/user_repository.dart';

class UserController extends LincaController<LincaUser> {
  late String? uid;
  late UserRepository userRepository;
  late BadgeRepository badgeRepository;
  late FriendRepository friendRepository;
  late GroupRepository groupRepository;

  @override
  FutureOr<LincaUser> buildImpl() async {
    final firebase.User? authUser = await ref.watch(authStateProvider.future);
    uid = authUser?.uid;
    if (uid == null) return const LincaUser();
    userRepository = ref.read(userRepositoryProvider);
    badgeRepository = ref.read(badgeRepositoryProvider);
    friendRepository = ref.read(friendRepositoryProvider);
    groupRepository = ref.read(groupRepositoryProvider);

    final User user = await userRepository.fetchUserData(uid!);
    final List<Group> groups =
        ref.read(groupControllerProvider).value ?? <Group>[];
    final List<LincaBadge> badges =
        ref.read(badgeControllerProvider).value ?? <LincaBadge>[];
    final List<String> acquiredBadgeIds =
        await badgeRepository.acuqiredBadgeIds();
    final List<User> friends = await friendRepository.fetch();
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
    displayName = displayName.isNotEmpty
        ? displayName
        : AppConstants
            .defaultNames[Random().nextInt(AppConstants.defaultNames.length)];
    if (uid == null) return;
    await userRepository.updateDisplayName(displayName);
    final User user = state.value?.user ?? const User();
    state = AsyncValue<LincaUser>.data(
        state.value?.copyWith(user: user.copyWith(displayName: displayName)) ??
            const LincaUser());
  }

  Future<void> updateBio(String bio) async {
    if (uid == null) return;
    await userRepository.updateBio(bio);
    final User user = state.value?.user ?? const User();
    state = AsyncValue<LincaUser>.data(
        state.value?.copyWith(user: user.copyWith(bio: bio)) ??
            const LincaUser());
  }

  Future<void> updateUserPhoto(String photoUrl) async {
    if (uid == null) return;
    await userRepository.updateUserPhoto(photoUrl);
    final User user = state.value?.user ?? const User();
    state = AsyncValue<LincaUser>.data(
        state.value?.copyWith(user: user.copyWith(photoUrl: photoUrl)) ??
            const LincaUser());
  }

  Future<void> updateUserData(User user) async {
    if (uid == null) return Future<void>.value();
    await userRepository.updateUserData(user);
    final List<LincaBadge> badges = await badgeRepository.get();
    final FavoriteBadges favoriteBadges = FavoriteBadges(
      badge01: badges.firstWhereOrNull(
          (LincaBadge badge) => badge.slug == user.favoriteBadges[0]),
      badge02: badges.firstWhereOrNull(
          (LincaBadge badge) => badge.slug == user.favoriteBadges[1]),
      badge03: badges.firstWhereOrNull(
          (LincaBadge badge) => badge.slug == user.favoriteBadges[2]),
    );
    final List<Group> groups = await groupRepository.get();
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
    // バッジ一覧と取得済みバッジIDを取得
    final List<LincaBadge> allBadges = await badgeRepository.get();
    final List<String> acquiredBadgeIds =
        await badgeRepository.acuqiredBadgeIds();

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
    final List<User> friends = await friendRepository.fetch();
    state = AsyncValue<LincaUser>.data(
      state.value!.copyWith(friends: friends),
    );
  }

  Future<void> acquireBadge(String badgeId) async {
    await badgeRepository.acquireBadge(badgeId);
    final List<LincaBadge> acquiredBadges =
        List<LincaBadge>.of(state.value?.acquiredBadges ?? <LincaBadge>[]);
    final List<LincaBadge> badges = await badgeRepository.get();
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
