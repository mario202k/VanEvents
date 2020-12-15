import 'dart:io';

import 'package:async/async.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/domain/models/event.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_event_repository.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/toggle_bool_chat_room.dart';

class HomeEvents extends HookWidget {
  @override
  Widget build(BuildContext context) {
    print('buildhome_events');
    // AsyncValue<List<MyEvent>> first = useProvider(streamGenreProvider);
    // AsyncValue<List<MyEvent>> second = useProvider(streamTypeProvider);
    //
    // if (first is AsyncError || second is AsyncError) {
    //   return Text('error');
    // } else if (first is AsyncLoading || second is AsyncLoading) {
    //   return Text('loading');
    // }
    if (context.read(boolToggleProvider).isEnableNotification == null) {
      context.read(boolToggleProvider).initNotification();
    }
    final streamMyUser = useProvider(streamMyUserProvider);
    final tabController = useTabController(initialLength: 3);
    final myEventRepo = context.read(myEventRepositoryProvider);
    final eventsAffiche = myEventRepo.eventsStreamAffiche();
    final allEvents = myEventRepo.allEvents();

    StreamZip<List<MyEvent>> streamZipMaSelection;
    streamMyUser.whenData((user) {
      streamZipMaSelection = StreamZip([
        myEventRepo.eventStreamMaSelectionGenre(user?.genres ?? [],
            user?.lieu ?? [], user?.quand ?? [], user?.geoPoint),
        myEventRepo.eventStreamMaSelectionType(user?.types ?? [],
            user?.lieu ?? [], user?.quand ?? [], user?.geoPoint),
      ]);
    });
    //
    // final StreamZip<List<MyEvent>> streamZipMaSelection = StreamZip([
    //   myEventRepo.eventStreamMaSelectionGenre(user?.genres ?? [],
    //       user?.lieu ?? [], user?.quand ?? [], user?.geoPoint),
    //   myEventRepo.eventStreamMaSelectionType(user?.types ?? [],
    //       user?.lieu ?? [], user?.quand ?? [], user?.geoPoint),
    // ]);

    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    return ModelBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.black,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'À l\'affiche',
                style: Theme.of(context).textTheme.headline5.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          StreamBuilder<List<MyEvent>>(
              stream: eventsAffiche,
              builder: (context, AsyncSnapshot snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary)),
                  );
                } else if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Erreur de connexion',
                      style: Theme.of(context).textTheme.display1,
                    ),
                  );
                } else if (snap.data.length == 0) {
                  return Center(
                    child: Text(
                      'Pas d\'évenements',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  );
                }
                List<MyEvent> events = List<MyEvent>();
                events.addAll(snap.data);
                events.removeWhere((element) =>
                    element.dateDebutAffiche.compareTo(DateTime.now()) > 0);

                return events.length != 0
                    ? SizedBox(
                        height: orientation == Orientation.portrait
                            ? size.height * 0.60
                            : size.height * 0.60,
                        child: Swiper(
                          physics: ClampingScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return events[index].imageFlyerUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: events[index].imageFlyerUrl,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.fill),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25)),
                                          color: Colors.white),
                                    ),
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                      baseColor: Colors.white,
                                      highlightColor:
                                          Theme.of(context).colorScheme.primary,
                                      child: Container(
                                        width:
                                            orientation == Orientation.portrait
                                                ? size.width
                                                : 400,
                                        height:
                                            orientation == Orientation.portrait
                                                ? size.height / 1.5
                                                : size.height,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25)),
                                            color: Colors.white),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  )
                                : SizedBox();
                          },
                          itemCount: events.length,
                          pagination: SwiperPagination(),
                          control: SwiperControl(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onTap: (index) {
                            ExtendedNavigator.of(context).push(Routes.details,
                                arguments: DetailsArguments(
                                    event: events.elementAt(index)));
                          },
                          itemWidth: orientation == Orientation.portrait
                              ? size.height * 0.60 * 0.709 //0.709 format A6
                              : size.height * 0.60 * 0.709,
                          itemHeight: orientation == Orientation.portrait
                              ? size.height
                              : size.height,
                          layout: SwiperLayout.TINDER,
                          loop: true,
                          outer: true,
                          autoplay: true,
                          autoplayDisableOnInteraction: false,
                        ),
                      )
                    : Center(
                        child: Text(
                          'Pas d\'évenements',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      );
              }),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Ma selection',
                style: Theme.of(context).textTheme.headline5,
              ),
              streamMyUser.when(
                  data: (user) => IconButton(
                      icon: Icon(
                        FontAwesomeIcons.search,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => Show.showDialogLieuQuandGenresEtTypes(
                          context,
                          user.genres != null ? user.genres.toList() : [],
                          user.types != null ? user.types.toList() : [],
                          0,
                          tabController,
                          user.lieu ?? [],
                          user.quand ?? [],
                          user.geoPoint)),
                  loading: () => Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary)),
                      ),
                  error: (err, stack) => Icon(Icons.error)),
            ],
          ),
          // myListEvent(first, second),
          StreamBuilder<List<List<MyEvent>>>(
              stream: streamZipMaSelection,
              builder: (context, AsyncSnapshot snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary)),
                  );
                } else if (snap.hasError) {
                  print(snap.error);
                  return Center(
                    child: Text(
                      'Erreur de connexion',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  );
                } else if (!snap.hasData) {
                  return Center(
                    child: Text(
                      'Pas d\'évenements',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  );
                }

                List<MyEvent> events = List<MyEvent>();
                events.addAll(snap.data[0]);
                events.addAll(snap.data[1]);
                if (events.isEmpty) {
                  return Center(
                    child: Text(
                      'Pas d\'évenements',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  );
                }

                for (int i = 0; i < events.length; i++) {
                  //doublon
                  for (int j = 0; j < events.length; j++) {
                    if (j != i && events[j].id == events[i].id) {
                      events.removeAt(j);
                    }
                  }
                }

                return SizedBox(
                  height: 200,
                  child: Center(
                    child: ListView.separated(
                        separatorBuilder: (context, index) => VerticalDivider(),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () => ExtendedNavigator.of(context).push(
                                Routes.details,
                                arguments: DetailsArguments(
                                    event: events.elementAt(index))),
                            child: CachedNetworkImage(
                              imageUrl: events[index].imageFlyerUrl,
                              imageBuilder: (_, imageProvider) {
                                return Container(
                                  width: 150,
                                  height: 211,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                      color: Colors.white),
                                );
                              },
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  //color: Colors.white,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                      color: Colors.white),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          );
                        }),
                  ),
                );
              }),
          Divider(),
          Text(
            'La selection van E.vents',
            style: Theme.of(context).textTheme.headline5,
          ),
          StreamBuilder<List<MyEvent>>(
              stream: allEvents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary)),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur de connexion',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  );
                } else if (snapshot.data.length == 0) {
                  return Center(
                    child: Text(
                      'Pas d\'évenements',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  );
                }
                List<MyEvent> events = List<MyEvent>();
                events.addAll(snapshot.data);

                return events.isNotEmpty
                    ? SizedBox(
                        height: 220,
                        child: ListView.separated(
                            separatorBuilder: (context, index) =>
                                VerticalDivider(),
                            scrollDirection: Axis.horizontal,
                            itemCount: events.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () => ExtendedNavigator.of(context).push(
                                    Routes.details,
                                    arguments: DetailsArguments(
                                        event: events.elementAt(index))),
                                child: events[index].imageFlyerUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: events[index].imageFlyerUrl,
                                        imageBuilder: (_, imageProvider) {
                                          return Container(
                                            width: 150,
                                            height: 211,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.fill),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25)),
                                                color: Colors.white),
                                          );
                                        },
                                        placeholder: (context, url) =>
                                            Shimmer.fromColors(
                                          baseColor: Colors.white,
                                          highlightColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          child: Container(
                                            width: 220,
                                            height: 220,
                                            //color: Colors.white,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25)),
                                                color: Colors.white),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      )
                                    : SizedBox(),
                              );
                            }),
                      )
                    : Center(
                        child: Text(
                          'Pas d\'évenements',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      );
              })
        ],
      ),
    );
  }

  Widget myListEvent(
      AsyncValue<List<MyEvent>> first, AsyncValue<List<MyEvent>> second) {
    List<MyEvent> events = List<MyEvent>();
    events.addAll(first.data.value);
    events.addAll(second.data.value);

    for (int i = 0; i < events.length; i++) {
      //doublon
      for (int j = 0; j < events.length; j++) {
        if (j != i && events[j].id == events[i].id) {
          events.removeAt(j);
        }
      }
    }

    return SizedBox(
      height: 200,
      child: Center(
        child: ListView.separated(
            separatorBuilder: (context, index) => VerticalDivider(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => ExtendedNavigator.of(context).push(Routes.details,
                    arguments:
                        DetailsArguments(event: events.elementAt(index))),
                child: CachedNetworkImage(
                  imageUrl: events[index].imageFlyerUrl,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 150,
                    height: 211,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.fill),
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        color: Colors.white),
                  ),
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Theme.of(context).colorScheme.primary,
                    child: Container(
                      width: 220,
                      height: 220,
                      //color: Colors.white,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          color: Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              );
            }),
      ),
    );
  }
}
