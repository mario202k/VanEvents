import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';

class AdminOrganisateurs extends HookWidget {

  @override
  Widget build(BuildContext context) {

    final stripeRepo = useProvider(stripeRepositoryProvider);

    return ModelScreen(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('Admin'),
        ),
        body: FutureBuilder<HttpsCallableResult>(
            future: stripeRepo.allStripeAccounts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erreur de connection',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.secondary)),
                );
              }
              final List organisateur = [];

              organisateur.addAll(snapshot.data.data['data'] as List);

              return organisateur.isNotEmpty
                  ? ListView.separated(
                      itemCount: organisateur.length,
                      itemBuilder: (context, index) {
                        return Slidable(
                          actionPane: const SlidableDrawerActionPane(),
                          actionExtentRatio: 0.15,
                          actions: <Widget>[
                            IconSlideAction(
                              caption: 'Supprimer',
                              color: Theme.of(context).colorScheme.secondary,
                              icon: FontAwesomeIcons.eraser,
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (_) => Platform.isAndroid
                                        ? AlertDialog(
                                            title: const Text('Supprimer?'),
                                            content: const Text(
                                                'Etes vous sur de vouloir supprimer l\'organisateur'),
                                            actions: <Widget>[
                                              FlatButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Non'),
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  Scaffold.of(context)
                                                    ..hideCurrentSnackBar()
                                                    ..showSnackBar(
                                                      SnackBar(
                                                        content: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: const [
                                                            Text(
                                                                'Suppression...'),
                                                            CircularProgressIndicator(),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  Navigator.of(context).pop();
                                                  stripeRepo
                                                      .deleteStripeAccount(
                                                          organisateur
                                                              .elementAt(
                                                                  index)['id'] as String)
                                                      .then((value) {
                                                    if (value.data['deleted'] as bool) {
                                                      Scaffold.of(context)
                                                        ..hideCurrentSnackBar()
                                                        ..showSnackBar(
                                                          SnackBar(
                                                            content: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: const [
                                                                Text(
                                                                    'Suppression ok'),
                                                              ],
                                                            ),
                                                            duration: const Duration(
                                                                seconds: 3),
                                                          ),
                                                        );

                                                    } else {
                                                      Scaffold.of(context)
                                                        ..hideCurrentSnackBar()
                                                        ..showSnackBar(
                                                          SnackBar(
                                                            content: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: const [
                                                                Text(
                                                                    'Suppression impossible'),
                                                                CircularProgressIndicator(),
                                                              ],
                                                            ),
                                                            duration: const Duration(
                                                                seconds: 3),
                                                          ),
                                                        );
                                                    }
                                                  });
                                                },
                                                child: const Text('Oui'),
                                              ),
                                            ],
                                          )
                                        : CupertinoAlertDialog(
                                            title: const Text('Supprimer?'),
                                            content: const Text(
                                                'Etes vous sur de vouloir annuler l\'organisateur'),
                                            actions: <Widget>[
                                              FlatButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Non'),
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  Scaffold.of(context)
                                                    ..hideCurrentSnackBar()
                                                    ..showSnackBar(
                                                      SnackBar(
                                                        content: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: const [
                                                            Text(
                                                                'Suppression...'),
                                                            CircularProgressIndicator(),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  Navigator.of(context).pop();
                                                  //db.deleteStripeAccount(organisateur.elementAt(index)['id']).;
                                                },
                                                child: const Text('Oui'),
                                              ),
                                            ],
                                          ));
                              },
                            ),
                          ],
                          child: ListTile(
                            leading: Text(
                              DateFormat('dd/MM/yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      organisateur
                                          .elementAt(index)['created'] as int)),
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                            ),
                            title: Text(
                              organisateur.elementAt(index)['business_profile']
                                  ['name'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                            ),
                            onTap: (){
                              ExtendedNavigator.of(context)
                                  .push(Routes.stripeProfile,arguments: StripeProfileArguments(
                                  stripeAccount: organisateur.elementAt(index)['id'].toString()
                              ));
                            },
                            trailing: FutureBuilder<HttpsCallableResult>(
                              future: stripeRepo.organisateurBalance(
                                  organisateur.elementAt(index)['id'] as String ),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Erreur de connection',
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  );
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context)
                                              .colorScheme
                                              .secondary));
                                } else if (!snapshot.hasData) {
                                  return const SizedBox();
                                }
                                final List available =
                                    snapshot.data.data['available'] as List;
                                final int amount = available.firstWhere((element) =>
                                    element['currency'] == 'eur')['amount'] as int;

                                final double amountd = amount / 100;

                                return Text(
                                    '${amountd.toStringAsFixed(
                                            amountd.truncateToDouble() ==
                                                    amountd
                                                ? 0
                                                : 2)} €',
                                    style: Theme.of(context)
                                        .textTheme
                                        .button
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground));
                              },
                            ),
//                      onTap: () => ExtendedNavigator.of(context).pushNamed(
//                          Routes.monitoringScanner,
//                          arguments: MonitoringScannerArguments(
//                              eventId: organisateur.elementAt(index).id)),
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
                        'Pas d\'organisateur',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    );
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(
            Icons.autorenew,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }
}
