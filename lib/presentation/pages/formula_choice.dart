import 'dart:async';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/billet.dart';
import 'package:van_events_project/domain/models/event.dart';
import 'package:van_events_project/domain/models/formule.dart';
import 'package:van_events_project/domain/models/my_transport.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_billet_repository.dart';
import 'package:van_events_project/domain/repositories/my_event_repository.dart';
import 'package:van_events_project/domain/repositories/my_transport_repository.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/presentation/widgets/card_formula.dart';
import 'package:van_events_project/presentation/widgets/card_participant.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/presentation/widgets/transports/selection_transport.dart';
import 'package:van_events_project/providers/formul_vtc.dart';
import 'package:van_events_project/providers/toggle_bool.dart';
import 'package:van_events_project/services/firestore_service.dart';

class FormulaChoice extends StatefulWidget {
  final List<Formule> formulas;
  final MyEvent myEvent;

  const FormulaChoice(this.formulas, this.myEvent);

  @override
  _FormulaChoiceState createState() => _FormulaChoiceState();
}

class _FormulaChoiceState extends State<FormulaChoice> {
  FormuleVTC formuleVTC;

  @override
  void initState() {
    formuleVTC = context.read(formuleVTCProvider);
    formuleVTC.initBillet(widget.myEvent);
    super.initState();
  }

