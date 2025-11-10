import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/controller/linca_controller.dart';

import '../model/group.dart';
import '../providers.dart';
import '../repository/group_repository.dart';

class GroupController extends LincaController<List<Group>> {
  late GroupRepository groupRepository;

  @override
  FutureOr<List<Group>> buildImpl() async {
    groupRepository = ref.read(groupRepositoryProvider);
    final List<Group> groups = await groupRepository.get();

    if (groups.isNotEmpty) {
      _refreshInBackground();
    } else {
      groups.addAll(await groupRepository.fetch());
    }

    return groups;
  }

  Future<void> _refreshInBackground() async {
    try {
      final List<Group> updated = await groupRepository.fetch();

      // 🔄 差分がある場合のみ state 更新
      if (updated.isNotEmpty) {
        final List<Group> current = state.value ?? <Group>[];
        state = AsyncValue<List<Group>>.data(
            <Group>[...current, ...updated]);
      }
    } catch (error, stacktrace) {
      state = AsyncValue<List<Group>>.error(error, stacktrace);
    }
  }
}
