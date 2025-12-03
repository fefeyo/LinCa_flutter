import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';

import '../model/user.dart';
import 'firestore_repository.dart';

class UserEventRepository extends FirestoreRepository<UnOfficialEvent> {
  UserEventRepository({
    required super.uid,
    required super.fireStore,
    required super.preferences,
  });

  @override
  Future<List<UnOfficialEvent>> fetch() async {
    if (uid == null) return <UnOfficialEvent>[];

    final DateTime? lastUpdatedAt =
        await preferences.getLastUpdatedAt(AppConstants.friendLastFetchedAtKey);
    final Query<Map<String, dynamic>> userEventsQuery =
        fireStore.collection(AppConstants.userEventPath).where(
              Filter.or(
                Filter('visibility', isEqualTo: true),
                Filter.and(
                  Filter('visibility', isEqualTo: false),
                  Filter('createdBy', isEqualTo: uid),
                ),
              ),
            );
    final QuerySnapshot<Map<String, dynamic>> cacheSnapshot =
        await userEventsQuery.get(const GetOptions(source: Source.cache));
    final List<UnOfficialEvent> cacheResult = cacheSnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            UnOfficialEvent.fromJson(
                <String, dynamic>{...doc.data(), 'id': doc.id}))
        .toList();
    final List<UnOfficialEvent> result = <UnOfficialEvent>[...cacheResult];
    try {
      final QuerySnapshot<Map<String, dynamic>> serverSnapshot =
          await userEventsQuery
              .where('updatedAt', isGreaterThan: lastUpdatedAt)
              .get();
      final List<UnOfficialEvent> serverResult = serverSnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              UnOfficialEvent.fromJson(
                  <String, dynamic>{...doc.data(), 'id': doc.id}))
          .toList();
      result.addAll(serverResult);
      preferences.updateLastUpdatedAt(AppConstants.friendLastFetchedAtKey);
    } catch (e) {
      return <UnOfficialEvent>[];
    }

    return result;
  }

  @override
  Future<List<UnOfficialEvent>> get() async {
    final Query<Map<String, dynamic>> userEventsQuery =
        fireStore.collection(AppConstants.userEventPath);
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await userEventsQuery.get(const GetOptions(source: Source.cache));
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            UnOfficialEvent.fromJson(
                <String, dynamic>{...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> registerEvent({
    required UnOfficialEvent event,
    required User user,
    required String documentId,
  }) async {
    final DocumentReference<Map<String, dynamic>> document =
        fireStore.collection(AppConstants.userEventPath).doc(documentId);
    await document.set(<String, dynamic>{
      ...event.toJson(),
      'updatedAt': FieldValue.serverTimestamp()
    });
  }

  Future<void> deleteEvent({
    required UnOfficialEvent event,
  }) async {
    final DocumentReference<Map<String, dynamic>> document =
        fireStore.collection(AppConstants.userEventPath).doc(event.id);
    await document.delete();
  }
}
