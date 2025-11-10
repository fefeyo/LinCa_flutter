import '../../constants/app_constants.dart';
import '../model/group.dart';
import 'firestore_repository.dart';

class GroupRepository extends FirestoreRepository<Group> {
  GroupRepository({
    required super.uid,
    required super.fireStore,
    required super.preferences,
  });

  @override
  Future<List<Group>> fetch() => fetchAll(
        collectionPath: AppConstants.groupCollectionPath,
        lastUpdatedAtKey: AppConstants.groupLastUpdatedAtKey,
        fromJson: (Map<String, dynamic> json) => Group.fromJson(json),
      );

  @override
  Future<List<Group>> get() => fetchAllFromCache(
        collectionPath: AppConstants.groupCollectionPath,
        fromJson: (Map<String, dynamic> json) => Group.fromJson(json),
      );
}
