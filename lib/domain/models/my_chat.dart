import 'package:cloud_firestore/cloud_firestore.dart';

class MyChat {
  final String id;
  final DateTime createdAt;
  final Map membres;
  final bool isGroupe;
  final String imageUrl;//Pour les groupes
  final String titre;//Pour lastactivity et msg read

  MyChat(
      {this.id,
      this.createdAt,
      this.membres,
      this.isGroupe,
      this.imageUrl,
      this.titre});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'createdAt': this.createdAt,
      'membres': this.membres,
      'isGroupe': this.isGroupe,
      'imageUrl': this.imageUrl,
      'titre':this.titre,

    };
  }

  factory MyChat.fromMap(Map<String, dynamic> map) {
    Timestamp createdAt = map['createdAt'] ?? Timestamp.now();

    return new MyChat(
      id: map['id'] as String,
      createdAt: createdAt.toDate(),
      membres: map['membres'] as Map?? {},
      isGroupe: map['isGroupe'] as bool ?? false,
      imageUrl: map['imageFlyerUrl'] as String ?? '',
      titre:  map['titre'] as String ?? '',
    );
  }

  @override
  String toString() {
    return 'MyChat{id: $id, createdAt: $createdAt, membres: $membres, isGroupe: $isGroupe, imageUrl: $imageUrl, titre: $titre}';
  }
}
