import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:van_events_project/constants/credentials.dart';
import 'package:van_events_project/domain/models/call.dart';
import 'package:van_events_project/domain/models/chat_membres.dart';
import 'package:van_events_project/domain/models/message.dart';
import 'package:van_events_project/domain/models/my_chat.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/providers/chat_room_change_notifier.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';

final myChatRepositoryProvider = Provider<MyChatRepository>((ref) {
  final uid = ref.watch(myUserProvider).id;
  return MyChatRepository(uid: uid);
});

class MyChatRepository {
  final _service = FirestoreService.instance;
  String uid;
  String chatId;

  MyChatRepository({this.uid, this.chatId});

  Stream<List<MyChat>> chatRoomsStream(String uid) {
    return _service.collectionStream(
        path: MyPath.chats(),
        builder: (data) => MyChat.fromMap(data),
        queryBuilder: (query) => query.where('membres.$uid', isEqualTo: true));
  }

  Stream<MyMessage> getLastChatMessage(String chatId) {
//////////????????????? a tester
    return _service
        .collectionStream(
            path: MyPath.messages(chatId),
            builder: (data) => MyMessage.fromMap(data),
            queryBuilder: (query) =>
                query.orderBy('date', descending: true).limit(1))
        .map((event) => event.first);
  }

  Future<MyMessage> getLastChatMessagesChatRoom(String chatId) async {
    return (await _service.collectionFuture(
            path: MyPath.messages(chatId),
            builder: (data) => MyMessage.fromMap(data),
            queryBuilder: (query) =>
                query.orderBy('date', descending: true).limit(1)))
        .first;
  }

  Stream<int> getNbChatMessageNonLu(String chatId) {
    return _service
        .collectionStream(
            path: MyPath.messages(chatId),
            queryBuilder: (query) => query
                .where('state', isLessThan: 2)
                .where('idTo', isEqualTo: uid),
            builder: (map) => MyMessage.fromMap(map))
        .map((event) => event.length);
  }

  Stream<MyMessage> getChatMessageStream(String chatId, String id) {
    return _service.documentStream(
        path: MyPath.message(chatId, id),
        builder: (map) => MyMessage.fromMap(map));
  }

  Stream<List<MyMessage>> getChatMessages(String chatId) {
    return _service.collectionStream(
        path: MyPath.messages(chatId),
        queryBuilder: (query) => query.orderBy('date', descending: true),
        builder: (map) => MyMessage.fromMap(map));
  }

  Future<void> sendMessage(MyMessage message) async {
    return _service.setData(
        path: MyPath.message(chatId, message.id), data: message.toMap());
  }

  Future<String> creationChatRoom(MyUser friend) async {
    //création d'un chatRoom
    String idChatRoom = '';

    await _service
        .collectionFuture(
            path: MyPath.chats(),
            queryBuilder: (query) => query
                .where('membres.${friend.id}', isEqualTo: true)
                .where('membres.$uid', isEqualTo: true)
                .where('isGroupe', isEqualTo: false),
            builder: (data) => MyChat.fromMap(data))
        .then((value) async {
      if (value != null && value.isNotEmpty) {
        idChatRoom = value.first.id;

      } else {
        idChatRoom = _service.getDocId(path: MyPath.chats());
        await _service.setData(path: MyPath.chat(idChatRoom), data: {
          'id': idChatRoom,
          'createdAt': FieldValue.serverTimestamp(),
          'isGroupe': false,
          'membres': {uid: true, friend.id: true},
        }).then((value) async {
          await _service.setData(
              path: MyPath.chatMembre(idChatRoom, uid),
              data: {
                'id': uid,
                'lastReading': FieldValue.serverTimestamp(),
                'isReading': true
              });
        }).then((value) async {
          await _service.setData(
              path: MyPath.chatMembre(idChatRoom, friend.id),
              data: {
                'id': friend.id,
                'lastReading': friend.lastActivity,
                'isReading': false
              });
        });
      }
    });
    return idChatRoom;
  }

