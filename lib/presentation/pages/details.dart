import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/domain/models/event.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_chat_repository.dart';
import 'package:van_events_project/domain/repositories/my_event_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/providers/toggle_bool.dart';

import 'gallery_page.dart';

class Details extends HookWidget {
  final MyEvent event;

  const Details(this.event);

  @override
  Widget build(BuildContext context) {
    final db = context.read(myEventRepositoryProvider);
    final participants = db.participantsEvent(event.id);
    final boolToggle = context.read(boolToggleProvider);
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

    boolToggle.imageProviderDetail.clear();

    return Consumer(builder: (context, watch, child) {
      return ModelScreen(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).colorScheme.background,
          body: NestedScrollView(
            //NestedScrollView
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                        event.titre[0].toUpperCase() + event.titre.substring(1),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline4),
                    background: boolToggle
                                .imageProviderEvent[event.imageFlyerUrl] !=
                            null
                        ? Hero(
                            tag: event.id,
                            child: Image(
                              image: boolToggle
                                  .imageProviderEvent[event.imageFlyerUrl],
                              fit: BoxFit.cover,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: event.imageFlyerUrl,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.white,
                              highlightColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Container(
                                  height: 300,
                                  width: double.maxFinite,
                                  color: Colors.white),
                            ),
                            imageBuilder: (context, imageProvider) {
                              return Image(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              );
                            },
                            errorWidget: (context, url, error) => Material(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.asset(
                                'assets/img/img_not_available.jpeg',
                                width: 300.0,
                                height: 300.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                  ),
                ),
              ];
            },
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.access_time,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          // "${DateFormat('dd/MM/yyyy').format(event.dateDebut)} à : ${event.dateDebut.hour}:${event.dateDebut.minute}"
                          '${DateFormat('dd/MM/yyyy').format(event.dateDebut)} à : ${DateFormat('HH').format(event.dateDebut)}h${DateFormat('mm').format(event.dateDebut)}',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      // RaisedButton.icon(
                      //     onPressed: () {
                      //       final Event myEvent = Event(
                      //         title: event.titre,
                      //         description: event.description,
                      //         location: [
                      //           ...event.adresseRue,
                      //           ...event.adresseZone
                      //         ].join(' '),
                      //         startDate: event.dateDebut,
                      //         endDate: event.dateFin,
                      //       );
                      //
                      //       Add2Calendar.addEvent2Cal(myEvent);
                      //     },
                      //     icon: Icon(
                      //       Icons.calendar_today,
                      //     ),
                      //     label: Flexible(child: Text("Plannifier"))),
                      RaisedButton.icon(
                          onPressed: () async {
                            firebaseMessaging.subscribeToTopic(event.chatId);
                            await context
                                .read(myChatRepositoryProvider)
                                .addAmongGroupe(event.chatId)
                                .then((_) {
                              ExtendedNavigator.of(context).push(
                                  Routes.chatRoom,
                                  arguments:
                                      ChatRoomArguments(chatId: event.chatId));
                            });
                          },
                          icon: const FaIcon(FontAwesomeIcons.comments),
                          label: const Text('Chat')),
                      RaisedButton.icon(
                          onPressed: () async {
                            final availableMaps =
                                await MapLauncher.installedMaps;

                            await availableMaps.first.showMarker(
                              coords: Coords(event.position.latitude,
                                  event.position.longitude),
                              title: event.titre,
                              description: 'event.addressZone',
                            );
                          },
                          icon: const Icon(
                            Icons.map,
                          ),
                          label: const Flexible(child: Text("Y aller"))),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Text(
                      "Description",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Text(event.description,
                      style: Theme.of(context).textTheme.bodyText1),
                  Text(
                    "Genres:",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: event.genres
                            ?.map((e) => Text(e?.toString() ?? '',
                                style: Theme.of(context).textTheme.bodyText1))
                            ?.toList() ??
                        [],
                  ),
                  Text(
                    "Types:",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: event.types
                            ?.map((e) => Text(e?.toString() ?? '',
                                style: Theme.of(context).textTheme.bodyText1))
                            ?.toList() ??
                        [],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 25,
                  ),
                  Text("Photos", style: Theme.of(context).textTheme.headline5),
                  GridView.builder(
                      itemCount: event.imagePhotos.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: (MediaQuery.of(context).orientation ==
                                  Orientation.landscape)
                              ? 3
                              : 2),
                      itemBuilder: (BuildContext context, int index) {
                        return CachedNetworkImage(
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor:
                                Theme.of(context).colorScheme.primary,
                            child: Container(
                                height: 300, width: 300, color: Colors.white),
                          ),
                          imageBuilder: (context, imageProvider) {
                            boolToggle.addDetailsPhotos(imageProvider, index);

                            return SizedBox(
                              height: 300,
                              width: 300,
                              child: GestureDetector(
                                  onTap: () => Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => GalleryPage(
                                                imageList: event.imagePhotos,
                                                initialPage: index,
                                              ))),
                                  child: Hero(
                                    tag: event.imagePhotos[index].substring(
                                        event.imagePhotos[index]
                                            .indexOf('token=')),
                                    child: Image(
                                      image: imageProvider,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  )),
                            );
                          },
                          errorWidget: (context, url, error) => Material(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.asset(
                              'assets/img/img_not_available.jpeg',
                              width: 300.0,
                              height: 300.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          imageUrl: event.imagePhotos[index] as String,
                          fit: BoxFit.scaleDown,
                        );
                      }),
                  const Divider(),
                  const SizedBox(
                    height: 25,
                  ),
                  Text("Participants",
                      style: Theme.of(context).textTheme.headline5),
                  SizedBox(
                    height: 100,
                    child: FutureBuilder<List<Future<MyUser>>>(
                        future: participants,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Erreur de connection'),
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.secondary)),
                            );
                          }
                          final List<Future<MyUser>> participantsList =
                              snapshot.data;

