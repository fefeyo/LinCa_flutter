import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  const AuthRepository({required this.auth});

  final FirebaseAuth auth;

  Stream<User?> authState() => auth.authStateChanges();

  User? get currentUser => auth.currentUser;

  Future<UserCredential> signInAnonymously() => auth.signInAnonymously();

  Future<void> signOut() => auth.signOut();

  Future<UserCredential> signInWithCredential(AuthCredential credential) =>
      auth.signInWithCredential(credential);

  Future<UserCredential> signInWithProvider(AuthProvider provider) =>
      auth.signInWithProvider(provider);

  Future<UserCredential> linkWithCredential(AuthCredential credential) =>
      currentUser!.linkWithCredential(credential);

  Future<UserCredential> linkWithProvider(AuthProvider provider) =>
      currentUser!.linkWithProvider(provider);

  Future<void> deleteAccount() => currentUser!.delete();

  bool isGoogleLinked() =>
      currentUser?.providerData
          .any((UserInfo info) => info.providerId == 'google.com') ??
      false;

  bool isTwitterLinked() =>
      currentUser?.providerData
          .any((UserInfo info) => info.providerId == 'twitter.com') ??
      false;

  Future<void> unlinkGoogle() async {
    if (isGoogleLinked()) {
      await currentUser!.unlink('google.com');
    }
  }

  Future<void> unlinkTwitter() async {
    if (isTwitterLinked()) {
      await currentUser!.unlink('twitter.com');
    }
  }
}