  Stream<ChatMembre> getChatMembre(String chatId, String idFriend) {
    return _service.documentStream(
        path: MyPath.chatMembre(chatId, idFriend),
        builder: (map) => ChatMembre.fromMap(map));
  }

  Stream<Stream<int>> nbMessagesNonLu(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('chatMembres')
        .doc(uid)
        .snapshots()
        .map((membre) {
          final mb = ChatMembre.fromMap(membre.data());
          return FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('date',
                isGreaterThan: mb.lastReading)
            .snapshots()
            .map((docs) {


              return mb.isWriting?0 : docs.size;
            });
        });
  }

  Future<MyChat> getMyChat(String chatId) {
    return _service.getDoc(
        path: MyPath.chat(chatId), builder: (map) => MyChat.fromMap(map));
  }

  Future<List<MyUser>> chatMyUsersFuture(MyChat myChat) {
    return _service.collectionFuture(
        path: MyPath.users(), builder: (map) => MyUser.fromMap(map));
  }

  void setChatId(String chatId) {
    this.chatId = chatId;
  }

  Stream<MyUser> userFriendStream(String id) {
    return _service.documentStream(
        path: MyPath.user(id), builder: (map) => MyUser.fromMap(map));
  }

  Future addAmongGroupe(String chatId) async {
    return _service.setData(path: MyPath.chat(chatId), data: {
      'membres': {uid: true}
    }).then((value) async {
      return _service.setData(
          path: MyPath.chatMembre(chatId, uid),
          data: {
            'id': uid,
            'lastReading': FieldValue.serverTimestamp(),
            'isReading': true
          });
    });
  }

  Future setIsReading() async {
    return _service.setData(path: MyPath.chatMembre(chatId, uid), data: {
      'lastReading': FieldValue.serverTimestamp(),
      'isReading': true,
      'isWriting': false
    });
  }

  Future setIsNotReading() async {
    return _service.setData(path: MyPath.chatMembre(chatId, uid), data: {
      'lastReading': FieldValue.serverTimestamp(),
      'isReading': false,
      'isWriting': false
    });
  }

  Future setIsWriting() async {
    return _service.setData(path: MyPath.chatMembre(chatId, uid), data: {
      'lastReading': FieldValue.serverTimestamp(),
      'isWriting': true
    });
  }

  void displayAndSendImage(File image, ChatRoomChangeNotifier chatRoomRead) {
    final String messageId = _service.getDocId(path: MyPath.messages(chatId));

    String idTo;

    if (!chatRoomRead.myChat.isGroupe) {
      idTo = chatRoomRead.friend.id;
    }

    final MyMessage myMessage = MyMessage(
        id: messageId,
        idTo: idTo,
        idFrom: uid,
        type: chatRoomRead.replyMessage.isEmpty
            ? MyMessageType.image
            : MyMessageType.reply,
        replyType: MyMessageReplyType.image,
        replyMessageId: chatRoomRead.replyMessageId,
        date: DateTime.now());

    chatRoomRead.addListPhoto(messageId, image);
    chatRoomRead.addTempMessage(messageId);

    chatRoomRead.myNewMessages(myMessage);

    uploadImageChat(
            chatRoomRead, image, chatRoomRead.myChat.id, uid, idTo, messageId)
        .then((_) => chatRoomRead.setTempMessageToloaded(messageId))
        .catchError((e) {
      chatRoomRead.setTempMessageToError(messageId);
    });
  }

  Future<void> uploadImageChat(ChatRoomChangeNotifier provider, File image,
      String chatId, String idSender, String friendId, String messageId) async {
    final String path = image.path.substring(image.path.lastIndexOf('/') + 1);

    await _service
        .uploadImg(
            file: image,
            path: MyPath.chatImage(chatId, path),
            contentType: 'image/jpeg')
        .then((url) async {
      final MyMessage myMessage = MyMessage(
          id: messageId,
          message: url,
          idTo: friendId,
          idFrom: uid,
          type: provider.replyMessage.isEmpty
              ? MyMessageType.image
              : MyMessageType.reply,
          replyMessageId: provider.replyMessageId,
          replyType: MyMessageReplyType.image);
      if (myMessage.type == MyMessageType.reply) {
        provider.setReplyToNull();
      }
      await sendMessage(myMessage);
    });
  }

