import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:van_events_project/domain/models/event.dart';
import 'package:van_events_project/domain/models/formule.dart';
import 'package:van_events_project/domain/models/indicator.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_event_repository.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/presentation/pages/upload_event.dart';
import 'package:van_events_project/presentation/widgets/show.dart';

final uploadEventProvider =
    ChangeNotifierProvider.autoDispose<UploadEventChangeNotifier>((ref) {
  return UploadEventChangeNotifier();
});

class UploadEventChangeNotifier extends ChangeNotifier {
  File flyer;
  double eventCost;
  double eventCostDiscounted;
  List<Asset> images;
  int nbPhotos;
  String promotionCodeId;
  bool isUpdating;
  List<Formule> formulas;
  PlacesDetailsResponse placesDetailsResponse;
  List<FocusScopeNode> nodes;
  DateTime dateDebut,
      dateFin,
      debutAffiche,
      finAffiche,
      finalDebutAffiche,
      finalFinAffiche;
  List<CircularSegmentEntry> circularSegmentEntry;
  List<CircularStackEntry> data;
  List<Indicator> listIndicator;
  List<Widget> formulesWidgets;
  List<Prediction> suggestions;
  List<int> listColors;
  bool showSpinner;
  bool showSpinnerAppliquer;
  bool hasGetFormulas;
  bool hasGetDates;
  bool initializationDone;
  int nbTotal;
  int daysAffiche;
  int daysOld;
  int percentOff;
  int amountOff;
  bool isAffiche;
  bool isJusquauJourJ;
  Map<String, bool> genre;
  Map<String, bool> type;
  GlobalKey<AnimatedCircularChartState> chartKey;
  GlobalKey<FormBuilderState> fbKey;
  TextEditingController description;
  TextEditingController title;
  TextEditingController rue;
  TextEditingController codePostal;
  TextEditingController ville;
  TextEditingController coords;
  TextEditingController codePromo;
  TextEditingController dateDebutController;
  TextEditingController dateFinController;
  TextEditingController debutAfficheController;
  TextEditingController finAfficheController;
  ScrollController scrollController;
  MyEvent myEvent;
  GlobalKey<ScaffoldState> myScaffoldKey;
  String myStripeAccount;

  void initState(BuildContext context, MyEvent myEvent) {
    initializationDone = false;
    isUpdating = myEvent != null;
    this.myEvent = myEvent;
    scrollController = ScrollController();
    dateDebutController = TextEditingController();
    dateFinController = TextEditingController();
    description = TextEditingController();
    title = TextEditingController();
    rue = TextEditingController();
    codePostal = TextEditingController();
    ville = TextEditingController();
    coords = TextEditingController();
    codePromo = TextEditingController();
    dateDebut = DateTime.now();
    dateFin = DateTime.now();
    debutAffiche = DateTime.now();
    finAffiche = DateTime.now();
    chartKey = GlobalKey<AnimatedCircularChartState>();
    nbTotal = 0;
    myScaffoldKey = GlobalKey<ScaffoldState>();
    fbKey = GlobalKey<FormBuilderState>();
    suggestions = <Prediction>[];
    isAffiche = false;
    eventCostDiscounted = null;
    eventCost = 0;
    isJusquauJourJ = true;
    nbPhotos = null;
    data = <CircularStackEntry>[];
    listIndicator = <Indicator>[];
    formulesWidgets = <Widget>[];
    listColors =
        List<int>.generate(Colors.primaries.length, (int index) => index);
    listColors.shuffle();
    nodes = List<FocusScopeNode>.generate(9, (index) => FocusScopeNode());
    flyer = null;
    images = <Asset>[];
    showSpinnerAppliquer = false;
    showSpinner = false;
    myStripeAccount = context.read(myUserProvider).stripeAccount;

    if (isUpdating) {
      initGenre(genres: myEvent.genres);
      initType(types: myEvent.types);
      daysOld =
          myEvent.dateFinAffiche.difference(myEvent.dateDebutAffiche).inDays;
      initFields();

      context
          .read(myEventRepositoryProvider)
          .getFormulasList(myEvent.id)
          .then((form) {
        formulas = form;
        for (final Formule formule in form) {
          addFormule(formule: formule);
        }
      });
    }

    if (!isUpdating) {
      initGenre();
      initType();
      addFormule();
      dateAffiche();
      updateDaysAffiche();
    }
    initializationDone = true;
  }

