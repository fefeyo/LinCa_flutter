import 'package:linca_otaku_support/core/constants/app_constants.dart';

import '../model/tag.dart';
import 'firestore_repository.dart';

class TagRepository extends FirestoreRepository<Tag> {
  TagRepository({
    required super.uid,
    required super.fireStore,
    required super.preferences,
  });

  @override
  Future<List<Tag>> fetch() => fetchAll(
        collectionPath: AppConstants.tagPath,
        lastUpdatedAtKey: AppConstants.tagLastUpdatedAtKey,
        fromJson: (Map<String, dynamic> json) => Tag.fromJson(json),
      );

  @override
  Future<List<Tag>> get() => fetchAllFromCache(
        collectionPath: AppConstants.tagPath,
        fromJson: (Map<String, dynamic> json) => Tag.fromJson(json),
      );
}
