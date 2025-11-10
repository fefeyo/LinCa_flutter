import 'package:linca_otaku_support/core/constants/app_constants.dart';

import '../model/event_base.dart';
import 'firestore_repository.dart';

class EventRepository extends FirestoreRepository<OfficialEvent> {
  EventRepository({
    required super.uid,
    required super.fireStore,
    required super.preferences,
  });

  @override
  Future<List<OfficialEvent>> fetch() => fetchAll(
        collectionPath: AppConstants.eventCollectionPath,
        lastUpdatedAtKey: AppConstants.eventLastUpdatedAtKey,
        fromJson: (Map<String, dynamic> json) => OfficialEvent.fromJson(json),
      );

  @override
  Future<List<OfficialEvent>> get() => fetchAllFromCache(
        collectionPath: AppConstants.eventCollectionPath,
        fromJson: (Map<String, dynamic> json) => OfficialEvent.fromJson(json),
      );
}