  Future getImageCamera(String type) async {
    final String str =
        (await ImagePicker().getImage(source: ImageSource.camera))?.path;
    if (str == null) {
      return;
    }
    flyer = File(str);
    notifyListeners();
    return;
  }

  Future getImageGallery(String type) async {
    final String str =
        (await ImagePicker().getImage(source: ImageSource.gallery))?.path;
    if (str == null) {
      return;
    }
    flyer = File(str);
    notifyListeners();
    return;
  }

  void setIsAffiche() {
    isAffiche = !isAffiche;

    dateAffiche();
    updateDaysAffiche();
    notifyListeners();
  }

  void setJusquauJourJ(bool val) {
    isJusquauJourJ = !isJusquauJourJ;
    if (isJusquauJourJ) {
      debutAffiche = null;
      finAffiche = null;
    } else {}
    dateAffiche();
    updateDaysAffiche();
    notifyListeners();
  }

  void initGenre({List genres}) {
    genre = genres == null
        ? {
            'Classique': false,
            'Dancehall/Reggae/Soca': false,
            'Électro': false,
            'Jazz': false,
            'Pop': false,
            'RAP': false,
            'RnB': false,
            'Rock': false,
            'Variété française': false,
            'Zouk/Kompa': false,
          }
        : {
            'Classique': genres.contains('Classique'),
            'Dancehall/Reggae/Soca': genres.contains('Dancehall/Reggae/Soca'),
            'Électro': genres.contains('Électro'),
            'Jazz': genres.contains('Jazz'),
            'Pop': genres.contains('Pop'),
            'RAP': genres.contains('RAP'),
            'RnB': genres.contains('RnB'),
            'Rock': genres.contains('Rock'),
            'Variété française': genres.contains('Variété française'),
            'Zouk/Kompa': genres.contains('Zouk/Kompa'),
          };
  }

  void initType({List types}) {
    type = types == null
        ? {
            'Concert': false,
            'Dîner': false,
            'Spectacle': false,
            'Foire': false,
            'Salon': false,
            'Soirée clubbing': false,
            'Festival': false,
            'Kids': false,
          }
        : {
            'Concert': types.contains('Concert'),
            'Dîner': types.contains('Dîner'),
            'Spectacle': types.contains('Spectacle'),
            'Foire': types.contains('Foire'),
            'Salon': types.contains('Salon'),
            'Soirée clubbing': types.contains('Soirée clubbing'),
            'Festival': types.contains('Festival'),
            'Kids': types.contains('Kids'),
          };
  }

  void setGenre(String key) {
    genre[key] = !genre[key];
    notifyListeners();
  }

  void setType(String key) {
    type[key] = !type[key];
    notifyListeners();
  }

  void setDateDebut(DateTime dateDebut) {
    this.dateDebut = dateDebut;
    notifyListeners();
    dateAffiche();
    updateDaysAffiche();
    notifyListeners();
  }

  void setDateFin(DateTime dateFin) {
    this.dateFin = dateFin;
    dateAffiche();
    updateDaysAffiche();
    notifyListeners();
  }

  void setDebutAffiche(DateTime debutAffiche) {
    this.debutAffiche = debutAffiche;
    dateAffiche();
    updateDaysAffiche();
    notifyListeners();
  }

  void setFinAffiche(DateTime finAffiche) {
    this.finAffiche = finAffiche;
    dateAffiche();
    updateDaysAffiche();
    notifyListeners();
  }

