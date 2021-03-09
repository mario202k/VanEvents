import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:meta/meta.dart';

class FirestoreService {
  FirestoreService._();

  static final instance = FirestoreService._();

  Future<void> setData({
    @required String path,
    @required Map<String, dynamic> data,
  }) async {
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.set(data, SetOptions(merge: true));
  }

  Future<void> updateData({
    @required String path,
    @required Map<String, dynamic> data,
  }) async {
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.update(data);
  }

  Future<void> deleteDoc({@required String path}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.delete();
  }


  Stream<List<T>> collectionStream<T>({
    @required String path,
    T Function(Map<String, dynamic> data) builder,
    Query Function(Query query) queryBuilder,
    int Function(T lhs, T rhs) sort,
  }) {
    Query query = FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Stream<QuerySnapshot> snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data()))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  Future<List<T>> collectionFuture<T>({
    @required String path,
    T Function(Map<String, dynamic> data) builder,
    Query Function(Query query) queryBuilder,
    int Function(T lhs, T rhs) sort,
  }) async {
    Query query = FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final QuerySnapshot docs = await query.get();

    final result = docs.docs
        .map((e) => builder(e.data()))
        .where((element) => element != null)
        .toList();

    if (sort != null) {
      result.sort(sort);
    }

    return result;
  }

  Future<T> getDoc<T>({
    @required String path,
    T Function(Map<String, dynamic> data) builder,
  }) async {
    final DocumentReference reference = FirebaseFirestore.instance.doc(path);
    final DocumentSnapshot doc = await reference.get();
    return builder(doc.data());
  }

  Stream<T> documentStream<T>({
    @required String path,
    T Function(Map<String, dynamic> data) builder,
  }) {
    final DocumentReference reference = FirebaseFirestore.instance.doc(path);
    final Stream<DocumentSnapshot> snapshots = reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data()));
  }

  Query getQuery({@required String path, Query Function(Query query) queryBuilder}) {
    Query query = FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query;
  }

  String getDocId<T>({
    @required String path,
  }) {
    return FirebaseFirestore.instance.collection(path).doc().id;
  }

  /// Generic file upload for any [path] and [contentType]
  Future<String> uploadImg({
    @required File file,
    @required String path,
    @required String contentType,
  }) async {
    final firebase_storage.TaskSnapshot taskSnapshot = await firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child(path)
        .putFile(
            file, firebase_storage.SettableMetadata(contentType: contentType));
    return taskSnapshot.ref.getDownloadURL();
  }

  Future<void> deleteImg({
    @required String path,
    @required String contentType,
  }) async {
    return firebase_storage.FirebaseStorage.instance
        .ref()
        .child(path)
        .delete();
  }

  Future<int> nbDocuments(
      {@required String path, Query Function(Query query) queryBuilder}) async {
    Query query = FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final QuerySnapshot docs = await query.get();

    final result = docs.docs
        .where((element) => element != null).length;

    return result;
  }
}
