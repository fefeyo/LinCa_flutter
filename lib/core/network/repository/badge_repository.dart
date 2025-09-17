import '../model/badge.dart';
import 'firestore_repository.dart';

class BadgeRepository extends FirestoreRepository<Badge> {
  BadgeRepository(super.fireStore);

  Future<List<Badge>> fetchBadges() =>
      fetchAll('badges', (Map<String, dynamic> json) => Badge.fromJson(json));

  Future<List<Badge>> getBadges() => fetchAllFromCache(
      'badges', (Map<String, dynamic> json) => Badge.fromJson(json));
}
