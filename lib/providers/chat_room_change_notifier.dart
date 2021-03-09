import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/message.dart';
import 'package:van_events_project/domain/models/my_chat.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_chat_repository.dart';

final chatRoomProvider = ChangeNotifierProvider.autoDispose<ChatRoomChangeNotifier>((ref) {
  return ChatRoomChangeNotifier();
});

final chatRoomFutureProvider = FutureProvider.autoDispose<void>((ref) {
  return ref.read(chatRoomProvider).fetchAllMessages();
});

class ChatRoomChangeNotifier extends ChangeNotifier {
  Timer _throttle;
  String chatId;
  bool showSendBotton = false;
  List<MyMessage> oldMessages;
  GlobalKey<AnimatedListState> listKey;
  MyChat myChat;
  List<MyUser> myUsersList;
  MyUser friend;
  String imageUrl;
  String nomTitre;
  Stream<MyUser> streamUserFriend;
  Map<String, File> listPhoto = <String, File>{};
  Map<String, int> listTempMessages =
      <String, int>{}; //-1 error; 0 loading; 1 success
  DocumentSnapshot lastDocument;
  int documentLimit = 20;
  bool hasNext = true;
  bool isFetchingUsers = false;
  bool isFetchingOldMessage = false;
  bool isLoading = true;
  bool hasError = false;
  bool hasErrorOnFetchingOldMessage = false;
  MyMessage lastOldMessage;
  List<MyMessage> messages = <MyMessage>[];
  BuildContext context;
  MyChatRepository myChatRepo;
  String replyName;
  String replyMessage;
  String replyMessageId;
  String uid;
  MyMessageType replyMessagetype;
  Map<String, MyMessage> myRepliedMessage;
  bool isBlocked;

  File tempImage;

  void setReplyToMessage(
      String name, String message, String messageId, MyMessageType replyType) {
    replyName = name;
    replyMessage = message;
    replyMessageId = messageId;
    replyMessagetype = replyType;
    notifyListeners();
  }

  void setReplyToNull() {
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
    uid = context.read(myUserProvider).id;
    myChatRepo.setChatId(chatId);
    messages = <MyMessage>[];
    oldMessages = <MyMessage>[];
    showSendBotton = false;
    listKey = GlobalKey<AnimatedListState>();
    hasNext = true;
    isLoading = true;
    myRepliedMessage = {};
    isBlocked = false;
  }

  Future<void> fetchAllMessages() async {
    try {
      myChat = await getMyChat(chatId);

      myUsersList = getFinalListUser(await chatUsers(myChat));

      for (final myUser in myUsersList) {// blocked or not
        if(myUser.id == uid){
          continue;
        }
        for(final id in myUser.blockedUser ){
          if(id.toString() == uid){
            isBlocked = true;
            break;
          }
        }
      }

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

      await Future.forEach(oldMessages, (element) async {
        if (element.type == MyMessageType.reply) {
          final MyMessage myMessage =
              await getReplyMessage(element.replyMessageId as String);
          myRepliedMessage.addAll({element.id as String: myMessage});
        }
      });

      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      hasError = true;
      notifyListeners();
    }
  }

  Future<void> fetchOldMessage() async {
    if (isFetchingOldMessage) {
      return;
    }

    isFetchingOldMessage = true;

    notifyListeners();
    try {
      final newOldMessage = await getOldChatMessages(chatId);

      oldMessages.addAll(newOldMessage);

      await Future.forEach(oldMessages, (element) async {
        if (element.type == MyMessageType.reply) {
          final MyMessage myMessage =
              await getReplyMessage(element.replyMessageId as String);
          myRepliedMessage.addAll({element.id as String: myMessage});
        }
      });

      isFetchingOldMessage = false;
      notifyListeners();
    } catch (error) {
      hasErrorOnFetchingOldMessage = true;
      notifyListeners();
    }
  }

