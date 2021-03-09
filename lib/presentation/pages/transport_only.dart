import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/domain/models/my_transport.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_transport_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/presentation/widgets/transports/selection_transport.dart';
import 'package:van_events_project/providers/formul_vtc.dart';
import 'package:google_maps_webservice/places.dart';

class TransportOnly extends StatefulWidget {
  @override
  _TransportOnlyState createState() => _TransportOnlyState();
}

class _TransportOnlyState extends State<TransportOnly> {
  FormuleVTC formuleVTC;

  @override
  void initState() {
    formuleVTC = context.read(formuleVTCProvider);
    formuleVTC.initSelectionTransport();
    super.initState();
  }

  @override
  void dispose() {
    formuleVTC.myDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModelScreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Demande de devis'),
        ),
        body: SingleChildScrollView(
          controller: formuleVTC.scrollController,
          child: Column(
            children: [
              Text(
                'Choix de l\'Event',
                style: Theme.of(context).textTheme.overline,
              ),
              Consumer(builder: (context, watch, child) {
                final watchFormule = watch(formuleVTCProvider);
                return watchFormule.myEvent != null
                    ? ListTile(
                        title: Text(watchFormule.myEvent.titre,
                            style: Theme.of(context).textTheme.bodyText1),
                        leading: CachedNetworkImage(
                          imageUrl: watchFormule.myEvent.imageFlyerUrl,
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            backgroundImage: imageProvider,
                            radius: 25,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Theme.of(context).colorScheme.onPrimary,
                            highlightColor:
                                Theme.of(context).colorScheme.primary,
                            child: const CircleAvatar(
                              radius: 25,
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        onTap: () {
                          ExtendedNavigator.of(context).push(
                              Routes.searchUserEvent,
                              arguments: SearchUserEventArguments(
                                  fromTransport: true,
                                  fromBilletForm: false,
                                  isEvent: true));
                        },
                      )
                    : RaisedButton(
                        onPressed: () {
                          ExtendedNavigator.of(context).push(
                              Routes.searchUserEvent,
                              arguments: SearchUserEventArguments(
                                  fromTransport: true,
                                  fromBilletForm: false,
                                  isEvent: true));
                        },
                        child: const Text('Veuillez choisir un Events'),
                      );
              }),
              SelectionTransport(),
              RaisedButton(
                onPressed: () async {
                  if (formuleVTC.fbKeyTransport.currentState != null &&
                      formuleVTC.fbKeyTransport.currentState.validate()) {
                    await uploadTransport(context, formuleVTC)
                        .then((value) async {
                      await Show.showDialogToDismiss(
                          context,
                          'Transport',
                          'Votre demande de transport sera traitée dans les plus brèves délai',
                          'Ok');
                    });
                  } else {
                    if (formuleVTC.fbKeyTransport.currentState == null) {
                      await Show.showDialogToDismiss(context, 'Transport',
                          'Vous n\'avez fait de demande de transport', 'Ok');
                    } else {
                      await Show.showDialogToDismiss(
                          context, 'Transport', 'Erreur de saisie', 'Ok');
                    }
                  }
                },
                child: const Text('Valider'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future uploadTransport(BuildContext context, FormuleVTC formuleVTC) async {
    final List<AddressComponent> adresse = <AddressComponent>[];

    final List<AddressComponent> rue = <AddressComponent>[];

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

    final String docId =
        FirebaseFirestore.instance.collection('transports').doc().id;

    await context
        .read(myTransportRepositoryProvider)
        .uploadTransport(MyTransport(
            id: docId,
            statusTransport: StatusTransport.submitted,
            car: formuleVTC.onGoingCar,
            position: GeoPoint(formuleVTC.latLngDepart.latitude,
                formuleVTC.latLngDepart.longitude),
            nbPersonne: formuleVTC.fbKeyTransport.currentState
                .fields['Nombre de personne'].value as String,
            distance: formuleVTC.totalDistance,
            dateTime: formuleVTC.fbKeyTransport.currentState
                .fields['Date et heure'].value as DateTime,
            adresseRue: List<String>.generate(
                rue.length, (index) => rue[index].longName),
            adresseZone: List<String>.generate(
                adresse.length, (index) => adresse[index].longName),
            userId: context.read(myUserProvider).id,
            eventId: formuleVTC.myEvent.id))
        .then((value) => Show.showDialogToDismiss(
            context, '', 'Demande de transport effectuée', 'Ok'))
        .catchError((e) {
      debugPrint(e.toString());
      Show.showDialogToDismiss(context, 'Erreur', 'Erreur $e', 'Ok');
    });
  }
}
