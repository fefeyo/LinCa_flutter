import 'package:fefeyo_flutter_template/core/network/model/group.dart';
import 'package:fefeyo_flutter_template/core/network/repository/firestore_repository.dart';

class GroupRepository extends FirestoreRepository<Group> {
  GroupRepository(super.fireStore);

  Future<List<Group>> fetchGroups() =>
      fetchAll('groups', (Map<String, dynamic> json) => Group.fromJson(json));

  Future<List<Group>> getGroups() => fetchAllFromCache(
      'groups', (Map<String, dynamic> json) => Group.fromJson(json));
}
