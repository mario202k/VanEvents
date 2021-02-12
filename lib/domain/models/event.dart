import 'package:cloud_firestore/cloud_firestore.dart';

class MyEvent {
  final String id;
  final String titre;
  final String description;
  final String imageFlyerUrl;
  final String imageBannerUrl;
  final List imagePhotos;
  final DateTime dateDebut;
  final DateTime dateFin;
  final List adresseZone;
  final List adresseRue;
  final String chatId;
  final String status;
  final List genres;
  final List types;
  final String stripeAccount;
  final DateTime dateDebutAffiche;
  final DateTime dateFinAffiche;
  final GeoPoint position;
  final DateTime uploadedDate;

  MyEvent(
      {this.id,
      this.titre,
      this.description,
      this.imageFlyerUrl,
      this.imageBannerUrl,
      this.imagePhotos,
      this.dateDebut,
      this.dateFin,
      this.adresseZone,
      this.adresseRue,
      this.chatId,
      this.status,
      this.genres,
      this.types,
      this.stripeAccount,
      this.dateFinAffiche,
      this.dateDebutAffiche,
      this.position,
      this.uploadedDate});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'imageFlyerUrl': imageFlyerUrl,
      'imageBannerUrl': imageBannerUrl,
      'imagePhotos': imagePhotos,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'adresseZone': adresseZone,
      'adresseRue': adresseRue,
      'chatId': chatId,
      'status': status,
      'genres': genres,
      'types': types,
      'stripeAccount': stripeAccount,
      'dateFinAffiche': dateFinAffiche,
      'dateDebutAffiche': dateDebutAffiche,
      'position': position,
      'uploadedDate': uploadedDate
    };
  }

  factory MyEvent.fromMap(Map<String, dynamic> map) {
    return MyEvent(
        id: map['id'] as String ?? '',
        titre: map['titre'] as String ?? '',
        description: map['description'] as String,
        imageFlyerUrl: map['imageFlyerUrl'] as String ?? '',
        imageBannerUrl: map['imageBannerUrl'] as String ?? '',
        imagePhotos: map['imagePhotos'] as List,
        dateDebut: (map['dateDebut'] as Timestamp).toDate(),
        dateFin: (map['dateFin'] as Timestamp).toDate(),
        adresseZone: map['adresseZone'] as List,
        adresseRue: map['adresseRue'] as List,
        chatId: map['chatId'] as String,
        status: map['status'] as String,
        genres: map['genres'] as List,
        types: map['types'] as List,
        stripeAccount: map['stripeAccount'] as String,
        position: map['position']['geopoint'] as GeoPoint,
        uploadedDate: (map['uploadedDate'] as Timestamp)?.toDate(),
        dateFinAffiche: (map['dateFinAffiche'] as Timestamp)?.toDate(),
        dateDebutAffiche: (map['dateDebutAffiche'] as Timestamp)?.toDate());
  }
}
