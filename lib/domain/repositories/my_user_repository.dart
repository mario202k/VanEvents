import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:van_events_project/constants/credentials.dart';
import 'package:van_events_project/domain/models/about.dart';
import 'package:van_events_project/domain/models/my_chat.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/presentation/widgets/lieu_quand_alertdialog.dart';
import 'package:van_events_project/providers/authentication_cubit/authentication_cubit.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';

final myUserRepository = Provider.autoDispose<MyUserRepository>((ref) {
  return MyUserRepository();
});

final streamMyUserProvider = StreamProvider.autoDispose<MyUser>((ref) {

  return ref.read(myUserRepository).userStream();
});

final aboutFutureProvider = FutureProvider.autoDispose<List<About>>((ref) {
  return ref.read(myUserRepository).aboutFuture();
});

class MyUserRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _service = FirestoreService.instance;

  String uid;
  String email;
  User user;

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    final b = await SignInWithApple.isAvailable();
    if (!b) {
      return null;
    }
    // 1. perform the sign-in request
    final appleIdCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
        clientId: MyPath.serviceId(), //Le service identifier
        redirectUri: Uri.parse(
          MyPath.redirecUri(),
        ),
      ),
    );

    if (appleIdCredential == null) {
      return null;
    }

    // 2. check the result
    final oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
      idToken: appleIdCredential.identityToken,
      accessToken: appleIdCredential.authorizationCode,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> checkDynamicLinkData(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      await handleLink(deepLink, context);
    }, onError: (OnLinkErrorException e) async {
      debugPrint('onLinkError');
      debugPrint(e.message);
    });
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (data?.link != null) {
      await handleLink(data?.link, context);
    }
  }

  Future<void> handleLink(Uri link, BuildContext context) async {
    if (link != null) {
      final mode = link.queryParameters['mode'];
      final actionCode = link.queryParameters['oobCode'];
      final continueUrl = link.queryParameters['continueUrl'];
      final lang = link.queryParameters['lang'] ?? 'fr';

      // Handle the user management action.
      switch (mode) {
        case 'resetPassword':
          // Display reset password handler and UI.
          handleResetPassword(actionCode, continueUrl, lang);
          break;
        case 'recoverEmail':
          // Display email recovery handler and UI.
          handleRecoverEmail(actionCode, lang);
          break;
        case 'verifyEmail':
          // Display email verification handler and UI.
          await handleVerifyEmail(context, actionCode, continueUrl, lang);
          break;
        default:
        // Error: invalid mode.
      }
    }
  }

  // Future<void> _createDynamicLink(bool short) async {
  //   final DynamicLinkParameters parameters = DynamicLinkParameters(
  //     uriPrefix: 'https://vanevents.page.link/',
  //     link: Uri.parse('https://dynamic.link.example/helloworld'),
  //     androidParameters: AndroidParameters(
  //       packageName: 'io.flutter.plugins.firebasedynamiclinksexample',
  //       minimumVersion: 0,
  //     ),
  //     dynamicLinkParametersOptions: DynamicLinkParametersOptions(
  //       shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
  //     ),
  //     iosParameters: IosParameters(
  //       bundleId: 'com.google.FirebaseCppDynamicLinksTestApp.dev',
  //       minimumVersion: '0',
  //     ),
  //   );
  //
  //   Uri url;
  //   if (short) {
  //     final ShortDynamicLink shortLink = await parameters.buildShortLink();
  //     url = shortLink.shortUrl;
  //   } else {
  //     url = await parameters.buildUrl();
  //   }
  // }

  Future<void> sendSignInLinkToEmail(
      {String email, ActionCodeSettings actionCodeSettings}) async {
    return _firebaseAuth.sendSignInLinkToEmail(
        email: email, actionCodeSettings: actionCodeSettings);
  }

  // Future<UserCredential> signInWithFacebook() async {
  //   // Trigger the sign-in flow
  //   final result = await FacebookAuth.instance.login();
  //
  //   // Create a credential from the access token
  //   final FacebookAuthCredential facebookAuthCredential =
  //   FacebookAuthProvider.credential(result.token);
  //
  //   // Once signed in, return the UserCredential
  //   return await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  // }

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
        path: MyPath.users(),
        queryBuilder: (query) =>
            query.where('id', whereIn: myChat.membres.keys.toList()),
        builder: (map) => MyUser.fromMap(map));
  }

  Future setInactive() {
    if (uid == null) {
      return Future.value();
    }
    return _service.setData(
        path: MyPath.user(uid),
        data: {'lastActivity': FieldValue.serverTimestamp(), 'isLogin': false});
  }

  Future setOnline() {
    if (uid == null) {
      return Future.value();
    }
    return _service.setData(
        path: MyPath.user(uid),
        data: {'lastActivity': FieldValue.serverTimestamp(), 'isLogin': true});
  }

  Future<String> signUp(
      {File image,
      String nomPrenom,
      String email,
      TypeOfAccount typeDeCompte,
      String password,
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
          final String uid = user.user.uid;
          this.uid = uid;

          if (image != null) {
            //création du path pour la photo profil
            final String path =
                image.path.substring(image.path.lastIndexOf('/') + 1);

            //création de l'url pour la photo profil
            await _service
                .uploadImg(
                    file: image,
                    path: MyPath.profilImage(uid, path),
                    contentType: 'image/jpeg')
                .then((url) async {
              //création du user dans la _db

              final MyUser myUser = MyUser(
                  id: uid,
                  nom: nomPrenom,
                  imageUrl: url,
                  email: email,
                  lastActivity: DateTime.now(),
                  isLogin: false,
                  typeDeCompte: typeDeCompte,
                  hasAcceptedCGUCGV: false,
                  stripeAccount: stripeAccount,
                  person: person);

              await _service
                  .setData(path: MyPath.user(uid), data: myUser.toMap())
                  .then((_) async {
                await user.user
                    .sendEmailVerification(
                        MyPath.actionCodeSettingsSignIn(email))
                    .then((value) {
                  rep = 'Un email de validation a été envoyé';
                }).catchError((e) {
                  return 'Impossible d\'envoyer l\'email';
                });
              });
            }).catchError((e) {
              return 'Impossible de charger l\'image';
            });
          } else {
            //sans image
            final MyUser myUser = MyUser(
                id: uid,
                nom: nomPrenom,
                email: email,
                lastActivity: DateTime.now(),
                isLogin: false,
                typeDeCompte: typeDeCompte,
                hasAcceptedCGUCGV: false,
                stripeAccount: stripeAccount,
                person: person);

            await _service
                .setData(path: MyPath.user(uid), data: myUser.toMap())
                .then((_) async {
              await user.user
                  .sendEmailVerification(MyPath.actionCodeSettingsSignIn(email))
                  .then((value) {
                rep = 'Un email de validation a été envoyé';
              }).catchError((e) {
                return 'Impossible d\'envoyer l\'email';
              });
            });
          }
          //rep = 'un email de validation a été envoyé';
        }).catchError((e) {
          rep = 'Impossible de joindre le serveur';
        });

        //rep = 'un email de validation a été envoyé';
      } else {
        rep = 'L\' email existe déjà';
      }
    }).catchError((e) {
      debugPrint(e.toString());
      rep = 'Impossible de joindre le serveur';
    });

    return rep;
  }

  Future resetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    setInactive();
    await _firebaseAuth.signOut().catchError((e) {
      debugPrint('_firebaseAuth');
      debugPrint(e.toString());
    });
    await _googleSignIn.signOut().catchError((e) {
      debugPrint('_googleSignIn');
      debugPrint(e.toString());
    });
    user = null;
    uid = null;

    // return Future.wait([
    //   _firebaseAuth.signOut(),
    //   _googleSignIn.signOut(),
    // ]);
  }

  Future<bool> isSignedIn() async {
    User currentUser = _firebaseAuth.currentUser;
    await currentUser?.reload();
    currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      await createOrUpdateUserOnDatabase(currentUser);
    }
    return (currentUser != null && currentUser.emailVerified) ||
        (currentUser != null && currentUser.isAnonymous);
  }

  User getFireBaseUser() {
    return user;
  }

  Future<bool> createOrUpdateUserOnDatabase(User user) async {
    this.user = user;
    setUid(user.uid);
    const bool isAcceptedCGUCGV = false;

    if (user.isAnonymous) {
      await _service.setData(path: MyPath.user(user.uid), data: {
        "id": user.uid,
        'lastActivity': FieldValue.serverTimestamp(),
        'provider': user.providerData,
      });
      return isAcceptedCGUCGV;
    }
    final MyUser fromDb = await _service.getDoc(
        path: MyPath.user(user.uid), builder: (map) => MyUser.fromMap(map));

    await _service.setData(path: MyPath.user(user.uid), data: {
      'id': user.uid,
      'email': user.email,
      'lastActivity': FieldValue.serverTimestamp(),
      'nom': fromDb?.nom ?? user?.displayName,
      'imageUrl': fromDb?.imageUrl ?? user?.photoURL,
      'hasAcceptedCGUCGV': fromDb?.hasAcceptedCGUCGV ?? false,
      'isLogin': true
    });

    return fromDb?.hasAcceptedCGUCGV ?? false;
  }

  Future<MyUser> getMyUser(String uid) async {
    return _service.getDoc(
        path: MyPath.user(uid), builder: (data) => MyUser.fromMap(data));
  }

  Future setIsAcceptCGUCGV(String uid) async {
    return _service.setData(path: MyPath.user(uid), data: {
      'hasAcceptedCGUCGV': true,
    });
  }

  Future<void> setMyUser(MyUser user) async => _service.setData(
        path: MyPath.user(uid),
        data: user.toMap(),
      );

  Future<MyUser> userFuture() async => _service.getDoc(
      path: MyPath.user(uid), builder: (data) => MyUser.fromMap(data));

  Stream<MyUser> userStream() => _service.documentStream(
        path: MyPath.user(uid),
        builder: (data) => MyUser.fromMap(data),
      );

  Stream<List<MyUser>> usersStream() => _service.collectionStream(
        path: MyPath.users(),
        builder: (data) => MyUser.fromMap(data),
      );

  Future updateMyUserImageProfil(String urlFlyer) {
    return _service.updateData(path: MyPath.user(uid), data: {
      'imageUrl': urlFlyer,
    });
  }

  void updateMyUserGenre(Map<String, bool> genre) {
    genre.forEach((key, value) {
      _service.updateData(path: MyPath.user(uid), data: {
        'genres':
            value ? FieldValue.arrayUnion([key]) : FieldValue.arrayRemove([key])
      });
    });
  }

  void updateMyUserType(Map<String, bool> type) {
    type.forEach((key, value) {
      _service.updateData(path: MyPath.user(uid), data: {
        'types':
            value ? FieldValue.arrayUnion([key]) : FieldValue.arrayRemove([key])
      });
    });
  }

  void updateMyUserLieuQuand(
      Lieu lieu, String address, int aroundMe, Quand quand, DateTime date) {
    switch (lieu) {
      case Lieu.address:
        _service.updateData(path: MyPath.user(uid), data: {
          'lieu': ['address', address]
        });
        break;
      case Lieu.aroundMe:
        _service.updateData(path: MyPath.user(uid), data: {
          'lieu': ['aroundMe', aroundMe]
        });

        break;
    }

    switch (quand) {
      case Quand.date:
        _service.updateData(path: MyPath.user(uid), data: {
          'quand': ['date', date]
        });
        break;
      case Quand.ceSoir:
        _service.updateData(path: MyPath.user(uid), data: {
          'quand': ['ceSoir']
        });

        break;
      case Quand.demain:
        _service.updateData(path: MyPath.user(uid), data: {
          'quand': ['demain']
        });
        break;
      case Quand.avenir:
        _service.updateData(path: MyPath.user(uid), data: {
          'quand': ['avenir']
        });
        break;
    }
  }

  void setUid(String uid) {
    this.uid = uid;
  }

  Future setUserPosition(Position position) async {
    return _service.updateData(
        path: MyPath.user(uid),
        data: {'geoPoint': GeoPoint(position.latitude, position.longitude)});
  }

  Future uploadImageProfil(File imageProfil) async {
    //création du path pour le flyer
    final String pathprofil =
        imageProfil.path.substring(imageProfil.path.lastIndexOf('/') + 1);

    final String urlFlyer = await _service.uploadImg(
        file: imageProfil,
        path: MyPath.profilImage(uid, pathprofil),
        contentType: 'image/jpeg');

    return updateUserImageProfil(urlFlyer);
  }

  Future updateUserImageProfil(String urlFlyer) async {
    return _service.updateData(path: MyPath.user(uid), data: {
      'imageUrl': urlFlyer,
    });
  }

  Future<void> changePassword() async {
    return _firebaseAuth.sendPasswordResetEmail(
        email: _firebaseAuth.currentUser.email);
  }

  Future<void> supprimerCompte() async {
    return _firebaseAuth.currentUser.delete();
  }

  Future<List<About>> aboutFuture() async {
    return _service.collectionFuture(
        path: MyPath.abouts(), builder: (data) => About.fromMap(data));
  }

  Future<List<MyUser>> getMyUserFromStripeAccount(String stripeAccount) {
    return _service.collectionFuture(
        path: MyPath.users(),
        builder: (map) => MyUser.fromMap(map),
        queryBuilder: (query) =>
            query.where('stripeAccount', isEqualTo: stripeAccount));
  }

  void handleResetPassword(
      String actionCode, String continueUrl, String lang) {}

  void handleRecoverEmail(String actionCode, String lang) {}

  Future<void> handleVerifyEmail(BuildContext context, String actionCode,
      String continueUrl, String lang) async {
    await _firebaseAuth.applyActionCode(actionCode).then((_) {
      final Uri deepLink = Uri.parse(continueUrl);

      BlocProvider.of<AuthenticationCubit>(context)
          .authenticationEmailLinkSuccess(deepLink.queryParameters['email']);
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  Future<void> setUserBlocked(String id) {
    return _service.updateData(path: MyPath.user(uid), data: {
      'blockedUser': FieldValue.arrayUnion([id])
    });
  }

  Future<void> setUserUnBlocked(String id) {
    return _service.updateData(path: MyPath.user(uid), data: {
      'blockedUser': FieldValue.arrayRemove([id])
    });
  }

  Future<void> setUserNull(String id) {
    return _firebaseAuth.signOut();
  }

  Future<void> setNewName(String newName) {
    return _service.updateData(path: MyPath.user(uid), data: {'nom': newName});
  }

  Future<void> addDummyUser() async {
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .get().then((value) async {
    //
    //       for(final user in value.docs){
    //
    //         final String id = user.id;
    //
    //         final MyUser myUser = MyUser.fromMap(user.data());
    //
    //         if(myUser.nom.contains("Britney") ||
    //             myUser.nom.contains("Amaury") ||
    //             myUser.nom.contains("Brad") ||
    //             myUser.nom.contains("David") ||
    //             myUser.nom.contains("Elon") ||
    //             myUser.nom.contains("Le Pape") ||
    //             myUser.nom.contains("Marlon") ||
    //             myUser.nom.contains("Hiro") ||
    //             myUser.nom.contains("Azziz") ||
    //             myUser.nom.contains("Satya") ||
    //             myUser.nom.contains("Mamoudou") ){
    //           await _service.deleteDoc(
    //             path: MyPath.user(id),
    //           );
    //         }
    //       }
    //
    //       return null;
    //     });

    for (final user in dummyUser) {
      final id = _service.getDocId(path: MyPath.users());

      final Map<String,dynamic> map = Map.from(user);

      map.addAll({"id": id});
      await _service.setData(path: MyPath.user(id), data: map);
    }
  }
}
