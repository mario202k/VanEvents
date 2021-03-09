import 'package:auto_route/auto_route.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/domain/models/message.dart';
import 'package:van_events_project/domain/models/my_chat.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_chat_repository.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';
import 'package:van_events_project/providers/toggle_bool.dart';

class Chat extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final myChatRepo = context.read(myChatRepositoryProvider);
    return ModelBody(
      child: StreamBuilder<List<MyChat>>(
        stream: myChatRepo.chatRoomsStream(myChatRepo.uid),
        //qui ont deja discuter
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Erreur de connexion'),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.secondary)),
            );
          }
          final List<MyChat> myChat = snapshot.data;
          return myChat.isNotEmpty
              ? ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: myChat.length,
                  itemBuilder: (context, index) {
                    final MyChat chat = myChat.elementAt(index);

                    final streamUserFriend =
                        context.read(myUserRepository).chatMyUsersStream(chat);
//
                    final Stream<MyMessage> lastMsg = context
                        .read(myChatRepositoryProvider)
                        .getLastChatMessage(chat.id);

                    final Stream<int> msgNonLu = context
                        .read(myChatRepositoryProvider)
                        .getNbChatMessageNonLu(chat.id);
                    MyUser participant = MyUser();

                    return StreamBuilder<List<MyUser>>(
                        stream: streamUserFriend,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const SizedBox();
                          }

                          List<MyUser> users = <MyUser>[];

                          users = snapshot.data;

                          if (!chat.isGroupe && users.isNotEmpty) {
                            for (final MyUser myUser in users) {
                              if (myUser.id != myChatRepo.uid) {
                                participant = myUser;
                              }
                            }
                          }

                          String titre = '';
                          if (chat.isGroupe) {
                            titre = chat.titre;
                          } else {
                            titre = participant.nom;
                          }

                          return buildListTile(titre, chat, users, lastMsg,
                              participant, msgNonLu, context);
                        });
                  })
              : Center(
                  child: Text(
                    'Pas de conversation',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                );
        },
      ),
    );
  }

  Widget buildListTile(
      String titre,
      MyChat chat,
      List<MyUser> users,
      Stream<MyMessage> lastMsg,
      MyUser friend,
      Stream<int> msgNonLu,
      BuildContext context) {
    return ListTile(
      title: Text(
        titre ?? '',
        style: Theme.of(context).textTheme.bodyText1,
      ),
      subtitle: StreamBuilder<MyMessage>(
          stream: lastMsg,
          builder: (context, snapshot) {
            MyMessage lastMessage;
            if (!snapshot.hasData) {
              lastMessage = MyMessage(message: 'aucun message');
            } else {
              lastMessage = snapshot.data;
            }
            return subtitle(lastMessage, context);
          }),
      onTap: () {
        ExtendedNavigator.of(context).push(Routes.chatRoom,
            arguments: ChatRoomArguments(chatId: chat.id));
      },
      leading: (!chat.isGroupe ? friend.imageUrl : chat.imageUrl) != null &&
              (!chat.isGroupe ? friend.imageUrl : chat.imageUrl).isNotEmpty
          ? Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: !chat.isGroupe ? friend.imageUrl : chat.imageUrl,
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(50)),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Theme.of(context).colorScheme.primary,
                    child: const CircleAvatar(
                      radius: 25,
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    debugPrint(url);
                    debugPrint(error.toString());
                    return const Icon(Icons.error);
                  },
                ),
                if (!chat.isGroupe) Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(),
                              color: friend?.isLogin ?? false
                                  ? Colors.green
                                  : Colors.orange),
                        ),
                      ) else const SizedBox()
              ],
            )
          : Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage:
                      const AssetImage('assets/img/normal_user_icon.png'),
                ),
                if (!chat.isGroupe) Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(),
                              color: friend?.isLogin ?? false
                                  ? Colors.green
                                  : Colors.orange),
                        ),
                      ) else const SizedBox()
              ],
            ),
      trailing: Column(
        children: <Widget>[
          StreamBuilder<MyMessage>(
              stream: lastMsg,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                final MyMessage lastMessage = snapshot.data;

                return lastMessage.date != null
                    ? Text(
                        //si c'est aujourh'hui l'heure sinon date
                        DateTime.now().day == lastMessage.date.day
                            ? 'aujourd\'hui'
                            : DateFormat('dd/MM/yyyy').format(lastMessage.date),
                        style: Theme.of(context).textTheme.bodyText1,
                      )
                    : const SizedBox();
              }),
          Consumer(builder: (context, watch, child) {
            final i = watch(boolToggleProvider).chatNbMsgNonLu[chat.id];

            return i != null && i != 0
                ? Badge(
                    badgeContent: Text(
                      '$i',
                      style: Theme.of(context).textTheme.caption.copyWith(color: Theme.of(context).colorScheme.onSecondary),
                    ),
                    badgeColor: Theme.of(context).colorScheme.secondary,
                    child: Icon(
                      Icons.markunread,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  )
                : const SizedBox();
          }),
        ],
      ),
    );
  }

  Widget subtitle(MyMessage message, BuildContext context) {
    return message.id == null
        ? Text(
            'Pas de messages',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyText1,
          )
        : message.type == MyMessageType.text
            ? Text(
                message.message,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyText1,
              )
            : message.type == MyMessageType.image
                ? Row(
                    children: <Widget>[
                      const Icon(FontAwesomeIcons.photoVideo),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text(
                          'Image',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      )
                    ],
                  )
                : Row(
                    children: <Widget>[
                      const Icon(FontAwesomeIcons.photoVideo),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text(
                          'Réponse',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      )
                    ],
                  );
  }
}
