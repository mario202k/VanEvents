import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:van_events_project/domain/models/chat_membres.dart';
import 'package:van_events_project/domain/models/message.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_chat_repository.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/chat_message_list_item.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/call_change_notifier.dart';
import 'package:van_events_project/providers/chat_room_change_notifier.dart';

class ChatRoom extends StatefulWidget {
  final String chatId;

  const ChatRoom(this.chatId);

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
    return ModelScreen(
      child: Consumer(builder: (context, watch, child) {
        chatRoomRead = context.read(chatRoomProvider);
        final future = watch(chatRoomFutureProvider);

        if (!chatRoomRead.isLoading) {
          db.setIsReading();
        }
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
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
                backgroundColor: Theme.of(context).colorScheme.background,
                appBar: AppBar(
                    elevation: 10,
                    shadowColor: Theme.of(context).colorScheme.onBackground,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      color: Theme.of(context).colorScheme.onBackground,
                      icon: const BackButtonIcon(),
                    ),
                    actions: [
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.camera,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        onPressed: () async {

                          await db.sendCall(chatRoomRead,true);

                          ExtendedNavigator.of(context).push(
                              Routes.callScreen,
                              arguments: CallScreenArguments(
                                  imageUrl: chatRoomRead.friend.imageUrl,
                                  isVideoCall: true,
                                  channel: context.read(myUserProvider).id,
                                  nom: chatRoomRead.friend.nom));

                        },
                      ),
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.phone,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        onPressed: () async {

                          await db.sendCall(chatRoomRead,false);

                          ExtendedNavigator.of(context).push(
                              Routes.callScreen,
                              arguments: CallScreenArguments(
                                  imageUrl: chatRoomRead.friend.imageUrl,
                                  isVideoCall: false,
                                  channel: context.read(myUserProvider).id,
                                  nom: chatRoomRead.friend.nom));

                        },
                      ),
                    ],
                    title: InkWell(
                      onTap: () {
                        if (chatRoomRead.imageUrl?.isNotEmpty ?? false) {
                          ExtendedNavigator.of(context).push(Routes.fullPhoto,
                              arguments: FullPhotoArguments(
                                  url: chatRoomRead.imageUrl));
                        }
                      },
                      child: Row(
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
                              child: chatRoomRead.imageUrl?.isNotEmpty ?? false
                                  ? CachedNetworkImage(
                                      imageUrl: chatRoomRead.imageUrl,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        height: 44,
                                        width: 44,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(44)),
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
                                        highlightColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        child: const CircleAvatar(
                                          radius: 22,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    )
                                  : CircleAvatar(
                                      radius: 25,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      backgroundImage: const AssetImage(
                                          'assets/img/normal_user_icon.png'),
                                    )),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  chatRoomRead.nomTitre,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                if (!chatRoomRead.myChat.isGroupe)
                                  StreamBuilder<MyUser>(
                                      stream: chatRoomRead.streamUserFriend,
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const SizedBox();
                                        }
                                        final MyUser user = snapshot.data;

                                        return StreamBuilder<ChatMembre>(
                                            stream: context
                                                .read(myChatRepositoryProvider)
                                                .getChatMembre(
                                                    widget.chatId, user.id),
                                            builder: (context, snapshot) {
                                              final ChatMembre chatMembre =
                                                  snapshot.data;

                                              return user != null
                                                  ? Text(
                                                      user.isLogin
                                                          ? chatMembre?.isWriting ??
                                                                  false
                                                              ? 'écrit...'
                                                              : 'En ligne'
                                                          : isToday(user
                                                                  .lastActivity)
                                                              ? 'Vu aujourd\'hui à ${DateFormat.Hm().format(user.lastActivity)}'
                                                              : DateFormat(
                                                                      'dd/MM/yy')
                                                                  .format(user
                                                                      .lastActivity),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .caption,
                                                    )
                                                  : const SizedBox();
                                            });
                                      })
                                else
                                  const SizedBox()
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                body: Stack(
                  children: [
                    Consumer(builder: (context, watch, child) {
                      final watchChat = watch(chatRoomProvider);
                      return watchChat.isFetchingOldMessage
                          ? Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.primary)),
                            )
                          : watchChat.oldMessages.isEmpty &&
                                  watchChat.messages.isEmpty
                              ? Center(
                                  child: Text(
                                  'Pas de messages.',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ))
                              : const SizedBox();
                    }),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            physics: const ClampingScrollPhysics(),
                            controller: scrollController,
                            reverse: true,
                            child: Column(
                              children: [
                                ListView.builder(
                                    reverse: true,
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
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
                                          if (isAnotherDay(
                                              index, chatRoomRead.oldMessages))
                                            Text(
                                              isToday(oldMessage.date)
                                                  ? 'Aujourd\'hui'
                                                  : isYesterday(oldMessage.date)
                                                      ? 'Hier'
                                                      : ' ${day(oldMessage.date.weekday)} ${oldMessage.date.day} ${month(oldMessage.date.month)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground),
                                            )
                                          else
                                            const SizedBox(),
                                          if (db.uid != oldMessage.idFrom)
                                            SwipeTo(
                                              onRightSwipe: () {
                                                chatRoomRead.setReplyToMessage(
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
                                                isMe:
                                                    db.uid == oldMessage.idFrom,
                                                chatId: chatRoomRead.myChat.id,
                                                isGroupe: chatRoomRead
                                                    .myChat.isGroupe,
                                                friendName: userFrom.nom,
                                                //name
                                                friendUrl: userFrom.imageUrl,
                                                idTo: oldMessage.idTo,
                                                replyName: replyUser?.nom,
                                                replyMessage: replyMessage,
                                                replyType: oldMessage.replyType,
                                                replyIsFromMe:
                                                    replyUser?.id == db.uid,
                                              ),
                                            )
                                          else
                                            ChatMessageListItem(
                                              message: oldMessage,
                                              isMe: db.uid == oldMessage.idFrom,
                                              chatId: chatRoomRead.myChat.id,
                                              isGroupe:
                                                  chatRoomRead.myChat.isGroupe,
                                              friendName: userFrom.nom,
                                              //name
                                              friendUrl: userFrom.imageUrl,
                                              idTo: oldMessage.idTo,
                                              replyName: replyUser?.nom,
                                              replyMessage: replyMessage,
                                              replyType: oldMessage.replyType,
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
                        const SizedBox(
                          height: 4,
                        ),
                        const Divider(
                          height: 1.0,
                          thickness: 2,
                        ),
                        Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                            ),
                            child: _buildTextComposer(db, chatRoomRead)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          bottomSheet: Consumer(builder: (context, watch, child) {
            final tempImage = watch(chatRoomProvider).tempImage;

            return tempImage != null
                ? LimitedBox(
                    maxHeight: 200,
                    child: FittedBox(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Theme.of(context).colorScheme.background,
                        child: Column(
                          children: [
                            Text(
                              'Voulez-vous envoyer cette image?',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: LimitedBox(
                                    maxHeight: 200,
                                    child: Image(
                                      image: FileImage(tempImage),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                                LimitedBox(
                                  maxHeight: 200,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                          ),
                                          onPressed: () => chatRoomRead
                                              .setNewTempImage(null)),
                                      IconButton(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          icon: FaIcon(
                                            FontAwesomeIcons.paperPlane,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                          ),
                                          onPressed: () {
                                            db.displayAndSendImage(
                                                tempImage, chatRoomRead);
                                            chatRoomRead.setNewTempImage(null);
                                          }),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox();
          }),
        );
      }),
    );
  }

  Widget listNewMessage(
      MyChatRepository db, ChatRoomChangeNotifier chatRoomRead) {
    return AnimatedList(
      //initialItemCount: chatRoomRead.messages?.length ?? 0,
      key: chatRoomRead.listKey,
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      reverse: true,
      itemBuilder:
          (BuildContext context, int index, Animation<double> animation) {
        final MyUser userFrom = chatRoomRead.myUsersList.firstWhere(
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
            axis: Axis.horizontal,
            sizeFactor: animation,
            child: Column(
              children: <Widget>[
                if (isAnotherDayNewMessage(
                    index, chatRoomRead.messages, chatRoomRead.lastOldMessage))
                  Text(
                    isToday(chatRoomRead.messages[index].date)
                        ? 'Aujourd\'hui'
                        : isYesterday(chatRoomRead.messages[index].date)
                            ? 'Hier'
                            : ' ${day(chatRoomRead.messages[index].date.weekday)} ${chatRoomRead.messages[index].date.day} ${month(chatRoomRead.messages[index].date.month)}',
                    style: Theme.of(context).textTheme.headline4,
                  )
                else
                  const SizedBox(),
                if (db.uid == newMessage.idFrom)
                  ChatMessageListItem(
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
                  )
                else
                  SwipeTo(
                    onRightSwipe: () {
                      chatRoomRead.setReplyToMessage(userFrom.nom,
                          newMessage.message, newMessage.id, newMessage.type);
                      FocusScope.of(context).requestFocus(textFieldFocus);
                    },
                    rightSwipeWidget: Icon(
                      FontAwesomeIcons.reply,
                      color: Theme.of(context).colorScheme.primary,
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
      default: //DateTime.sunday
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
      default: //DateTime.december
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
    final PickedFile image =
        await ImagePicker().getImage(source: ImageSource.camera);

    db.displayAndSendImage(File(image.path), chatRoomRead);
  }

  Future _getImageGallery(
      MyChatRepository db, ChatRoomChangeNotifier chatRoomRead) async {
    final PickedFile image =
        await ImagePicker().getImage(source: ImageSource.gallery);

    db.displayAndSendImage(File(image.path), chatRoomRead);
  }

  Widget _buildTextComposer(
      MyChatRepository db, ChatRoomChangeNotifier chatRoomRead) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Consumer(builder: (context, watch, child) {
            return watch(chatRoomProvider).replyMessage?.isNotEmpty ?? false
                ? Container(
                    clipBehavior: Clip.hardEdge,
                    constraints:
                        const BoxConstraints(maxHeight: 200, maxWidth: 300),
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 5,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        chatRoomRead.replyName,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                    ),
                                    IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        onPressed: () =>
                                            chatRoomRead.setReplyToNull()),
                                  ],
                                ),
                                Expanded(
                                  child: chatRoomRead.replyMessagetype ==
                                          MyMessageType.text
                                      ? Text(
                                          chatRoomRead.replyMessage,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
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
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Image(image: imageProvider),
                                          errorWidget: (context, url, error) =>
                                              Material(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child: Image.asset(
                                              'assets/img/img_not_available.jpeg',
                                              width: 200.0,
                                              height: 200.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          imageUrl: chatRoomRead.replyMessage,
                                          fit: BoxFit.scaleDown,
                                        ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox();
          }), //ReplyMessage
          Row(children: [
            IconButton(
              color: Theme.of(context).colorScheme.primary,
              icon: Icon(
                Icons.photo,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              onPressed: () async {
                if (context.read(myUserRepository).user.isAnonymous) {
                  Show.showDialogToDismiss(
                      context,
                      'Dommage',
                      'Vous devez vous connecter pour envoyer un message',
                      'Ok');
                  return;
                }

                final file = await Show.showDialogSource(context);
                chatRoomRead.setNewTempImage(file);
                // if (file != null) {
                //   db.displayAndSendImage(file, chatRoomRead);
                // }
                // showSourceChoice(db, chatRoomRead);
              },
            ),
            IconButton(
              color: Theme.of(context).colorScheme.primary,
              iconSize: 35,
              icon: Icon(
                Icons.gif,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              onPressed: () {
                if (context.read(myUserRepository).user.isAnonymous) {
                  Show.showDialogToDismiss(
                      context,
                      'Dommage',
                      'Vous devez vous connecter pour envoyer un message',
                      'Ok');
                  return;
                }
                context
                    .read(myChatRepositoryProvider)
                    .pickGif(context, chatRoomRead);
              },
            ),
            Flexible(
              child: GestureDetector(
                onTap: () {
                  if (context.read(myUserRepository).user.isAnonymous) {
                    Show.showDialogToDismiss(
                        context,
                        'Dommage',
                        'Vous devez vous connecter pour envoyer un message',
                        'Ok');
                    return;
                  }
                },
                child: TextField(
                  controller: _textEditingController,
                  enabled: !context.read(myUserRepository).user.isAnonymous,
                  focusNode: textFieldFocus,
                  style: Theme.of(context).textTheme.bodyText1,
                  onChanged: (val) {
                    if (val.isNotEmpty && val.trim() != '') {
                      chatRoomRead.setShowSendBotton(true);
                    } else {
                      chatRoomRead.setShowSendBotton(false);
                    }
                  },
                  decoration: InputDecoration(
                    border:
                        const OutlineInputBorder(borderSide: BorderSide.none),
                    hintText: 'Saisir un message',
                    hintStyle: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
            ),
            Consumer(builder: (context, watch, child) {
              return watch(chatRoomProvider).showSendBotton
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconButton(
                          color: Theme.of(context).colorScheme.primary,
                          icon: FaIcon(
                            FontAwesomeIcons.paperPlane,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          onPressed: () => db.sendTextMessage(
                              chatRoomRead, _textEditingController)))
                  : const SizedBox();
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
              onPressed: () {
                Navigator.of(context).pop();
                _getImageCamera(db, chatRoomRead);
              },
              child: Text(
                'Caméra',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            PlatformDialogAction(
              //actionType: ActionType.,
              onPressed: () {
                Navigator.of(context).pop();
                _getImageGallery(db, chatRoomRead);
              },
              child: Text(
                'Galerie',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ],
        );
      },
    );
  }
}
