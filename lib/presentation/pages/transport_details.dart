import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:van_events_project/domain/models/my_transport.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_transport_repository.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/toggle_bool_chat_room.dart';

class TransportDetail extends HookWidget {
  final MyTransport _myTransport;
  final String _addressArriver;

  final prixController = TextEditingController();
  final sfkey = GlobalKey<ScaffoldState>();

  TransportDetail(this._myTransport, this._addressArriver);

  @override
  Widget build(BuildContext context) {
    final myTransRepo = useProvider(myTransportRepositoryProvider);
    final myUser = useProvider(myUserProvider);
    final boolToggle = useProvider(boolToggleProvider);

    return ModelScreen(
      child: Scaffold(
        key: sfkey,
        appBar: AppBar(
          title: Text('Détails'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StreamBuilder<MyTransport>(
                    stream: myTransRepo.streamTransport(_myTransport.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary)),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return Center(
                          child: Text(
                            'Erreur de connexion',
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        );
                      }

                      final transport = snapshot.data.statusTransport;

                      return Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Status : ',
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          Text(
                            transport.toString().substring(
                                transport.toString().indexOf('.') + 1),
                            style: Theme.of(context).textTheme.headline5,
                          )
                        ],
                      );
                    }),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Pour le :',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      DateFormat('dd/MM/yyy à HH:mm')
                          .format(_myTransport.dateTime),
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Voiture:',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Column(
                      children: [
                        Image(
                          image: AssetImage(getPath(_myTransport.car)),
                          height: 50,
                        ),
                        Text(
                          _myTransport.car,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Nombre de personnes : ',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      _myTransport.nbPersonne,
                      style: Theme.of(context).textTheme.headline5,
                    )
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Prix : ',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    myUser.typeDeCompte == TypeOfAccount.userNormal?Text(
                      getPrix(_myTransport.amount),
                      style: Theme.of(context).textTheme.headline5,
                    ):myUser.typeDeCompte == TypeOfAccount.owner && _myTransport.statusTransport == StatusTransport.submitted?
                    FormBuilderTextField(
                      controller: prixController,
                      keyboardType: TextInputType.number,
                      name: 'prix',
                    ):Text(
                      getPrix(_myTransport.amount),
                      style: Theme.of(context).textTheme.headline5,
                    )
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Départ:',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Column(
                      children: [
                        Text(
                          _myTransport.adresseRue.join(" "),
                          style: Theme.of(context).textTheme.headline5,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          _myTransport.adresseZone.join(" "),
                          style: Theme.of(context).textTheme.headline5,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Distance:',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      _myTransport.distance.toStringAsFixed(2) + ' km',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Arrivée:',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      _addressArriver,
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Visibility(
                  visible: myUser.typeDeCompte == TypeOfAccount.owner && _myTransport.statusTransport == StatusTransport.submitted,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                          child: Text('Accepter'),
                          onPressed: () async {
                            if(prixController.value.text.trim().isNotEmpty){
                              await myTransRepo.setTransportAccepted(_myTransport.id,prixController.value.text.trim());
                              Show.showSnackBar('Transport accepté', sfkey);
                            }else{
                              Show.showSnackBar('Veuillez saisir un prix', sfkey);
                            }
                          }),
                      RaisedButton(child: Text('Refuser'), onPressed: () {
                        myTransRepo.setTransportRefuserParVtc(_myTransport.id);

                      }),
                    ],
                  ),
                ),
                Visibility(
                    visible: myUser.typeDeCompte == TypeOfAccount.userNormal&&
                    _myTransport.statusTransport == StatusTransport.holdOnCard,
                    child: Consumer(
                      builder: (context,watch,child){

                        return !watch(boolToggleProvider).showSpinner
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
                              context.read(boolToggleProvider).setShowSpinner();

                              await context.read(stripeRepositoryProvider)
                                  .paymentIntentVtc(_myTransport.amount,'id:'+_myTransport.id+' '+_myTransport.adresseRue.join(' ')+' '+_myTransport.adresseZone.join(' '))
                                  .then((value) async {
                                if (value is String) {
                                  Show.showDialogToDismiss(context, 'Oups!',
                                      'Payement refusé\nEssayer avec une autre carte', 'Ok');

                                  return;
                                }
                                if (value is Map) {

                                  //await db.setTransportPaid(value['id']);
                                }
                              });
                              boolToggle.setShowSpinner();
                            })
                            : CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary));
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
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

  String getPrix(double amount) {
    if (amount == null) return 'non définie';

    return '${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)} €';
  }
}
