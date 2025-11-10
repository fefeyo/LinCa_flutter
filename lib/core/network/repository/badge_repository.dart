import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/app_constants.dart';
import '../model/linca_badge.dart';
import 'firestore_repository.dart';

class BadgeRepository extends FirestoreRepository<LincaBadge> {
  BadgeRepository({
    required super.uid,
    required super.fireStore,
    required super.preferences,
  });

  @override
  Future<List<LincaBadge>> fetch() => fetchAll(
        collectionPath: AppConstants.badgeCollectionPath,
        lastUpdatedAtKey: AppConstants.badgeLastUpdatedAtKey,
        fromJson: (Map<String, dynamic> json) => LincaBadge.fromJson(json),
      );

  @override
  Future<List<LincaBadge>> get() => fetchAllFromCache(
        collectionPath: AppConstants.badgeCollectionPath,
        fromJson: (Map<String, dynamic> json) => LincaBadge.fromJson(json),
      );

  Future<List<String>> acuqiredBadgeIds() async {
    if (uid == null) <String>[];

    final QuerySnapshot<Map<String, dynamic>> result = await fireStore
        .collection(AppConstants.userCollectionPath)
        .doc(uid)
        .collection(AppConstants.badgeCollectionPath)
        .get();
    return result.docs
        .map((DocumentSnapshot<Map<String, dynamic>> doc) => doc.id)
        .toList();
  }

  Future<void> acquireBadge(String badgeId) async {
    if (uid == null) <String>[];

    final DocumentReference<Map<String, dynamic>> document = fireStore
        .collection('users')
        .doc(uid)
        .collection('badges')
        .doc(badgeId);
    document.set(<String, dynamic>{
      'achievedAt': FieldValue.serverTimestamp(),
    });
  }
}
