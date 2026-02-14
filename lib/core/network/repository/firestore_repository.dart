import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:linca_otaku_support/core/utils/preferences_service.dart';

abstract class FirestoreRepository<T> {
  FirestoreRepository({
    required this.uid,
    required this.fireStore,
    required this.preferences,
  });

  final String? uid;
  final FirebaseFirestore fireStore;
  final PreferencesService preferences;

  Future<List<T>> fetch();

  Future<List<T>> get();

  /// ================================
  /// 通常：サーバーからデータ取得
  /// ================================
  Future<List<T>> fetchAll({
    required String collectionPath,
    String? lastUpdatedAtKey,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    Query<Map<String, dynamic>> query = fireStore.collection(collectionPath);

    if (lastUpdatedAtKey != null) {
      final DateTime? lastUpdatedAt =
          await preferences.getLastUpdatedAt(lastUpdatedAtKey);
      query = query.where('updatedAt', isGreaterThan: lastUpdatedAt);
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await query.get();

      final int readCount = querySnapshot.docs.length;

      debugPrint(
        '[Firestore READ] '
        'collection=$collectionPath '
        'read=$readCount '
        'diffFetch=${lastUpdatedAtKey != null}',
      );

      final List<T> updatedResult = querySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              fromJson(<String, dynamic>{...doc.data(), 'id': doc.id}))
          .toList();

      if (lastUpdatedAtKey != null) {
        preferences.updateLastUpdatedAt(lastUpdatedAtKey);
      }

      return updatedResult;
    } catch (e) {
      return <T>[];
    }
  }

  /// ================================
  /// キャッシュ：ローカルからデータ取得
  /// ================================
  Future<List<T>> fetchAllFromCache({
    required String collectionPath,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> querySnapShot = await fireStore
        .collection(collectionPath)
        .get(const GetOptions(source: Source.cache));

    return querySnapShot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            fromJson(<String, dynamic>{...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> refreshInBackground({
    required List<T> current,
    required List<T> updated,
    required String Function(T item) getId,
    required Function(List<T> merged) onChanged,
  }) async {
    try {
      if (updated.isEmpty) {
        onChanged(current);
        return;
      }

      final Map<String, T> merged = <String, T>{
        for (final T item in current) getId(item): item,
        for (final T item in updated) getId(item): item,
      };

      onChanged(merged.values.toList());
    } catch (_) {
      onChanged(current);
    }
  }
}
