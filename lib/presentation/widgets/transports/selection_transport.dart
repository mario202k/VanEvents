import 'dart:math' show cos, sqrt, asin;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:van_events_project/constants/credentials.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/formul_vtc.dart';

class SelectionTransport extends StatelessWidget {

  final List<String> mercedes = [
    'assets/images/classee.png',
    'assets/images/van.png',
    'assets/images/classes.png',
    'assets/images/suv.png'
  ];

  final TextEditingController _rue = TextEditingController();

  final TextEditingController _codePostal = TextEditingController();

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Choix du véhicule',
          style: Theme.of(context).textTheme.overline,
        ),
        InkWell(
          onTap: () async {
            final formuleVTC = context.read(formuleVTCProvider);

            if (formuleVTC.myEvent == null) {
              return;
            }

            if (formuleVTC.isNotDisplay) {
              _listKey.currentState
                  .insertItem(0, duration: const Duration(milliseconds: 200));
              await Future.delayed(const Duration(milliseconds: 200));
              formuleVTC.setautoPlay(false);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (formuleVTC.scrollController != null &&
                    formuleVTC.scrollController.hasClients) {
                  formuleVTC.scrollController.animateTo(
                      formuleVTC.scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.fastOutSlowIn);
                }
              });
            } else {
              _listKey.currentState.removeItem(
                0,
                (BuildContext context, Animation<double> animation) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                        parent: animation, curve: const Interval(0.5, 1.0)),
                    child: SizeTransition(
                      sizeFactor: CurvedAnimation(
                          parent: animation, curve: const Interval(0.0, 1.0)),
                      child: _buildRemovedItem(context),
                    ),
                  );
                },
                duration: const Duration(milliseconds: 600),
              );
              formuleVTC.setautoPlay(true);
            }

            formuleVTC.setisNotDisplay();
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
                    final String e = mercedes.elementAt(index);
                    context.read(formuleVTCProvider).setonGoingCar(
                        e.substring(e.lastIndexOf('/') + 1, e.indexOf('.')));
                  },
                  autoPlay: watch(formuleVTCProvider).autoPlay,
                  autoPlayInterval: const Duration(seconds: 3),
                  height: 250.0),
            );
          }),
        ),
        AnimatedList(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          key: _listKey,
          itemBuilder:
              (BuildContext context, int index, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: _buildItem(context),
            );
          },
        ),
      ],
    );
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
            key: context.read(formuleVTCProvider).fbKeyTransport, //
            //autovalidate: false,
            child: Column(
              children: <Widget>[
                FormBuilderTextField(
                  controller: _rue,
                  keyboardType: TextInputType.text,
                  name: 'Rue',
                  decoration: const InputDecoration(labelText: 'Rue'),
                ),
                const SizedBox(
                  height: 8,
                ),
                FormBuilderTextField(
                  controller: _codePostal,
                  keyboardType: TextInputType.text,
                  name: 'Code postal',
                  decoration: const InputDecoration(labelText: 'Code postal'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context) {
    final formuleVTC = context.read(formuleVTCProvider);
    formuleVTC.markers
        .removeWhere((element) => element.markerId.value == 'Arrivée');
    formuleVTC.markers.add(makeMarker(
        LatLng(formuleVTC.myEvent.position.latitude,
            formuleVTC.myEvent.position.longitude),
        'Arrivée'));

    return FormBuilder(
      key: context.read(formuleVTCProvider).fbKeyTransport,
      //autovalidate: false,
      child: Consumer(builder: (context, watch, child) {
        final formulewatch = watch(formuleVTCProvider);
        return Column(
          children: [
            Text(formulewatch.onGoingCar,
                style: Theme.of(context).textTheme.bodyText1),
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
                        decoration: const InputDecoration(labelText: 'Rue'),
                        onTap: () async {
                          final placesDetailsResponse =
                              await Show.showAddress(context, 'FormulaChoice');

                          if (placesDetailsResponse == null) {
                            return;
                          }
                          formuleVTC
                              .setplacesDetailsResponse(placesDetailsResponse);

                          buildAddress(
                              placesDetailsResponse, formuleVTC, context);
                        },
                        validator: FormBuilderValidators.required(context,
                            errorText: 'Champs requis'),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      FormBuilderTextField(
                        controller: _codePostal,
                        keyboardType: TextInputType.text,
                        name: 'Code postal',
                        decoration:
                            const InputDecoration(labelText: 'Code postal'),
                        onTap: () async {
                          final placesDetailsResponse =
                              await Show.showAddress(context, 'FormulaChoice');

                          if (placesDetailsResponse == null) {
                            return;
                          }

                          formuleVTC
                              .setplacesDetailsResponse(placesDetailsResponse);
                          buildAddress(
                              placesDetailsResponse, formuleVTC, context);
                        },
                        validator: FormBuilderValidators.required(context,
                            errorText: 'Champs requis'),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Destination : ${formulewatch.myEvent.adresseRue.join(" ")}',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Visibility(
                  visible: formulewatch.totalDistance != 0,
                  child: Text(
                    'Distance : ${formulewatch.totalDistance.toStringAsFixed(2)} km',
                    style: Theme.of(context).textTheme.bodyText1,
                  )),
            ),
            SizedBox(
              height: 200,
              child: GoogleMap(
                markers: formulewatch.markers,
                polylines: formulewatch.polylines,
                zoomGesturesEnabled: false,
                myLocationButtonEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  formuleVTC.setcontroller(controller);
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(formuleVTC.myEvent.position.latitude,
                      formuleVTC.myEvent.position.longitude),
                  zoom: 11,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Visibility(
                    visible: formulewatch.placesDetailsResponse != null,
                    child: FormBuilderDateTimePicker(
                      format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                      name: 'Date et heure',
                      decoration:
                          const InputDecoration(labelText: 'Date et heure'),
                      initialDate: formuleVTC.myEvent.dateDebut,
                      validator: FormBuilderValidators.required(context,
                          errorText: 'Champs requis'),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Visibility(
                      visible: formulewatch.placesDetailsResponse != null,
                      child: FormBuilderTextField(
                        keyboardType: TextInputType.number,
                        name: 'Nombre de personne',
                        decoration: const InputDecoration(
                            labelText: 'Nombre de personne'),
                        validator: FormBuilderValidators.required(context,
                            errorText: 'Champs requis'),
                      ))
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Marker makeMarker(LatLng latLng, String nom) {
    // Start Location Marker
    return Marker(
      markerId: MarkerId(nom),
      position: latLng,
      infoWindow: InfoWindow(
        title: nom,
      ),
    );
  }

  Future<void> moveCam(FormuleVTC formuleVTC) async {
    final Set<Polyline> p = formuleVTC.polylines;

    double minLat = p.first.points.first.latitude;
    double minLong = p.first.points.first.longitude;
    double maxLat = p.first.points.first.latitude;
    double maxLong = p.first.points.first.longitude;
    for (final poly in p) {
      for (final point in poly.points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLong) minLong = point.longitude;
        if (point.longitude > maxLong) maxLong = point.longitude;
      }
    }

    await formuleVTC.controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(minLat, minLong),
            northeast: LatLng(maxLat, maxLong)),
        20));
    await formuleVTC.scrollController.animateTo(
        formuleVTC.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn);
  }

  double _coordinateDistance(num lat1, num lon1, num lat2, num lon2) {
    const p = 0.017453292519943295;
    const c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future _createPolylines(
      LatLng start, LatLng destination, BuildContext context) async {
    final formuleVTC = context.read(formuleVTCProvider);

    formuleVTC.polylines.clear();
    formuleVTC.polylineCoordinates.clear();
    // Initializing PolylinePoints
    final polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    final PolylineResult result =
        await polylinePoints.getRouteBetweenCoordinates(
      placesApiKey, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      //travelMode: TravelMode.transit,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      for(final point in result.points){
        formuleVTC.polylineCoordinates
            .add(LatLng(point.latitude, point.longitude));
      }
    }
    formuleVTC.settotalDistance(0);

    for (int i = 0; i < formuleVTC.polylineCoordinates.length - 1; i++) {
      formuleVTC.settotalDistancePlus(_coordinateDistance(
        formuleVTC.polylineCoordinates[i].latitude,
        formuleVTC.polylineCoordinates[i].longitude,
        formuleVTC.polylineCoordinates[i + 1].latitude,
        formuleVTC.polylineCoordinates[i + 1].longitude,
      ));
    }

    formuleVTC.polylines.add(Polyline(
        polylineId: PolylineId("poly"),
        color: const Color.fromARGB(255, 40, 122, 198),
        width: 5,
        points: formuleVTC.polylineCoordinates));
  }

  Future<void> waitForGoogleMap(GoogleMapController c) async {
    final LatLngBounds l1 = await c.getVisibleRegion();
    final LatLngBounds l2 = await c.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return Future.delayed(const Duration(milliseconds: 100))
          .then((_) => waitForGoogleMap(c));
    }
    return Future.value();
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

    _createPolylines(
            formuleVTC.latLngDepart,
            LatLng(formuleVTC.myEvent.position.latitude,
                formuleVTC.myEvent.position.longitude),
            context)
        .then((_) {
      moveCam(formuleVTC);

      //waitForGoogleMap(mapController);
    });
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}
