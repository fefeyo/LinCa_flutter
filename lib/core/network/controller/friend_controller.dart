import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/repository/friend_repository.dart';

import '../../auth/providers.dart';
import '../model/user.dart';
import '../providers.dart';

class FriendController extends AsyncNotifier<List<User>> {
  late String? uid;
  late FriendRepository friendRepository;

  @override
  FutureOr<List<User>> build() async {
    uid = ref.read(uidProvider);
    if (uid == null) return <User>[];
    friendRepository = ref.read(friendRepositoryProvider);
    return await fetchFriends();
  }

  Future<void> registerFriend(String friendUid) async {
    if (uid == null) return;
    await friendRepository.registerFriend(uid!, friendUid);
  }

  Future<List<User>> fetchFriends() async {
    if (uid == null) return <User>[];
    return await friendRepository.fetchFriends(uid!);
  }
}
