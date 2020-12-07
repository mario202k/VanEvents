class Path {
  static String user(String uid) => 'users/$uid';

  static String users() => 'users';

  static String event(String id) => 'events/$id';

  static String events() => 'events';

  static String messages(String chatId) => 'chats/$chatId/messages';

  static eventPhotos(String idEvent, String name) => 'photos/$idEvent/$name';

  static transport(String id) => 'transports/$id';

  static transports() => 'transports';

  static flyer(String docId) => 'flyer/$docId';

  static chats()=>'chats';

  static formules(String eventId) => 'events/$eventId/formules';

  static formule(String eventId, String formuleId) => 'events/$eventId/formules/$formuleId';

  static billets() => 'billets';

  static message(String chatId, String id) => 'chats/$chatId/messages/$id';

  static chat(String idChatRoom) =>'chats/$idChatRoom';

  static chatMembre(String idChatRoom, String uid) =>'chats/$idChatRoom/$uid';

  static billet(String id) => 'billets/$id';

  static chatImage(String chatId, String nom) =>'chats/$chatId/$nom';

  static profilImage(String uid, String pathprofil) =>'imageProfil/$uid/$pathprofil';
}
