import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/network/repository/firestore_repository.dart';

import '../model/user.dart';

class FriendRepository extends FirestoreRepository<User> {
  FriendRepository({
    required super.uid,
    required super.fireStore,
    required super.preferences,
  });

  Future<void> registerFriend(String friendUid) async {
    if (uid == null) return;

    final FieldValue date = FieldValue.serverTimestamp();
    // 自分の友達リストに追加
    final DocumentReference<Map<String, dynamic>> document = fireStore
        .collection(AppConstants.userCollectionPath)
        .doc(uid)
        .collection(AppConstants.friendCollectionPath)
        .doc(friendUid);
    await document.set(<String, dynamic>{
      'updatedAt': date,
    });

    // 友達の友達リストに追加
    final DocumentReference<Map<String, dynamic>> friendDocument = fireStore
        .collection(AppConstants.userCollectionPath)
        .doc(friendUid)
        .collection(AppConstants.friendCollectionPath)
        .doc(uid);
    await friendDocument.set(<String, dynamic>{
      'updatedAt': date,
    });
  }

  @override
  Future<List<User>> fetch() async {
    if (uid == null) return <User>[];
    final QuerySnapshot<Map<String, dynamic>> cacheUidSnapshot = await fireStore
        .collection(AppConstants.userCollectionPath)
        .doc(uid)
        .collection(AppConstants.friendCollectionPath)
        .get(const GetOptions(source: Source.cache));

    final List<String> cacheUidResult = cacheUidSnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.id)
        .toList();

    final List<String> friendUids = <String>[
      ...cacheUidResult,
    ];

    try {
      final QuerySnapshot<Map<String, dynamic>> serverUidSnapshot =
          await fireStore
              .collection(AppConstants.userCollectionPath)
              .doc(uid)
              .collection(AppConstants.friendCollectionPath)
              .get();

      final List<String> serverUidResult = serverUidSnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.id)
          .toList();
      friendUids.addAll(serverUidResult);
      preferences.updateLastUpdatedAt(AppConstants.friendLastFetchedAtKey);
    } catch (e) {
      return <User>[];
    }

    if (friendUids.isEmpty) return <User>[];

    final Query<Map<String, dynamic>> userQuery = fireStore
        .collection(AppConstants.userCollectionPath)
        .where(FieldPath.documentId, whereIn: friendUids);

    final QuerySnapshot<Map<String, dynamic>> cacheUserSnapshot =
        await userQuery.get(const GetOptions(source: Source.cache));

    final List<User> cacheUserResult = cacheUserSnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            User.fromJson(doc.data()).copyWith(id: doc.id))
        .toList();

    final List<String> noUserDataFriendUids = friendUids
        .where(
            (String uid) => !cacheUserResult.any((User user) => user.id == uid))
        .toList();

    final List<User> friends = <User>[...cacheUserResult];

    if (noUserDataFriendUids.isNotEmpty) {
      final QuerySnapshot<Map<String, dynamic>> serverUserSnapshot =
          await fireStore
              .collection(AppConstants.userCollectionPath)
              .where(FieldPath.documentId, whereIn: noUserDataFriendUids)
              .get();

      final List<User> serverUserResult = serverUserSnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              User.fromJson(doc.data()).copyWith(id: doc.id))
          .toList();
      friends.addAll(serverUserResult);
    }

    return friends;
  }

  @override
  Future<List<User>> get() async {
    if (uid == null) return <User>[];

    final QuerySnapshot<Map<String, dynamic>> cacheUidSnapshot = await fireStore
        .collection(AppConstants.userCollectionPath)
        .doc(uid)
        .collection(AppConstants.friendCollectionPath)
        .get(const GetOptions(source: Source.cache));

    final List<String> cacheUidResult = cacheUidSnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.id)
        .toList();

    if (cacheUidResult.isEmpty) return <User>[];

    final Query<Map<String, dynamic>> userQuery = fireStore
        .collection(AppConstants.userCollectionPath)
        .where(FieldPath.documentId, whereIn: cacheUidResult);

    final QuerySnapshot<Map<String, dynamic>> cacheUserSnapshot =
        await userQuery.get(const GetOptions(source: Source.cache));

    return cacheUserSnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            User.fromJson(doc.data()).copyWith(id: doc.id))
        .toList();
  }
}
