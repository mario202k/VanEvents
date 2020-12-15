import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:meta/meta.dart';
import 'package:van_events_project/domain/models/event.dart';

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

  Future<void> deleteData({@required String path}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.delete();
  }

  Stream<List<T>> collectionStream<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data),
    Query queryBuilder(Query query),
    int sort(T lhs, T rhs),
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

  Future<List<T>> collectionFuture<T> ({
    @required String path,
    @required T builder(Map<String, dynamic> data),
    Query queryBuilder(Query query),
    int sort(T lhs, T rhs),
  }) async {
    Query query = FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final QuerySnapshot docs = await query.get();

    final result = docs.docs.map((e) => builder(e.data()))
        .where((element) => element != null).toList();

    if (sort != null) {
      result.sort(sort);
    }

    return result;
  }

  Future<T> getDoc<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data),
  }) async {
    final DocumentReference reference = FirebaseFirestore.instance.doc(path);
    final DocumentSnapshot doc = await reference.get();
    return builder(doc.data());
  }

  Stream<T> documentStream<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data),
  }) {
    final DocumentReference reference = FirebaseFirestore.instance.doc(path);
    final Stream<DocumentSnapshot> snapshots = reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data()));
  }

  Query getQuery({@required String path, Query queryBuilder(Query query)}) {
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
    String url;
    firebase_storage.TaskSnapshot taskSnapshot = await firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child(path)
        .putFile(
            file, firebase_storage.SettableMetadata(contentType: contentType));
    print('upload state: ${taskSnapshot.state}');
    url = await taskSnapshot.ref.getDownloadURL();
    return url;
  }

  Future<void> deleteImg({
    @required String path,
    @required String contentType,
  }) async {
    return await firebase_storage.FirebaseStorage.instance
        .ref()
        .child(path)
        .delete();
  }

}
