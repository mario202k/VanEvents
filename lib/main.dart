import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:van_events_project/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final sharePref = await SharedPreferences.getInstance();

  runApp(ProviderScope(child: MyApp(sharePref)));
}

// void onStart() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//
//   Map<String, int> chatNbMsgNonLu = Map<String, int>();
//
//   void setMessageReceived(String chatId, String uid, QuerySnapshot docs) {
//
//     List<MyMessage> myList = List.from(docs.docs.map((e) => MyMessage.fromMap(e.data())));
//
//     myList.sort((a,b)=>a.date
//         .compareTo(b.date));
//
//     FirebaseFirestore.instance
//         .collection('chats')
//         .doc(chatId)
//         .collection('chatMembres')
//         .doc(uid)
//         .update({'lastReceived': myList.last.date});
//   }
//
//   Stream<Stream<int>> nbMessagesNonLu(String chatId, String uid) {
//     return FirebaseFirestore.instance
//         .collection('chats')
//         .doc(chatId)
//         .collection('chatMembres')
//         .doc(uid)
//         .snapshots()
//         .map((membre) {
//       final mb = ChatMembre.fromMap(membre.data());
//       return FirebaseFirestore.instance
//           .collection('chats')
//           .doc(chatId)
//           .collection('messages')
//           .where('date', isGreaterThan: mb.lastReading)
//           .snapshots()
//           .map((docs) {
//             if(docs.size >0){
//               setMessageReceived(chatId, uid, docs);
//             }
//         return mb.isWriting ? 0 : docs.size;
//       });
//     });
//   }
//
//   Stream<List<MyChat>> chatRoomsStream(String uid) {
//     return FirebaseFirestore.instance
//         .collection('chats')
//         .where('membres.$uid', isEqualTo: true)
//         .snapshots()
//         .map((event) =>
//             event.docs.map((data) => MyChat.fromMap(data.data())).toList());
//   }
//
//   StreamSubscription<List<MyChat>> streamSubscriptionListChat;
//   List<StreamSubscription<Stream<int>>> streamSubscriptionListStream;
//   List<StreamSubscription<int>> streamSubscriptionNbMsgNonLu;
//
//   final service = FlutterBackgroundService();
//
//   service.onDataReceived.listen((uid) {
//     if (uid != null) {
//       final streamListChat = chatRoomsStream(uid['uid']);
//
//       streamSubscriptionListChat?.cancel();
//       streamSubscriptionListChat = streamListChat.listen((myChat) {
//         streamSubscriptionNbMsgNonLu = List<StreamSubscription<int>>.generate(
//             myChat.length, (index) => null);
//         streamSubscriptionListStream =
//             List<StreamSubscription<Stream<int>>>.generate(
//                 myChat.length, (index) => null);
//
//         for (int i = 0; i < myChat.length; i++) {
//           final stream = nbMessagesNonLu(myChat[i].id, uid['uid']);
//           streamSubscriptionListStream[i]?.cancel();
//           streamSubscriptionListStream[i] = stream.listen((fluxStream) {
//             streamSubscriptionNbMsgNonLu[i]?.cancel();
//             streamSubscriptionNbMsgNonLu[i] = fluxStream.listen((event) async {
//               chatNbMsgNonLu.addAll({myChat[i].id: event});
//
//               if (chatNbMsgNonLu.keys.length == myChat.length) {
//                 print('!!!!!!!!Coucou');
//                 service.sendData(chatNbMsgNonLu);
//               }
//             });
//           });
//         }
//       });
//     }
//   });
// }
