import '../model/event_base.dart';
import 'firestore_repository.dart';

class EventRepository extends FirestoreRepository<OfficialEvent> {
  EventRepository(super.fireStore);

  Future<List<OfficialEvent>> fetchEvents() => fetchAll(
      'events', (Map<String, dynamic> json) => OfficialEvent.fromJson(json));

  Future<List<OfficialEvent>> getEvents() => fetchAllFromCache(
      'events', (Map<String, dynamic> json) => OfficialEvent.fromJson(json));
}
