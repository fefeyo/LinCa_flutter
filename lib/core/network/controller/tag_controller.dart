import 'dart:async';

import 'package:linca_otaku_support/core/network/controller/linca_controller.dart';
import '../model/tag.dart';
import '../providers.dart';
import '../repository/tag_repository.dart';

class TagController extends LincaController<List<Tag>> {
  late TagRepository tagRepository;

  @override
  FutureOr<List<Tag>> buildImpl() async {
    tagRepository = ref.read(tagRepositoryProvider);
    final List<Tag> tags = await tagRepository.getLatest(
      getId: (Tag tag) => tag.id,
    );

    tags.sort((Tag tagA, Tag tabB) => tagA.order.compareTo(tabB.order));

    return tags.toSet().toList();
  }
}
