import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:van_events_project/domain/models/my_chat.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/presentation/widgets/lieuQuandAlertDialog.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';

final myUserRepository = Provider<MyUserRepository>((ref) {
  return MyUserRepository();
});

final streamMyUserProvider = StreamProvider<MyUser>((ref) {

  return ref.read(myUserRepository).userStream();
});

class MyUserRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _service = FirestoreService.instance;

  String uid;

  MyUserRepository({String uid}) : this.uid = uid;

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithCredentials(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> loginAnonymous() {
    return _firebaseAuth.signInAnonymously();
  }

  Stream<List<MyUser>> chatMyUsersStream(MyChat myChat) {

    return _service.collectionStream(
        path: Path.users(),
        queryBuilder: (query)=>query.where('id', whereIn: myChat.membres.keys.toList()),
        builder: (map)=>MyUser.fromMap(map));
  }

  Future setInactive() {

    return _service.setData(
        path: Path.user(uid),
        data: {'lastActivity': FieldValue.serverTimestamp(), 'isLogin': false});
  }
  Future setOnline() {

    return _service.setData(
        path: Path.user(uid),
        data: {'lastActivity': FieldValue.serverTimestamp(), 'isLogin': true});
  }

  Future<String> signUp(
      {File image,
      String nomPrenom,
      String email,
      String password,
      TypeOfAccount typeDeCompte,
      String stripeAccount,
      String person}) async {
    String rep = 'Impossible de joindre le serveur';
    //Si l'utilisateur est bien inconnu
    await _firebaseAuth.fetchSignInMethodsForEmail(email)
        // ignore: missing_return
        .then((list) async {
      if (list.isEmpty) {
        //création du user
        await _firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((user) async {
          String uid = user.user.uid;

          if (image != null) {
            //création du path pour la photo profil
            String path = image.path.substring(image.path.lastIndexOf('/') + 1);

            //création de l'url pour la photo profil
            await _service
                .uploadImg(file: image, path: "/$path", contentType: 'image/jpeg')
                .then((url) async {
              //création du user dans la _db

              MyUser myUser = MyUser(
                  id: uid,
                  nom: nomPrenom,
                  imageUrl: url,
                  email: email,
                  password: password,
                  lastActivity: DateTime.now(),
                  isLogin: false,
                  typeDeCompte: typeDeCompte,
                  hasAcceptedCGUCGV: false,
                  stripeAccount: stripeAccount,
                  person: person);

              await _service
                  .setData(path: Path.user(uid), data: myUser.toMap())
                  .then((_) async {
                //envoi de l'email de vérification
                await user.user.sendEmailVerification().then((value) {
                  print('Un email de validation a été envoyé');
                  rep = 'Un email de validation a été envoyé';
                  return 'Un email de validation a été envoyé';
                }).catchError((e) {
                  print(e);
                  return 'Impossible d\'envoyer l\'email';
                });
              });
            }).catchError((e) {
              print(e);
              return 'Impossible de charger l\'image';
            });
          } else {
            //sans image
            MyUser myUser = MyUser(
                id: uid,
                nom: nomPrenom,
                email: email,
                password: password,
                lastActivity: DateTime.now(),
                isLogin: false,
                typeDeCompte: typeDeCompte,
                hasAcceptedCGUCGV: false,
                stripeAccount: stripeAccount,
                person: person);
            await _service
                .setData(path: Path.user(uid), data: myUser.toMap())
                .then((value) async {
              print('I love you Diana');
              await user.user.sendEmailVerification().then((value) {
                print('Un email de validation a été envoyé');
                rep = 'Un email de validation a été envoyé';
                return rep;
              }).catchError((e) {
                print(e);
                print('//');
                rep = 'Impossible d\'envoyer l\'email';
              });
            }).catchError((e) {
              print(e);
              rep = 'Impossible de joindre le serveur';
            });
          }
          //rep = 'un email de validation a été envoyé';
        }).catchError((e) {
          print(e);
          rep = 'Impossible de joindre le serveur';
        });

        //rep = 'un email de validation a été envoyé';
      } else {
        rep = 'L\' email existe déjà';
      }
    }).catchError((e) {
      print(e);
      rep = 'Impossible de joindre le serveur';
    });

    return rep;
  }

  Future resetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  Future<User> getFireBaseUser() async {
    return _firebaseAuth.currentUser;
  }

  Future<bool> createOrUpdateUserOnDatabase(User user) async {
    bool isAcceptedCGUCGV = false;

    if (user.isAnonymous) {
      await _service.setData(path: Path.user(user.uid), data: {
        "id": user.uid,
        'lastActivity': FieldValue.serverTimestamp(),
        'provider': user.providerData,
      });
      return isAcceptedCGUCGV;
    }
    final myUser = await _service.getDoc(
        path: Path.user(user.uid),
        builder: (data) => MyUser.fromMap(data));

    if (myUser == null) {
      MyUser myUser = MyUser(
          id: user.uid,
          nom: user.displayName,
          email: user.email,
          lastActivity: DateTime.now(),
          isLogin: false,
          typeDeCompte: TypeOfAccount.userNormal,
          hasAcceptedCGUCGV: false);

      await _service.setData(path: Path.user(user.uid), data: myUser.toMap());
    } else {
      if (myUser.hasAcceptedCGUCGV) {
        isAcceptedCGUCGV = true;
      }
      await _service.setData(path: Path.user(user.uid), data: {
        'lastActivity': FieldValue.serverTimestamp(),
        'isLogin': true,
      });
    }
    return isAcceptedCGUCGV;
  }



  Future<MyUser> getMyUser(String uid) async {
    return await _service.getDoc(
        path: Path.user(uid), builder: (data) => MyUser.fromMap(data));
  }

  Future setIsAcceptCGUCGV(String uid) async {
    return await _service.setData(path: Path.user(uid), data: {
      'hasAcceptedCGUCGV': true,
    });
  }

  Future<void> setMyUser(MyUser user) async => await _service.setData(
        path: Path.user(uid),
        data: user.toMap(),
      );

  Future<MyUser> userFuture() async => await _service.getDoc(
      path: Path.user(uid),
      builder: (data) => MyUser.fromMap(data));

  Stream<MyUser> userStream() => _service.documentStream(
        path: Path.user(uid),
        builder: (data) => MyUser.fromMap(data),
      );

  Stream<List<MyUser>> usersStream() => _service.collectionStream(
        path: Path.users(),
        builder: (data) => MyUser.fromMap(data),
      );

  Future updateMyUserImageProfil(String urlFlyer) {

    return _service.updateData(path: Path.user(uid), data: {
      'imageUrl': urlFlyer,
    });
  }

  void updateMyUserGenre(Map genre) {

    genre.forEach((key, value) {
      _service.updateData(path: Path.user(uid), data: {
        'genres':
        value ? FieldValue.arrayUnion([key]) : FieldValue.arrayRemove([key])
      });
    });
  }

  void updateMyUserType(Map<String, bool> type) {

    type.forEach((key, value) {
      _service.updateData(path: Path.user(uid), data: {
        'types':
        value ? FieldValue.arrayUnion([key]) : FieldValue.arrayRemove([key])
      });
    });
  }

  void updateMyUserLieuQuand(Lieu lieu, String address, int aroundMe,
      Quand quand,
      DateTime date) {

    switch (lieu) {
      case Lieu.address:
        _service.updateData(path: Path.user(uid), data: {
          'lieu': ['address', address]
        });
        break;
      case Lieu.aroundMe:
        _service.updateData(path: Path.user(uid), data: {
          'lieu': ['aroundMe', aroundMe]
        });

        break;
    }

    switch (quand) {
      case Quand.date:
        _service.updateData(path: Path.user(uid), data: {
          'quand': ['date', date]
        });
        break;
      case Quand.ceSoir:
        _service.updateData(path: Path.user(uid), data: {
          'quand': ['ceSoir']
        });

        break;
      case Quand.demain:
        _service.updateData(path: Path.user(uid), data: {
          'quand': ['demain']
        });
        break;
      case Quand.avenir:
        _service.updateData(path: Path.user(uid), data: {
          'quand': ['avenir']
        });
        break;
    }
  }

  void setUid(String uid) {
    this.uid = uid;
  }
  Future setUserPosition(Position position) async {

    return await _service.updateData(path: Path.user(uid), data: {
      'geoPoint': GeoPoint(position.latitude, position.longitude)
    });
  }

  Future uploadImageProfil(File imageProfil) async {
    //création du path pour le flyer
    String pathprofil =
    imageProfil.path.substring(imageProfil.path.lastIndexOf('/') + 1);

    String urlFlyer = await _service.uploadImg(file: imageProfil,
        path: Path.profilImage(uid,pathprofil), contentType: 'image/jpeg');

    return await updateUserImageProfil(urlFlyer);
  }

  Future updateUserImageProfil(String urlFlyer) async {

    return await _service.updateData(path: Path.user(uid), data: {
      'imageUrl': urlFlyer,
    });
  }
}
