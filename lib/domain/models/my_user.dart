import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/all.dart';
final myUserProvider = Provider<MyUser>((ref) {
  return MyUser();
});
enum TypeOfAccount { userNormal, organizer, owner }

class MyUser {
  String id;
  String email;
  String imageUrl, idRectoUrl, idVersoUrl, proofOfAddress;
  bool isLogin;
  DateTime lastActivity;
  String nom;
  String password;
  List genres;
  List types;
  TypeOfAccount typeDeCompte;
  String stripeAccount;
  String person;
  bool hasAcceptedCGUCGV;
  List lieu;
  List quand;
  GeoPoint geoPoint;

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
      this.password,
      this.types,
      this.genres,
      this.typeDeCompte,
      this.stripeAccount,
      this.person,
      this.hasAcceptedCGUCGV,
      this.lieu,
      this.quand,
      this.geoPoint});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'email': this.email,
      'imageUrl': this.imageUrl,
      'idRectoUrl': this.idRectoUrl,
      'idVersoUrl': this.idVersoUrl,
      'proofOfAddress': this.proofOfAddress,
      'isLogin': this.isLogin,
      'lastActivity': this.lastActivity,
      'nom': this.nom,
      'password': this.password,
      'genres': this.genres,
      'types': this.types,
      'typeDeCompte': this.typeDeCompte.toString(),
      'stripeAccount': this.stripeAccount,
      'person': this.person,
      'hasAcceptedCGUCGV': this.hasAcceptedCGUCGV,
      'lieu': this.lieu,
      'quand': this.quand,
      'geoPoint': this.geoPoint,
    };
  }

  factory MyUser.fromMap(Map<String, dynamic> map) {
    if (map == null) {
      return MyUser();
    }
    Timestamp time = map['lastActivity'];

    TypeOfAccount typeOfAccount;

    switch (map['typeDeCompte'] as String) {
      case 'TypeOfAccount.owner':
        typeOfAccount = TypeOfAccount.owner;
        break;
      case 'TypeOfAccount.userNormal':
        typeOfAccount = TypeOfAccount.userNormal;
        break;
      case 'TypeOfAccount.organizer':
        typeOfAccount = TypeOfAccount.organizer;
        break;
    }

    return MyUser(
        id: map['id'] ?? '',
        email: map['email'] as String ?? '',
        imageUrl: map['imageUrl'] as String ?? '',
        idRectoUrl: map['idRectoUrl'] as String ?? '',
        idVersoUrl: map['idVersoUrl'] as String ?? '',
        proofOfAddress: map['proofOfAddress'] as String ?? '',
        isLogin: map['isLogin'] as bool ?? false,
        lastActivity: time?.toDate() ?? DateTime.now(),
        nom: map['nom'] as String ?? 'Anonymous',
        password: map['password'] as String,
        genres: map['genres'] as List ?? List.generate(1, (index) => null),
        types: map['types'] as List ?? List.generate(1, (index) => null),
        lieu: map['lieu'] as List ?? List.generate(1, (index) => null),
        quand: map['quand'] as List ?? List.generate(1, (index) => null),
        geoPoint: map['geoPoint'] as GeoPoint,
        typeDeCompte: typeOfAccount ?? TypeOfAccount.userNormal,
        stripeAccount: map['stripeAccount'] as String,
        person: map['person'] as String,
        hasAcceptedCGUCGV: map['hasAcceptedCGUCGV'] as bool ?? false);
  }

  void setUser(MyUser user) {
    this.types = user.types;
    this.genres = user.genres;
    this.lieu = user.lieu;
    this.quand = user.quand;
    this.geoPoint = user.geoPoint;
    this.id = user.id;
    this.email = user.email;
    this.password = user.password;
    this.nom = user.nom;
    this.imageUrl = user.imageUrl;
    this.idRectoUrl = user.idRectoUrl;
    this.idVersoUrl = user.idVersoUrl;
    this.proofOfAddress = user.proofOfAddress;
    this.lastActivity = user.lastActivity;
    this.isLogin = user.isLogin;
    this.typeDeCompte = user.typeDeCompte;
    this.stripeAccount = user.stripeAccount;
    this.person = user.person;
  }

  @override
  String toString() {
    return 'MyUser{id: $id, email: $email, imageUrl: $imageUrl, idRectoUrl: $idRectoUrl, idVersoUrl: $idVersoUrl, proofOfAddress: $proofOfAddress, isLogin: $isLogin, lastActivity: $lastActivity, nom: $nom, password: $password, genres: $genres, types: $types, typeDeCompte: $typeDeCompte, stripeAccount: $stripeAccount, person: $person, hasAcceptedCGUCGV: $hasAcceptedCGUCGV, lieu: $lieu, quand: $quand, geoPoint: $geoPoint}';
  }
}
