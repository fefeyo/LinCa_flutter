import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';

import '../model/event.dart';
import '../model/user.dart';
import 'firestore_repository.dart';

class UserEventRepository extends FirestoreRepository<Event> {
  UserEventRepository(super.fireStore);

  Future<List<UnOfficialEvent>> fetchEvents(String uid) async {
    final Query<Map<String, dynamic>> userEventsQuery =
        fireStore.collection('user_events').where(
              Filter.or(
                Filter('visibility', isEqualTo: true),
                Filter.and(
                  Filter('visibility', isEqualTo: false),
                  Filter('createdBy', isEqualTo: uid),
                ),
              ),
            );
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await userEventsQuery.get();
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            UnOfficialEvent.fromJson(
                <String, dynamic>{...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<List<UnOfficialEvent>> getEvents(String uid) async {
    final Query<Map<String, dynamic>> userEventsQuery =
        fireStore.collection('user_events');
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
        fireStore.collection('user_events').doc(documentId);
    await document.set(event.toJson());
  }

  Future<void> deleteEvent({
    required UnOfficialEvent event,
  }) async {
    final DocumentReference<Map<String, dynamic>> document =
        fireStore.collection('user_events').doc(event.id);
    await document.delete();
  }
}
