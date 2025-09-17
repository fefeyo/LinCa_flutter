
import '../model/event.dart';
import 'firestore_repository.dart';

class EventRepository extends FirestoreRepository<Event> {
  EventRepository(super.fireStore);

  Future<List<Event>> fetchEvents() =>
      fetchAll('events', (Map<String, dynamic> json) => Event.fromJson(json));

  Future<List<Event>> getEvents() => fetchAllFromCache(
      'events', (Map<String, dynamic> json) => Event.fromJson(json));

  Future<Event> getEventById(String id) async {
    final List<Event> events = await getEvents();
    return events.firstWhere((Event event) => event.id == id);
  }
}
