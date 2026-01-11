import 'package:linca_otaku_support/core/constants/app_constants.dart';

import '../model/participation_info.dart';
import 'firestore_repository.dart';

class ParticipationRepository extends FirestoreRepository<ParticipationInfo> {
  ParticipationRepository({
    required super.uid,
    required super.fireStore,
    required super.preferences,
  });

  @override
  Future<List<ParticipationInfo>> fetch() async {
    if (uid == null) return <ParticipationInfo>[];

    final String path = fireStore
        .collection(AppConstants.userCollectionPath)
        .doc(uid)
        .collection(AppConstants.participationsPath)
        .path;

    return fetchAll(
      collectionPath: path,
      lastUpdatedAtKey: AppConstants.participationLastUpdatedAtKey,
      fromJson: (Map<String, dynamic> json) => ParticipationInfo.fromJson(json),
    );
  }

  @override
  Future<List<ParticipationInfo>> get() async {
    if (uid == null) return <ParticipationInfo>[];

    final String path = fireStore
        .collection(AppConstants.userCollectionPath)
        .doc(uid)
        .collection(AppConstants.participationsPath)
        .path;

    return fetchAllFromCache(
      collectionPath: path,
      fromJson: (Map<String, dynamic> json) => ParticipationInfo.fromJson(json),
    );
  }

  Future<void> update(ParticipationInfo participation) async {
    if (uid == null) return;

    await fireStore
        .collection(AppConstants.userCollectionPath)
        .doc(uid)
        .collection(AppConstants.participationsPath)
        .doc(participation.eventId)
        .set(participation.toJson());
  }

  Future<void> delete(String eventId) async {
    if (uid == null) return;

    await fireStore
        .collection(AppConstants.userCollectionPath)
        .doc(uid)
        .collection(AppConstants.participationsPath)
        .doc(eventId)
        .delete();
  }
}
