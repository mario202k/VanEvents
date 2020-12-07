import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hooks_riverpod/all.dart';
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

  init() {
    showSpinner = false;
    isNotDisplay = true;
    formuleParticipant = Map<CardFormula, CardFormIntParticipant>();
    listFbKey = Map<Formule, List<GlobalKey<FormBuilderState>>>();

    formules = List<Formule>();
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
    print('disposeChangeNotifier!!');
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

  setplacesDetailsResponse(PlacesDetailsResponse placesDetailsResponse) {
    this.placesDetailsResponse = placesDetailsResponse;
  }

  setcontroller(GoogleMapController controller) {
    this.controller = controller;
    notifyListeners();
  }

  setformuleParticipant(
      Map<CardFormula, CardFormIntParticipant> formuleParticipant) {
    this.formuleParticipant = formuleParticipant;
    //notifyListeners();
  }

  setFormule(List<Formule> formules) {
    this.formules = formules;
    notifyListeners();
  }

  setshowSpinner() {
    showSpinner = !showSpinner;
    notifyListeners();
  }

  setisNotDisplay() {
    isNotDisplay = !isNotDisplay;
    notifyListeners();
  }

  setplaceDistance(String value) {
    placeDistance = value;
    notifyListeners();
  }

  setindexParticipants(int value) {
    indexParticipants = value;
    notifyListeners();
  }

  settotalCostMoins(double value) {
    totalCost -= value;
    notifyListeners();
  }

  settotalCostPlus(double value) {
    totalCost += value;
    notifyListeners();
  }

  setmarkers(Set<Marker> value) {
    markers = value;
    notifyListeners();
  }

  setlatLngDepart(LatLng value) {
    latLngDepart = value;
    notifyListeners();
  }

  setautoPlay(bool value) {
    autoPlay = value;
    notifyListeners();
  }

  setpolylinePoints(PolylinePoints value) {
    polylinePoints = value;
    notifyListeners();
  }

  setpolylineCoordinates(List<LatLng> value) {
    polylineCoordinates = value;
    notifyListeners();
  }

  setpolylines(Set<Polyline> value) {
    polylines = value;
    notifyListeners();
  }

  settotalDistance(double value) {
    totalDistance = value;
    notifyListeners();
  }

  settotalDistancePlus(double value) {
    totalDistance += value;
    notifyListeners();
  }

  setonGoingCar(String value) {
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
    print('setCarParticipants');
    if (!formuleParticipant.containsKey(formule)) {
      print('azert');
    }
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
    print('removeCardParticipants');
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
        List<CardParticipant>();
  }

  List<CardParticipant> getAllCardParticipants() {
    List<CardParticipant> myList = List<CardParticipant>();

    for (List<CardParticipant> cardParticipant
        in formuleParticipant.values.map((e) => e.cardParticipant)) {
      myList.addAll(cardParticipant);
    }

    return myList;
  }
}
