import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:van_events_project/domain/models/my_transport.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_transport_repository.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/presentation/widgets/transports/customer_handle.dart';


class TransportDetailScreen extends HookWidget {
  final MyTransport _myTransport;
  final String _addressArriver;

  final prixController = TextEditingController();
  final sfkey = GlobalKey<ScaffoldState>();

  TransportDetailScreen(this._myTransport, this._addressArriver);

  @override
  Widget build(BuildContext context) {
    final myTransRepo = useProvider(myTransportRepositoryProvider);
    final myUser = useProvider(myUserProvider);

    return ModelScreen(
      child: Scaffold(
        key: sfkey,
        appBar: AppBar(
          title: Text('Détails'),
        ),
        body: ModelBody(
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
                          style: Theme.of(context).textTheme.bodyText1,
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
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        Text(
                          transport.toString().substring(
                              transport.toString().indexOf('.') + 1),
                          style: Theme.of(context).textTheme.bodyText1,
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
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    DateFormat('dd/MM/yyy à HH:mm')
                        .format(_myTransport.dateTime),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Voiture:',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Column(
                    children: [
                      Image(
                        image: AssetImage(getPath(_myTransport.car)),
                        height: 50,
                      ),
                      Text(
                        _myTransport.car,
                        style: Theme.of(context).textTheme.bodyText1,
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
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    _myTransport.nbPersonne,
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Prix : ',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  myUser.typeDeCompte == TypeOfAccount.userNormal?Text(
                    getPrix(_myTransport.amount),
                    style: Theme.of(context).textTheme.bodyText1,
                  ):Text(
                    getPrix(_myTransport.amount),
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Départ:',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Column(
                    children: [
                      Text(
                        _myTransport.adresseRue.join(" "),
                        style: Theme.of(context).textTheme.bodyText1,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        _myTransport.adresseZone.join(" "),
                        style: Theme.of(context).textTheme.bodyText1,
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
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    _myTransport.distance.toStringAsFixed(2) + ' km',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Arrivée:',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    _addressArriver,
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      );
                    }

                  return CustomerHandle(snapshot.data);
                }
              )
            ],
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
