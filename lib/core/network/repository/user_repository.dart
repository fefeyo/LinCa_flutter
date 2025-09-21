import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/user.dart';

class UserRepository {
  const UserRepository(this.fireStore);

  final FirebaseFirestore fireStore;

  DocumentReference<Map<String, dynamic>> doc(String uid) =>
      fireStore.collection('users').doc(uid);

  Future<void> ensureUserDoc(String uid,
      {String? displayName, String? photoUrl}) async {
    final DocumentReference<Map<String, dynamic>> document = doc(uid);
    await fireStore.runTransaction((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snap =
          await transaction.get(document);
      if (!snap.exists) {
        transaction.set(document, <String, Object?>{
          'displayName': '幻の学院生',
          'photoUrl': '',
          'bio': '',
          'favoriteGroups': <String>[],
          'favoriteBadges': <String>[],
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

  Future<User> getUserData(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> result =
        await fireStore.collection('users').doc(uid).get();
    final Map<String, dynamic>? data = result.data();
    if (data == null) return const User();

    return User.fromJson(data);
  }

  Future<void> updateDisplayName(String uid, String displayName) async {
    final DocumentReference<Map<String, dynamic>> document = doc(uid);
    await document.update(<String, dynamic>{
      'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
