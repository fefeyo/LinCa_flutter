import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';

import '../model/user.dart';
import 'firestore_repository.dart';

class UserEventRepository extends FirestoreRepository<UnOfficialEvent> {
  UserEventRepository({
    required super.uid,
    required super.fireStore,
    required super.preferences,
  });

  @override
  Future<List<UnOfficialEvent>> fetch() async {
    if (uid == null) return <UnOfficialEvent>[];

    final DateTime? lastUpdatedAt = await preferences
        .getLastUpdatedAt(AppConstants.userEventLastFetchedAtKey);

    final CollectionReference<Map<String, dynamic>> col =
        fireStore.collection(AppConstants.userEventPath);

    // -----------------------------
    // ① キャッシュフェッチ（public + private）
    // -----------------------------
    final QuerySnapshot<Map<String, dynamic>> publicCacheSnapshot = await col
        .where('visibility', isEqualTo: true)
        .get(const GetOptions(source: Source.cache));

    final QuerySnapshot<Map<String, dynamic>> privateCacheSnapshot = await col
        .where('visibility', isEqualTo: false)
        .where('createdBy', isEqualTo: uid)
        .get(const GetOptions(source: Source.cache));

    final List<UnOfficialEvent> cacheResult = <UnOfficialEvent>[
      ...publicCacheSnapshot.docs.map(toEvent),
      ...privateCacheSnapshot.docs.map(toEvent),
    ];

    // -----------------------------
    // ② サーバーフェッチ（差分 only）
    // -----------------------------
    List<UnOfficialEvent> serverResult = <UnOfficialEvent>[];

    try {
      // 公開イベントの差分
      final QuerySnapshot<Map<String, dynamic>> publicServerSnapshot = await col
          .where('visibility', isEqualTo: true)
          .where('updatedAt', isGreaterThan: lastUpdatedAt)
          .get();

      // 自分の非公開イベントの差分
      final QuerySnapshot<Map<String, dynamic>> privateServerSnapshot =
          await col
              .where('visibility', isEqualTo: false)
              .where('createdBy', isEqualTo: uid)
              .where('updatedAt', isGreaterThan: lastUpdatedAt)
              .get();

      serverResult = <UnOfficialEvent>[
        ...publicServerSnapshot.docs.map(toEvent),
        ...privateServerSnapshot.docs.map(toEvent),
      ];

      int cacheReadCount = 0;
      int serverReadCount = 0;

      cacheReadCount =
          publicCacheSnapshot.docs.length + privateCacheSnapshot.docs.length;

      serverReadCount =
          publicServerSnapshot.docs.length + privateServerSnapshot.docs.length;

      debugPrint(
        '[Firestore READ][user_events] '
        'cache=$cacheReadCount '
        'server=$serverReadCount',
      );

      // 最後に同期時間を更新
      preferences.updateLastUpdatedAt(AppConstants.userEventLastFetchedAtKey);
    } catch (e) {
      return <UnOfficialEvent>[];
    }

    // -----------------------------
    // ③ 統合 + 重複排除（ID による）
    // -----------------------------
    final Map<String, UnOfficialEvent> merged = <String, UnOfficialEvent>{
      for (final UnOfficialEvent e in <UnOfficialEvent>[
        ...cacheResult,
        ...serverResult
      ])
        e.id: e
    };

    return merged.values
        .where((UnOfficialEvent event) => !event.deleted)
        .toList();
  }

  UnOfficialEvent toEvent(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return UnOfficialEvent.fromJson(
      <String, dynamic>{...doc.data(), 'id': doc.id},
    );
  }

  @override
  Future<List<UnOfficialEvent>> get() async {
    final Query<Map<String, dynamic>> userEventsQuery =
        fireStore.collection(AppConstants.userEventPath);
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await userEventsQuery.get(const GetOptions(source: Source.cache));
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            UnOfficialEvent.fromJson(
                <String, dynamic>{...doc.data(), 'id': doc.id}))
        .where((UnOfficialEvent event) => !event.deleted)
        .toList();
  }

  Future<void> registerEvent({
    required UnOfficialEvent event,
    required User user,
    required String documentId,
  }) async {
    final DocumentReference<Map<String, dynamic>> document =
        fireStore.collection(AppConstants.userEventPath).doc(documentId);
    await document.set(<String, dynamic>{
      ...event.toJson(),
      'updatedAt': FieldValue.serverTimestamp()
    });
  }

  Future<void> deleteEvent({
    required UnOfficialEvent event,
  }) async {
    final DocumentReference<Map<String, dynamic>> document =
        fireStore.collection(AppConstants.userEventPath).doc(event.id);
    await document.set(<String, dynamic>{
      ...event.toJson(),
      'deleted': true,
      'updatedAt': FieldValue.serverTimestamp()
    });
  }

  Future<void> deleteMyPrivateEvents(String? userId) async {
    if (userId == null) return;

    final CollectionReference<Map<String, dynamic>> col =
        fireStore.collection(AppConstants.userEventPath);

    final QuerySnapshot<Map<String, dynamic>> privateSnapshot = await col
        .where('visibility', isEqualTo: false)
        .where('createdBy', isEqualTo: userId)
        .get();

    final WriteBatch batch = fireStore.batch();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in privateSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
