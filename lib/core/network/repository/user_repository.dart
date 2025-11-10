import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/user.dart';

class UserRepository {
  const UserRepository({
    required this.fireStore,
    required this.uid,
  });

  final FirebaseFirestore fireStore;
  final String? uid;

  DocumentReference<Map<String, dynamic>> doc(String uid) =>
      fireStore.collection('users').doc(uid);

  Future<void> ensureUserDoc({String? displayName, String? photoUrl}) async {
    if (uid == null) return;

    final DocumentReference<Map<String, dynamic>> document = doc(uid!);
    await fireStore.runTransaction((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snap =
          await transaction.get(document);
      if (!snap.exists) {
        transaction.set(document, <String, Object?>{
          'displayName': '',
          'photoUrl': '',
          'bio': '',
          'favoriteGroups': <String>[],
          'favoriteBadges': <String>['', '', ''],
          'links': <String, String>{'x': '', 'instagram': '', 'bluesky': ''},
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.update(document,
            <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()});
      }
    });
  }

  Future<User> fetchUserData(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> result =
        await fireStore.collection('users').doc(uid).get();
    final Map<String, dynamic>? data = result.data();
    if (data == null) return const User();

    return User.fromJson(data).copyWith(id: uid);
  }

  Future<void> updateDisplayName(String displayName) async {
    if (uid == null) return;

    final DocumentReference<Map<String, dynamic>> document = doc(uid!);
    await document.update(<String, dynamic>{
      'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserPhoto(String photoUrl) async {
    if (uid == null) return;

    final DocumentReference<Map<String, dynamic>> document = doc(uid!);
    await document.update(<String, dynamic>{
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserData(User user) async {
    if (uid == null) return;

    final DocumentReference<Map<String, dynamic>> document = doc(uid!);
    await document.update(<String, dynamic>{
      ...user.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
