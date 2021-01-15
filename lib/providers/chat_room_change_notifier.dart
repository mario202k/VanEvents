import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/message.dart';
import 'package:van_events_project/domain/models/my_chat.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_chat_repository.dart';


final chatRoomProvider = ChangeNotifierProvider<ChatRoomChangeNotifier>((ref) {
  return ChatRoomChangeNotifier();
});

final chatRoomFutureProvider = FutureProvider.autoDispose<void>((ref) {
  return ref.read(chatRoomProvider).fetchAllMessages();
});

class ChatRoomChangeNotifier extends ChangeNotifier {
  Timer _throttle;
  String chatId;
  bool showSendBotton = false;
  List<MyMessage> oldMessages = List<MyMessage>();
  GlobalKey<AnimatedListState> listKey;
  MyChat myChat;
  List<MyUser> myUsersList;
  MyUser friend;
  String imageUrl;
  String nomTitre;
  Stream<MyUser> streamUserFriend;
  Map<String, File> listPhoto = Map<String, File>();
  Map<String, int> listTempMessages =
      Map<String, int>(); //-1 error; 0 loading; 1 success
  DocumentSnapshot lastDocument;
  int documentLimit = 20;
  bool hasNext = true;
  bool isFetchingUsers = false;
  bool isFetchingOldMessage = false;
  bool isLoading = true;
  bool hasError = false;
  bool hasErrorOnFetchingOldMessage = false;
  MyMessage lastOldMessage;
  List<MyMessage> messages = List<MyMessage>();
  BuildContext context;
  MyChatRepository myChatRepo;
  String replyName;
  String replyMessage;
  String replyMessageId;
  MyMessageType replyMessagetype;
  Map<String, MyMessage> myRepliedMessage;

  File tempImage;

  void setReplyToMessage(String name, String message,String messageId, MyMessageType replyType) {
    replyName = name;
    replyMessage = message;
    replyMessageId = messageId;
    this.replyMessagetype = replyType;
    notifyListeners();
  }
  setReplyToNull() {
    replyName = '';
    replyMessage = '';
    replyMessageId = '';
    replyMessagetype = null;
    notifyListeners();
  }

  void initial(String chatId, BuildContext context) {
    replyName = '';
    replyMessage = '';
    this.chatId = chatId;
    this.context = context;
    myChatRepo = context.read(myChatRepositoryProvider);
    myChatRepo.setChatId(chatId);
    messages = List<MyMessage>();
    oldMessages = List<MyMessage>();
    showSendBotton = false;
    listKey = GlobalKey<AnimatedListState>();
    hasNext = true;
    isLoading = true;
    myRepliedMessage = {};
  }

  Future<void> fetchAllMessages() async {

    try {
      myChat = await getMyChat(chatId);

      myUsersList = await chatUsers(myChat);

      oldMessages = await getChatMessages(chatId);

      if (oldMessages.isNotEmpty) {
        lastOldMessage = oldMessages.first;
      }


      if (!myChat.isGroupe) {

        friend = myUsersList.firstWhere((user) => user.id != myChatRepo.uid);
        streamUserFriend = myChatRepo.userFriendStream(friend.id);
        imageUrl = friend.imageUrl;
        nomTitre = friend.nom;
      } else {
        imageUrl = myChat.imageUrl;
        nomTitre = myChat.titre;
      }
      isLoading = false;

      await Future.forEach(oldMessages, (element) async{
        if (element.type == MyMessageType.reply) {
          MyMessage myMessage = await getReplyMessage(element.replyMessageId);
          myRepliedMessage.addAll({element.id: myMessage});
        }
      });

      notifyListeners();
    } catch (error) {
      print(error);
      hasError = true;
      notifyListeners();
    }
  }

  void fetchOldMessage() async {
    if (isFetchingOldMessage) {
      return;
    }

    isFetchingOldMessage = true;

    notifyListeners();
    try {
      final newOldMessage = await getOldChatMessages(chatId);

      oldMessages.addAll(newOldMessage);

      isFetchingOldMessage = false;
      notifyListeners();
    } catch (error) {
      hasErrorOnFetchingOldMessage = true;
      notifyListeners();
    }
  }

