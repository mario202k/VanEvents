import 'package:async/async.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/domain/models/event.dart';
import 'package:van_events_project/domain/repositories/my_event_repository.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/toggle_bool.dart';

import 'details.dart';

class HomeEvents extends HookWidget {
  @override
  Widget build(BuildContext context) {
    // AsyncValue<List<MyEvent>> first = useProvider(streamGenreProvider);
    // AsyncValue<List<MyEvent>> second = useProvider(streamTypeProvider);
    //
    // if (first is AsyncError || second is AsyncError) {
    //   return Text('error');
    // } else if (first is AsyncLoading || second is AsyncLoading) {
    //   return Text('loading');
    // }

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

    return ModelBody(
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('À l\'affiche',
                  style: Theme.of(context).textTheme.headline3.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary)),
            ),
          ),
          const SizedBox(
            height: 15,
          ),

          StreamBuilder<List<MyEvent>>(
              stream: eventsAffiche,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary)),
                  );
                } else if (snap.hasError) {
                  debugPrint(snap.error.toString());
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
                final List<MyEvent> events = <MyEvent>[];
                events.addAll(snap.data);
                events.removeWhere((element) =>
                    element.dateDebutAffiche.compareTo(DateTime.now()) > 0);

                return events.isNotEmpty
                    ? SizedBox(
                        height: 280,
                        child: Swiper(
                            itemCount: events.length,
                            pagination: const SwiperPagination(),
                            control: const SwiperControl(),
                            controller: SwiperController(),
                            autoplay: true,
                            autoplayDelay: 5000,
                            itemBuilder: (context, index) {
                              return FittedBox(
                                child: CachedNetworkImage(
                                  imageUrl: events[index].imageFlyerUrl,
                                  imageBuilder: (context, imageProvider) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Details(events[index])));

                                        // return ExtendedNavigator.of(context).push(
                                        //   Routes.details,
                                        //   arguments: DetailsArguments(
                                        //       event: events.elementAt(index)));
                                      },
                                      child: Container(
                                          height: 280,
                                          clipBehavior: Clip.hardEdge,
                                          decoration: const BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25)),
                                          ),
                                          child: Image(
                                            image: imageProvider,
                                          )),
                                    );
                                  },
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.white,
                                    highlightColor:
                                        Theme.of(context).colorScheme.primary,
                                    child: Container(
                                      width: 172,
                                      height: 280,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25)),
                                          color: Colors.white),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              );
                            }),
                      )
                    : Center(
                        child: Text(
                          'Pas d\'évenements',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      );

                // return Container(
                //   height: 280,
                //   child: CarouselSlider.builder(
                //     itemCount: events.length,
                //     itemBuilder: (BuildContext context, int index) {
                //       return CachedNetworkImage(
                //         imageUrl: events[index].imageFlyerUrl,
                //         imageBuilder: (context, imageProvider) {
                //           context.read(boolToggleProvider).addEventsPhotos(
                //               imageProvider, events[index].imageFlyerUrl);
                //           return InkWell(
                //             onTap: () {
                //               Navigator.of(context).push(AppPageRoute(
                //                   builder: (context) =>
                //                       Details(events[index])));
                //
                //               // return ExtendedNavigator.of(context).push(
                //               //   Routes.details,
                //               //   arguments: DetailsArguments(
                //               //       event: events.elementAt(index)));
                //             },
                //             child: Container(
                //                 height: 280,
                //                 clipBehavior: Clip.hardEdge,
                //                 decoration: BoxDecoration(
                //                   color: Colors.amber,
                //                   borderRadius:
                //                       BorderRadius.all(Radius.circular(25)),
                //                 ),
                //                 child: Hero(
                //                     tag: events[index].id,
                //                     child: Image(
                //                       image: imageProvider,
                //                     ))),
                //           );
                //         },
                //         placeholder: (context, url) => Shimmer.fromColors(
                //           baseColor: Colors.white,
                //           highlightColor: Theme.of(context).colorScheme.primary,
                //           child: Container(
                //             width: 172,
                //             height: 280,
                //             decoration: BoxDecoration(
                //                 borderRadius:
                //                     BorderRadius.all(Radius.circular(25)),
                //                 color: Colors.white),
                //           ),
                //         ),
                //         errorWidget: (context, url, error) => Icon(Icons.error),
                //       );
                //     },
                //     options: CarouselOptions(
                //         autoPlay: true,
                //         autoPlayInterval: Duration(seconds: 3),
                //         autoPlayAnimationDuration: Duration(milliseconds: 800),
                //         height: 250.0),
                //   ),
                // );
              }),
          const Divider(),
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
                      onPressed: () => Show.showLieuQuandGenresEtTypes(
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
                  error: (err, stack) => const Icon(Icons.error)),
            ],
          ),
          // myListEvent(first, second),
          StreamBuilder<List<List<MyEvent>>>(
              stream: streamZipMaSelection,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary)),
                  );
                } else if (snap.hasError) {
                  debugPrint(snap.error.toString());
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

                final List<MyEvent> events = <MyEvent>[];
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
                        separatorBuilder: (context, index) =>
                            const VerticalDivider(),
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
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(25)),
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
                                  decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                      color: Colors.white),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          );
                        }),
                  ),
                );
              }),
          const Divider(),
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
                } else if (snapshot.data.isEmpty) {
                  return Center(
                    child: Text(
                      'Pas d\'évenements',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  );
                }
                final List<MyEvent> events = <MyEvent>[];
                events.addAll(snapshot.data);

                return events.isNotEmpty
                    ? SizedBox(
                        height: 220,
                        child: ListView.separated(
                            separatorBuilder: (context, index) =>
                                const VerticalDivider(),
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
                                          context
                                              .read(boolToggleProvider)
                                              .addEventsPhotos(imageProvider,
                                                  events[index].imageFlyerUrl);

                                          return Hero(
                                            tag: events[index].id,
                                            child: Container(
                                              width: 150,
                                              height: 211,
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.fill),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(25)),
                                                  color: Colors.white),
                                            ),
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
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25)),
                                                color: Colors.white),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      )
                                    : const SizedBox(),
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
    final List<MyEvent> events = <MyEvent>[];
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
            separatorBuilder: (context, index) => const VerticalDivider(),
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                        color: Colors.white),
                  ),
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Theme.of(context).colorScheme.primary,
                    child: Container(
                      width: 220,
                      height: 220,
                      //color: Colors.white,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          color: Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              );
            }),
      ),
    );
  }
}
