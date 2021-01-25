import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_chat_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/pages/profile.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';

class OtherProfile extends StatelessWidget {
  final MyUser _myUser;

  OtherProfile(this._myUser);

  @override
  Widget build(BuildContext context) {
    final me = context.read(myUserProvider);
    return ModelScreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profil'),
        ),
        body: Profil(other: _myUser),
        floatingActionButton:me.id != _myUser.id? FloatingActionButton(
          onPressed: () async{
            final db = context.read(myChatRepositoryProvider);
            final chatId = await db.creationChatRoom(_myUser);

            await db.getMyChat(chatId).then((myChat) {
              ExtendedNavigator.of(context).push(Routes.chatRoom,
                  arguments: ChatRoomArguments(chatId: chatId));
            }).catchError((onError) {
              print(onError);
            });
          },
          child: FaIcon(FontAwesomeIcons.comments),
        ):SizedBox(),
      ),
    );
  }
}
