import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/network/controller/linca_controller.dart';
import '../model/tag.dart';
import '../providers.dart';
import '../repository/tag_repository.dart';

class TagController extends LincaController<List<Tag>> {
  late TagRepository tagRepository;

  @override
  FutureOr<List<Tag>> buildImpl() async {
    tagRepository = ref.read(tagRepositoryProvider);
    final List<Tag> tags = await tagRepository.get();

    if (tags.isNotEmpty) {
      _refreshInBackground();
    } else {
      tags.addAll(await tagRepository.fetch());
    }

    tags.sort((Tag tagA, Tag tabB) => tagA.order.compareTo(tabB.order));

    return tags.toSet().toList();
  }

  Future<void> _refreshInBackground() async {
    try {
      final List<Tag> updated = await tagRepository.fetch();

      // 🔄 差分がある場合のみ state 更新
      if (updated.isNotEmpty) {
        final List<Tag> current = state.value ?? <Tag>[];

        final Map<String, Tag> map = <String, Tag>{
          for (final Tag tag in current) tag.id: tag,
        };

        for (final Tag tag in updated) {
          map[tag.id] = tag;
        }

        state = AsyncValue<List<Tag>>.data(map.values.toList());
      }
    } catch (error, stacktrace) {
      state = AsyncValue<List<Tag>>.error(error, stacktrace);
    }
  }
}
