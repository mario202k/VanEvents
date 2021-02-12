import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:van_events_project/domain/models/my_transport.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_transport_repository.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/toggle_bool.dart';

class CustomerHandle extends StatelessWidget {
  final MyTransport transport;

  const CustomerHandle(this.transport);

  @override
  Widget build(BuildContext context) {
    return Center(child: toWidget(context));
  }

  Widget toWidget(BuildContext context) {
    switch (transport.statusTransport) {
      case StatusTransport.submitted:
        return RaisedButton(
            onPressed: () {
              context.read(myTransportRepositoryProvider).cancelTransport(
                  transport.id,
                  context.read(myUserProvider).typeDeCompte ==
                      TypeOfAccount.userNormal);
            },
            child: const Text('Annuler'));
        break;
      case StatusTransport.acceptedByVtc:
        return Column(
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                Show.showDialogToDismiss(
                    context,
                    'Paiement',
                    'Vous pourrez payer dans les 6 jours précédants le transport',
                    'Ok');
              },
              label: const Text('À venir'),
              icon: const FaIcon(FontAwesomeIcons.creditCard),
            ),
            FlatButton(
                onPressed: () async {
                  final rep = await Show.showAreYouSureModel(
                      context: context,
                      title: 'Annuler?',
                      content:
                          'Etes-vous sur de vouloir annuler le transport?');
                  if (rep != null && rep) {
                    context.read(myTransportRepositoryProvider).cancelTransport(
                        transport.id,
                        context.read(myUserProvider).typeDeCompte ==
                            TypeOfAccount.userNormal);
                  }
                },
                child: const Text('Annuler'))
          ],
        );
        break;
      case StatusTransport.invoiceSent:
        return Column(
          children: [
            Consumer(
              builder: (context, watch,child) {

                return !watch(boolToggleProvider).showSpinner? FloatingActionButton.extended(
                  onPressed: () async {
                    context.refresh(boolToggleProvider).setShowSpinner();
                    final value = await context
                        .read(stripeRepositoryProvider)
                        .paymentIntentAuthorize(transport.amount, transport.id);

                    if (value is String) {
                      context.refresh(boolToggleProvider).setShowSpinner();
                      Show.showDialogToDismiss(context, 'Oups!',
                          'Paiement refusé\nEssayer avec une autre carte', 'Ok');

                      return;
                    }
                    if (value is Map) {
                      context.refresh(boolToggleProvider).setShowSpinner();
                      double amount = double.parse(value['amount'].toString());

                      amount = amount / 100;

                      final price = toNormalPrice(amount);
                      await Show.showDialogToDismiss(context, 'Youpi!', 'Authorisation d\'un montant de $price € accordée.', 'Ok');

                      await context
                          .read(myTransportRepositoryProvider)
                          .setTransportPaymentIntentId(transport.id, value['id'] as String);


                    }

                  },
                  label: const Text('Continuer'),
                  icon: const FaIcon(FontAwesomeIcons.creditCard),
                ):Center(
                  child: CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(
                          Theme.of(context)
                              .colorScheme
                              .primary)),
                );
              }
            ),
            FlatButton(
                onPressed: () async {
                  final rep = await Show.showAreYouSureModel(
                      context: context,
                      title: 'Annuler?',
                      content:
                          'Etes-vous sur de vouloir annuler le transport?');
                  if (rep != null && rep) {
                    context.read(myTransportRepositoryProvider).cancelTransport(
                        transport.id,
                        context.read(myUserProvider).typeDeCompte ==
                            TypeOfAccount.userNormal);
                  }
                },
                child: const Text('Annuler')),
          ],
        );
        break;
      case StatusTransport.holdOnCard:
        return Column(
          children: [
            Center(
              child: QrImage(
                data: transport.paymentIntentId,
                size: 320,
                gapless: false,
              ),
            ),
            FlatButton(
                onPressed: () async {
                  final rep = await Show.showAreYouSureModel(
                      context: context,
                      title: 'Annuler?',
                      content:
                      'Etes-vous sur de vouloir annuler le transport?');
                  if (rep != null && rep) {
                    context.read(myTransportRepositoryProvider).cancelTransport(
                        transport.id,
                        context.read(myUserProvider).typeDeCompte ==
                            TypeOfAccount.userNormal);
                  }
                },
                child: const Text('Annuler'))
          ],
        ); //Display QR code
        break;
      case StatusTransport.captureFunds:
        return Column(
          children: [
            Text('Payé',style: Theme.of(context).textTheme.headline5,),
            SizedBox(
              height: 320,
              width: 320,
              child: Stack(
                children: <Widget>[
                  Align(
                    child: QrImage(
                      data: transport.paymentIntentId,
                      size: 320,
                      gapless: false,
                    ),
                  ),
                  const FlareActor(
                    'assets/animations/ok.flr',
                    animation: 'Checkmark Appear',
                  )
                ],
              ),
            ),

          ],
        ); //Display Flare
        break;
      case StatusTransport.refunded:
        return Text('Remboursé',style: Theme.of(context).textTheme.headline5,);
        break;
      case StatusTransport.cancelledByVTC:
        return Text('Annulé par le chauffeur.',style: Theme.of(context).textTheme.headline5,);
        break;
      case StatusTransport.cancelledByCustomer:
        return Text('Annulé par le client.',style: Theme.of(context).textTheme.headline5,);
        break;
      default://Error
        return Text('Une erreur s\'est produite' ,style: Theme.of(context).textTheme.headline5,);
        break;
    }
  }

  String toNormalPrice(double price) {
    return price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2);
  }
}
