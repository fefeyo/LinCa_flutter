
import '../model/venue.dart';
import 'firestore_repository.dart';

class VenueRepository extends FirestoreRepository<Venue> {
  VenueRepository(super.fireStore);

  Future<List<Venue>> fetchVenues() =>
      fetchAll('venues', (Map<String, dynamic> json) => Venue.fromJson(json));

  Future<List<Venue>> getVenues() =>
      fetchAllFromCache(
          'venues', (Map<String, dynamic> json) => Venue.fromJson(json));

  Future<Venue> getVenueById(String id) async {
    final List<Venue> venues = await getVenues();
    return venues.firstWhere((Venue venue) => venue.id == id);
  }
}