  void addFormule({Formule formule}) {
    List<CircularSegmentEntry> circularSegmentEntry;

    if (data.isEmpty) {
      circularSegmentEntry = <CircularSegmentEntry>[];
    } else {
      circularSegmentEntry = data[0].entries;
    }
    double nb = 1;
    if (formule != null) {
      nb = formule.nombreDePersonne.toDouble();
    }

    circularSegmentEntry.add(CircularSegmentEntry(
        nb, Colors.primaries[listColors[circularSegmentEntry.length]]));
    data = <CircularStackEntry>[
      CircularStackEntry(
        circularSegmentEntry,
        //rankKey: 'Les formules',
      ),
    ];
    if (chartKey.currentState != null) {
      chartKey.currentState.updateData(data);
    }

    formulesWidgets.add(CardFormula(
      circularSegmentEntry.length - 1,
      (value) {
        //nombe de personne
        final String str = value.toString();
        final int index = int.parse(str.substring(0, str.indexOf('/')));
        final String val = str.substring(str.indexOf('/') + 1);

        if (val.isNotEmpty) {
          final double nb = double.parse(val);
          data[0].entries.removeAt(index);
          final List<CircularSegmentEntry> circularSegmentEntry =
              data[0].entries;
          data[0].entries.insert(
              index,
              CircularSegmentEntry(nb, Colors.primaries[listColors[index]],
                  rankKey: 'f${circularSegmentEntry.length}'));
          data = <CircularStackEntry>[
            CircularStackEntry(
              circularSegmentEntry,
              rankKey: 'Les formules',
            ),
          ];
          // if (chartKey.currentState != null && isUpdating && initializationDone) {
          //   chartKey.currentState.updateData(data);
          // }
          if (chartKey.currentState != null) {
            chartKey.currentState.updateData(data);
          }

          nbTotal = 0;

          for(final segment in data[0].entries){
            nbTotal += segment.value.toInt();
          }

        }
        notifyListeners();
      },
      formule: formule,
    ));
    formulesWidgets.add(const Divider());
    listIndicator.add(
      Indicator(
        color: Colors.primaries[listColors[circularSegmentEntry.length - 1]],
        text: 'F${circularSegmentEntry.length}',
        isSquare: false,
        textColor: Colors.white,
      ),
    );
    if (isUpdating && initializationDone) {
      notifyListeners();
    } else if (listIndicator.length > 1 && !isUpdating) {
      notifyListeners();
    }
  }

  void deleteFormule() {
    data[0].entries.removeLast();
    if (chartKey.currentState != null) {
      chartKey.currentState.updateData(data);
    }
    formulesWidgets.removeLast();
    formulesWidgets.removeLast();
    listIndicator.removeLast();
    nbTotal = 0;
    for(final segment in data[0].entries){
      nbTotal += segment.value.toInt();
    }
    notifyListeners();
  }

  void setPlace(PlacesDetailsResponse place) {
    placesDetailsResponse = place;
    rue.text =
        "${placesDetailsResponse.result?.addressComponents?.firstWhere((element) => element.types.first == 'street_number')?.longName ?? ''} ${placesDetailsResponse.result?.addressComponents?.firstWhere((element) => element.types.first == 'route')?.longName ?? ''}";

    codePostal.text = placesDetailsResponse.result?.addressComponents
            ?.firstWhere((element) => element.types.first == 'postal_code')
            ?.longName ??
        '';
    ville.text = placesDetailsResponse.result?.addressComponents
            ?.firstWhere((element) => element.types.first == 'locality')
            ?.longName ??
        '';

    coords.text =
        "${placesDetailsResponse.result?.geometry?.location?.lat?.toString() ?? ''},${placesDetailsResponse.result?.geometry?.location?.lng?.toString() ?? ''}";
    notifyListeners();
  }

  void setEventCostDiscounted(double cost) {
    eventCostDiscounted = cost;
    notifyListeners();
  }

  void dateAffiche() {
    if (isAffiche && isJusquauJourJ) {
      finalDebutAffiche = DateTime.now();
      finalFinAffiche = dateFin;
    } else if (isAffiche && !isJusquauJourJ) {
      finalDebutAffiche = debutAffiche;
      finalFinAffiche = finAffiche;
    } else if (!isAffiche) {
      finalDebutAffiche = null;
      finalFinAffiche = null;
    }
  }

  void updateDaysAffiche() {
    if (finalDebutAffiche == null || finalFinAffiche == null) {
      daysAffiche = 0;
    } else {
      if (isUpdating) {
        daysOld = finalFinAffiche.difference(finalDebutAffiche).inDays;
      }
      daysAffiche = finalFinAffiche.difference(finalDebutAffiche).inDays;
    }
    eventCostChanges();
    //context.watch<BoolToggle>().eventCostChangeWithoutNotif(images.length,daysAffiche);
  }

