import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linca_otaku_support/core/network/repository/firestore_repository.dart';

import '../model/user.dart';

class FriendRepository extends FirestoreRepository<User> {
  FriendRepository(super.fireStore);

  Future<void> registerFriend(String uid, String friendUid) async {
    final FieldValue date = FieldValue.serverTimestamp();
    // 自分の友達リストに追加
    final DocumentReference<Map<String, dynamic>> document = fireStore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .doc(friendUid);
    await document.set(<String, dynamic>{
      'addedAt': date,
    });

    // 友達の友達リストに追加
    final DocumentReference<Map<String, dynamic>> friendDocument = fireStore
        .collection('users')
        .doc(friendUid)
        .collection('friends')
        .doc(uid);
    await friendDocument.set(<String, dynamic>{
      'addedAt': date,
    });
  }

  Future<List<User>> fetchFriends(String uid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .get();

    final List<String> friendUids = snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.id)
        .toList();

    if (friendUids.isEmpty) return <User>[];

    // 注意：whereIn の配列のサイズに制限があるので次節を参照
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendUids)
        .get();

    final List<User> friends = querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            User.fromJson(doc.data()))
        .toList();

    return friends;
  }
}
