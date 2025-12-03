import 'dart:async';

import 'package:linca_otaku_support/core/network/repository/friend_repository.dart';

import '../model/user.dart';

class FriendController {
  FriendController({
    required this.friendRepository,
  });

  final FriendRepository friendRepository;

  Future<void> registerFriend(String friendUid) async =>
      await friendRepository.registerFriend(friendUid);

  Future<List<User>> fetchFriends() async => await friendRepository.fetch();
}
