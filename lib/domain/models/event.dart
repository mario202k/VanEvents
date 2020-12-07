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
      'id': this.id,
      'titre': this.titre,
      'description': this.description,
      'imageFlyerUrl': this.imageFlyerUrl,
      'imageBannerUrl': this.imageBannerUrl,
      'imagePhotos': this.imagePhotos,
      'dateDebut': this.dateDebut,
      'dateFin': this.dateFin,
      'adresseZone': this.adresseZone,
      'adresseRue': this.adresseRue,
      'chatId': this.chatId,
      'status': this.status,
      'genres': this.genres,
      'types': this.types,
      'stripeAccount': this.stripeAccount,
      'dateFinAffiche': this.dateFinAffiche,
      'dateDebutAffiche': this.dateDebutAffiche,
      'position': this.position,
      'uploadedDate':this.uploadedDate
    };
  }

  factory MyEvent.fromMap(Map<String, dynamic> map) {
    Timestamp dateDebut = map['dateDebut'] ?? '';
    Timestamp dateFin = map['dateFin'] ?? '';
    Timestamp dateFinAffiche = map['dateFinAffiche'] ?? null;
    Timestamp dateDebutAffiche = map['dateDebutAffiche'] ?? null;
    Timestamp uploadedDate = map['uploadedDate'] ?? null;
    Map geo = map['position'] as Map;
    GeoPoint coords = geo['geopoint'];

    return MyEvent(
        id: map['id'] as String ?? '',
        titre: map['titre'] as String ?? '',
        description: map['description'] as String,
        imageFlyerUrl: map['imageFlyerUrl'] as String ?? '',
        imageBannerUrl: map['imageBannerUrl'] as String ?? '',
        imagePhotos: map['imagePhotos'] as List,
        dateDebut: dateDebut.toDate(),
        dateFin: dateFin.toDate(),
        adresseZone: map['adresseZone'] as List,
        adresseRue: map['adresseRue'],
        chatId: map['chatId'] as String,
        status: map['status'] as String,
        genres: map['genres'] as List,
        types: map['types'] as List,
        stripeAccount: map['stripeAccount'],
        position: coords,
        uploadedDate : uploadedDate?.toDate() ?? null,
        dateFinAffiche: dateFinAffiche != null ? dateFinAffiche.toDate() : null,
        dateDebutAffiche:
            dateDebutAffiche != null ? dateDebutAffiche.toDate() : null);
  }
}
