import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../model/tag.dart';
import '../providers.dart';
import '../repository/tag_repository.dart';

class TagController extends AsyncNotifier<List<Tag>> {
  late TagRepository tagRepository;

  @override
  FutureOr<List<Tag>> build() async {
    tagRepository = ref.read(tagRepositoryProvider);
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    List<Tag> tags = await getTags();
    if (preferences.getString(AppConstants.tagVersionKey) !=
            packageInfo.version ||
        tags.isEmpty) {
      tags = await fetchTags();
      await preferences.setString(
          AppConstants.tagVersionKey, packageInfo.version);
    }

    return tags;
  }

  Future<List<Tag>> fetchTags() => tagRepository.fetchTags();

  Future<List<Tag>> getTags() => tagRepository.getTags();
}
