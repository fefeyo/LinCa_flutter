import 'dart:async';

import 'package:fefeyo_flutter_template/core/auth/providers.dart';
import 'package:fefeyo_flutter_template/core/network/providers.dart';
import 'package:fefeyo_flutter_template/core/network/repository/user_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/user.dart';

class UserController extends AsyncNotifier<User>{
  late String? uid;
  late UserRepository userRepository;

  @override
  FutureOr<User> build() async {
    uid = ref.read(uidProvider);
    if (uid == null) return const User();
    userRepository = ref.read(userRepositoryProvider);
    return await userRepository.getUserData(uid!);
  }

  Future<User> getUserData() async {
    uid = ref.read(uidProvider);
    if (uid == null) return const User();
    return await userRepository.getUserData(uid!);
  }

}
