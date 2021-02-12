import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/formule.dart';
import 'package:van_events_project/presentation/pages/formula_choice.dart';

final formuleVTCProvider = ChangeNotifierProvider<FormuleVTC>((ref) {
  return FormuleVTC();
});

class FormuleVTC extends ChangeNotifier {
  bool showSpinner;
  bool isNotDisplay;
  Map<CardFormula, CardFormIntParticipant> formuleParticipant ;
  Map<Formule, List<GlobalKey<FormBuilderState>>> listFbKey ;
  List<Formule> formules ;
  String placeDistance;
  int indexParticipants ;
  double totalCost ;
  Set<Marker> markers ;
  LatLng latLngDepart;
  bool autoPlay ;
  PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates ;
  Set<Polyline> polylines ;
  double totalDistance;
  String onGoingCar ;
  GoogleMapController controller;
  PlacesDetailsResponse placesDetailsResponse;

  static final FormuleVTC _formuleVTC = FormuleVTC._internal();

  factory FormuleVTC(){
    return _formuleVTC;
  }

  FormuleVTC._internal();

  void init() {
    showSpinner = false;
    isNotDisplay = true;
    formuleParticipant = <CardFormula, CardFormIntParticipant>{};
    listFbKey = <Formule, List<GlobalKey<FormBuilderState>>>{};

    formules = <Formule>[];
    indexParticipants = 0;
    totalCost = 0;
    markers = {};
    autoPlay = true;

    polylineCoordinates = [];
    polylines = {};
    totalDistance = 0;
    onGoingCar = 'classee';

  }

  void myDispose() {
      showSpinner = null;
      isNotDisplay = null;
      formuleParticipant =
      null;
      listFbKey =
      null;

      formules = null;
      placeDistance = null;
      indexParticipants = null;
      totalCost = null;
      markers = null;
      latLngDepart = null;
      autoPlay = null;
      polylinePoints = null;
      polylineCoordinates = null;
      polylines = null;
      totalDistance = null;
      onGoingCar = null;
      controller = null;
      placesDetailsResponse = null;


  }

  void setplacesDetailsResponse(PlacesDetailsResponse placesDetailsResponse) {
    this.placesDetailsResponse = placesDetailsResponse;
  }

  void setcontroller(GoogleMapController controller) {
    this.controller = controller;
    notifyListeners();
  }

  void setformuleParticipant(
      Map<CardFormula, CardFormIntParticipant> formuleParticipant) {
    this.formuleParticipant = formuleParticipant;
    //notifyListeners();
  }

  void setFormule(List<Formule> formules) {
    this.formules = formules;
    notifyListeners();
  }

  void setshowSpinner() {
    showSpinner = !showSpinner;
    notifyListeners();
  }

  void setisNotDisplay() {
    isNotDisplay = !isNotDisplay;
    notifyListeners();
  }

  void setplaceDistance(String value) {
    placeDistance = value;
    notifyListeners();
  }

  void setindexParticipants(int value) {
    indexParticipants = value;
    notifyListeners();
  }

  void settotalCostMoins(double value) {
    totalCost -= value;
    notifyListeners();
  }

  void settotalCostPlus(double value) {
    totalCost += value;
    notifyListeners();
  }

  void setmarkers(Set<Marker> value) {
    markers = value;
    notifyListeners();
  }

  void setlatLngDepart(LatLng value) {
    latLngDepart = value;
    notifyListeners();
  }

  void setautoPlay(bool value) {
    autoPlay = value;
    notifyListeners();
  }

  void setpolylinePoints(PolylinePoints value) {
    polylinePoints = value;
    notifyListeners();
  }

  void setpolylineCoordinates(List<LatLng> value) {
    polylineCoordinates = value;
    notifyListeners();
  }

  void setpolylines(Set<Polyline> value) {
    polylines = value;
    notifyListeners();
  }

  void settotalDistance(double value) {
    totalDistance = value;
    notifyListeners();
  }

  void settotalDistancePlus(double value) {

    totalDistance += value;
    notifyListeners();
  }

  void setonGoingCar(String value) {
    switch (value) {
      case 'van':
        onGoingCar = 'Van';
        break;
      case 'classes':
        onGoingCar = 'Classe S';
        break;
      case 'suv':
        onGoingCar = value.toUpperCase();
        break;
      case 'classee':
        onGoingCar = 'Classe E';
        break;
    }

    notifyListeners();
  }

  void onChangeParticipant(Formule formule, GlobalKey<FormBuilderState> fbKey,
      int index, bool isToDestroy, bool isNewKey) {
    if (isToDestroy) {
      if (listFbKey[formule].isNotEmpty) {
        listFbKey[formule].removeAt(index);
      }
    } else if (!listFbKey.keys.contains(formule)) {
      listFbKey.addAll({
        formule: [fbKey]
      });
    } else if (isNewKey) {
      listFbKey[formule].insert(index, fbKey);
    } else {
      if (listFbKey[formule].isNotEmpty) {
        listFbKey[formule].removeAt(index);
      }
      listFbKey[formule].insert(index, fbKey);
    }
  }

  void setNb(Formule formule, int nb) {
    formuleParticipant[formuleParticipant.keys
            .firstWhere((element) => element.formule.id == formule.id)]
        .setNb(nb);

    notifyListeners();
  }

  void setNewStateFbKey() {}

  int getNb(String formuleId) {
    return formuleParticipant[formuleParticipant.keys
            .firstWhere((element) => element.formule.id == formuleId)]
        .nb;
  }

  void setCarParticipants(Formule formule, int index) {
    // print('setCarParticipants');
    // if (!formuleParticipant.containsKey(formule)) {
    //   print('azert');
    // }
    formuleParticipant[formuleParticipant.keys
            .firstWhere((element) => element.formule.id == formule.id)]
        .cardParticipant
        .add(CardParticipant(
          formule: formule,
          index: index,
          isToDestroy: false,
        ));

    //notifyListeners();
  }

  void removeCardParticipants(Formule formule, int index) {
    formuleParticipant[formuleParticipant.keys
            .firstWhere((element) => element.formule.id == formule.id)]
        .cardParticipant
        .removeAt(index);
  }

  List<CardParticipant> getCardParticipants(String formuleId) {
    return formuleParticipant[formuleParticipant?.keys?.firstWhere((element) {
          return element.formule.id == formuleId;
        })]
            .cardParticipant ??
        <CardParticipant>[];
  }

  List<CardParticipant> getAllCardParticipants() {
    final List<CardParticipant> myList = <CardParticipant>[];

    for (final List<CardParticipant> cardParticipant
        in formuleParticipant.values.map((e) => e.cardParticipant)) {
      myList.addAll(cardParticipant);
    }

    return myList;
  }

}
