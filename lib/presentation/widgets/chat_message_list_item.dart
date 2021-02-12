import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  const ChatMessageListItem(
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

  @override
  Widget build(BuildContext context) {
    final chatRoomRead = context.read(chatRoomProvider);
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (!isMe)
          friendUrl?.isNotEmpty ?? false
              ? CachedNetworkImage(
                  imageUrl: friendUrl,
                  imageBuilder: (context, imageProvider) => Container(
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(22)),
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
                    child: const CircleAvatar(
                      radius: 11,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              : CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage:
                      const AssetImage('assets/img/normal_user_icon.png'),
                )
        else
          const SizedBox(),
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: message.type == MyMessageType.text
              ? buildText(context, chatRoomRead)
              : message.type == MyMessageType.image
                  ? buildImage(context, chatRoomRead)
                  : message.type == MyMessageType.reply
                      ? buildReplyMessage(context, chatRoomRead)
                      : message.type == MyMessageType.call
                          ? buildCall(context, chatRoomRead)
                          : const Text('Error'),
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
        if (isMe && chatRoomRead.myChat.isGroupe)
          Text(
            DateFormat('HH:mm').format(message.date),
            style: Theme.of(context).textTheme.caption,
          )
        else
          const SizedBox(),
        if (message.type != MyMessageType.reply && isMe)
          horodatage(context, chatRoomRead)
        else
          const SizedBox(),
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary,
            borderRadius: isMe
                ? const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
          ),
          child: Column(
            children: <Widget>[
              if (isGroupe && !isMe)
                Text(
                  friendName,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.bodyText2,
                )
              else
                const SizedBox(),
              Text(
                message.message,
                textAlign: isMe ? TextAlign.end : TextAlign.start,
                style: isMe
                    ? Theme.of(context).textTheme.bodyText1
                    : Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
        ),
        if (!isMe && message.type != MyMessageType.reply)
          Text(
            DateFormat('HH:mm').format(message.date),
            style: Theme.of(context).textTheme.caption,
          )
        else
          const SizedBox(),
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
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (message.type != MyMessageType.reply)
                horodatage(context, chatRoomRead)
              else
                const SizedBox(),
              if (!chatRoomRead.listPhoto.containsKey(message.id) &&
                  message.message != null)
                CachedNetworkImage(
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Theme.of(context).colorScheme.primary,
                    child:
                        Container(height: 200, width: 200, color: Colors.white),
                  ),
                  imageBuilder: (context, imageProvider) => Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                          maxHeight: 220),
                      child:
                          Image(fit: BoxFit.fitHeight, image: imageProvider)),
                  errorWidget: (context, url, error) => Material(
                    borderRadius: const BorderRadius.all(
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
                  imageUrl: message.message,
                  fit: BoxFit.scaleDown,
                )
              else
                Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                        maxHeight: 220),
                    child: chatRoomRead.listPhoto[message.id] != null
                        ? Image(
                            fit: BoxFit.fitHeight,
                            image:
                                FileImage(chatRoomRead.listPhoto[message.id]))
                        : const SizedBox()),
              if (!isMe && message.type != MyMessageType.reply)
                Text(
                  DateFormat('HH:mm').format(message.date),
                  style: Theme.of(context).textTheme.caption,
                )
              else
                const SizedBox(),
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
        if (isMe) horodatage(context, chatRoomRead) else const SizedBox(),
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary,
            borderRadius: isMe
                ? const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFcfd8dc),
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
                        if (replyMessage.type == MyMessageType.text)
                          Text(
                            replyMessage.message,
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(color: Colors.black54),
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FullPhoto(
                                            url: replyMessage.message,
                                            file: chatRoomRead
                                                .listPhoto[message.id],
                                          )));
                            },
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Container(
                                    height: 200,
                                    width: 200,
                                    color: Colors.white),
                              ),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                      constraints: BoxConstraints(
                                          maxHeight: 120,
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7),
                                      child: FittedBox(
                                        child: Image(image: imageProvider),
                                      )),
                              errorWidget: (context, url, error) => Material(
                                borderRadius: const BorderRadius.all(
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
                              imageUrl: replyMessage.message,
                              fit: BoxFit.scaleDown,
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
              if (replyType == MyMessageReplyType.text)
                buildText(context, chatRoomRead)
              else
                replyType == MyMessageReplyType.image
                    ? buildImage(context, chatRoomRead)
                    : const Text('Error'),
            ],
          ),
        ),
        if (!isMe)
          Text(
            DateFormat('HH:mm').format(message.date),
            style: Theme.of(context).textTheme.caption,
          )
        else
          const SizedBox(),
      ],
    );
  }

  Widget buildCall(BuildContext context, ChatRoomChangeNotifier chatRoomRead) {
    return Row(
      children: const [
        FaIcon(
          FontAwesomeIcons.phone,
        ),
        Text('Call')
      ],
    );
  }

  Widget horodatage(BuildContext context, ChatRoomChangeNotifier chatRoomRead) {
    return isMe && !isGroupe
        ? Consumer(builder: (context, watch, child) {
            return watch(chatRoomProvider).listTempMessages[message.id] == -1
                ? const Icon(Icons.error)
                : watch(chatRoomProvider).listTempMessages[message.id] == 0
                    ? CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary))
                    : StreamBuilder<ChatMembre>(
                        stream: context
                            .read(myChatRepositoryProvider)
                            .getChatMembre(chatId, idTo),
                        builder: (context,
                             snapshot) {
                          if (snapshot.hasData) {
                            final ChatMembre chatMembre = snapshot.data;

                            if (message.date
                                        .compareTo(chatMembre.lastReading) ==
                                    -1 ||
                                chatMembre.isReading) {
                              return Row(
                                children: <Widget>[
                                  Container(
                                    constraints: BoxConstraints.tight(
                                        const Size(18, 15)),
                                    padding: const EdgeInsets.only(right: 7),
                                    child: Stack(
                                      overflow: Overflow.visible,
                                      children: const [
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
                                  Text(DateFormat('HH:mm').format(message.date),
                                      style:
                                          Theme.of(context).textTheme.caption),
                                ],
                              );
                            }

                            if (message.date
                                        .compareTo(chatMembre.lastReceived) ==
                                    -1 ||
                                message.date
                                        .compareTo(chatMembre.lastReceived) ==
                                    0) {
                              return Row(
                                children: <Widget>[
                                  Container(
                                    constraints: BoxConstraints.tight(
                                        const Size(18, 15)),
                                    padding: const EdgeInsets.only(right: 7),
                                    child: Stack(
                                      overflow: Overflow.visible,
                                      children: const [
                                        Positioned.fill(
                                          child: Icon(
                                            Icons.check,
                                            size: 19,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Positioned(
                                          right: -3,
                                          child: Icon(
                                            Icons.check,
                                            size: 19,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(DateFormat('HH:mm').format(message.date),
                                      style:
                                          Theme.of(context).textTheme.caption),
                                ],
                              );
                            }
                          }

                          return Row(
                            children: <Widget>[
                              const Icon(
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
                      );
          })
        : const SizedBox();
  }
}