  @override
  void dispose() {
    formuleVTC.myDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (formuleVTC.formuleParticipant.isEmpty) {
      formuleVTC.setformuleParticipant({
        for (var form in widget.formulas)
          CardFormula(form): CardFormIntParticipant(0, <CardParticipant>[])
      });
    }

    return ModelScreen(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
            title: const Text(
          "Formules",
        )),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          controller: formuleVTC.scrollController,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 15, 10, 80),
                child: Column(
                  children: [
                    Text('Billets',
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(fontSize: 40)),
                    ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        itemCount: widget.formulas.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return CardFormula(widget.formulas[index]);
                        }),
                    const Divider(),
                    const SizedBox(
                      height: 100,
                    ),
                    Text('Transport(Devis)',
                        style: Theme.of(context).textTheme.headline5),
                    SelectionTransport()
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomSheet: Consumer(builder: (context, watch, child) {
          return Container(
            clipBehavior: Clip.hardEdge,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            child: _buildTotalContent(context, formuleVTC),
          );
        }),
      ),
    );
  }

  Widget _buildTotalContent(BuildContext context, FormuleVTC readFormuleVtc) {
    return SizedBox(
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
              style: Theme.of(context).textTheme.headline4,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: !formuleVTC.showSpinner
                  ? FloatingActionButton.extended(
                      icon: Text(
                        'Continuer',
                        style: Theme.of(context).textTheme.button,
                      ),
                      label: Icon(
                        FontAwesomeIcons.creditCard,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      onPressed: () async {
                        // Show.showProgress(context);
                        readFormuleVtc.setshowSpinner();

                        await process(readFormuleVtc, context);
                        readFormuleVtc.setshowSpinner();
                      })
                  : CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.secondary)),
            ),
          ],
        );
      }),
    );
  }

  Future process(
    FormuleVTC readFormuleVtc,
    BuildContext context,
  ) async {
    if (readFormuleVtc.fbKeyTransport.currentState != null &&
        readFormuleVtc.fbKeyTransport.currentState.validate()) {
      await uploadTransport(context, readFormuleVtc).then((value) async {
        await Show.showDialogToDismiss(
            context,
            'Transport',
            'Votre demande de transport sera traitée dans les plus brèves délai',
            'Ok');
      });
    } else {
      if (readFormuleVtc.fbKeyTransport.currentState == null) {
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
        for (final form in value) {
          nb++;
          description = '''
          ${key.title} pour ${form.formBuilderKey.currentState.fields['prenom_nom'].value}\n''';
        }
      });

      final nbEvents = await context
          .read(myEventRepositoryProvider)
          .nbEvents(widget.myEvent.stripeAccount);
      final nbOrganizer =
          await context.read(myEventRepositoryProvider).nbOrganizer();

      await context
          .read(stripeRepositoryProvider)
          .paymentIntentBillet(
              readFormuleVtc.totalCost * 100,
              widget.myEvent.stripeAccount,
              description,
              nb,
              nbEvents,
              nbOrganizer,
              context)
          .then((value) async {
        Navigator.pop(context.read(boolToggleProvider).progressContext);

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
      if (readFormuleVtc.getAllCardParticipants().isEmpty) {
        await Show.showDialogToDismiss(context, 'Billets!',
            'Vous n\'avez fait de demande de billets', 'Ok');
      } else {
        await Show.showDialogToDismiss(
            context, 'Billets', 'Erreur de saisie', 'Ok');
      }
    }
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
            eventId: widget.myEvent.id))
        .then((value) => Show.showDialogToDismiss(
            context, '', 'Demande de transport effectuée', 'Ok'))
        .catchError((e) {
      debugPrint(e.toString());
      Show.showDialogToDismiss(context, 'Erreur', 'Erreur $e', 'Ok');
    });
  }

  Future paymentValider(
      Map paymentIntentX, FormuleVTC formuleVTC, BuildContext context) async {
    final Map<String, List<dynamic>> participant = {};
    formuleVTC.listFbKey.forEach((key, value) {
      for (final form in value) {
        participant.addAll({
          "${form.formBuilderKey.currentState.fields['prenom_nom'].value}": [
            key.title,
            false
          ]
        });
      }
    });

    final organizateur = await context
        .read(myUserRepository)
        .getMyUserFromStripeAccount(widget.myEvent.stripeAccount);

    final Map participantsId = {};
    participantsId.addAll({context.read(myUserProvider).id: true});

    for (int i = 0; i < formuleVTC.listFbKey.values.length; i++) {
      final myList = formuleVTC.listFbKey.values.elementAt(i);
      for (int j = 0; j < myList.length; j++) {
        if (myList.elementAt(j).isUserBuyingFor.isNotEmpty) {
          participantsId.addAll({myList.elementAt(j).isUserBuyingFor: true});
        }
      }
    }

    final Billet billet = Billet(
      id: FirestoreService.instance.getDocId(path: 'billets'),
      status: BilletStatus.upComing,
      paymentIntentId: paymentIntentX['id'] as String,
      participantsId: participantsId,
      eventId: widget.myEvent.id,
      imageUrl: widget.myEvent.imageFlyerUrl,
      participants: participant,
      organisateurId: organizateur.first.id,
      amount: paymentIntentX['amount'] as int,
      dateTime: widget.myEvent.dateDebut,
    );

    await context.read(myBilletRepositoryProvider).addNewBillet(billet);

    //payment was confirmed by the server without need for futher authentification

    double amount = double.parse(paymentIntentX['amount'].toString());

    amount = amount / 100;

    await Show.showDialogToDismiss(
        context,
        'Payement validé!',
        '$amount € montant payé avec succès\nUn nouveau billet est disponible',
        'Ok');

    final rep = await Show.showAreYouSureModel(
        context: context,
        title: 'Calendrier',
        content: 'Voulez-vous le rajouter au calendrier?');

    if (rep != null && rep) {
      addEventsToCalendar();
    }
  }

  bool allParticipantIsOk(FormuleVTC formuleVTC) {
    bool b = true;
    if (formuleVTC.getAllCardParticipants().isEmpty) {
      b = false;
    }

    for (int i = 0; i < formuleVTC.listFbKey.length; i++) {
      final Formule formule = formuleVTC.listFbKey.keys.elementAt(i);
      for (int j = 0; j < formuleVTC.listFbKey[formule].length; j++) {
        if (!formuleVTC.listFbKey[formule][j].formBuilderKey.currentState
            .validate()) {
          b = false;
          break;
        }
      }
    }
    return b;
  }

  void addEventsToCalendar() {
    final Event myEvent = Event(
      title: widget.myEvent.titre,
      description: widget.myEvent.description,
      location: [...widget.myEvent.adresseRue, ...widget.myEvent.adresseZone]
          .join(' '),
      startDate: widget.myEvent.dateDebut,
      endDate: widget.myEvent.dateFin,
    );

    Add2Calendar.addEvent2Cal(myEvent);
  }
}

class CardFormIntParticipant {
  int nb;
  final List<CardParticipant> cardParticipant;

  CardFormIntParticipant(this.nb, this.cardParticipant);

  void setNb(int nb) {
    this.nb = nb;
  }
}

class MyParticipant {
  GlobalKey<FormBuilderState> formBuilderKey;
  String isUserBuyingFor;

  MyParticipant({this.formBuilderKey, this.isUserBuyingFor});
}
