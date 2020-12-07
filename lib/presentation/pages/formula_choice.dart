import 'dart:async';
import 'dart:math' show cos, sqrt, asin;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:van_events_project/constants/credentials.dart';
import 'package:van_events_project/domain/models/billet.dart';
import 'package:van_events_project/domain/models/formule.dart';
import 'package:van_events_project/domain/models/my_transport.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_billet_repository.dart';
import 'package:van_events_project/domain/repositories/my_transport_repository.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/formul_vtc.dart';


class FormulaChoice extends StatefulWidget {
  final List<Formule> formulas;
  final String eventId;
  final String imageUrl;
  final String stripeAccount;
  final LatLng latLng;
  final DateTime dateDebut;

  FormulaChoice(this.formulas, this.eventId, this.imageUrl, this.stripeAccount,
      this.latLng, this.dateDebut);

  @override
  _FormulaChoiceState createState() => _FormulaChoiceState();
}

class _FormulaChoiceState extends State<FormulaChoice> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final TextEditingController _rue = TextEditingController();

  final TextEditingController _codePostal = TextEditingController();

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  final List<String> mercedes = [
    'assets/images/classee.png',
    'assets/images/van.png',
    'assets/images/classes.png',
    'assets/images/suv.png'
  ];

  @override
  void initState() {
    FormuleVTC().init();
    super.initState();
  }

  @override
  void dispose() {
    FormuleVTC().myDispose();
    super.dispose();
    //context.read(formuleVTCProvider).dispose();
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future _createPolylines(
      LatLng start, LatLng destination, BuildContext context) async {
    final formuleVtc = context.read(formuleVTCProvider);

    formuleVtc.polylines.clear();
    formuleVtc.polylineCoordinates.clear();
    // Initializing PolylinePoints
    final polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      PLACES_API_KEY, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      //travelMode: TravelMode.transit,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        formuleVtc.polylineCoordinates
            .add(LatLng(point.latitude, point.longitude));
      });
    }
    formuleVtc.settotalDistance(0);

    for (int i = 0; i < formuleVtc.polylineCoordinates.length - 1; i++) {
      formuleVtc.settotalDistancePlus(_coordinateDistance(
        formuleVtc.polylineCoordinates[i].latitude,
        formuleVtc.polylineCoordinates[i].longitude,
        formuleVtc.polylineCoordinates[i + 1].latitude,
        formuleVtc.polylineCoordinates[i + 1].longitude,
      ));
    }

    formuleVtc.polylines.add(Polyline(
        polylineId: PolylineId("poly"),
        color: Color.fromARGB(255, 40, 122, 198),
        width: 5,
        points: formuleVtc.polylineCoordinates));
  }

  Future<void> waitForGoogleMap(GoogleMapController c) async {
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    print(l1.toString());
    print(l2.toString());
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return Future.delayed(Duration(milliseconds: 100))
          .then((_) => waitForGoogleMap(c));
    }
    return Future.value();
  }

  Widget _buildItem(BuildContext context, FormuleVTC formuleVTC) {
    formuleVTC.markers
        .removeWhere((element) => element.markerId.value == 'Arrivée');
    formuleVTC.markers.add(makeMarker(widget.latLng, 'Arrivée'));

    return FormBuilder(
      key: _fbKey,
      //autovalidate: false,
      child: Consumer(builder: (context, watch, child) {
        final formulewatch = watch(formuleVTCProvider);
        return Column(
          children: [
            Text(formulewatch.onGoingCar),
            Card(
              child: Column(
                children: <Widget>[
                  Text(
                    'Lieu de prise en charge',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        controller: _rue,
                        keyboardType: TextInputType.text,
                        name: 'Rue',
                        decoration: InputDecoration(labelText: 'Rue'),
                        onTap: () async {
                          final placesDetailsResponse =
                              await Show.showAddress(context,'FormulaChoice');

                          if (placesDetailsResponse == null) {
                            return;
                          }
                          formuleVTC
                              .setplacesDetailsResponse(placesDetailsResponse);

                          buildAddress(
                              placesDetailsResponse, formuleVTC, context);
                        },
                        validator: FormBuilderValidators.required(context),

                      ),
                      SizedBox(
                        height: 8,
                      ),
                      FormBuilderTextField(
                        controller: _codePostal,
                        keyboardType: TextInputType.text,
                        name: 'Code postal',
                        decoration: InputDecoration(labelText: 'Code postal'),
                        onTap: () async {
                          final placesDetailsResponse =
                              await Show.showAddress(context,'FormulaChoice');

                          if (placesDetailsResponse == null) {
                            return;
                          }

                          formuleVTC
                              .setplacesDetailsResponse(placesDetailsResponse);
                          buildAddress(
                              placesDetailsResponse, formuleVTC, context);
                        },
                        validator:
                          FormBuilderValidators.required(
                              context),

                      ),
                    ],
                  )
                ],
              ),
            ),
            Visibility(
                visible: formulewatch.totalDistance == 0 ? false : true,
                child: Text(
                    'Distance : ${formulewatch.totalDistance.toStringAsFixed(2)} km')),
            SizedBox(
              height: 200,
              child: GoogleMap(
                mapType: MapType.normal,
                markers: formulewatch.markers,
                polylines: formulewatch.polylines,
                cameraTargetBounds: CameraTargetBounds.unbounded,
                zoomGesturesEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                zoomControlsEnabled: true,
                scrollGesturesEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  formuleVTC.setcontroller(controller);
                },
                initialCameraPosition: CameraPosition(
                  target:
                      LatLng(widget.latLng.latitude, widget.latLng.longitude),
                  zoom: 11,
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Visibility(
              visible:
                  formulewatch.placesDetailsResponse == null ? false : true,
              child: FormBuilderDateTimePicker(
                inputType: InputType.both,
                format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                name: 'Date et heure',
                decoration: InputDecoration(labelText: 'Date et heure'),
                initialDate: widget.dateDebut,
                validator: FormBuilderValidators.required(context),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Visibility(
                visible:
                    formulewatch.placesDetailsResponse == null ? false : true,
                child: FormBuilderTextField(
                  keyboardType: TextInputType.number,
                  name: 'Nombre de personne',
                  decoration: InputDecoration(labelText: 'Nombre de personne'),
                  validator: FormBuilderValidators.required(context),
                ))
          ],
        );
      }),
    );
  }

  void buildAddress(PlacesDetailsResponse placesDetailsResponse,
      FormuleVTC formuleVTC, BuildContext context) {
    _rue.text =
        "${placesDetailsResponse.result?.addressComponents?.firstWhere((element) => element.types.first == 'street_number')?.longName ?? ''} ${placesDetailsResponse.result?.addressComponents?.firstWhere((element) => element.types.first == 'route')?.longName ?? ''}";

    _codePostal.text = placesDetailsResponse.result?.addressComponents
            ?.firstWhere((element) => element.types.first == 'postal_code')
            ?.longName ??
        '';

    formuleVTC.setlatLngDepart(LatLng(
        placesDetailsResponse.result.geometry.location.lat,
        placesDetailsResponse.result.geometry.location.lng));

    // Start Location Marker
    formuleVTC.markers
        .removeWhere((element) => element.markerId.value == 'Départ');
    formuleVTC.markers.add(makeMarker(formuleVTC.latLngDepart, 'Départ'));

    _createPolylines(formuleVTC.latLngDepart, widget.latLng, context).then((_) {
      moveCam(formuleVTC);

      //waitForGoogleMap(mapController);
    });
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Widget _buildRemovedItem(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Text(
            'Lieu de prise en charge',
            style: Theme.of(context).textTheme.headline5,
          ),
          FormBuilder(
            key: _fbKey,
            //autovalidate: false,
            child: Column(
              children: <Widget>[
                FormBuilderTextField(
                  controller: _rue,
                  keyboardType: TextInputType.text,
                  name: 'Rue',
                  decoration: InputDecoration(labelText: 'Rue'),
                ),
                SizedBox(
                  height: 8,
                ),
                FormBuilderTextField(
                  controller: _codePostal,
                  keyboardType: TextInputType.text,
                  name: 'Code postal',
                  decoration: InputDecoration(labelText: 'Code postal'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void moveCam(FormuleVTC formuleVTC) async {
    Set<Polyline> p = formuleVTC.polylines;

    double minLat = p.first.points.first.latitude;
    double minLong = p.first.points.first.longitude;
    double maxLat = p.first.points.first.latitude;
    double maxLong = p.first.points.first.longitude;
    p.forEach((poly) {
      poly.points.forEach((point) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLong) minLong = point.longitude;
        if (point.longitude > maxLong) maxLong = point.longitude;
      });
    });

    formuleVTC.controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(minLat, minLong),
            northeast: LatLng(maxLat, maxLong)),
        20));
  }

  Marker makeMarker(LatLng latLng, String nom) {
    // Start Location Marker
    return Marker(
      markerId: MarkerId(nom),
      position: latLng,
      infoWindow: InfoWindow(
        title: nom,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('buildFormulaChoice');
    final formuleVtc = context.read(formuleVTCProvider);
    if (formuleVtc.formuleParticipant.isEmpty) {
      formuleVtc.setformuleParticipant(Map.fromIterable(widget.formulas,
          key: (form) => CardFormula(form),
          value: (form) => CardFormIntParticipant(0, List<CardParticipant>())));
    }


    return Consumer(builder: (context, watch, child) {
      return ModelScreen(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          key: _scaffoldKey,
          appBar: AppBar(
              title: Text(
            "Formules",
            style: Theme.of(context).textTheme.headline1,
          )),
          body: ModelBody(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Text('Billets'),
                  ListView.builder(
                      physics: ClampingScrollPhysics(),
                      itemCount: widget.formulas.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return CardFormula(widget.formulas[index]);
                      }),
                  Divider(),
                  Text('Transport'),
                  Text(
                    'Choix du véhicule',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  InkWell(
                    onTap: () {
                      if (formuleVtc.isNotDisplay) {
                        _listKey.currentState.insertItem(0);

                        formuleVtc.setautoPlay(false);
                      } else {
                        _listKey.currentState.removeItem(
                          0,
                          (BuildContext context, Animation<double> animation) {
                            return FadeTransition(
                              opacity: CurvedAnimation(
                                  parent: animation, curve: Interval(0.5, 1.0)),
                              child: SizeTransition(
                                sizeFactor: CurvedAnimation(
                                    parent: animation,
                                    curve: Interval(0.0, 1.0)),
                                axisAlignment: 0.0,
                                child: _buildRemovedItem(context),
                              ),
                            );
                          },
                          duration: Duration(milliseconds: 600),
                        );
                        formuleVtc.setautoPlay(true);
                      }

                      formuleVtc.setisNotDisplay();
                    },
                    child: Consumer(builder: (context, watch, child) {
                      return CarouselSlider.builder(
                        itemCount: mercedes.length,
                        itemBuilder: (BuildContext context, int itemIndex) {
                          return Image(
                            image: AssetImage(mercedes.elementAt(itemIndex)),
                          );
                        },
                        options: CarouselOptions(
                            onPageChanged: (index, raison) {
                              String e = mercedes.elementAt(index);
                              formuleVtc.setonGoingCar(e.substring(
                                  e.lastIndexOf('/') + 1, e.indexOf('.')));
                            },
                            autoPlay: watch(formuleVTCProvider).autoPlay,
                            autoPlayInterval: Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                            height: 250.0),
                      );
                    }),
                  ),
                  AnimatedList(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    key: _listKey,
                    itemBuilder: (BuildContext context, int index,
                        Animation<double> animation) {
                      print(index);
                      return SizeTransition(
                        axis: Axis.vertical,
                        sizeFactor: animation,
                        child: _buildItem(context, formuleVtc),
                      );
                    },
                  ),


                ],
              ),
            ),
          ),
          bottomSheet: Consumer(builder: (context, watch, child) {
            return Container(
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: _buildTotalContent(context, formuleVtc),
            );
          }),
        ),
      );
    });
  }

  _buildTotalContent(
      BuildContext context, FormuleVTC readFormuleVtc) {
    print('_buildTotalContent');
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80,
      child: Consumer(builder: (context, watch, child) {
        final formuleVTC = watch(formuleVTCProvider);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '   ${formuleVTC.totalCost.toStringAsFixed(formuleVTC.totalCost.truncateToDouble() == formuleVTC.totalCost ? 0 : 2)} €',
              textAlign: TextAlign.center,
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: !formuleVTC.showSpinner
                  ? FloatingActionButton.extended(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      icon: Text(
                        'Continuer',
                        style: Theme.of(context).textTheme.button,
                      ),
                      label: Icon(
                        FontAwesomeIcons.creditCard,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      onPressed: () async {
                        readFormuleVtc.setshowSpinner();

                        await process(readFormuleVtc, context);
                        readFormuleVtc.setshowSpinner();
                      })
                  : CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary)),
            ),
          ],
        );
      }),
    );
  }

  Future process(FormuleVTC readFormuleVtc, BuildContext context,
      ) async {
    if (_fbKey.currentState != null && _fbKey.currentState.validate()) {
      await uploadTransport(context, readFormuleVtc).then((value) async {
        await Show.showDialogToDismiss(
            context,
            'Transport',
            'Votre demande de transport sera traitée dans les plus brèves délai',
            'Ok');
      });
    } else {
      if (_fbKey.currentState == null) {
        await Show.showDialogToDismiss(context, 'Transport',
            'Vous n\'avez fait de demande de transport', 'Ok');
      } else {
        await Show.showDialogToDismiss(
            context, 'Transport', 'Erreur de saisie', 'Ok');
      }
    }

    if (allParticipantIsOk(readFormuleVtc)) {
      int nb = 0;
      String description = '';

      readFormuleVtc.listFbKey.forEach((key, value) {
        value.forEach((element) {
          nb++;

          description = description +
              key.title +
              ' pour ' +
              element.currentState.fields['prenom'].value +
              ' ' +
              element.currentState.fields['nom'].value +
              '\n ';
        });
      });

      await context.read(stripeRepositoryProvider)
          .paymentIntentBillet(readFormuleVtc.totalCost * 100, widget.stripeAccount,
              description, nb)
          .then((value) async {
        if (value is String) {
          Show.showDialogToDismiss(context, 'Oups!',
              'Payement refusé\nEssayer avec une autre carte', 'Ok');

          return;
        }
        if (value is Map) {
          await paymentValider(value, readFormuleVtc, context);
        }
      });
    } else {
      if (readFormuleVtc.getAllCardParticipants().length == 0) {
        await Show.showDialogToDismiss(context, 'Billets!',
            'Vous n\'avez fait de demande de billets', 'Ok');
      } else {
        await Show.showDialogToDismiss(
            context, 'Billets', 'Erreur de saisie', 'Ok');
      }
    }
  }

  Future uploadTransport(BuildContext context, FormuleVTC formuleVTC) async {
    List<AddressComponent> adresse = List<AddressComponent>();

    List<AddressComponent> rue = List<AddressComponent>();

    rue.addAll(formuleVTC.placesDetailsResponse.result.addressComponents);

    adresse.addAll(formuleVTC.placesDetailsResponse.result.addressComponents);

    rue.removeWhere((element) =>
        element.types[0] == "locality" ||
        element.types[0] == "administrative_area_level_2" ||
        element.types[0] == "administrative_area_level_1" ||
        element.types[0] == "country" ||
        element.types[0] == "postal_code");

    adresse.removeWhere((element) =>
        element.types[0] == "floor" ||
        element.types[0] == "street_number" ||
        element.types[0] == "route" ||
        element.types[0] == 'country');

    String docId = FirebaseFirestore.instance.collection('transports').doc().id;

    await context
        .read(myTransportRepositoryProvider)
        .uploadTransport(MyTransport(
            id: docId,
            statusTransport: StatusTransport.submitted,
            car: formuleVTC.onGoingCar,
            position: GeoPoint(formuleVTC.latLngDepart.latitude,
                formuleVTC.latLngDepart.longitude),
            paymentIntentId: null,
            nbPersonne: _fbKey
                .currentState.fields['Nombre de personne'].value,
            distance: formuleVTC.totalDistance,
            dateTime:
                _fbKey.currentState.fields['Date et heure'].value,
            amount: null,
            adresseRue: List<String>.generate(
                rue.length, (index) => rue[index].longName),
            adresseZone: List<String>.generate(
                adresse.length, (index) => adresse[index].longName),
            userId: context.read(myUserProvider).id,
            eventId: widget.eventId))
        .then((value) =>
        Show.showDialogToDismiss(context,
            '', 'Demande de transport effectuée', 'Ok')
    )
        .catchError((e) {
      print(e);
      Show.showDialogToDismiss(context,
          'Erreur', 'Erreur $e', 'Ok');
    });
  }

  Future paymentValider(
      paymentIntentX, FormuleVTC formuleVTC, BuildContext context) async {
    Map participant = Map();
    formuleVTC.listFbKey.forEach((key, value) {
      value.forEach((element) {
        participant.addAll({
          element.currentState.fields['prenom'].value +
              ' ' +
              element.currentState.fields['nom'].value: [
            key.title,
            false
          ]
        });
      });
    });

    Billet billet = Billet(
      id: paymentIntentX['id'],
      status: 'En attente',
      uid: context.read(myUserProvider).id,
      eventId: widget.eventId,
      imageUrl: widget.imageUrl,
      participants: participant,
      amount: paymentIntentX['amount'],
      dateTime: DateTime.now(),
    );

    await context.read(myBilletRepositoryProvider).addNewBillet(billet);

    //payment was confirmed by the server without need for futher authentification

    double amount = double.parse(paymentIntentX['amount'].toString());

    amount = amount / 100;

    Show.showDialogToDismiss(
        context,
        'Payement validé!',
        '$amount € montant payé avec succès\nUn nouveau billet est disponible',
        'Ok');
  }

  bool allParticipantIsOk(FormuleVTC formuleVTC) {
    bool b = true;
    if (formuleVTC.getAllCardParticipants().length == 0) {
      b = false;
    }

    for (int i = 0; i < formuleVTC.listFbKey.length; i++) {
      Formule formule = formuleVTC.listFbKey.keys.elementAt(i);
      for (int j = 0; j < formuleVTC.listFbKey[formule].length; j++) {
        print(formuleVTC.listFbKey[formule][j].currentState.fields['prenom']);
        print('//');
        if (!formuleVTC.listFbKey[formule][j].currentState.validate()) {
          b = false;
          break;
        }
      }
    }
    return b;
  }
}