  Future<void> pickGif(
      BuildContext context, ChatRoomChangeNotifier chatRoomRead) async {
    final gif =
        await GiphyPicker.pickGif(context: context, apiKey: GIPHY_API_KEY);

    if (gif != null) {
      final String messageId = _service.getDocId(path: MyPath.messages(chatId));
      String idTo;

      if (!chatRoomRead.myChat.isGroupe) {
        idTo = chatRoomRead.friend.id;
      }
      final MyMessage myMessage = MyMessage(
          id: messageId,
          message: gif.images.original.url,
          idTo: idTo,
          idFrom: uid,
          date: DateTime.now(),
          type: chatRoomRead.replyMessage.isEmpty
              ? MyMessageType.image
              : MyMessageType.reply,
          replyMessageId: chatRoomRead.replyMessageId,
          replyType: MyMessageReplyType.image);

      chatRoomRead.myNewMessages(myMessage);

      await sendMessage(myMessage);
      if (myMessage.type == MyMessageType.reply) {
        chatRoomRead.setReplyToNull();
      }
    }
  }

  Future<void> sendTextMessage(ChatRoomChangeNotifier chatRoomRead,
      TextEditingController textEditingController) async {
    final String messageId = _service.getDocId(path: MyPath.messages(chatId));

    String idTo;

    if (!chatRoomRead.myChat.isGroupe) {
      idTo = chatRoomRead.friend.id;
    }
    final MyMessage myMessage = MyMessage(
        id: messageId,
        message: textEditingController.text.trim(),
        idTo: idTo,
        idFrom: uid,
        date: DateTime.now(),
        type: chatRoomRead.replyMessage.isEmpty
            ? MyMessageType.text
            : MyMessageType.reply,
        replyMessageId: chatRoomRead.replyMessageId ?? '',
        replyType: chatRoomRead.replyMessageId != null
            ? MyMessageReplyType.text
            : null);

    chatRoomRead.addTempMessage(myMessage.id);

    chatRoomRead.myNewMessages(myMessage);

    if (textEditingController.text.trim() != '') {
      chatRoomRead.setShowSendBotton(false);
      textEditingController.clear();

      await sendMessage(myMessage).catchError((err) {
        debugPrint(err.toString());
        chatRoomRead.setShowSendBotton(true);
        chatRoomRead.setTempMessageToError(myMessage.id);
      }).whenComplete(() {
        chatRoomRead.setShowSendBotton(false);
        chatRoomRead.setTempMessageToloaded(myMessage.id);
      });
      if (myMessage.type == MyMessageType.reply) {
        chatRoomRead.setReplyToNull();
      }
    }
  }

  Future<MyMessage> getMessage(String chatId, String replyMessageId) async {
    return _service.getDoc(
        path: MyPath.message(chatId, replyMessageId),
        builder: (map) => MyMessage.fromMap(map));
  }

  Future<String> sendCall(ChatRoomChangeNotifier chatRoomRead) async {
    final String callId = _service.getDocId(path: MyPath.calls(chatId));

    final Call myCall = Call(
      id: callId,
      date: DateTime.now(),
      uuid: Uuid().v4(),
      idFrom: uid,
      idTo: chatRoomRead.friend.id,
      hasVideo: false
    );

    await _service.setData(
        path: MyPath.call(chatId,callId), data: myCall.toMap());
    return callId;
  }

  Future<HttpsCallableResult> getAgoraToken(String channelName) async {
    HttpsCallableResult agoraResponse;
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'getAgoraToken',
      );
      agoraResponse = await callable.call(
        <String, dynamic>{'channelName': channelName, 'uid': uid},
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint(e.toString());
    } catch (e) {
      debugPrint(e.toString());
    }

    return agoraResponse;
  }
}
