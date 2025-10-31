import 'package:collection/collection.dart';

import '../network/model/tag.dart';

extension TagExtension on List<Tag> {
  List<Tag> get typeTags => where((Tag tag) => !tag.slug.startsWith('series_'))
      .sorted((Tag a, Tag b) => a.order.compareTo(b.order))
      .toList();

  List<Tag> get seriesTags => where((Tag tag) => tag.slug.startsWith('series_'))
      .sorted((Tag a, Tag b) => a.order.compareTo(b.order))
      .toList();

  Tag? get priorityTypeTag => typeTags
      .sorted((Tag a, Tag b) => b.order.compareTo(a.order))
      .firstOrNull;
}
