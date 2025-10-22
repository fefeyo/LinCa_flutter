import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/group.dart';
import '../providers.dart';
import '../repository/group_repository.dart';

class GroupController extends AsyncNotifier<List<Group>> {
  late GroupRepository groupRepository;

  @override
  FutureOr<List<Group>> build() async {
    groupRepository = ref.read(groupRepositoryProvider);

    return groupRepository.loadGroups();
  }
}
