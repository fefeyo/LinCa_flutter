import 'dart:async';

import 'package:fefeyo_flutter_template/core/constants/app_constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../model/badge.dart';
import '../providers.dart';
import '../repository/badge_repository.dart';

class BadgeController extends AsyncNotifier<List<Badge>> {
  late BadgeRepository badgeRepository;

  @override
  FutureOr<List<Badge>> build() async {
    badgeRepository = ref.read(badgeRepositoryProvider);
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    List<Badge> badges = await getBadges();
    if (preferences.getString(AppConstants.badgeVersionKey) ==
        packageInfo.version) {
      badges = await fetchBadges();
      await preferences.setString(
          AppConstants.badgeVersionKey, packageInfo.version);
    }

    return badges;
  }

  Future<List<Badge>> fetchBadges() => badgeRepository.fetchBadges();

  Future<List<Badge>> getBadges() => badgeRepository.getBadges();
}
