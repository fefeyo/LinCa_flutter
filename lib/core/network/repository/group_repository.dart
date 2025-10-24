import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../model/group.dart';
import 'firestore_repository.dart';

class GroupRepository extends FirestoreRepository<Group> {
  GroupRepository(super.fireStore);

  Future<List<Group>> _fetchGroups() =>
      fetchAll('groups', (Map<String, dynamic> json) => Group.fromJson(json));

  Future<List<Group>> _getGroups() => fetchAllFromCache(
      'groups', (Map<String, dynamic> json) => Group.fromJson(json));

  Future<List<Group>> loadGroups() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final PackageInfo info = await PackageInfo.fromPlatform();

    List<Group> groups = await _getGroups();

    if (preferences.getString(AppConstants.groupVersionKey) != info.version ||
        groups.isEmpty) {
      groups = await _fetchGroups();
      await preferences.setString(AppConstants.groupVersionKey, info.version);
    }
    groups.sort((Group a, Group b) => a.order.compareTo(b.order));

    return groups;
  }

  Future<Group> getGroupById(String id) async {
    final List<Group> groups = await _getGroups();
    return groups.firstWhere((Group group) => group.id == id);
  }

  Future<Group> getGroupBySlug(String slug) async {
    final List<Group> groups = await _getGroups();
    return groups.firstWhere((Group group) => group.slug == slug);
  }
}
