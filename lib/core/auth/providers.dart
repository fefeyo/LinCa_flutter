import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'controller/auth_controller.dart';
import 'data/auth_state.dart';
import 'repository/auth_repository.dart';

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
    Provider<FirebaseFirestore>((Ref ref) {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  fireStore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  return fireStore;
});

final AsyncNotifierProvider<AuthController, AuthState> authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(() => AuthController());
