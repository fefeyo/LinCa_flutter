import 'package:cloud_firestore/cloud_firestore.dart';

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
          'artistIds':<String>[],
          'badgeIds': <String>[],
          'links': <String, String>{
            'x': '',
            'instagram': '',
            'bluesky': ''
          },
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.update(document,
            <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()});
      }
    });
  }
}
