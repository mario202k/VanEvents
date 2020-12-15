import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:van_events_project/constants/credentials.dart';
import 'package:van_events_project/domain/models/message.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_chat_repository.dart';
import 'package:van_events_project/presentation/widgets/chatMessageListItem.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/providers/chat_room_change_notifier.dart';

class ChatRoom extends StatefulWidget {
  final String chatId;

  ChatRoom(this.chatId);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with WidgetsBindingObserver {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode textFieldFocus = FocusNode();
  final scrollController = ScrollController();
  MyChatRepository db;
  ChatRoomChangeNotifier chatRoomRead;
  List<int> listColors =
      List<int>.generate(Colors.primaries.length, (int index) => index);

  @override
  void initState() {
    listColors.shuffle();
    WidgetsBinding.instance.addObserver(this);
    scrollController.addListener(scrollListener);
    chatRoomRead = context.read(chatRoomProvider);
    db = context.read(myChatRepositoryProvider);
    chatRoomRead.initial(widget.chatId, context);

    context.read(chatRoomProvider).fetchAllMessages();
    super.initState();
  }

  void scrollListener() {
    if (scrollController.offset >=
            scrollController.position.maxScrollExtent * 0.3 &&
        !scrollController.position.outOfRange) {
      if (context.read(chatRoomProvider).hasNext) {
        context.read(chatRoomProvider).fetchOldMessage();
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    db.setIsNotReading();
    chatRoomRead.setAllNull();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        db.setIsNotReading();
        break;
      case AppLifecycleState.resumed:
        db.setIsReading();
        break;
      case AppLifecycleState.inactive:
        db.setIsNotReading();
        break;
      case AppLifecycleState.detached:
        db.setIsNotReading();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('buildChatRoom');

    return ModelScreen(
      child: Consumer(builder: (context, watch, child) {
        chatRoomRead = context.read(chatRoomProvider);
        final future = watch(chatRoomFutureProvider);

        if (!chatRoomRead.isLoading) {
          db.setIsReading();
        }
        return Scaffold(
          body: future.when(
            loading: () => Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary)),
            ),
            error: (e, s) => Center(
              child: Text(
                'Erreur de connexion',
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
            data: (data) {
              return Scaffold(
                appBar: AppBar(
                    elevation: 0.4,
                    iconTheme: IconThemeData(color: Colors.black),
                    backgroundColor: Colors.white,
                    leading: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: BackButtonIcon()),
                    title: Row(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
                            child: Visibility(
                              visible: chatRoomRead.imageUrl.isNotEmpty,
                              child: CachedNetworkImage(
                                imageUrl: chatRoomRead.imageUrl,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(44)),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.white,
                                  highlightColor:
                                      Theme.of(context).colorScheme.primary,
                                  child: CircleAvatar(
                                    radius: 22,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              replacement: CircleAvatar(
                                radius: 25,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                backgroundImage: AssetImage(
                                    'assets/img/normal_user_icon.png'),
                              ),
                            )),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                chatRoomRead.nomTitre,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              Visibility(
                                visible: !chatRoomRead.myChat.isGroupe,
                                child: StreamBuilder<MyUser>(
                                    stream: chatRoomRead.streamUserFriend,
                                    builder: (context, snapshot) {
                                      MyUser user = snapshot.data;
                                      return user != null
                                          ? Text(
                                              user.isLogin
                                                  ? 'En ligne'
                                                  : isToday(user.lastActivity)
                                                      ? 'Vu aujourd\'hui à ${DateFormat.Hm().format(user.lastActivity)}'
                                                      : DateFormat('dd/MM/yy')
                                                          .format(user
                                                              .lastActivity),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption,
                                            )
                                          : SizedBox();
                                    }),
                              )
                            ],
                          ),
                        ),
                      ],
                    )),
                body: Stack(
                  children: [
                    Consumer(builder: (context, watch, child) {
                      final watchChat = watch(chatRoomProvider);
                      return Visibility(
                        visible: watchChat.isFetchingOldMessage,
                        child: Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary)),
                        ),
                        replacement: Visibility(
                          visible:
                              watchChat.oldMessages.isEmpty &&

                                  watchChat.messages.isEmpty,
                          child: Center(child: Text('Pas de messages.')),
                        ),
                      );
                    }),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            physics: ClampingScrollPhysics(),
                            controller: scrollController,
                            reverse: true,
                            child: Column(
                              children: [
                                ListView.builder(
                                    reverse: true,
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    itemCount: chatRoomRead.oldMessages.length,
                                    itemBuilder: (context, index) {
                                      final oldMessage =
                                          chatRoomRead.oldMessages[index];

                                      final MyUser userFrom = chatRoomRead
                                          .myUsersList
                                          .firstWhere((user) =>
                                              user.id == oldMessage.idFrom);
                                      MyUser replyUser;
                                      MyMessage replyMessage;
                                      if (oldMessage.type ==
                                          MyMessageType.reply) {
                                        replyMessage = chatRoomRead
                                            .myRepliedMessage[oldMessage.id];

                                        replyUser = chatRoomRead.myUsersList
                                            .firstWhere((user) =>
                                                user.id ==
                                                chatRoomRead
                                                    .myRepliedMessage[
                                                        oldMessage.id]
                                                    .idFrom);
                                      }

                                      return Column(
                                        children: [
                                          Visibility(
                                            visible: isAnotherDay(index,
                                                chatRoomRead.oldMessages),
                                            child: Text(
                                              isToday(oldMessage.date)
                                                  ? 'Aujourd\'hui'
                                                  : isYesterday(oldMessage.date)
                                                      ? 'Hier'
                                                      : ' ${day(oldMessage.date.weekday)} ${oldMessage.date.day} ${month(oldMessage.date.month)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4,
                                            ),
                                          ),
                                          db.uid != oldMessage.idFrom
                                              ? SwipeTo(
                                                  onRightSwipe: () {
                                                    chatRoomRead
                                                        .setReplyToMessage(
                                                            userFrom.nom,
                                                            oldMessage.message,
                                                            oldMessage.id,
                                                            oldMessage.type);
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            textFieldFocus);
                                                  },
                                                  rightSwipeWidget: Icon(
                                                    FontAwesomeIcons.reply,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                  child: ChatMessageListItem(
                                                    message: oldMessage,
                                                    isMe: db.uid ==
                                                        oldMessage.idFrom,
                                                    chatId:
                                                        chatRoomRead.myChat.id,
                                                    isGroupe: chatRoomRead
                                                        .myChat.isGroupe,
                                                    friendName: userFrom.nom,
                                                    //name
                                                    friendUrl:
                                                        userFrom.imageUrl,
                                                    idTo: oldMessage.idTo,
                                                    replyName: replyUser?.nom,
                                                    replyMessage:
                                                        replyMessage,
                                                    replyType:
                                                        oldMessage.replyType,
                                                    replyIsFromMe:
                                                        replyUser?.id == db.uid,
                                                  ),
                                                )
                                              : ChatMessageListItem(
                                                  message: oldMessage,
                                                  isMe: db.uid ==
                                                      oldMessage.idFrom,
                                                  chatId:
                                                      chatRoomRead.myChat.id,
                                                  isGroupe: chatRoomRead
                                                      .myChat.isGroupe,
                                                  friendName: userFrom.nom,
                                                  //name
                                                  friendUrl: userFrom.imageUrl,
                                                  idTo: oldMessage.idTo,
                                                  replyName: replyUser?.nom,
                                                  replyMessage: replyMessage,
                                                  replyType:
                                                  oldMessage.replyType,
                                                  replyIsFromMe:
                                                      replyUser?.id == db.uid,
                                                ),
                                        ],
                                      );
                                    }),
                                listNewMessage(db, chatRoomRead),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: 1.0,
                          thickness: 2,
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor),
                            child: _buildTextComposer(db, chatRoomRead)),
                        Consumer(builder: (context, watch, child) {
                          return Visibility(
                            visible: watch(chatRoomProvider).showEmojiPicker ??
                                false,
                            child: emojiContainer(chatRoomRead),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget listNewMessage(
      MyChatRepository db, ChatRoomChangeNotifier chatRoomRead) {
    return AnimatedList(
      //initialItemCount: chatRoomRead.messages?.length ?? 0,
      key: chatRoomRead.listKey,
      padding: EdgeInsets.all(8.0),
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      reverse: true,
      itemBuilder:
          (BuildContext context, int index, Animation<double> animation) {
        MyUser userFrom = chatRoomRead.myUsersList.firstWhere(
            (user) => user.id == chatRoomRead.messages.first.idFrom);

        final newMessage = chatRoomRead.messages[index];

        MyUser replyUser;
        MyMessage replyMessage;
        if (newMessage.type == MyMessageType.reply) {
          replyMessage = chatRoomRead.myRepliedMessage[newMessage.id];

          replyUser = chatRoomRead.myUsersList.firstWhere((user) =>
              user.id == chatRoomRead.myRepliedMessage[newMessage.id].idFrom);
        }

        return SizeTransition(
            axis: Axis.vertical,
            sizeFactor: animation,
            child: Column(
              children: <Widget>[
                Visibility(
                  visible: isAnotherDayNewMessage(index, chatRoomRead.messages,
                      chatRoomRead.lastOldMessage),
                  child: Text(
                    isToday(chatRoomRead.messages[index].date)
                        ? 'Aujourd\'hui'
                        : isYesterday(chatRoomRead.messages[index].date)
                            ? 'Hier'
                            : ' ${day(chatRoomRead.messages[index].date.weekday)} ${chatRoomRead.messages[index].date.day} ${month(chatRoomRead.messages[index].date.month)}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                db.uid == newMessage.idFrom?ChatMessageListItem(
                  message: newMessage,
                  isMe: db.uid == newMessage.idFrom,
                  chatId: chatRoomRead.myChat.id,
                  isGroupe: chatRoomRead.myChat.isGroupe,
                  friendName: userFrom.nom,
                  //name
                  friendUrl: userFrom.imageUrl,
                  idTo: newMessage.idTo,
                  replyName: replyUser?.nom,
                  replyMessage: replyMessage,
                  replyType: newMessage?.replyType,
                  replyIsFromMe: replyUser?.id == db.uid,
                ):SwipeTo(
                  onRightSwipe: () {
                    chatRoomRead
                        .setReplyToMessage(
                        userFrom.nom,
                        newMessage.message,
                        newMessage.id,
                        newMessage.type);
                    FocusScope.of(context)
                        .requestFocus(
                        textFieldFocus);
                  },
                  rightSwipeWidget: Icon(
                    FontAwesomeIcons.reply,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                  child: ChatMessageListItem(

                    message: newMessage,
                    isMe: db.uid == newMessage.idFrom,
                    chatId: chatRoomRead.myChat.id,
                    isGroupe: chatRoomRead.myChat.isGroupe,
                    friendName: userFrom.nom,
                    //name
                    friendUrl: userFrom.imageUrl,
                    idTo: newMessage.idTo,
                    replyName: replyUser?.nom,
                    replyMessage: replyMessage,
                    replyType: newMessage?.replyType,
                    replyIsFromMe: replyUser?.id == db.uid,
                  ),
                )
              ],
            ));
      },
    );
  }

  emojiContainer(ChatRoomChangeNotifier chatRoomRead) {
    double height = MediaQuery.of(context).size.height;
    return LayoutBuilder(builder: (context, constraint) {
      return LimitedBox(
        maxWidth: constraint.maxWidth,
        maxHeight: constraint.maxHeight * 0.2,
        child: FittedBox(
          child: EmojiPicker(
            bgColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            rows: height < 700 ? 1 : 3,
            columns: 7,
            onEmojiSelected: (emoji, category) {
              chatRoomRead.setShowSendBotton(true);
              _textEditingController.text =
                  _textEditingController.text + emoji.emoji;
            },
          ),
        ),
      );
    });
  }

  String day(int week) {
    switch (week) {
      case DateTime.monday:
        return 'Lundi';
      case DateTime.tuesday:
        return 'Mardi';
      case DateTime.wednesday:
        return 'Mercredi';
      case DateTime.thursday:
        return 'Jeudi';
      case DateTime.friday:
        return 'Vendredi';
      case DateTime.saturday:
        return 'Samedi';
      case DateTime.sunday:
        return 'Dimanche';
    }
  }

  String month(int month) {
    switch (month) {
      case DateTime.january:
        return 'Janvier';
      case DateTime.february:
        return 'Février';
      case DateTime.march:
        return 'Mars';
      case DateTime.april:
        return 'Avril';
      case DateTime.may:
        return 'Mai';
      case DateTime.june:
        return 'Juin';
      case DateTime.july:
        return 'Juillet';
      case DateTime.august:
        return 'Août';
      case DateTime.september:
        return 'Septembre';
      case DateTime.october:
        return 'Octobre';
      case DateTime.november:
        return 'Novembre';
      case DateTime.december:
        return 'Décembre';
    }
  }

  bool isAnotherDay(int index, List<MyMessage> messages) {
    if (index == messages.length - 1) {
      return true;
    }

    bool b = false;

    if (index > 0 && index < messages.length - 1) {
      if (messages[index].date.day > messages[index + 1].date.day) {
        b = true;
      }
    }

    return b;
  }

  bool isAnotherDayNewMessage(
      int index, List<MyMessage> messages, MyMessage lastOldMyMessage) {
    if (lastOldMyMessage == null) {
      return true;
    }

    if (index == messages.length - 1) {
      if (messages[index].date.day == lastOldMyMessage.date.day) {
        return false;
      }
    }

    return isAnotherDay(index, messages);
  }

  bool isToday(DateTime date) {
    bool b = false;

    if (date.day == DateTime.now().day) {
      b = true;
    }

    return b;
  }

  bool isYesterday(DateTime date) {
    bool b = false;

    if (date.day + 1 == DateTime.now().day) {
      b = true;
    }

    return b;
  }

  Future _getImageCamera(
      MyChatRepository db, ChatRoomChangeNotifier chatRoomRead) async {
    PickedFile image = await ImagePicker().getImage(source: ImageSource.camera);

    db.displayAndSendImage(File(image.path), chatRoomRead);
  }



  Future _getImageGallery(
      MyChatRepository db, ChatRoomChangeNotifier chatRoomRead) async {
    PickedFile image =
        await ImagePicker().getImage(source: ImageSource.gallery);

    db.displayAndSendImage(File(image.path), chatRoomRead);
  }

  Widget _buildTextComposer(
      MyChatRepository db, ChatRoomChangeNotifier chatRoomRead) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Consumer(builder: (context, watch, child) {
            return Visibility(
              visible: watch(chatRoomProvider).replyMessage.isNotEmpty,
              child: Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Container(
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: Theme.of(context).colorScheme.primary,
                                width: 4,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chatRoomRead.replyName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                  chatRoomRead.replyMessagetype ==
                                          MyMessageType.text
                                      ? Text(
                                          chatRoomRead.replyMessage,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5,
                                        )
                                      : CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              Shimmer.fromColors(
                                            baseColor: Colors.white,
                                            highlightColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            child: Container(
                                                height: 200,
                                                width: 200,
                                                color: Colors.white),
                                          ),
                                          imageBuilder: (context,
                                                  imageProvider) =>
                                              SizedBox(
                                                  height: 220,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.8,
                                                  child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Image(
                                                        image: imageProvider),
                                                  )),
                                          errorWidget: (context, url, error) =>
                                              Material(
                                            child: Image.asset(
                                              'assets/img/img_not_available.jpeg',
                                              width: 200.0,
                                              height: 200.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                          ),
                                          imageUrl: chatRoomRead.replyMessage,
                                          fit: BoxFit.scaleDown,
                                        )
                                ],
                              )),
                              IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () =>
                                      chatRoomRead.setReplyToNull()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SizedBox(),
                  )
                ],
              ),
            );
          }),
          Row(children: [
            Container(
              child: IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: Icon(Icons.photo),
                onPressed: () {
                  showSourceChoice(db, chatRoomRead);
                },
              ),
            ),
            Container(
              child: IconButton(
                color: Theme.of(context).colorScheme.primary,
                iconSize: 35,
                icon: Icon(Icons.gif),
                onPressed: () {
                  context.read(myChatRepositoryProvider).pickGif(context, chatRoomRead);
                },
              ),
            ),
            Flexible(
              child: Stack(
                children: <Widget>[
                  TextField(
                    controller: _textEditingController,
                    focusNode: textFieldFocus,
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: Colors.black),
                    onTap: () {
                      chatRoomRead.setShowEmojiPicker(false);
                    },
                    onChanged: (val) {
                      if (val.length > 0 && val.trim() != '') {
                        chatRoomRead.setShowSendBotton(true);
                      } else {
                        chatRoomRead.setShowSendBotton(false);
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: 'Saisir un message',
                      hintStyle: Theme.of(context).textTheme.headline5,
                    ),
                    maxLines: null,
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                        color: Theme.of(context).colorScheme.primary,
                        icon: Icon(FontAwesomeIcons.smile),
                        onPressed: () {
                          if (!chatRoomRead.showEmojiPicker) {
                            textFieldFocus.unfocus();

                            chatRoomRead.setShowEmojiPicker(true);
                          } else {
                            textFieldFocus.requestFocus();
                            chatRoomRead.setShowEmojiPicker(false);
                          }
                        }),
                  ),
                ],
              ),
            ),
            Consumer(builder: (context, watch, child) {
              return Visibility(
                  visible: watch(chatRoomProvider).showSendBotton,
                  child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconButton(
                          color: Theme.of(context).colorScheme.primary,
                          icon: Icon(Icons.send),
                          onPressed: () => db.sendTextMessage(
                              chatRoomRead,_textEditingController))));
            })
          ]),
        ],
      ),
    );
  }

  void showSourceChoice(
      MyChatRepository db, ChatRoomChangeNotifier chatRoomRead) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: Text(
            'Source?',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          actions: <Widget>[
            PlatformDialogAction(
              child: Text(
                'Caméra',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _getImageCamera(db, chatRoomRead);
              },
            ),
            PlatformDialogAction(
              child: Text(
                'Galerie',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              //actionType: ActionType.,
              onPressed: () {
                Navigator.of(context).pop();
                _getImageGallery(db, chatRoomRead);
              },
            ),
          ],
        );
      },
    );
  }




}
