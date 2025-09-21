import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../constants/app_constants.dart';
import '../model/linca_badge.dart';
import '../providers.dart';
import '../repository/badge_repository.dart';

class BadgeController extends AsyncNotifier<List<LincaBadge>> {
  late BadgeRepository badgeRepository;

  @override
  FutureOr<List<LincaBadge>> build() async {
    badgeRepository = ref.read(badgeRepositoryProvider);
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    List<LincaBadge> badges = await getBadges();
    if (preferences.getString(AppConstants.badgeVersionKey) ==
        packageInfo.version) {
      badges = await fetchBadges();
      await preferences.setString(
          AppConstants.badgeVersionKey, packageInfo.version);
    }

    return badges;
  }

  Future<List<LincaBadge>> fetchBadges() => badgeRepository.fetchBadges();

  Future<List<LincaBadge>> getBadges() => badgeRepository.getBadges();
}
