import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../auth/providers.dart';
import '../model/user.dart';
import '../providers.dart';
import '../repository/user_repository.dart';

class UserController extends AsyncNotifier<User> {
  late String? uid;
  late UserRepository userRepository;

  @override
  FutureOr<User> build() async {
    uid = ref.watch(uidProvider);
    if (uid == null) return const User();
    userRepository = ref.read(userRepositoryProvider);
    return await userRepository.getUserData(uid!);
  }

  Future<User> getUserData() async {
    if (uid == null) return const User();
    return await userRepository.getUserData(uid!);
  }

  Future<void> updateDisplayName(String displayName) async {
    if (uid == null) return;
    await userRepository.updateDisplayName(uid!, displayName);
    state = AsyncValue<User>.data(
        state.value?.copyWith(displayName: displayName) ?? const User());
  }

  Future<void> updateUserPhoto(String photoUrl) async {
    if (uid == null) return;
    await userRepository.updateUserPhoto(uid!, photoUrl);
    state = AsyncValue<User>.data(
        state.value?.copyWith(photoUrl: photoUrl) ?? const User());
  }

  Future<void> updateUserData(User user) async {
    if (uid == null) return Future<void>.value();
    await userRepository.updateUserData(uid!, user);
    state = AsyncValue<User>.data(user);
  }
}
