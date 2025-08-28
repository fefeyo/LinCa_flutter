import 'dart:async';

import 'package:fefeyo_flutter_template/core/auth/repository/auth_repository.dart';
import 'package:fefeyo_flutter_template/core/network/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/auth_state.dart';
import '../providers.dart';

class AuthController extends AsyncNotifier<AuthState> {
  late AuthRepository authRepository;
  late UserRepository userRepository;

  @override
  FutureOr<AuthState> build() async {
    authRepository = ref.read(authRepositoryProvider);
    userRepository = ref.read(userRepositoryProvider);
    return AuthState(
      isSignedIn: authRepository.currentUser != null,
      isGoogleLinked: authRepository.isGoogleLinked(),
      isTwitterLinked: authRepository.isTwitterLinked(),
    );
  }

  /// 状態を再構築する共通関数
  AuthState _buildAuthState() => AuthState(
        isSignedIn: authRepository.currentUser != null,
        isGoogleLinked: authRepository.isGoogleLinked(),
        isTwitterLinked: authRepository.isTwitterLinked(),
      );

  /// 状態を更新する共通関数
  void _updateState() {
    state = AsyncData<AuthState>(_buildAuthState());
  }

  // ---------------------------
  // 公開 API（Android / iOS）
  // ---------------------------

  /// Google ログイン
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading<AuthState>();
    state = await AsyncValue.guard(() async {
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential =
          GoogleAuthProvider.credential(idToken: googleAuth.idToken);

      final UserCredential result =
          await authRepository.signInWithCredential(credential);

      await userRepository.ensureUserDoc(result.user!.uid);

      return _buildAuthState();
    });
  }

  /// X(Twitter) ログイン
  Future<void> signInWithTwitter() async {
    state = const AsyncLoading<AuthState>();
    state = await AsyncValue.guard(() async {
      final TwitterAuthProvider provider = TwitterAuthProvider();
      final UserCredential result =
          await authRepository.signInWithProvider(provider);
      await userRepository.ensureUserDoc(result.user!.uid);

      return _buildAuthState();
    });
  }

  /// ゲストログイン（匿名）
  Future<void> signInAnonymously() async {
    state = const AsyncLoading<AuthState>();
    state = await AsyncValue.guard(() async {
      final UserCredential result = await authRepository.signInAnonymously();
      await userRepository.ensureUserDoc(result.user!.uid);

      return _buildAuthState();
    });
  }

  /// サインアウト（Google のセッションも明示的に切る）
  Future<void> signOut() async {
    state = const AsyncLoading<AuthState>();
    state = await AsyncValue.guard(() async {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
      await authRepository.signOut();

      return _buildAuthState();
    });
  }

  /// 既存ユーザーに Google を連携（任意）
  Future<void> linkGoogle() async {
    state = const AsyncLoading<AuthState>();
    state = await AsyncValue.guard(() async {
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final UserCredential result =
          await authRepository.linkWithCredential(credential);
      await userRepository.ensureUserDoc(result.user!.uid);

      return _buildAuthState();
    });
  }

  /// 既存ユーザーに Twitter を連携（任意）
  Future<void> linkTwitter() async {
    state = const AsyncLoading<AuthState>();
    state = await AsyncValue.guard(() async {
      final TwitterAuthProvider provider = TwitterAuthProvider();
      final UserCredential result =
          await authRepository.linkWithProvider(provider);
      await userRepository.ensureUserDoc(result.user!.uid);

      return _buildAuthState();
    });
  }

  Future<void> deleteMyAccount() async {
    state = const AsyncLoading<AuthState>();
    state = await AsyncValue.guard(() async {
      await authRepository.deleteAccount();

      return _buildAuthState();
    });
  }
}