  Future findCodePromo(BuildContext context) async {
    showSpinnerAppliquer = true;
    notifyListeners();

    await context
        .read(stripeRepositoryProvider)
        .retrievePromotionCode(codePromo.text.trim())
        .then((rep) {
      if (rep?.data != null) {
        final Map promotionCode = rep.data['data'][0] as Map;
        //check restriction
        final int minimumAmount =
            promotionCode['restrictions']['minimum_amount'] as int;
        if (minimumAmount != null) {
          final double min = minimumAmount / 100;
          if (eventCost >= min) {
            applyPercentOff(promotionCode, context);
          } else {
            setEventCostDiscounted(null);
            promotionCodeId = null;
            Show.showDialogToDismiss(
                context, 'OOps!', 'Montant minimum : $min €', 'Ok');
          }
        } else {
          applyPercentOff(promotionCode, context);
        }
      } else {
        setEventCostDiscounted(null);
        promotionCodeId = null;
        Show.showDialogToDismiss(context, 'OOps!', 'Code invalide', 'Ok');
      }
    });
    showSpinnerAppliquer = false;
    notifyListeners();
  }

  void applyPercentOff(Map promotionCode, BuildContext context) {
    if (promotionCodeId != promotionCode['id']) {
      promotionCodeId = promotionCode['id'] as String;
      percentOff = promotionCode['coupon']['percent_off'] as int;
      amountOff = promotionCode['coupon']['amount_off'] as int;

      if (percentOff != null) {
        setEventCostDiscounted(eventCost - eventCost * (percentOff / 100));
      } else if (amountOff != null) {
        setEventCostDiscounted(eventCost - amountOff);
      }
      Show.showDialogToDismiss(context, 'Yes!', 'Code bon', 'Ok');
    } else {
      Show.showDialogToDismiss(context, 'OOps!', 'Déjà utilisé', 'Ok');
    }
  }

  Future<void> submit(BuildContext context) async {
    showSpinner = true;
    notifyListeners();

    //Flyer obligatoire
    if (flyer == null && myEvent == null) {
      Show.showSnackBar('Flyer obligatoire', myScaffoldKey);
      //Show.showDialogToDismiss(context, 'OOps!', 'Flyer obligatoire', 'Ok');
      showSpinner = false;
      notifyListeners();
      return;
    }
    if (!genre.values.contains(true)) {
      Show.showDialogToDismiss(context, 'OOps!', 'Genre obligatoire', 'Ok');

      showSpinner = false;
      notifyListeners();
      return;
    }
    if (!type.values.contains(true)) {
      Show.showDialogToDismiss(context, 'OOps!', 'Type obligatoire', 'Ok');

      showSpinner = false;
      notifyListeners();
      return;
    }
    //au moins 3 jours de plus pris pour pouvoir faire 0.5€
    // if (isUpdating &&
    //     daysAffiche != null &&
    //     finAffiche != myEvent.dateFinAffiche &&
    //     daysAffiche < daysOld + 3) {
    //   Show.showDialogToDismiss(
    //       context, 'OOps!', 'Affiche doit être supérieur à 3 de plus', 'Ok');
    //   showSpinner = false;
    //   notifyListeners();
    //   return;
    // }
    fbKey.currentState.save();

    if (fbKey.currentState.validate()) {
      final String coordsString =
          fbKey.currentState.fields['Coordonnée'].value as String;
      final String latitude =
          coordsString.substring(0, coordsString.indexOf(',')).trim();
      final String longitude =
          coordsString.substring(coordsString.indexOf(',') + 1).trim();

      final Coords coords =
          Coords(double.parse(latitude), double.parse(longitude));

      final List<Formule> formules = <Formule>[];

      for(final f in formulesWidgets){
        if (f is CardFormula) {
          if (f.fbKey.currentState.validate()) {
            formules.add(Formule(
                title: f.fbKey.currentState.fields['Nom'].value as String,
                prix: double.parse(
                    f.fbKey.currentState.fields['Prix'].value.toString()),
                nombreDePersonne: int.parse(f.fbKey.currentState
                    .fields['Nombre de personne par formule'].value as String),
                id: f.numero.toString()));
          } else {
            Show.showSnackBar(
                'Corriger la formule n°${f.numero + 1}', myScaffoldKey);
            return;
          }
        }
      }

      if (formules.length == formulesWidgets.length / 2) {
        if ((eventCostDiscounted ?? eventCost) < 0.5) {
          await upload(formules, coords, context);
          return;
        }

        await context
            .read(stripeRepositoryProvider)
            .paymentIntentUploadEvents(
                eventCostDiscounted ?? eventCost,
                title.text,
                eventCostDiscounted != null ? promotionCodeId : null)
            .then((value) async {
          if (value is String) {
            Show.showSnackBar(value, myScaffoldKey);

            showSpinner = false;
            notifyListeners();
            return;
          }

          if (value is Map) {
            Show.showDialogToDismiss(context, 'Yes!', 'Paiement accepté', 'Ok');
            Show.showSnackBar('Chargement de l\'événement...', myScaffoldKey);

            await upload(formules, coords, context);
            showSpinner = false;
            notifyListeners();
            return;
          }
        });
      }

      //Navigator.pop(context);
    } else {
      //print(_fbKey.currentState.value);
      Show.showSnackBar('Formulaire non valide', myScaffoldKey);
    }

    showSpinner = false;
    notifyListeners();
  }

