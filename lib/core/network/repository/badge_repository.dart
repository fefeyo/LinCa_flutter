import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../../env/env.dart';
import '../model/linca_badge.dart';
import 'firestore_repository.dart';

class BadgeRepository extends FirestoreRepository<LincaBadge> {
  BadgeRepository(super.fireStore);

  Future<List<String>> acuqiredBadgeIds(String uid) async {
    final QuerySnapshot<Map<String, dynamic>> result =
        await fireStore.collection('users').doc(uid).collection('badges').get();
    return result.docs
        .map((DocumentSnapshot<Map<String, dynamic>> doc) => doc.id)
        .toList();
  }

  Future<List<LincaBadge>> _fetchBadges() => fetchAll(
      'badges', (Map<String, dynamic> json) => LincaBadge.fromJson(json));

  Future<List<LincaBadge>> _getBadges() => fetchAllFromCache(
      'badges', (Map<String, dynamic> json) => LincaBadge.fromJson(json));

  Future<List<LincaBadge>> loadBadges() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final PackageInfo info = await PackageInfo.fromPlatform();

    List<LincaBadge> badges = await _getBadges();

    if (preferences.getString(AppConstants.badgeVersionKey) != info.version ||
        badges.isEmpty ||
        Env.flavor != 'prod') {
      badges = await _fetchBadges();
      await preferences.setString(AppConstants.badgeVersionKey, info.version);
    }

    return badges;
  }
}
