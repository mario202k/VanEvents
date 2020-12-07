import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/domain/models/chat_membres.dart';
import 'package:van_events_project/domain/models/message.dart';
import 'package:van_events_project/domain/repositories/my_chat_repository.dart';
import 'package:van_events_project/presentation/pages/full_photo.dart';
import 'package:van_events_project/providers/chat_room_change_notifier.dart';


class ChatMessageListItem extends HookWidget {
  final MyMessage message;
  final bool isMe;
  final String chatId;
  final bool isGroupe;
  final String friendName;
  final String friendUrl;
  final String idTo;
  final String replyName;
  final MyMessage replyMessage;
  final MyMessageReplyType replyType;
  final bool replyIsFromMe;

  ChatMessageListItem(
      {this.message,
      this.isMe,
      this.chatId,
      this.isGroupe,
      this.friendName,
      this.friendUrl,
      this.idTo,
      this.replyName,
      this.replyMessage,
      this.replyType,
      this.replyIsFromMe});

  Widget build(BuildContext context) {
    final chatRoomRead = context.read(chatRoomProvider);
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Visibility(
          visible: !isMe,
          child: Visibility(
            visible: friendUrl.isNotEmpty,
            replacement: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: AssetImage('assets/img/normal_user_icon.png'),
            ),
            child: CachedNetworkImage(
              imageUrl: friendUrl,
              imageBuilder: (context, imageProvider) => Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(22)),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: Theme.of(context).colorScheme.primary,
                child: CircleAvatar(
                  radius: 11,
                ),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: message.type == MyMessageType.text
              ? buildText(context, chatRoomRead)
              : message.type == MyMessageType.image
                  ? buildImage(context, chatRoomRead)
                  : message.type == MyMessageType.reply
                      ? buildReplyMessage(context, chatRoomRead)
                      : Text('Error'),
        ),
      ],
    );
  }

  Widget buildText(BuildContext context, ChatRoomChangeNotifier chatRoomRead) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Visibility(
            visible: isMe && chatRoomRead.myChat.isGroupe,
            child: Text(
              DateFormat('HH:mm').format(message.date),
              style: Theme.of(context).textTheme.caption,
            )),
        Visibility(
            visible: message.type != MyMessageType.reply && isMe,
            child: horodatage(context, chatRoomRead)),
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary,
            borderRadius: isMe
                ? BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                    bottomRight: Radius.circular(0),
                    bottomLeft: Radius.circular(15),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                    bottomLeft: Radius.circular(0),
                  ),
          ),
          child: Column(
            children: <Widget>[
              isGroupe && !isMe
                  ? Text(
                      friendName,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.button,
                    )
                  : SizedBox(),
              Text(
                message.message,
                textAlign: isMe ? TextAlign.end : TextAlign.start,
                style: isMe
                    ? Theme.of(context).textTheme.headline5
                    : Theme.of(context).textTheme.headline6,
              ),
            ],
          ),
        ),
        Visibility(
            visible: !isMe && message.type != MyMessageType.reply,
            child: Text(
              DateFormat('HH:mm').format(message.date),
              style: Theme.of(context).textTheme.caption,
            )),
      ],
    );
  }

  Row buildImage(BuildContext context, ChatRoomChangeNotifier chatRoomRead) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FullPhoto(
                          url: message.message,
                          file: chatRoomRead.listPhoto[message.id],
                        )));
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Visibility(
                visible: message.type != MyMessageType.reply,
                  child: horodatage(context, chatRoomRead),),
              !chatRoomRead.listPhoto.containsKey(message.id) &&
                      message.message != null
                  ? CachedNetworkImage(
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Theme.of(context).colorScheme.primary,
                        child: Container(
                            height: 200, width: 200, color: Colors.white),
                      ),
                      imageBuilder: (context, imageProvider) => Container(
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                              maxHeight: 220),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Image(image: imageProvider),
                          )),
                      errorWidget: (context, url, error) => Material(
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
                      imageUrl: message.message,
                      fit: BoxFit.scaleDown,
                    )
                  : Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                          maxHeight: 220),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: chatRoomRead.listPhoto[message.id] != null
                            ? Image(
                                image: FileImage(
                                    chatRoomRead.listPhoto[message.id]))
                            : SizedBox(),
                      )),
              Visibility(
                  visible: !isMe && message.type != MyMessageType.reply,
                  child: Text(
                    DateFormat('HH:mm').format(message.date),
                    style: Theme.of(context).textTheme.caption,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildReplyMessage(
      BuildContext context, ChatRoomChangeNotifier chatRoomRead) {

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(visible: isMe, child: horodatage(context, chatRoomRead)),
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary,
            borderRadius: isMe
                ? BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                    bottomRight: Radius.circular(0),
                    bottomLeft: Radius.circular(15),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                    bottomLeft: Radius.circular(0),
                  ),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFcfd8dc),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          replyIsFromMe ? 'Vous' : replyName,
                          style: Theme.of(context).textTheme.headline5.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Visibility(
                          visible: replyMessage.type == MyMessageType.text,
                          child: Text(
                            replyMessage.message,
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(color: Colors.black54),
                          ),
                          replacement: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FullPhoto(
                                        url: replyMessage.message,
                                        file: chatRoomRead.listPhoto[message.id],
                                      )));
                            },
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Container(
                                    height: 200, width: 200, color: Colors.white),
                              ),
                              imageBuilder: (context, imageProvider) => Container(
                                  constraints:
                                  BoxConstraints(
                                    maxHeight: 120,
                                      maxWidth: MediaQuery.of(context).size.width * 0.7),
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    child: Image(image: imageProvider),
                                  )),
                              errorWidget: (context, url, error) => Material(
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
                              imageUrl: replyMessage.message,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              replyType == MyMessageReplyType.text?
              buildText(context, chatRoomRead):
              replyType == MyMessageReplyType.image?
              buildImage(context, chatRoomRead):Text('Error'),
              // Visibility(
              //   visible: replyType == MyMessageReplyType.text,
              //   child: buildText(context, chatRoomRead),
              //   replacement: Visibility(
              //       visible: replyType == MyMessageReplyType.image,
              //       child: buildImage(context, chatRoomRead),
              //       replacement: Text('Error')),
              // ),

              //Text
            ],
          ),
        ),
        Visibility(
            visible: !isMe,
            child: Text(
              DateFormat('HH:mm').format(message.date),
              style: Theme.of(context).textTheme.caption,
            )),
      ],
    );
  }

  Widget horodatage(BuildContext context, ChatRoomChangeNotifier chatRoomRead) {
    return Visibility(
        visible: isMe && !isGroupe,
        child: Consumer(builder: (context, watch, child) {
          return Visibility(
            visible: watch(chatRoomProvider).listTempMessages[message.id] == -1,
            child: Icon(Icons.error),
            replacement: Visibility(
              visible:
                  watch(chatRoomProvider).listTempMessages[message.id] == 0,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary)),
              replacement: StreamBuilder<ChatMembre>(
                stream: context
                    .read(myChatRepositoryProvider)
                    .getChatMembre(chatId, idTo),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    ChatMembre chatMembre = snapshot.data;

                    if (message.date.compareTo(chatMembre.lastReading) == -1 ||
                        chatMembre.isReading) {
                      return Row(
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints.tight(Size(18,15)),
                            padding: EdgeInsets.only(right: 7),
                            child: Stack(
                              overflow: Overflow.visible,
                              children: [
                                Positioned.fill(
                                  child: Icon(
                                      Icons.check,
                                    size: 19,
                                    color: Colors.green,
                                  ),
                                ),
                                Positioned(
                                  right: -3,
                                  child: Icon(
                                    Icons.check,
                                    size: 19,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm').format(message.date),
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(color: Colors.black),
                          ),
                        ],
                      );
                    }
                  }

                  return Row(
                    children: <Widget>[
                      Icon(
                        Icons.check,
                        size: 19,
                        color: Colors.grey,
                      ),
                      Text(
                        DateFormat('HH:mm').format(message.date),
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            .copyWith(color: Colors.black),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        }));
  }
}
