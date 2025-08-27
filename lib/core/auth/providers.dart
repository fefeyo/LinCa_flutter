import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fefeyo_flutter_template/core/auth/controller/auth_controller.dart';
import 'package:fefeyo_flutter_template/core/auth/data/auth_state.dart';
import 'package:fefeyo_flutter_template/core/auth/repository/auth_repository.dart';
import 'package:fefeyo_flutter_template/core/network/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<FirebaseAuth> firebaseAuthProvider = Provider<FirebaseAuth>((_) {
  return FirebaseAuth.instance;
});

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((Ref ref) {
  return AuthRepository(auth: ref.watch(firebaseAuthProvider));
});

// 認証ストリームをアプリ全域に配信
final StreamProvider<User?> authStateProvider = StreamProvider<User?>(
    (Ref ref) => ref.watch(authRepositoryProvider).authState());

// ログイン中前提の UID
final Provider<String?> uidProvider = Provider<String?>(
  (Ref ref) => ref.watch(authStateProvider).value?.uid,
);

final Provider<FirebaseFirestore> fireStoreProvider =
    Provider<FirebaseFirestore>((Ref ref) => FirebaseFirestore.instance);

final Provider<UserRepository> userRepositoryProvider =
    Provider<UserRepository>(
        (Ref ref) => UserRepository(ref.watch(fireStoreProvider)));

final AsyncNotifierProvider<AuthController, AuthState> authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(() => AuthController());
