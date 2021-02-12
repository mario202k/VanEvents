import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/domain/models/event.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_chat_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';

class SearchUserEvent extends StatefulWidget {
  final bool isEvent;

  const SearchUserEvent({this.isEvent});

  @override
  _SearchUserEventState createState() => _SearchUserEventState();
}

class _SearchUserEventState extends State<SearchUserEvent> {
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();
  final scrollController = ScrollController();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  String query = '';

  @override
  void dispose() {
    refreshChangeListener.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read(myUserProvider).id;
    return ModelScreen(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(77),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IconButton(
                icon: const BackButtonIcon(),color: Theme.of(context).colorScheme.onPrimary,
                onPressed: () {
                  ExtendedNavigator.of(context).pop();
                },
              ),
              Flexible(
                child: FormBuilder(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FormBuilderTextField(
                      name: 'search',
                      style: Theme.of(context).textTheme.bodyText2,
                      cursorColor: Theme.of(context).colorScheme.onPrimary,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onPrimary,
                                width: 2),
                            borderRadius: BorderRadius.circular(25.0)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onPrimary,
                                width: 2),
                            borderRadius: BorderRadius.circular(25.0)),
                        labelText: 'Recherche',
                        labelStyle: Theme.of(context).textTheme.bodyText2,
                      ),
                      onChanged: (val) {
                        setState(() {
                          query = val;
                        });
                      },
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.clear,color: Theme.of(context).colorScheme.onPrimary,),
                onPressed: () {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                },
              )
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refreshChangeListener.refreshed = true;
        },
        child: PaginateFirestore(
          itemBuilder: (index, context, documentSnapshot) {
            MyUser myUser;
            MyEvent myEvent;

            if (!widget.isEvent) {
              myUser =
                  MyUser.fromMap(documentSnapshot.data());
            } else {
              myEvent =
                  MyEvent.fromMap(documentSnapshot.data());
            }

            return(widget.isEvent ? myEvent.titre : myUser.nom)
                .toLowerCase()
                .contains(query.toLowerCase())? (myEvent != null || myUser.id != uid)? Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(widget.isEvent ? myEvent.titre : myUser.nom,
                    style: Theme.of(context).textTheme.bodyText1),
                leading: (widget.isEvent
                    ? myEvent.imageFlyerUrl
                    : myUser.imageUrl)
                    .isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: widget.isEvent
                      ? myEvent.imageFlyerUrl
                      : myUser.imageUrl,
                  imageBuilder: (context, imageProvider) =>
                      CircleAvatar(
                        backgroundImage: imageProvider,
                        radius: 25,
                        backgroundColor:
                        Theme.of(context).colorScheme.primary,
                      ),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.onPrimary,
                    highlightColor:
                    Theme.of(context).colorScheme.primary,
                    child: const CircleAvatar(
                      radius: 25,
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                )
                    : CircleAvatar(
                  radius: 25,
                  backgroundColor:
                  Theme.of(context).colorScheme.primary,
                  backgroundImage:
                  const AssetImage('assets/img/normal_user_icon.png'),
                ),
                onTap: () async {
                  final db = context.read(myChatRepositoryProvider);
                  if (myUser != null) {
                    await toChatRoomUser(db, myUser, context);
                  } else if (myEvent != null) {
                    await toChatRoomEvent(myEvent, db, context);
                  }
                },
              ),
            ): const SizedBox():const SizedBox();
          },
          listeners: [
            refreshChangeListener,
          ],
          query: !widget.isEvent
              ? FirebaseFirestore.instance.collection('users').orderBy('nom')
              : FirebaseFirestore.instance
                  .collection('events')
                  .orderBy('titre'),
          itemBuilderType: PaginateBuilderType.listView,
          bottomLoader: Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary)),
          ),
        ),
      ),
    ));
  }

  Future toChatRoomEvent(
      MyEvent myEvent, MyChatRepository db, BuildContext context) async {
    firebaseMessaging.subscribeToTopic(myEvent.chatId);

    await db.addAmongGroupe(myEvent.chatId).then((_) {
      ExtendedNavigator.of(context).push(Routes.chatRoom,
          arguments: ChatRoomArguments(chatId: myEvent.chatId));
    });
  }

  Future toChatRoomUser(
      MyChatRepository db, MyUser myUser, BuildContext context) async{
    final chatId = await db.creationChatRoom(myUser);

    await db.getMyChat(chatId).then((myChat) {
      ExtendedNavigator.of(context).push(Routes.chatRoom,
          arguments: ChatRoomArguments(chatId: chatId));
    }).catchError((onError) {
      debugPrint(onError.toString());
    });


  }
}
