import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linca_otaku_support/core/network/repository/firestore_repository.dart';
import 'package:linca_otaku_support/core/utils/preferences_service.dart';
import 'package:mocktail/mocktail.dart';

class _Item {
  const _Item(this.id, this.value);

  final String id;
  final String value;
}

class _MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class _MockPreferencesService extends Mock implements PreferencesService {}

class _FakeRepository extends FirestoreRepository<_Item> {
  _FakeRepository({
    required this.cached,
    required this.fetched,
  }) : super(
          uid: null,
          fireStore: _MockFirebaseFirestore(),
          preferences: _MockPreferencesService(),
        );

  final List<_Item> cached;
  final List<_Item> fetched;
  int cacheReadCount = 0;
  int serverFetchCount = 0;

  @override
  Future<List<_Item>> fetch() async {
    serverFetchCount += 1;
    return fetched;
  }

  @override
  Future<List<_Item>> get() async {
    cacheReadCount += 1;
    return cached;
  }
}

void main() {
  group('FirestoreRepository.getLatest', () {
    test('merges a single server fetch into cached data', () async {
      final _FakeRepository repository = _FakeRepository(
        cached: const <_Item>[
          _Item('updated', 'old'),
          _Item('cached', 'cached'),
        ],
        fetched: const <_Item>[
          _Item('updated', 'new'),
          _Item('new', 'new'),
        ],
      );

      final List<_Item> result = await repository.getLatest(
        getId: (_Item item) => item.id,
      );

      expect(repository.cacheReadCount, 1);
      expect(repository.serverFetchCount, 1);
      expect(
        result.map((_Item item) => '${item.id}:${item.value}'),
        <String>['updated:new', 'cached:cached', 'new:new'],
      );
    });

    test('returns cached data when the server has no updates', () async {
      final _FakeRepository repository = _FakeRepository(
        cached: const <_Item>[_Item('cached', 'cached')],
        fetched: const <_Item>[],
      );

      final List<_Item> result = await repository.getLatest(
        getId: (_Item item) => item.id,
      );

      expect(repository.cacheReadCount, 1);
      expect(repository.serverFetchCount, 1);
      expect(result.single.value, 'cached');
    });

    test('uses one server fetch when the cache is empty', () async {
      final _FakeRepository repository = _FakeRepository(
        cached: const <_Item>[],
        fetched: const <_Item>[_Item('new', 'new')],
      );

      final List<_Item> result = await repository.getLatest(
        getId: (_Item item) => item.id,
      );

      expect(repository.cacheReadCount, 1);
      expect(repository.serverFetchCount, 1);
      expect(result.single.value, 'new');
    });
  });
}
