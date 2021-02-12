import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:majascan/majascan.dart';
import 'package:van_events_project/domain/models/billet.dart';
import 'package:van_events_project/domain/repositories/my_billet_repository.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/presentation/widgets/show.dart';

class MonitoringScanner extends StatefulWidget {
  final String eventId;

  const MonitoringScanner(this.eventId);

  @override
  _MonitoringScannerState createState() => _MonitoringScannerState();
}

class _MonitoringScannerState extends State<MonitoringScanner> {
  GlobalKey qrKey = GlobalKey();
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      GlobalKey<AnimatedCircularChartState>();
  int nbAttendu;
  int nbPresent;
  Map participants;
  String qrResult;
  List<Billet> billets;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    nbAttendu = 0;
    nbPresent = 0;
    billets = <Billet>[];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read(myBilletRepositoryProvider);

    return ModelScreen(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Monitoring'),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight),
              child: StreamBuilder<List<Billet>>(
                  stream: db.streamBilletsAdmin(widget.eventId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      debugPrint(snapshot.error.toString());
                      return const Center(
                        child: Text('Erreur de connexion'),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.secondary)),
                      );
                    }

                    billets = snapshot.data;
                    int expected = 0, present = 0;

                    Billet ongoingBillet;
                    for (int i = 0; i < billets.length; i++) {
                      if (billets[i].id == qrResult) {
                        ongoingBillet = billets[i];
                      }

                      if (billets[i].status == BilletStatus.upComing ||
                          billets[i].status == BilletStatus.check) {
                        for (int j = 0;
                            j < billets[i].participants.length;
                            j++) {
                          expected++;

                          if (billets[i].participants.values.toList()[j][1] != null && billets[i].participants.values.toList()[j][1] as bool) {
                            present++;
                          }
                        }
                      }
                    }

                    final double totalAttendu =
                        expected.toDouble() - present.toDouble();

                    final List<CircularStackEntry> data = <CircularStackEntry>[
                      CircularStackEntry(
                        <CircularSegmentEntry>[
                          CircularSegmentEntry(totalAttendu, Colors.red,
                              rankKey: 'Attendu'),
                          CircularSegmentEntry(
                              present.toDouble(), Colors.green,
                              rankKey: 'Present'),
                        ],
                        rankKey: 'Quarterly Profits',
                      ),
                    ];

                    if (_chartKey.currentState != null) {
                      _chartKey.currentState.updateData(data);
                    }

                    final int total = totalAttendu.toInt();

                    return billets.isNotEmpty
                        ? Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Center(
                                        child: Text(
                                      'Present : $present',
                                      style: const TextStyle(color: Colors.green),
                                    )),
                                  ),
                                  Expanded(
                                      child: Center(
                                          child: Text(
                                    'Attendu : $total',
                                    style: const TextStyle(color: Colors.red),
                                  )))
                                ],
                              ),
                              AnimatedCircularChart(
                                key: _chartKey,
                                size: const Size(300.0, 300.0),
                                initialChartData: data,
                                //percentageValues: true,
                                holeLabel: '${(100 * present) / expected} %',
                                labelStyle: TextStyle(
                                  color: Colors.blueGrey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                ),
                              ),
                              if (ongoingBillet != null) SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            ongoingBillet.participants.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final String key = ongoingBillet
                                              .participants.keys
                                              .toList()[index].toString();
                                          final bool isHere = ongoingBillet
                                              .participants[key][1] as bool;
                                          return SizedBox(
                                            width: 250,
                                            child: GestureDetector(
                                              onTap: () => context
                                                  .read(
                                                      myBilletRepositoryProvider)
                                                  .setToggleisHere(
                                                      ongoingBillet
                                                          .participants as Map<String, List<dynamic>>,
                                                      qrResult,
                                                      index),
                                              child: Card(
                                                color: isHere
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .surface,
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      key,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: isHere
                                                              ? Colors.white
                                                              : Colors.black),
                                                    ),
                                                    Text(
                                                      ongoingBillet
                                                          .participants[key][0] as String,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: isHere
                                                              ? Colors.white
                                                              : Colors.black),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ) else const SizedBox(),
                              if (ongoingBillet != null) RaisedButton(
                                      onPressed: () => context
                                          .read(myBilletRepositoryProvider)
                                          .toutValider(ongoingBillet),
                                      child: Text(
                                        'Tout le monde',
                                        style:
                                            Theme.of(context).textTheme.button,
                                      ),
                                    ) else const SizedBox(),
                            ],
                          )
                        : Center(
                            child: Text(
                              'Aucun ticket vendu',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          );
                  }),
            ),
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(
            Icons.camera_alt,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          label: Text(
            "Scan",
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () {
            _scanQR(db, context);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  bool isValide(String data) {
    bool rep = false;
    for (int i = 0; i < billets.length; i++) {
      if (billets[i].paymentIntentId == data) {
        rep = true;
        break;
      }
    }
    return rep;
  }

  Future _scanQR(MyBilletRepository db, BuildContext context) async {
    try {
      qrResult = await MajaScan.startScan(
          title: "QRcode scanner",
          titleColor: Colors.amberAccent[700],
          qRCornerColor: Colors.orange,
          qRScannerColor: Colors.orange);

      bool rep = false;
      int j = 0;

      for (int i = 0; i < billets.length; i++) {
        j = i;
        if (billets[i].paymentIntentId == qrResult) {
          rep = true;
          break;
        }
      }

      if (rep) {
        if (billets[j].participants.length == 1) {
          Show.showDialogToDismiss(
              context, 'Validé!', "Ok pour : 1 participant", 'ok');
        } else {
          Show.showDialogToDismiss(context, 'Validé!',
              "Ok pour : ${billets[j].participants.length} participants", 'ok');
        }
        db.billetValidated(billets[j].id);
      } else {
        Show.showDialogToDismiss(context, 'OOps!', "Billet inconnu", 'ok');
      }
    } on PlatformException catch (ex) {
      if (ex.code == MajaScan.CameraAccessDenied) {
        Show.showDialogToDismiss(
            context, 'OOps!', "Pas de permission pour la caméra", 'ok');
        //db.showSnackBar("Camera permission was denied", context);

      } else {
        Show.showDialogToDismiss(context, 'OOps!', "Erreur inconnue", 'ok');
        //db.showSnackBar("Unknown Error $ex", context);

      }
    } on FormatException {
      Show.showDialogToDismiss(context, 'OOps!', "Aucun billet scanné", 'ok');
      //db.showSnackBar("You pressed the back button before scanning anything", context);

    } catch (ex) {
      debugPrint(ex.toString());
      Show.showDialogToDismiss(context, 'OOps!', "Erreur inconnue", 'ok');
      //db.showSnackBar("Unknown Error $ex", context);
    }
  }
}