  Future<void> myNewMessages(MyMessage myMessage) async {
    if (messages != null && listKey != null) {
      if (myMessage.idFrom == context.read(myUserProvider).id) {
        final AudioCache audioCache = AudioCache();
        final AudioPlayer advancedPlayer = AudioPlayer();

        if (Platform.isIOS) {
          if (audioCache.fixedPlayer != null) {
            audioCache.fixedPlayer.startHeadlessService();
          }
          advancedPlayer.startHeadlessService();
        }

        audioCache.play('sound/send.aac').catchError((e) {
          debugPrint(e.toString());
        });
      }

      if (myMessage.type == MyMessageType.reply) {
        final MyMessage myMessagee =
            await getReplyMessage(myMessage.replyMessageId);
        myRepliedMessage.addAll({myMessage.id: myMessagee});
      }
      messages.insert(0, myMessage);
      listKey.currentState
          .insertItem(0, duration: const Duration(milliseconds: 500));
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

  void setShowSendBotton(bool b) {
    showSendBotton = b;
    notifyListeners();

    myChatRepo.setIsWriting();
    if (_throttle?.isActive ?? false) {
      _throttle.cancel();
    }
    _throttle = Timer(const Duration(seconds: 2), () {
      myChatRepo?.setIsReading();
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
        return <MyMessage>[];
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

  Future<List<List<MyUser>>> chatUsers(MyChat myChat) async {
    final myListOfList = listLimit(myChat.membres.keys.toList(), 10);

    final List<Future<List<MyUser>>> myListFuture = [];

    for (final listOf10 in myListOfList) {
      myListFuture.add(FirebaseFirestore.instance
          .collection('users')
          .where('id', whereIn: listOf10)
          .get()
          .then((users) =>
              users.docs.map((user) => MyUser.fromMap(user.data())).toList()));
    }

    return Future.wait(myListFuture);
    // //TODO whereIn limité a 10
    // return FirebaseFirestore.instance
    //     .collection('users')
    //     .where('id', whereIn: myChat.membres.keys.toList())
    //     .get()
    //     .then((users) =>
    //         users.docs.map((user) => MyUser.fromMap(user.data())).toList());
  }

  List<List<String>> listLimit(List list, int limit) {
    final List<List<String>> toReturn = [<String>[]];

    for (int i = 0; i < list.length; i++) {
      if (toReturn.last.length < limit) {
        toReturn.last.add(list[i].toString());
      } else {
        toReturn.add(<String>[]);
        toReturn.last.add(list[i].toString());
      }
    }

    return toReturn;
  }

  @override
  String toString() {
    return 'ChatRoomChangeNotifier{chatId: $chatId,  showSendBotton: $showSendBotton, oldMessages: $oldMessages, listKey: $listKey, myChat: $myChat, myUsersList: $myUsersList, friend: $friend, imageUrl: $imageUrl, nomTitre: $nomTitre, streamUserFriend: $streamUserFriend, listPhoto: $listPhoto, listTempMessages: $listTempMessages, lastDocument: $lastDocument, documentLimit: $documentLimit, hasNext: $hasNext, isFetchingUsers: $isFetchingUsers, isFetchingOldMessage: $isFetchingOldMessage, isLoading: $isLoading, hasError: $hasError, hasErrorOnFetchingOldMessage: $hasErrorOnFetchingOldMessage, lastOldMessage: $lastOldMessage, messages: $messages, context: $context, db: $myChatRepo, replyName: $replyName, replyMessage: $replyMessage, replyMessagetype: $replyMessagetype, myRepliedMessage: $myRepliedMessage}';
  }

  Future<MyMessage> getReplyMessage(String replyMessageId) async {
    return myChatRepo.getMessage(chatId, replyMessageId);
  }

  void setAllNull() {
    replyName = null;
    replyMessage = null;
    chatId = null;
    context = null;
    myChatRepo = null;
    messages = null;
    oldMessages = null;
    showSendBotton = null;
    listKey = null;
    hasNext = null;
    isLoading = null;
  }

  void setNewTempImage(File file) {
    tempImage = file;

    notifyListeners();
  }

  void newCall(MyMessage myMessage) {
    if (messages != null && listKey != null) {
      messages.insert(0, myMessage);
      listKey.currentState
          .insertItem(0, duration: const Duration(milliseconds: 500));
    }
  }

  List<MyUser> getFinalListUser(List<List<MyUser>> list) {
    final List<MyUser> toReturn = [];

    for (final myList in list) {
      for (final myUser in myList) {
        toReturn.add(myUser);
      }
    }

    return toReturn;
  }

  MyUser getUserFriend() {

   return myUsersList.firstWhere((element) => element.id != uid);

  }

  void setIsBlocked() {
    isBlocked = true;
    //notifyListeners();
  }
}
