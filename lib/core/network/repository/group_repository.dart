
import '../model/group.dart';
import 'firestore_repository.dart';

class GroupRepository extends FirestoreRepository<Group> {
  GroupRepository(super.fireStore);

  Future<List<Group>> fetchGroups() =>
      fetchAll('groups', (Map<String, dynamic> json) => Group.fromJson(json));

  Future<List<Group>> getGroups() => fetchAllFromCache(
      'groups', (Map<String, dynamic> json) => Group.fromJson(json));

  Future<Group> getGroupById(String id) async {
    final List<Group> groups = await getGroups();
    return groups.firstWhere((Group group) => group.id == id);
  }

  Future<Group> getGroupBySlug(String slug) async {
    final List<Group> groups = await getGroups();
    return groups.firstWhere((Group group) => group.slug == slug);
  }
}
