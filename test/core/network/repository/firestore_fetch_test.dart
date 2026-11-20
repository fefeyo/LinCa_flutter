// Firestore interfaces are mocked only at the SDK boundary in these tests.
// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linca_otaku_support/core/network/repository/firestore_repository.dart';
import 'package:linca_otaku_support/core/utils/preferences_service.dart';
import 'package:mocktail/mocktail.dart';

class _Store extends Mock implements FirebaseFirestore {}

class _Collection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _Snapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}

class _Document extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class _Preferences extends Mock implements PreferencesService {}

class _Repository extends FirestoreRepository<String> {
  _Repository(FirebaseFirestore store, PreferencesService prefs)
      : super(uid: 'user', fireStore: store, preferences: prefs);

  @override
  Future<List<String>> get() async => <String>[];

  @override
  Future<List<String>> fetch() => fetchAll(
        collectionPath: 'participations',
        lastUpdatedAtKey: 'cursor',
        fromJson: (Map<String, dynamic> json) => json['id'] as String,
      );
}

void main() {
  late _Store store;
  late _Collection collection;
  late _Snapshot snapshot;
  late _Preferences preferences;
  late _Repository repository;
  final DateTime latest = DateTime(2026, 11, 20);

  setUp(() {
    store = _Store();
    collection = _Collection();
    snapshot = _Snapshot();
    preferences = _Preferences();
    repository = _Repository(store, preferences);
    when(() => store.collection('participations')).thenReturn(collection);
    when(() => collection.where('updatedAt', isGreaterThan: null))
        .thenReturn(collection);
    when(() => collection.get()).thenAnswer((_) async => snapshot);
    when(() => preferences.getLastUpdatedAt('cursor'))
        .thenAnswer((_) async => null);
    when(() => preferences.updateLastUpdatedAt('cursor', latest))
        .thenAnswer((_) async {});
  });

  void documents(List<Object?> timestamps) {
    final List<_Document> docs = <_Document>[];
    for (int i = 0; i < timestamps.length; i++) {
      final _Document doc = _Document();
      when(() => doc.id).thenReturn('event-$i');
      when(() => doc.data()).thenReturn(<String, dynamic>{
        if (timestamps[i] != null) 'updatedAt': timestamps[i],
      });
      docs.add(doc);
    }
    when(() => snapshot.docs).thenReturn(docs);
  }

  for (final Object? legacy in <Object?>[null, 'old-date-format']) {
    test('first uncached fetch retains legacy data: $legacy', () async {
      documents(<Object?>[legacy, Timestamp.fromDate(latest)]);
      expect(await repository.getLatest(getId: (String id) => id),
          <String>['event-0', 'event-1']);
      verify(() => collection.get()).called(1);
      verifyNever(() => preferences.updateLastUpdatedAt('cursor', latest));
    });
  }

  test('valid timestamps keep the latest cursor and one request', () async {
    documents(<Object?>[
      Timestamp.fromDate(latest.subtract(const Duration(days: 1))),
      Timestamp.fromDate(latest),
    ]);
    expect(await repository.fetch(), <String>['event-0', 'event-1']);
    verify(() => preferences.updateLastUpdatedAt('cursor', latest)).called(1);
    verify(() => collection.get()).called(1);
  });

  test('empty response leaves cursor unchanged', () async {
    documents(<Object?>[]);
    expect(await repository.fetch(), isEmpty);
    verifyNever(() => preferences.updateLastUpdatedAt('cursor', latest));
  });

  test('cursor persistence failure does not discard fetched data', () async {
    documents(<Object?>[Timestamp.fromDate(latest)]);
    when(() => preferences.updateLastUpdatedAt('cursor', latest))
        .thenThrow(StateError('storage unavailable'));
    expect(await repository.fetch(), <String>['event-0']);
    verify(() => collection.get()).called(1);
  });
}