                          return participantsList.isNotEmpty
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: participantsList.length,
                                  itemBuilder: (context, index) {
                                    return FutureBuilder<MyUser>(
                                        future:
                                            participantsList.elementAt(index),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return const Center(
                                              child:
                                                  Text('Erreur de connection'),
                                            );
                                          } else if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary)),
                                            );
                                          }

                                          final MyUser user = snapshot.data;

                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                if (user?.imageUrl == null) {
                                                  return;
                                                }
                                                ExtendedNavigator.of(context)
                                                    .push(Routes.otherProfile,
                                                        arguments:
                                                            OtherProfileArguments(
                                                                myUser: user));
                                              },
                                              child: user?.imageUrl != null
                                                  ? CachedNetworkImage(
                                                      imageUrl: user?.imageUrl,
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        height: 80,
                                                        width: 80,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          80)),
                                                          image:
                                                              DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      fit: BoxFit.cover,
                                                      placeholder: (context,
                                                              url) =>
                                                          Shimmer.fromColors(
                                                        baseColor: Colors.white,
                                                        highlightColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        child:
                                                            const CircleAvatar(
                                                          radius: 40,
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                          url, error) {
                                                        return Center(
                                                          child: CircleAvatar(
                                                            radius: 40,
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                            backgroundImage:
                                                                const AssetImage(
                                                                    'assets/img/normal_user_icon.png'),
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Center(
                                                      child: CircleAvatar(
                                                        radius: 40,
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        backgroundImage:
                                                            const AssetImage(
                                                                'assets/img/normal_user_icon.png'),
                                                      ),
                                                    ),
                                            ),
                                          );
                                        });
                                  },
                                )
                              : const SizedBox();
                        }),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: RaisedButton.icon(
            onPressed: () {
              db.getFormulasList(event.id).then((form) {
                ExtendedNavigator.of(context).push(Routes.formulaChoice,
                    arguments:
                        FormulaChoiceArguments(formulas: form, myEvent: event));
              });
            },
            icon: const Icon(
              FontAwesomeIcons.cartArrowDown,
            ),
            label: const PulseAnimation(
              child: Text(
                "PARTICIPER",
              ),
            ),
          ),
          // floatingActionButton: RawMaterialButton(
          //     elevation: 10,
          //     child: Padding(
          //       padding: const EdgeInsets.all(12.0),
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: const <Widget>[
          //           Icon(
          //             FontAwesomeIcons.cartArrowDown,
          //             color: Colors.white,
          //           ),
          //           SizedBox(
          //             width: 15,
          //           ),
          //           PulseAnimation(
          //             child: Text(
          //               "PARTICIPER",
          //               style: TextStyle(color: Colors.white, fontSize: 20),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //     shape: StadiumBorder(),
          //     fillColor: Theme.of(context).colorScheme.primary,
          //     onPressed: () {
          //       db.getFormulasList(event.id).then((form) {
          //
          //         ExtendedNavigator.of(context).push(Routes.formulaChoice,
          //             arguments: FormulaChoiceArguments(
          //                 formulas: form,
          //                 eventId: event.id,
          //                 latLng: LatLng(
          //                     event.position.latitude, event.position.longitude),
          //                 stripeAccount: event.stripeAccount,
          //                 imageUrl: event.imageFlyerUrl,
          //                 dateDebut: event.dateDebut));
          //       });
          //     }),
        ),
      );
    });
  }
}

class PulseAnimation extends HookWidget {
  final Widget child;

  const PulseAnimation({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _controller =
        useAnimationController(duration: const Duration(milliseconds: 1000));

    final _animation = Tween(begin: .2, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart));

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();

    return FadeTransition(
      opacity: _animation,
      child: child,
    );
  }
}
