import 'dart:async';

import 'package:linca_otaku_support/core/network/controller/linca_controller.dart';

import '../model/group.dart';
import '../providers.dart';
import '../repository/group_repository.dart';

class GroupController extends LincaController<List<Group>> {
  late GroupRepository groupRepository;

  @override
  FutureOr<List<Group>> buildImpl() async {
    groupRepository = ref.read(groupRepositoryProvider);
    final List<Group> groups = await groupRepository.getLatest(
      getId: (Group group) => group.id,
    );

    groups.sort(
        (Group groupA, Group groupB) => groupA.order.compareTo(groupB.order));

    return groups.toSet().toList();
  }
}