class CardParticipant extends StatefulWidget {
  final Formule formule;
  final int index;
  final bool isToDestroy;

  CardParticipant({this.formule, this.index, this.isToDestroy});

  @override
  _CardParticipantState createState() => _CardParticipantState();
}

class _CardParticipantState extends State<CardParticipant>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final FocusScopeNode _nom = FocusScopeNode();
  final FocusScopeNode _prenom = FocusScopeNode();

  @override
  void initState() {
    print('initState');
    context.read(formuleVTCProvider).onChangeParticipant(
        widget.formule, _fbKey, widget.index, widget.isToDestroy, true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('buildCardParticipant');

    return Consumer(builder: (context, watch, child) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            // gradient: LinearGradient(colors: [
            //   Theme.of(context).colorScheme.primary,
            //   Theme.of(context).colorScheme.secondary
            // ]),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Participant',
                  style: Theme.of(context).textTheme.button,
                ),
                FormBuilder(
                  key: _fbKey,
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        valueTransformer: (value) => value.toString().trim(),
                        keyboardType: TextInputType.text,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        name: 'prenom',
                        decoration: InputDecoration(
                          labelText: 'Prénom',
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  style: BorderStyle.solid,
                                  width: 2),
                              borderRadius: BorderRadius.circular(25.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  style: BorderStyle.solid,
                                  width: 2),
                              borderRadius: BorderRadius.circular(25.0)),
                          labelStyle: Theme.of(context).textTheme.button,
                          counterStyle: TextStyle(color: Colors.white),
                        ),
                        onChanged: (val) {
                          print(val);
                          context.read(formuleVTCProvider).onChangeParticipant(
                              widget.formule,
                              _fbKey,
                              widget.index,
                              widget.isToDestroy,
                              false);
                        },
                        focusNode: _prenom,
                        onEditingComplete: () {
                          if (_fbKey.currentState.fields['prenom']
                              .validate()) {
                            _prenom.unfocus();
                            FocusScope.of(context).requestFocus(_nom);
                          }
                        },
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                          FormBuilderValidators.match(context, r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ ]{2,30}$')]),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      FormBuilderTextField(
                        valueTransformer: (value) => value.toString().trim(),
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        name: 'nom',
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    style: BorderStyle.solid,
                                    width: 2),
                                borderRadius: BorderRadius.circular(25.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    style: BorderStyle.solid,
                                    width: 2),
                                borderRadius: BorderRadius.circular(25.0)),
                            labelText: 'Nom',
                            labelStyle: Theme.of(context).textTheme.button,
                            counterStyle: TextStyle(color: Colors.white)),
                        focusNode: _nom,
                        onEditingComplete: () {
                          if (_fbKey.currentState.fields['nom']
                              .validate()) {
                            _nom.unfocus();
                          }
                        },
                        onChanged: (val) {
                          print(val);
                          context.read(formuleVTCProvider).onChangeParticipant(
                              widget.formule,
                              _fbKey,
                              widget.index,
                              widget.isToDestroy,
                              false);
                        },
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                          FormBuilderValidators.match(context, r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ ]{2,30}$')]),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class CardFormula extends StatefulWidget {
  final Formule formule;

  CardFormula(this.formule);

  @override
  _CardFormulaState createState() => _CardFormulaState();
}

