import 'dart:async';

import 'package:fefeyo_flutter_template/core/network/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../model/group.dart';
import '../repository/group_repository.dart';

class GroupController extends AsyncNotifier<List<Group>> {
  late GroupRepository groupRepository;

  @override
  FutureOr<List<Group>> build() async {
    groupRepository = ref.read(groupRepositortyProvider);
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    List<Group> groups = await getGroups();
    if (preferences.getString(AppConstants.groupVersionKey) !=
        packageInfo.version || groups.isEmpty) {
      groups = await fetchGroups();
      await preferences.setString(
          AppConstants.groupVersionKey, packageInfo.version);
    }

    return groups;
  }

  Future<List<Group>> fetchGroups() => groupRepository.fetchGroups();

  Future<List<Group>> getGroups() => groupRepository.getGroups();
}
