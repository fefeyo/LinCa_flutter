import 'dart:async';

import 'package:linca_otaku_support/core/network/repository/friend_repository.dart';

import '../model/user.dart';

class FriendController {
  FriendController({
    required this.uid,
    required this.friendRepository,
  });

  final String? uid;
  final FriendRepository friendRepository;

  Future<void> registerFriend(String friendUid) async {
    if (uid == null) return;
    await friendRepository.registerFriend(uid!, friendUid);
  }

  Future<List<User>> fetchFriends() async {
    if (uid == null) return <User>[];
    return await friendRepository.fetchFriends(uid!);
  }
}
