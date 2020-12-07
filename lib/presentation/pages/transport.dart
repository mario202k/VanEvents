import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/my_transport.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_event_repository.dart';
import 'package:van_events_project/domain/repositories/my_transport_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';


class Transport extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final db = useProvider(myTransportRepositoryProvider);

    return ModelScreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transports'),
        ),
        body: StreamBuilder<List<MyTransport>>(
            stream: db.streamTransportsUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.secondary)),
                );
              } else if (snapshot.hasError) {
                print(snapshot.error.toString());

                return Center(
                  child: Text(
                    'Erreur de connexion',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                );
              } else if (snapshot.data.length == 0) {
                return Center(
                  child: Text(
                    'Pas de transport',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                );
              }
              List<MyTransport> transports = List<MyTransport>();
              transports.addAll(snapshot.data);

              return transports.isNotEmpty
                  ? ListView.separated(
                      physics: ClampingScrollPhysics(),
                      itemCount: transports.length,
                      itemBuilder: (context, index) {
                        return Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.15,
                          actions: <Widget>[
                            IconSlideAction(
                              caption: 'Annuler',
                              color: Theme.of(context).colorScheme.secondary,
                              icon: FontAwesomeIcons.car,
                              onTap: () => showAreYouSure(
                                  context, transports.elementAt(index).id),
                            ),
                          ],
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: 'Chat',
                              color:
                                  Theme.of(context).colorScheme.primaryVariant,
                              icon: FontAwesomeIcons.comments,
                              //onTap: () => db.showSnackBar('Search', context),
                            ),
                          ],
                          child: ListTile(
                            leading: Text(
                              transports
                                  .elementAt(index)
                                  .statusTransport
                                  .toString()
                                  .substring(transports
                                          .elementAt(index)
                                          .statusTransport
                                          .toString()
                                          .indexOf('.') +
                                      1),
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            title: Text(
                              transports
                                      .elementAt(index)
                                      .distance
                                      .toStringAsFixed(2) +
                                  ' km pour ' +
                                  transports.elementAt(index).nbPersonne +
                                  ' personne(s)',
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            trailing: Image(
                              image: AssetImage(
                                  getPath(transports.elementAt(index).car)),
                            ),
                            onTap: () async {
                              final event = await context
                                  .read(myEventRepositoryProvider)
                                  .eventFuture(
                                      transports.elementAt(index).eventId);

                              ExtendedNavigator.of(context).push(
                                  Routes.transportDetail,
                                  arguments: TransportDetailArguments(
                                      myTransport: transports.elementAt(index),
                                      addressArriver: [
                                        ...event.adresseRue,
                                        ...event.adresseZone
                                      ].join(' ')));
                            },
                          ),
                        );
                      },
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => Divider(
                        color: Theme.of(context).colorScheme.secondary,
                        thickness: 1,
                      ),
                    )
                  : Center(
                      child: Text(
                        'Pas de transport',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    );
            }),
      ),
    );
  }

  void showAreYouSure(BuildContext context, String idTransport) {
    showDialog(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
                title: Text('Annuler?'),
                content: Text('Etes vous sur de vouloir annuler le transport'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Non'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Oui'),
                    onPressed: () {
                      context.read(myTransportRepositoryProvider).cancelTransport(
                          idTransport,
                          context.read(myUserProvider).typeDeCompte == TypeOfAccount.userNormal);
                    },
                  ),
                ],
              )
            : CupertinoAlertDialog(
                title: Text('Annuler?'),
                content: Text('Etes vous sur de vouloir annuler le transport'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Non'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Oui'),
                    onPressed: () {
                      context.read(myTransportRepositoryProvider).cancelTransport(
                          idTransport,
                          context.read(myUserProvider).typeDeCompte == TypeOfAccount.userNormal);
                    },
                  ),
                ],
              ));
  }

  String getPath(String car) {
    print(car);

    switch (car) {
      case 'classee':
        return 'assets/images/classee.png';
      case 'van':
        return 'assets/images/van.png';
      case 'classes':
        return 'assets/images/classes.png';
      case 'suv':
        return 'assets/images/suv.png';
    }

    return 'assets/images/suv.png';
  }
}