  Future upload(
      List<Formule> formules, Coords coords, BuildContext context) async {
    Show.showLoading(context);
    await context
        .read(myEventRepositoryProvider)
        .uploadEvent(
          oldId: myEvent?.id,
          oldIdChatRoom: myEvent?.chatId,
          myOldEvent: myEvent,
          type: type,
          genre: genre,
          titre: title.text,
          formules: formules,
          adresse: placesDetailsResponse?.result?.addressComponents,
          coords: coords,
          dateDebut: dateDebut,
          dateFin: dateFin,
          dateDebutAffiche: isAffiche ? finalDebutAffiche : null,
          dateFinAffiche: isAffiche ? finalFinAffiche : null,
          description: description.text,
          flyer: flyer,
          images: images,
          stripeAccount: myEvent?.stripeAccount ?? myStripeAccount,
        )
        .then((rep) {
          ExtendedNavigator.root.pop();
      showSpinner = false;
      Show.showSnackBar('Event ajouter', myScaffoldKey);
      notifyListeners();
    }).catchError((e) {
      ExtendedNavigator.root.pop();
      debugPrint(e.toString());
      Show.showSnackBar('Impossible d\'ajouter l\'Event', myScaffoldKey);
      showSpinner = false;
      notifyListeners();
    });
  }

  void setSuggestions(List<Prediction> suggestions) {
    this.suggestions = suggestions;
    notifyListeners();
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 20,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: const CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: const MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    images.clear();

    images.addAll(resultList);
    eventCostChanges();
    notifyListeners();
  }

  void eventCostChanges() {
    if (isUpdating &&
            myEvent != null &&
            myEvent.imagePhotos.length <= images.length ||
        isUpdating && daysOld != null && daysAffiche >= daysOld) {
      eventCostChangeWithoutNotif(
          images.length - myEvent.imagePhotos.length >= 0
              ? images.length - myEvent.imagePhotos.length
              : 0,
          daysAffiche - daysOld >= 0 ? daysAffiche - daysOld : 0);
    } else if (!isUpdating) {
      eventCostChangeWithoutNotif(images.length, daysAffiche);
    }
    //notifyListeners();
  }

  void eventCostChangeWithoutNotif(int nbPhotos, int day) {
    this.nbPhotos = nbPhotos;
    if (nbPhotos >= 1) {
      nbPhotos--;
    }

    eventCost = ((nbPhotos ?? 0) * 0.5 + (day ?? 0) * 0.2).toDouble();
  }

  void clearPromoCode() {
    codePromo.clear();
    amountOff = null;
    percentOff = null;
    promotionCodeId = null;
  }

  void setFlyer(File file) {
    flyer = file;
    notifyListeners();
  }

  void initFields() {
    dateDebutController.text = myEvent.dateDebut.toString();
    dateFinController.text = myEvent.dateFin.toString();
    description.text = myEvent.description;
    title.text = myEvent.titre;
    rue.text = myEvent.adresseRue.join(' ');
    codePostal.text = myEvent.adresseZone[3]?.toString() ?? '';
    ville.text = myEvent.adresseZone[0]?.toString() ?? '';
    coords.text = '${myEvent.position.latitude},${myEvent.position.longitude}';
  }
}
