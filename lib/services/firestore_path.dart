import 'package:firebase_auth/firebase_auth.dart';

class MyPath {
  static String user(String uid) => 'users/$uid';

  static String users() => 'users';

  static String refunds(String organisateurId) => 'users/$organisateurId/refunds';

  static String refund(String organisateurId,String id) => 'users/$organisateurId/refunds/$id';

  static String event(String id) => 'events/$id';

  static String events() => 'events';

  static String messages(String chatId) => 'chats/$chatId/messages';

  static eventPhotos(String idEvent, String name) =>
      'eventsImages/$idEvent/$name';

  static transport(String id) => 'transports/$id';

  static transports() => 'transports';

  static flyer(String docId) => 'flyer/$docId';

  static chats() => 'chats';

  static formules(String eventId) => 'events/$eventId/formules';

  static formule(String eventId, String formuleId) =>
      'events/$eventId/formules/$formuleId';

  static billets() => 'billets';

  static message(String chatId, String id) => 'chats/$chatId/messages/$id';

  static chat(String idChatRoom) => 'chats/$idChatRoom';

  static chatMembre(String idChatRoom, String uid) =>
      'chats/$idChatRoom/chatMembres/$uid';

  static billet(String id) => 'billets/$id';

  static chatImage(String chatId, String nom) => 'chatsImages/$chatId/$nom';

  static profilImage(String uid, String pathprofil) =>
      'imageProfil/$uid/$pathprofil';

  static signInUrl(String email) =>
      'https://myvanevents.page.link/signIn?email=$email';

  static androidPackageName() => 'com.vanevents.VanEvents';

  static iOSBundleId() => 'com.vanevents.VanEvents';

  static actionCodeSettingsSignIn(String email) => ActionCodeSettings(
      url: signInUrl(email),
      androidInstallApp: true,
      androidMinimumVersion: '9',
      androidPackageName: androidPackageName(),
      iOSBundleId: iOSBundleId(),dynamicLinkDomain: 'myvanevents.page.link',
      handleCodeInApp: true);

  static logoImage(String pathlogo) => 'imageLogo/$pathlogo';

  static String redirecUri() =>'https://equatorial-spangle-llama.glitch.me/callbacks/sign_in_with_apple';

  static serviceId() => 'com.vanevent.VanEvents';

  static String stripeDocs(String id, String front)  => 'imageStripeDoc/$id/$front';

  static abouts() => 'about';

}