class _CardFormulaState extends State<CardFormula>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('buildCardFormula!!!!');
    final formulVtc = context.read(formuleVTCProvider);
    return Consumer(builder: (context, watch, child) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: SizedBox(
              height: 128.0,
              child: Card(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Flexible(
                          child: Text(
                        '${widget.formule.title} : ${toNormalPrice(widget.formule.prix)} €',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Colors.black, fontSize: 20),
                        textAlign: TextAlign.center,
                      )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {
                              if (formulVtc.getNb(widget.formule.id) > 0) {
                                _listKey.currentState.removeItem(
                                  formulVtc
                                          .getCardParticipants(
                                              widget.formule.id)
                                          .length -
                                      1,
                                  (BuildContext context,
                                      Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: CurvedAnimation(
                                          parent: animation,
                                          curve: Interval(0.5, 1.0)),
                                      child: SizeTransition(
                                        sizeFactor: CurvedAnimation(
                                            parent: animation,
                                            curve: Interval(0.0, 1.0)),
                                        axisAlignment: 0.0,
                                        child: CardParticipant(
                                          index: formulVtc
                                              .getCardParticipants(
                                                  widget.formule.id)
                                              .length,
                                          isToDestroy: true,
                                          formule: widget.formule,
                                        ),
                                      ),
                                    );
                                  },
                                  duration: Duration(milliseconds: 600),
                                );
                                formulVtc.removeCardParticipants(
                                    widget.formule,
                                    context
                                            .read(formuleVTCProvider)
                                            .getCardParticipants(
                                                widget.formule.id)
                                            .length -
                                        1);

                                formulVtc.setNb(
                                    widget.formule,
                                    context
                                        .read(formuleVTCProvider)
                                        .getCardParticipants(widget.formule.id)
                                        .length);
                                formulVtc
                                    .settotalCostMoins(widget.formule.prix);
                              }
                            },
                            child: Icon(
                              FontAwesomeIcons.minus,
                              color: Theme.of(context).colorScheme.primary,
                              size: 30.0,
                            ),
                            shape: CircleBorder(),
                            elevation: 5.0,
                            fillColor: Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.all(10.0),
                          ),
                          Consumer(builder: (context, watch, child) {
                            final formulVtc = watch(formuleVTCProvider);
                            return Text(formulVtc
                                .formuleParticipant[formulVtc
                                    .formuleParticipant.keys
                                    .firstWhere((element) =>
                                        element.formule.id ==
                                        widget.formule.id)]
                                .nb
                                .toString());
                          }),
                          RawMaterialButton(
                            onPressed: () {
                              if (formulVtc.getNb(widget.formule.id) >= 0) {
                                formulVtc.setCarParticipants(
                                    widget.formule,
                                    formulVtc
                                            .getCardParticipants(
                                                widget.formule.id)
                                            .length -
                                        1);
                                formulVtc.setNb(
                                    widget.formule,
                                    formulVtc
                                        .getCardParticipants(widget.formule.id)
                                        .length);
                                formulVtc.settotalCostPlus(widget.formule.prix);

                                _listKey.currentState.insertItem(
                                    formulVtc
                                            .getCardParticipants(
                                                widget.formule.id)
                                            .length -
                                        1,
                                    duration: Duration(milliseconds: 500));
                              }
                            },
                            child: Icon(
                              FontAwesomeIcons.plus,
                              color: Theme.of(context).colorScheme.primary,
                              size: 30.0,
                            ),
                            shape: CircleBorder(),
                            elevation: 5.0,
                            fillColor: Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.all(10.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedList(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            key: _listKey,
            initialItemCount: context
                    .read(formuleVTCProvider)
                    .getCardParticipants(widget.formule.id)
                    ?.length ??
                0,
            itemBuilder:
                (BuildContext context, int index, Animation<double> animation) {
              return SizeTransition(
                axis: Axis.vertical,
                sizeFactor: animation,
                child: CardParticipant(
                  formule: widget.formule,
                  index: index,
                  isToDestroy: false,
                ),
              );
            },
          ),
        ],
      );
    });
  }

  String toNormalPrice(double price) {
    return price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class CardFormIntParticipant {
  int nb;
  final List<CardParticipant> cardParticipant;

  CardFormIntParticipant(this.nb, this.cardParticipant);

  setNb(int nb) {
    this.nb = nb;
  }
}