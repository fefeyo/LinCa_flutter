import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreRepository<T> {
  FirestoreRepository(this.fireStore);

  final FirebaseFirestore fireStore;

  /// ================================
  /// 通常：サーバーからデータ取得
  /// ================================
  Future<List<T>> fetchAll(
      String collectionPath,
      T Function(Map<String, dynamic> json) fromJson,
      ) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await fireStore.collection(collectionPath).get();
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
        fromJson(<String, dynamic>{...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<T?> fetchOne(
      String collectionPath,
      String id,
      T Function(Map<String, dynamic> json) fromJson,
      ) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
    await fireStore.collection(collectionPath).doc(id).get();
    if (!snapshot.exists) return null;
    return fromJson(<String, dynamic>{...snapshot.data()!, 'id': snapshot.id});
  }

  /// ================================
  /// キャッシュ：ローカルからデータ取得
  /// ================================
  Future<List<T>> fetchAllFromCache(
      String collectionPath,
      T Function(Map<String, dynamic> json) fromJson,
      ) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await fireStore.collection(collectionPath).get(
      const GetOptions(source: Source.cache),
    );
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
        fromJson(<String, dynamic>{...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<T?> fetchOneFromCache(
      String collectionPath,
      String id,
      T Function(Map<String, dynamic> json) fromJson,
      ) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
    await fireStore.collection(collectionPath).doc(id).get(
      const GetOptions(source: Source.cache),
    );
    if (!snapshot.exists) return null;
    return fromJson(<String, dynamic>{...snapshot.data()!, 'id': snapshot.id});
  }


}
