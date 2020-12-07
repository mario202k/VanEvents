import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/constants/credentials.dart';
import 'package:van_events_project/domain/models/chat_membres.dart';
import 'package:van_events_project/domain/models/message.dart';
import 'package:van_events_project/domain/models/my_chat.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/providers/chat_room_change_notifier.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';

final myChatRepositoryProvider = Provider<MyChatRepository>((ref) {
  final uid = ref.read(myUserProvider).id;
  return MyChatRepository(uid: uid);
});

class MyChatRepository {
  final _service = FirestoreService.instance;
  String uid;
  String chatId;

  MyChatRepository({this.uid, this.chatId});

  Stream<List<MyChat>> chatRoomsStream() {
    return _service.collectionStream(
        path: Path.chats(),
        builder: (data) => MyChat.fromMap(data),
        queryBuilder: (query) => query.where('membres.$uid', isEqualTo: true));
  }

  Stream<MyMessage> getLastChatMessage(String chatId) {
//////////????????????? a tester
    return _service
        .collectionStream(
            path: Path.messages(chatId),
            builder: (data) => MyMessage.fromMap(data),
            queryBuilder: (query) =>
                query.orderBy('date', descending: true).limit(1))
        .map((event) => event.first);
  }

  Future<MyMessage> getLastChatMessagesChatRoom(String chatId) async {
    return (await _service.collectionFuture(
            path: Path.messages(chatId),
            builder: (data) => MyMessage.fromMap(data),
            queryBuilder: (query) =>
                query.orderBy('date', descending: true).limit(1)))
        .first;
  }

  Stream<int> getNbChatMessageNonLu(String chatId) {
    return _service
        .collectionStream(
            path: Path.messages(chatId),
            queryBuilder: (query) => query
                .where('state', isLessThan: 2)
                .where('idTo', isEqualTo: uid),
            builder: (map) => MyMessage.fromMap(map))
        .map((event) => event.length);
  }

  Stream<MyMessage> getChatMessageStream(String chatId, String id) {
    return _service
        .documentStream(
            path: Path.message(chatId, id),
            builder: (map) => MyMessage.fromMap(map));
  }

  Stream<List<MyMessage>> getChatMessages(String chatId) {
    return _service.collectionStream(
        path: Path.messages(chatId),
        queryBuilder: (query) => query.orderBy('date', descending: true),
        builder: (map) => MyMessage.fromMap(map));
  }

  Future<void> sendMessage(MyMessage message) async {
    return await _service.setData(
        path: Path.message(chatId, message.id), data: message.toMap());
  }