  void myNewMessages(MyMessage myMessage) async {
    if (messages != null && listKey != null) {
      if (myMessage.type == MyMessageType.reply) {
        MyMessage myMessagee = await getReplyMessage(myMessage.replyMessageId);
        myRepliedMessage.addAll({myMessage.id: myMessagee});
      }
      messages.insert(0, myMessage);
      listKey.currentState.insertItem(0, duration: Duration(milliseconds: 500));

    }
  }

  void setTempMessageToError(String id) {
    listTempMessages[id] = -1;
    notifyListeners();
  }

  void setTempMessageToloaded(String id) {
    listTempMessages[id] = 1;
    notifyListeners();
  }

  setShowSendBotton(bool b) {

    showSendBotton = b;
    notifyListeners();

    myChatRepo.setIsWriting();
    if (_throttle?.isActive ?? false) {
      _throttle.cancel();
    }
    _throttle = Timer(const Duration(seconds: 2), (){
      myChatRepo.setIsReading();
    });
  }

  void addListPhoto(String path, File image) {
    listPhoto.addAll({path: image});
  }

  void addTempMessage(String id) {
    listTempMessages.addAll({id: 0});
  }

  Future<List<MyMessage>> getChatMessages(String chatId) {


    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .limit(documentLimit)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        return List<MyMessage>();
      }

      lastDocument = value.docs.last;

      if (value.docs.length < documentLimit) {
        hasNext = false;
      }

      return value.docs.map((doc) => MyMessage.fromMap(doc.data())).toList();
    });
  }

  Future<List<MyMessage>> getOldChatMessages(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .startAfterDocument(lastDocument)
        .limit(documentLimit)
        .get()
        .then((value) {
      lastDocument = value.docs.last;

      if (value.docs.length < documentLimit) {
        hasNext = false;
      }

      return value.docs.map((doc) => MyMessage.fromMap(doc.data())).toList();
    });
  }

  Future<MyChat> getMyChat(String chatId) {

    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .get()
        .then((doc) => MyChat.fromMap(doc.data()));
  }

  Future<List<MyUser>> chatUsers(MyChat myChat) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('id', whereIn: myChat.membres.keys.toList())
        .get()
        .then((users) => users.docs
            .map((user) => MyUser.fromMap(user.data()))
            .toList());
  }

  @override
  String toString() {
    return 'ChatRoomChangeNotifier{chatId: $chatId,  showSendBotton: $showSendBotton, oldMessages: $oldMessages, listKey: $listKey, myChat: $myChat, myUsersList: $myUsersList, friend: $friend, imageUrl: $imageUrl, nomTitre: $nomTitre, streamUserFriend: $streamUserFriend, listPhoto: $listPhoto, listTempMessages: $listTempMessages, lastDocument: $lastDocument, documentLimit: $documentLimit, hasNext: $hasNext, isFetchingUsers: $isFetchingUsers, isFetchingOldMessage: $isFetchingOldMessage, isLoading: $isLoading, hasError: $hasError, hasErrorOnFetchingOldMessage: $hasErrorOnFetchingOldMessage, lastOldMessage: $lastOldMessage, messages: $messages, context: $context, db: $myChatRepo, replyName: $replyName, replyMessage: $replyMessage, replyMessagetype: $replyMessagetype, myRepliedMessage: $myRepliedMessage}';
  }

  Future<MyMessage> getReplyMessage(String replyMessageId) async{

    return await myChatRepo.getMessage(chatId,replyMessageId);

  }

  void setAllNull() {
    replyName = null;
    replyMessage = null;
    this.chatId = null;
    this.context = null;
    myChatRepo = null;
    messages = null;
    oldMessages = null;
    showSendBotton = null;
    listKey = null;
    hasNext = null;
    isLoading = null;

  }

  void setNewTempImage(File file) {
    this.tempImage = file;

    notifyListeners();
  }
}
