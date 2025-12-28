import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../network/providers.dart';
import '../../network/repository/user_repository.dart';
import '../data/auth_state.dart';
import '../providers.dart';
import '../repository/auth_repository.dart';

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

  // ---------------------------
  // 公開 API（Android / iOS）
  // ---------------------------

  /// Google ログイン
  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading<AuthState>();
    state = await AsyncValue.guard(() async {
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential =
          GoogleAuthProvider.credential(idToken: googleAuth.idToken);

      final UserCredential userCredential =
          await authRepository.signInWithCredential(credential);

      await userRepository.ensureUserDoc(userId: userCredential.user!.uid);

      return _buildAuthState();
    });

    return state.value?.isSignedIn == true;
  }

  /// X(Twitter) ログイン
  Future<bool> signInWithTwitter() async {
    state = const AsyncLoading<AuthState>();
    state = await AsyncValue.guard(() async {
      final TwitterAuthProvider provider = TwitterAuthProvider();
      final UserCredential userCredential =
          await authRepository.signInWithProvider(provider);
      await userRepository.ensureUserDoc(userId: userCredential.user!.uid);

      return _buildAuthState();
    });

    return state.value?.isSignedIn == true;
  }

  /// ゲストログイン（匿名）
  Future<bool> signInAnonymously() async {
    state = const AsyncLoading<AuthState>();
    state = await AsyncValue.guard(() async {
      final UserCredential userCredential =
          await authRepository.signInAnonymously();
      await userRepository.ensureUserDoc(userId: userCredential.user!.uid);

      return _buildAuthState();
    });

    return state.value?.isSignedIn == true;
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
  Future<bool> linkGoogle() async {
    state = const AsyncLoading<AuthState>();
    state = await AsyncValue.guard(() async {
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await authRepository.linkWithCredential(credential);

      return _buildAuthState();
    });

    return state.value?.isGoogleLinked == true;
  }

  /// 既存ユーザーに Twitter を連携（任意）
  Future<bool> linkTwitter() async {
    state = const AsyncLoading<AuthState>();
    state = await AsyncValue.guard(() async {
      final TwitterAuthProvider provider = TwitterAuthProvider();
      await authRepository.linkWithProvider(provider);

      return _buildAuthState();
    });

    return state.value?.isTwitterLinked == true;
  }

  Future<void> unLinkGoogle() async {
    await authRepository.unlinkGoogle();
  }

  Future<void> unLinkTwitter() async {
    await authRepository.unlinkTwitter();
  }

  bool isTwitterLinked() => authRepository.isTwitterLinked();

  bool isGoogleLinked() => authRepository.isGoogleLinked();

  bool isBothProviderLinked() =>
      authRepository.isGoogleLinked() && authRepository.isTwitterLinked();

  Future<void> deleteMyAccount() async {
    state = const AsyncLoading<AuthState>();
    state = await AsyncValue.guard(() async {
      await userRepository.deleteMyUserData(authRepository.currentUser?.uid);
      await authRepository.deleteAccount();

      return _buildAuthState();
    });
  }
}
