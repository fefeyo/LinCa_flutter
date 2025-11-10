import 'package:linca_otaku_support/core/constants/app_constants.dart';

import '../model/venue.dart';
import 'firestore_repository.dart';

class VenueRepository extends FirestoreRepository<Venue> {
  VenueRepository({
    required super.uid,
    required super.fireStore,
    required super.preferences,
  });

  @override
  Future<List<Venue>> fetch() => fetchAll(
        collectionPath: AppConstants.venuePath,
        lastUpdatedAtKey: AppConstants.venueLastUpdatedAtKey,
        fromJson: (Map<String, dynamic> json) => Venue.fromJson(json),
      );

  @override
  Future<List<Venue>> get() => fetchAllFromCache(
        collectionPath: AppConstants.venuePath,
        fromJson: (Map<String, dynamic> json) => Venue.fromJson(json),
      );
}
