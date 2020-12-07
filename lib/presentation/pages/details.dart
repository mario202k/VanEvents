import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/domain/models/event.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_event_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';

import 'GalleryPage.dart';


class Details extends HookWidget {
  final MyEvent event;

  const Details(this.event);

  @override
  Widget build(BuildContext context) {
    print('buildDetails');
    final db = context.read(myEventRepositoryProvider);
    final participants = db.participantsEvent(event.id);

    return Consumer(
        builder: (context, watch, child) {
        return ModelScreen(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 300,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Theme.of(context).colorScheme.secondary,

                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(event.titre[0].toUpperCase()+event.titre.substring(1),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText1.copyWith(
                                  color: Theme.of(context).colorScheme.primary,fontWeight: FontWeight.bold)),
                        ),
                      ),
                      background: Image(
                        image: NetworkImage(event.imageFlyerUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ];
              },
              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.access_time,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            // "${DateFormat('dd/MM/yyyy').format(event.dateDebut)} à : ${event.dateDebut.hour}:${event.dateDebut.minute}"
                            '${DateFormat('dd/MM/yyyy').format(event.dateDebut)} à : ${DateFormat('HH').format(event.dateDebut)}h${DateFormat('mm').format(event.dateDebut)}',
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(color: Colors.black,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Theme.of(context).colorScheme.secondary,

                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.black,),
                            child: FlatButton.icon(
                                onPressed: () {
                                  final Event myEvent = Event(
                                    title: event.titre,
                                    description: event.description,
                                    location: [
                                      ...event.adresseRue,
                                      ...event.adresseZone
                                    ].join(' '),
                                    startDate: event.dateDebut,
                                    endDate: event.dateFin,
                                  );

                                  Add2Calendar.addEvent2Cal(myEvent);
                                },
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                label: Flexible(
                                    child: Text(
                                  "Plannifier",style: TextStyle(color: Theme.of(context).colorScheme.secondary,fontWeight: FontWeight.bold)
                                ))),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.black,

                          ),
                          child: FlatButton.icon(
                              onPressed: () async {
                                final availableMaps =
                                    await MapLauncher.installedMaps;
                                print(
                                    availableMaps); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

                                await availableMaps.first.showMarker(
                                  coords: Coords(event.position.latitude,
                                      event.position.longitude),
                                  title: event.titre,
                                  description: 'event.addressZone',
                                );
                              },
                              icon: Icon(
                                Icons.map,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              label: Flexible(child: Text("Y aller",style: TextStyle(color: Theme.of(context).colorScheme.secondary,fontWeight: FontWeight.bold)))),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Text(
                        "Description",
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                            color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      event.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(color: Colors.black, fontSize: 20),
                    ),
                    Text(
                      "Genres:",
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: event.genres
                              ?.map((e) => Text(
                                    e,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            color: Colors.black, fontSize: 20),
                                  ))
                              ?.toList() ??
                          [],
                    ),
                    Text(
                      "Types:",
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: event.types
                              ?.map((e) => Text(
                                    e,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                            color: Colors.black, fontSize: 20),
                                  ))
                              ?.toList() ??
                          [],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Divider(),
                    SizedBox(
                      height: 25,
                    ),
                    Text(
                      "Photos",
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                    GridView.builder(
                        itemCount: event.imagePhotos.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: (MediaQuery.of(context).orientation ==
                                    Orientation.landscape)
                                ? 3
                                : 2),
                        itemBuilder: (BuildContext context, int index) {
                          return CachedNetworkImage(
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.white,
                              highlightColor: Theme.of(context).colorScheme.primary,
                              child: Container(
                                  height: 300, width: 300, color: Colors.white),
                            ),
                            imageBuilder: (context, imageProvider) => SizedBox(
                              height: 300,
                              width: 300,
                              child: GestureDetector(
                                  onTap: () =>
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => GalleryPage(
                                                imageList: event.imagePhotos,
                                                initialPage: index,
                                              ))),
                                  child: Hero(
                                    tag: event.imagePhotos[index].substring(
                                        event.imagePhotos[index].indexOf('token=')),
                                    child: Image(
                                      image: imageProvider,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  )),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'assets/img/img_not_available.jpeg',
                                width: 300.0,
                                height: 300.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: event.imagePhotos[index],
                            fit: BoxFit.scaleDown,
                          );
                        }),
                    Divider(),
                    SizedBox(
                      height: 25,
                    ),
                    Text(
                      "Participants",
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                    Container(
                      height: 200,
                      child: FutureBuilder<List<Future<MyUser>>>(
                          future: participants,
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasError) {
                              return Center(
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
                            List<Future<MyUser>> participantsList = snapshot.data;

                            return participantsList.isNotEmpty
                                ? ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: participantsList.length,
                                    itemBuilder: (context, index) {
                                      return FutureBuilder<MyUser>(
                                          future: participantsList.elementAt(index),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return Center(
                                                child: Text('Erreur de connection'),
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

                                            MyUser user = snapshot.data;

                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.all(6),
                                                  child: CircleAvatar(
                                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                                    radius: 30,
                                                    backgroundImage:
                                                    user.imageUrl !=
                                                        null
                                                        ? NetworkImage(user.imageUrl)
                                                        : AssetImage(
                                                        'assets/img/normal_user_icon.png'),
                                                  ),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                  )
                                : SizedBox();
                          }),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: RawMaterialButton(
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Icon(
                        FontAwesomeIcons.cartArrowDown,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      PulseAnimation(
                        child: Text(
                          "PARTICIPER",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                shape: StadiumBorder(),
                fillColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  db.getFormulasList(event.id).then((form) {

                    ExtendedNavigator.of(context).push(Routes.formulaChoice,
                        arguments: FormulaChoiceArguments(
                            formulas: form,
                            eventId: event.id,
                            latLng: LatLng(
                                event.position.latitude, event.position.longitude),
                            stripeAccount: event.stripeAccount,
                            imageUrl: event.imageFlyerUrl,
                            dateDebut: event.dateDebut));
                  });
                }),
          ),
        );
      }
    );
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
