import 'dart:io';
import 'dart:math' as math;

import 'package:async/async.dart';
import 'package:auto_route/auto_route.dart';
import 'package:badges/badges.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/message.dart';
import 'package:van_events_project/domain/models/my_chat.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_chat_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/pages/billets.dart';
import 'package:van_events_project/presentation/pages/chat.dart';
import 'package:van_events_project/presentation/pages/home_events.dart';
import 'package:van_events_project/presentation/pages/profile.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/providers/toggle_bool.dart';
import 'package:van_events_project/services/firebase_cloud_messaging.dart';

final navigationProvider = StateProvider<String>((ref) {
  return 'HomeEvents';
});

class BaseScreens extends HookWidget {
  final double maxSlide = 60.0;

  @override
  Widget build(BuildContext context) {
    print('buildBaseScreens');

    final _animationController = useAnimationController(
        duration: Duration(milliseconds: 400), initialValue: 0.0);
    final myUser = useProvider(myUserProvider);
    NotificationHandler().initializeFcmNotification(myUser.id, context);
    final boolToggle = context.read(boolToggleProvider);
    boolToggle.initial();
    boolToggle.setNbMsgNonLu(context, myUser.id);


    return ModelScreen(
      child: Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              title: Consumer(builder: (context, watch, _) {
                final nav = watch(navigationProvider).state;
                return Platform.isAndroid? Padding(
                  padding: const EdgeInsets.only(left:  30),
                  child: Text(
                    nav,
                  ),
                ):Text(
                  nav,
                );
              }),
            ),
            body: Consumer(builder: (context, watch, _) {
              final nav = watch(navigationProvider).state;
              return nav == 'HomeEvents'
                  ? HomeEvents()
                  : nav == 'Chat'
                      ? Chat()
                      : nav == 'Billets'
                          ? Billets()
                          : Profil();
            }),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Consumer(builder: (context, watch, _) {
              final nav = watch(navigationProvider).state;

              int i;
              switch (nav) {
                case 'HomeEvents':
                  i = 0;
                  break;
                case 'Chat':
                  i = 1;
                  break;
                case 'Billets':
                  i = 2;
                  break;
                case 'Profil':
                  i = 3;
                  break;
              }

              return CurvedNavigationBar(
                backgroundColor: Colors.transparent,
                index: i,
                color: Theme.of(context).colorScheme.primary,
                height: 45,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      context.read(navigationProvider).state = 'HomeEvents';
                      break;
                    case 1:
                      context.read(navigationProvider).state = 'Chat';
                      break;
                    case 2:
                      context.read(navigationProvider).state = 'Billets';
                      break;
                    case 3:
                      context.read(navigationProvider).state = 'Profil';
                      break;
                  }
                },
                items: <Widget>[
                  Icon(
                    FontAwesomeIcons.home,
                    size: 30,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        FontAwesomeIcons.comments,
                        size: 30,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      Consumer(
                        builder: (context, watch, child) {
                          final nbMap =
                              watch(boolToggleProvider).chatNbMsgNonLu;
                          int i = 0;
                          for (final nb in nbMap.values) {
                            i += nb;
                          }

                          return i != 0
                              ? Badge(
                                  badgeContent: Text(
                                    '$i',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondary),
                                  ),
                                  badgeColor:
                                      Theme.of(context).colorScheme.secondary,
                                  child: Icon(
                                    Icons.markunread,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryVariant,
                                  ),
                                )
                              : SizedBox();
                        },
                      ),
                    ],
                  ),
                  Icon(
                    FontAwesomeIcons.ticketAlt,
                    size: 30,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  Icon(
                    FontAwesomeIcons.user,
                    size: 30,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              );
            }),
          ),
          Consumer(builder: (context, watch, _) {
            final nav = watch(navigationProvider).state;
            return nav == 'Chat'
                ? Positioned(
                    right: 15,
                    bottom: 60,
                    child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, _) {
                          return Container(
                            width: 120,
                            height: 120,
                            child: Stack(
                              overflow: Overflow.visible,
                              children: <Widget>[
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Transform.translate(
                                    offset: Offset(
                                        -maxSlide * _animationController.value,
                                        0),
                                    child: Transform.rotate(
                                      angle: _animationController.value *
                                          2.0 *
                                          math.pi,
                                      child: Transform.scale(
                                        scale: _animationController.value,
                                        child: FloatingActionButton(
                                            heroTag: 1,
                                            child: Icon(
                                              FontAwesomeIcons.userFriends,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                            ),
                                            onPressed: () {
                                              ExtendedNavigator.of(context).push(
                                                  Routes.searchUserEvent,
                                                  arguments:
                                                      SearchUserEventArguments(
                                                          isEvent: false));
                                            }),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Transform.translate(
                                    offset: Offset(0,
                                        -maxSlide * _animationController.value),
                                    child: Transform.rotate(
                                      angle: _animationController.value *
                                          2.0 *
                                          math.pi,
                                      child: Transform.scale(
                                        scale: _animationController.value,
                                        child: FloatingActionButton(
                                            heroTag: 2,
                                            child: Icon(
                                              FontAwesomeIcons.users,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                            ),
                                            onPressed: () {
                                              ExtendedNavigator.of(context).push(
                                                  Routes.searchUserEvent,
                                                  arguments:
                                                      SearchUserEventArguments(
                                                          isEvent: true));
                                            }
                                            //ExtendedNavigator.of(context).pushNamed(Routes.uploadEvent),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: FloatingActionButton(
                                      heroTag: 3,
                                      child: Icon(
                                        FontAwesomeIcons.search,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                      ),
                                      onPressed: () {
                                        //NotificationHandler().showOverlayWindow();
                                        _animationController.isCompleted
                                            ? _animationController.reverse()
                                            : _animationController.forward();
                                      }
                                      //ExtendedNavigator.of(context).pushNamed(Routes.uploadEvent),
                                      ),
                                ),
                              ],
                            ),
                          );
                        }),
                  )
                : SizedBox();
          }),
          Consumer(builder: (context, watch, _) {
            final nav = watch(navigationProvider).state;

            return nav == 'Billets'
                ? Positioned(
                    right: 15,
                    bottom: 60,
                    child: FloatingActionButton(
                      heroTag: 4,
                      child: Icon(
                        FontAwesomeIcons.car,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      onPressed: () {
                        ExtendedNavigator.of(context)
                            .push(Routes.transportScreen);
                      },
                    ))
                : SizedBox();
          })
        ],
      ),
    );
  }
}
