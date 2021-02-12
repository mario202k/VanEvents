import 'package:firebase_auth/firebase_auth.dart';

class MyPath {
  static String user(String uid) => 'users/$uid';

  static String users() => 'users';

  static String refunds(String organisateurId) => 'users/$organisateurId/refunds';

  static String refund(String organisateurId,String id) => 'users/$organisateurId/refunds/$id';

  static String event(String id) => 'events/$id';

  static String events() => 'events';

  static String messages(String chatId) => 'chats/$chatId/messages';

  static String calls(String chatId) => 'chats/$chatId/calls';

  static String call(String chatId, String callId) => 'chats/$chatId/calls/$callId';

  static String eventPhotos(String idEvent, String name) =>
      'eventsImages/$idEvent/$name';

  static String transport(String id) => 'transports/$id';

  static String transports() => 'transports';

  static String flyer(String docId) => 'flyer/$docId';

  static String chats() => 'chats';

  static String formules(String eventId) => 'events/$eventId/formules';

  static String formule(String eventId, String formuleId) =>
      'events/$eventId/formules/$formuleId';

  static String billets() => 'billets';

  static String message(String chatId, String id) => 'chats/$chatId/messages/$id';

  static String chat(String idChatRoom) => 'chats/$idChatRoom';

  static String chatMembre(String idChatRoom, String uid) =>
      'chats/$idChatRoom/chatMembres/$uid';

  static String billet(String id) => 'billets/$id';

  static String chatImage(String chatId, String nom) => 'chatsImages/$chatId/$nom';

  static String profilImage(String uid, String pathprofil) =>
      'imageProfil/$uid/$pathprofil';

  static String signInUrl(String email) =>
      'https://myvanevents.page.link/signIn?email=$email';

  static String androidPackageName() => 'com.vanevents.VanEvents';

  static String iOSBundleId() => 'com.vanevents.VanEvents';

  static ActionCodeSettings actionCodeSettingsSignIn(String email) => ActionCodeSettings(
      url: signInUrl(email),
      androidInstallApp: true,
      androidMinimumVersion: '9',
      androidPackageName: androidPackageName(),
      iOSBundleId: iOSBundleId(),dynamicLinkDomain: 'myvanevents.page.link',
      handleCodeInApp: true);

  static String logoImage(String pathlogo) => 'imageLogo/$pathlogo';

  static String redirecUri() =>'https://equatorial-spangle-llama.glitch.me/callbacks/sign_in_with_apple';

  static String serviceId() => 'com.vanevent.VanEvents';

  static String stripeDocs(String id, String front)  => 'imageStripeDoc/$id/$front';

  static String abouts() => 'about';

}
