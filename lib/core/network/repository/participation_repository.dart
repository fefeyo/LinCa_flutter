import '../model/participation_info.dart';
import 'firestore_repository.dart';

class ParticipationRepository extends FirestoreRepository<ParticipationInfo> {
  ParticipationRepository(super.fireStore);

  Future<List<ParticipationInfo>> fetchParticipations(String userId) {
    final String path = fireStore
        .collection('users')
        .doc(userId)
        .collection('participations')
        .path;

    return fetchAll(
        path, (Map<String, dynamic> json) => ParticipationInfo.fromJson(json));
  }

  Future<List<ParticipationInfo>> getParticipations(String userId) {
    final String path = fireStore
        .collection('users')
        .doc(userId)
        .collection('participations')
        .path;

    return fetchAllFromCache(
        path, (Map<String, dynamic> json) => ParticipationInfo.fromJson(json));
  }

  Future<void> create(String userId, ParticipationInfo participation) async {
    await fireStore
        .collection('users')
        .doc(userId)
        .collection('participations')
        .doc(participation.eventId)
        .set(participation.toJson());
  }

  Future<void> delete(String userId, String eventId) async {
    await fireStore
        .collection('users')
        .doc(userId)
        .collection('participations')
        .doc(eventId)
        .delete();
  }
}
