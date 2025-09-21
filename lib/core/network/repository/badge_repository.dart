import '../model/linca_badge.dart';
import 'firestore_repository.dart';

class BadgeRepository extends FirestoreRepository<LincaBadge> {
  BadgeRepository(super.fireStore);

  Future<List<LincaBadge>> fetchBadges() => fetchAll(
      'badges', (Map<String, dynamic> json) => LincaBadge.fromJson(json));

  Future<List<LincaBadge>> getBadges() => fetchAllFromCache(
      'badges', (Map<String, dynamic> json) => LincaBadge.fromJson(json));
}
