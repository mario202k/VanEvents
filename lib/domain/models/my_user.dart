import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final myUserProvider = Provider<MyUser>((ref) {
  return MyUser();
});
enum TypeOfAccount { userNormal, organizer }

class MyUser {
  String id;
  String email;
  String imageUrl, idRectoUrl, idVersoUrl, proofOfAddress;
  bool isLogin;
  DateTime lastActivity;
  String nom;
  List genres;
  List types;
  TypeOfAccount typeDeCompte;
  String stripeAccount;
  String person;
  bool hasAcceptedCGUCGV;
  List lieu;
  List quand;
  GeoPoint geoPoint;
  List blockedUser;

  MyUser(
      {this.id,
      this.email,
      this.imageUrl,
      this.idRectoUrl,
      this.idVersoUrl,
      this.proofOfAddress,
      this.isLogin,
      this.lastActivity,
      this.nom,
      this.types,
      this.genres,
      this.typeDeCompte,
      this.stripeAccount,
      this.person,
      this.hasAcceptedCGUCGV,
      this.lieu,
      this.quand,
      this.geoPoint,
      this.blockedUser});

  Map<String, dynamic> toMap() {
    switch (typeDeCompte) {
      case TypeOfAccount.userNormal:
        return {
          'id': id,
          'email': email,
          'imageUrl': imageUrl,
          'isLogin': isLogin,
          'lastActivity': lastActivity,
          'nom': nom,
          'genres': genres,
          'types': types,
          'typeDeCompte': typeDeCompte.toString(),
          'hasAcceptedCGUCGV': hasAcceptedCGUCGV,
          'lieu': lieu,
          'quand': quand,
          'geoPoint': geoPoint,
          'blockedUser': blockedUser
        };
        break;
      default: //TypeOfAccount.organizer
        return {
          'id': id,
          'email': email,
          'imageUrl': imageUrl,
          'idRectoUrl': idRectoUrl,
          'idVersoUrl': idVersoUrl,
          'proofOfAddress': proofOfAddress,
          'isLogin': isLogin,
          'lastActivity': lastActivity,
          'nom': nom,
          'genres': genres,
          'types': types,
          'typeDeCompte': typeDeCompte.toString(),
          'stripeAccount': stripeAccount,
          'person': person,
          'hasAcceptedCGUCGV': hasAcceptedCGUCGV,
          'lieu': lieu,
          'quand': quand,
          'geoPoint': geoPoint,
          'blockedUser':blockedUser
        };
        break;
    }
  }

  factory MyUser.fromMap(Map<String, dynamic> map) {
    if (map == null) {
      return null;
    }

    TypeOfAccount typeOfAccount;

    switch (map['typeDeCompte'] as String) {
      case 'TypeOfAccount.userNormal':
        typeOfAccount = TypeOfAccount.userNormal;
        break;
      case 'TypeOfAccount.organizer':
        typeOfAccount = TypeOfAccount.organizer;
        break;
    }

    return MyUser(
        id: map['id'] as String ?? '',
        email: map['email'] as String ?? '',
        imageUrl: map['imageUrl'] as String ?? '',
        idRectoUrl: map['idRectoUrl'] as String ?? '',
        idVersoUrl: map['idVersoUrl'] as String ?? '',
        proofOfAddress: map['proofOfAddress'] as String ?? '',
        isLogin: map['isLogin'] as bool ?? false,
        lastActivity:
            (map['lastActivity'] as Timestamp)?.toDate() ?? DateTime.now(),
        nom: map['nom'] as String ?? 'Anonymous',
        genres: map['genres'] as List ?? List.generate(1, (index) => null),
        types: map['types'] as List ?? List.generate(1, (index) => null),
        lieu: map['lieu'] as List ?? List.generate(1, (index) => null),
        quand: map['quand'] as List ?? List.generate(1, (index) => null),
        geoPoint: map['geoPoint'] as GeoPoint,
        typeDeCompte: typeOfAccount ?? TypeOfAccount.userNormal,
        stripeAccount: map['stripeAccount'] as String,
        person: map['person'] as String,
        hasAcceptedCGUCGV: map['hasAcceptedCGUCGV'] as bool ?? false,
        blockedUser: map['blockedUser'] as List ?? []);
  }

  void setUser(MyUser user) {
    types = user?.types;
    genres = user?.genres;
    lieu = user?.lieu;
    quand = user?.quand;
    geoPoint = user?.geoPoint;
    id = user?.id;
    email = user?.email;
    nom = user?.nom;
    imageUrl = user?.imageUrl;
    idRectoUrl = user?.idRectoUrl;
    idVersoUrl = user?.idVersoUrl;
    proofOfAddress = user?.proofOfAddress;
    lastActivity = user?.lastActivity;
    isLogin = user?.isLogin;
    typeDeCompte = user?.typeDeCompte;
    stripeAccount = user?.stripeAccount;
    person = user?.person;
    hasAcceptedCGUCGV = user?.hasAcceptedCGUCGV;
    blockedUser = user?.blockedUser;
  }

  @override
  String toString() {
    return 'MyUser{id: $id, email: $email, imageUrl: $imageUrl, idRectoUrl: $idRectoUrl, idVersoUrl: $idVersoUrl, proofOfAddress: $proofOfAddress, isLogin: $isLogin, lastActivity: $lastActivity, nom: $nom, genres: $genres, types: $types, typeDeCompte: $typeDeCompte, stripeAccount: $stripeAccount, person: $person, hasAcceptedCGUCGV: $hasAcceptedCGUCGV, lieu: $lieu, quand: $quand, geoPoint: $geoPoint, blockedUser: $blockedUser}';
  }
}
