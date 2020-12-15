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


class Chat extends HookWidget  {
  @override
  Widget build(BuildContext context) {
    print('buildChat');
    final myChatRepo = context.read(myChatRepositoryProvider);
    return StreamBuilder<List<Object>>(
      stream: myChatRepo.chatRoomsStream(),
      //qui ont deja discuter
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur de connexion'),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary)),
          );
        }
        List<MyChat> myChat = snapshot.data;
        return myChat.isNotEmpty
            ? ListView.separated(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (context, index) => Divider(),
                itemCount: myChat.length,
                itemBuilder: (context, index) {
                  MyChat chat = myChat.elementAt(index);

                  final streamUserFriend = context
                      .read(myUserRepository)
                      .chatMyUsersStream(chat);
//
                  Stream<MyMessage> lastMsg = context
                      .read(myChatRepositoryProvider)
                      .getLastChatMessage(chat.id);

                  Stream<int> msgNonLu = context
                      .read(myChatRepositoryProvider)
                      .getNbChatMessageNonLu(chat.id);
                  MyUser participant = MyUser();

                  return Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.15,
                    actions: <Widget>[
                      // IconSlideAction(
                      //   caption: 'Call',
                      //   color: Theme.of(context).colorScheme.secondary,
                      //   icon: FontAwesomeIcons.phone,
                      //   onTap: () => CallUtils.dial(
                      //       from: user, to: userFriend, context: context),
                      // ),
                    ],
                    child: StreamBuilder<List<MyUser>>(
                        stream: streamUserFriend,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return SizedBox();
                          }

                          List<MyUser> users = List<MyUser> ();

                          users = snapshot.data;

                          if (!chat.isGroupe && users.isNotEmpty) {

                            for(MyUser myUser in users){

                              if(myUser.id != myChatRepo.uid){
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
                              participant, msgNonLu);
                        }),
                  );
                })
            : Center(
                child: Text(
                  'Pas de conversation',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
      },
    );
  }

  Widget buildListTile(String titre, MyChat chat, List<MyUser> users,
      Stream<MyMessage> lastMsg, MyUser friend, Stream<int> msgNonLu) {
    MyMessage lastMessage;

    return StreamBuilder<MyMessage>(
        stream: lastMsg,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            lastMessage = MyMessage(message: 'aucun message');
          } else {
            lastMessage = snapshot.data;
          }
          return ListTile(
            title: Text(
              titre??'',
              style: Theme.of(context).textTheme.subtitle2,
            ),
            subtitle: subtitle(lastMessage, context),
            onTap: () {
              ExtendedNavigator.of(context).push(Routes.chatRoom,
                  arguments: ChatRoomArguments(chatId: chat.id));
            },

            leading: Visibility(
              visible: (!chat.isGroupe ? friend.imageUrl : chat.imageUrl).isNotEmpty,
              replacement: CircleAvatar(
                radius: 25,
                backgroundColor:
                Theme.of(context).colorScheme.primary,
                backgroundImage:
                AssetImage('assets/img/normal_user_icon.png'),
              ),
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: !chat.isGroupe ? friend.imageUrl : chat.imageUrl,
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
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
                      child: CircleAvatar(
                        radius: 25,
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      return Icon(Icons.error);
                    },
                  ),
                  !chat.isGroupe
                      ? Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 1),
                                color: friend.isLogin
                                    ? Colors.green
                                    : Colors.orange),
                          ),
                        )
                      : SizedBox()
                ],
              ),
            ),


            trailing: Column(
              children: <Widget>[
                lastMessage.date != null
                    ? Text(
                        //si c'est aujourh'hui l'heure sinon date
                        DateTime.now().day == lastMessage.date.day
                            ? 'aujourd\'hui'
                            : DateFormat('dd/MM/yyyy').format(lastMessage.date),
                        style: Theme.of(context).textTheme.subtitle1,
                      )
                    : SizedBox(),
                StreamBuilder<Stream<List<MyMessage>>>(
                    stream: context
                        .read(myChatRepositoryProvider)
                        .nbMessagesNonLu(chat.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox();
                      }

                      return StreamBuilder<List<MyMessage>>(
                          stream: snapshot.data,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return SizedBox();
                            }

                            int i = snapshot.data.length;

                            return i != 0
                                ? Badge(
                                    badgeContent: Text(
                                      '$i',
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    child: Icon(Icons.markunread),
                                  )
                                : SizedBox();
                          });
                    }),
              ],
            ),
          );
        });
  }

  Widget subtitle(MyMessage message, BuildContext context) {

    return message.id == null? Text(
      'Pas de messages',
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: Theme.of(context).textTheme.subtitle1,
    ): message.type == MyMessageType.text
        ? Text(
            message.message,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.subtitle1,
          )
        : message.type == MyMessageType.image
            ? Row(
                children: <Widget>[
                  Icon(FontAwesomeIcons.photoVideo),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Image',
                    style: Theme.of(context).textTheme.subtitle1,
                  )
                ],
              )
            :  Row(
                children: <Widget>[
                  Icon(FontAwesomeIcons.photoVideo),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Réponse',
                    style: Theme.of(context).textTheme.subtitle1,
                  )
                ],
              );
  }
}