  Future<String> creationChatRoom(MyUser friend) async {
    //création d'un chatRoom
    String idChatRoom = '';

    _service
        .collectionFuture(
            path: Path.chats(),
            queryBuilder: (query) => query
                .where('membres.${friend.id}', isEqualTo: true)
                .where('membres.$uid', isEqualTo: true)
                .where('isGroupe', isEqualTo: false),
            builder: (data) => MyChat.fromMap(data))
        .then((value) async {
      if (value != null) {
        idChatRoom = value.first.id;
      } else {
        idChatRoom = _service.getDocId(path: Path.chats());
        await _service.setData(path: Path.chat(idChatRoom), data: {
          'id': idChatRoom,
          'createdAt': FieldValue.serverTimestamp(),
          'isGroupe': false,
          'membres': {uid: true, friend.id: true},
        }).then((value) async {
          await _service.setData(path: Path.chatMembre(idChatRoom, uid), data: {
            'id': uid,
            'lastReading': FieldValue.serverTimestamp(),
            'isReading': true
          });
        }).then((value) async {
          await _service.setData(
              path: Path.chatMembre(idChatRoom, friend.id),
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

    return _service.collectionStream(path: Path.chatMembre(chatId, idFriend),
        builder: (map)=>ChatMembre.fromMap(map)).map((event) => event.first);
  }

  Stream<Stream<List<MyMessage>>> nbMessagesNonLu(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('chatMembres')
        .doc(uid)
        .snapshots()
        .map((membre) => FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            //.where('idFrom', isEqualTo: uid)
            .where('date',
                isGreaterThan: ChatMembre.fromMap(membre.data()).lastReading)
            .snapshots()
            .map((docs) => docs.docs
                .map((msg) => MyMessage.fromMap(msg.data()))
                .toList()));
  }

  Future<MyChat> getMyChat(String chatId) {

    return _service.getDoc(path: Path.chat(chatId), builder: (map)=>MyChat.fromMap(map));
  }

  Future<List<MyUser>> chatMyUsersFuture(MyChat myChat) {

    return _service.collectionFuture(path: Path.users(), builder: (map)=>MyUser.fromMap(map));
  }

  void setChatId(String chatId) {
    this.chatId = chatId;
  }

  Stream<MyUser> userFriendStream(String id) {

    return _service
        .documentStream(
            path: Path.user(id), builder: (map) => MyUser.fromMap(map));
  }
  Future addAmongGroupe(String chatId) async {

    return await _service.setData(path: Path.chat(chatId), data: {
      'membres': {uid: true}
    }).then((value) async {
      return await _service.setData(path: Path.chatMembre(chatId,uid), data: {
        'id': uid,
        'lastReading': FieldValue.serverTimestamp(),
        'isReading': true
      });
    });
  }

  Future setIsReading() async {
    return await _service.setData(path: Path.chatMembre(chatId, uid),
        data: {'lastReading': FieldValue.serverTimestamp(), 'isReading': true});
  }


  Future setIsNotReading()async {
    return await _service.setData(path: Path.chatMembre(chatId, uid),
        data: {'lastReading': FieldValue.serverTimestamp(), 'isReading': false});
  }

  void displayAndSendImage(
      File image, ChatRoomChangeNotifier chatRoomRead) {
    String messageId = _service.getDocId(path: Path.messages(chatId));

    String idTo;

    if (!chatRoomRead.myChat.isGroupe) {
      idTo = chatRoomRead.friend.id;
    }

    MyMessage myMessage = MyMessage(
        id: messageId,
        idTo: idTo,
        idFrom: uid,
        type: chatRoomRead.replyMessage.isEmpty
            ? MyMessageType.image
            : MyMessageType.reply,
        replyType: MyMessageReplyType.image,
        date: DateTime.now());

    chatRoomRead.addListPhoto(messageId, image);
    chatRoomRead.addTempMessage(messageId);

    chatRoomRead.myNewMessages(myMessage);

    uploadImageChat(chatRoomRead, image, chatRoomRead.myChat.id, uid, idTo,messageId)
        .then((_) => chatRoomRead.setTempMessageToloaded(messageId))
        .catchError((e) {
      chatRoomRead.setTempMessageToError(messageId);
    });
  }

  Future<void> uploadImageChat(ChatRoomChangeNotifier provider, File image, String chatId,
      String idSender, String friendId,String messageId) async {
    String path = image.path.substring(image.path.lastIndexOf('/') + 1);


    await _service.uploadImg(file: image, path: Path.chatImage(chatId,path), contentType: 'image/jpeg')
        .then((url) {

      MyMessage myMessage = MyMessage(
          id: messageId,
          message: url,
          idTo: friendId,
          idFrom: uid,
          type: provider
              .replyMessage
              .isEmpty ?
          MyMessageType.image : MyMessageType.reply,
          replyMessageId: provider
              .replyMessageId,
          replyType: MyMessageReplyType.image
      );
      if (myMessage.type == MyMessageType.reply) {
        provider.setReplyToNull();
      }
      sendMessage(myMessage);
    });
  }

  void pickGif(BuildContext context,ChatRoomChangeNotifier chatRoomRead) async {
    final gif = await GiphyPicker.pickGif(
        context: context, apiKey: GIPHY_API_KEY);

    if (gif != null) {

      String messageId = _service.getDocId(path: Path.messages(chatId));
      String idTo;

      if (!chatRoomRead.myChat.isGroupe) {
        idTo = chatRoomRead.friend.id;
      }
      MyMessage myMessage = MyMessage(
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

      if (myMessage.type == MyMessageType.reply) {
        chatRoomRead.setReplyToNull();
      }
      sendMessage(myMessage);
    }
  }

  void sendTextMessage(ChatRoomChangeNotifier chatRoomRead,
      TextEditingController textEditingController) {

    String messageId = _service.getDocId(path: Path.messages(chatId));

    String idTo;

    if (!chatRoomRead.myChat.isGroupe) {
      idTo = chatRoomRead.friend.id;
    }
    MyMessage myMessage = MyMessage(
        id: messageId,
        message: textEditingController.text.trim(),
        idTo: idTo,
        idFrom: uid,
        date: DateTime.now(),
        type: chatRoomRead.replyMessage.isEmpty
            ? MyMessageType.text
            : MyMessageType.reply,
        replyMessageId: chatRoomRead.replyMessageId != null
            ? chatRoomRead.replyMessageId
            : '',
        replyType: chatRoomRead.replyMessageId != null
            ? MyMessageReplyType.text
            : null);

    chatRoomRead.addTempMessage(myMessage.id);

    chatRoomRead.myNewMessages(myMessage);

    if (textEditingController.text.trim() != '') {
      chatRoomRead.setShowSendBotton(false);
      textEditingController.clear();
      if (myMessage.type == MyMessageType.reply) {
        chatRoomRead.setReplyToNull();
      }
      sendMessage(myMessage).catchError((err) {
        print(err);
        chatRoomRead.setShowSendBotton(true);
        chatRoomRead.setTempMessageToError(myMessage.id);
      }).whenComplete(() {
        chatRoomRead.setShowSendBotton(false);
        chatRoomRead.setTempMessageToloaded(myMessage.id);
      });
    } else {
      print('Text vide ou null');
    }
  }
}
