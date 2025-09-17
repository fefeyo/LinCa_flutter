
import '../model/tag.dart';
import 'firestore_repository.dart';

class TagRepository extends FirestoreRepository<Tag> {
  TagRepository(super.fireStore);

  Future<List<Tag>> fetchTags() =>
      fetchAll('tags', (Map<String, dynamic> json) => Tag.fromJson(json));

  Future<List<Tag>> getTags() => fetchAllFromCache(
      'tags', (Map<String, dynamic> json) => Tag.fromJson(json));

  Future<Tag> getTagById(String id) async {
    final List<Tag> tags = await getTags();
    return tags.firstWhere((Tag tag) => tag.id == id);
  }
}
