import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:van_events_project/domain/models/my_transport.dart';
import 'package:van_events_project/domain/repositories/my_event_repository.dart';
import 'package:van_events_project/domain/repositories/my_transport_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';

class New extends StatelessWidget {
  final streamTransport = useProvider(myStreamTransportNonTraiterProvider);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        streamTransport.when(
          data: (transports) => transports.isNotEmpty
              ? ListView.builder(
                  itemCount: transports.length,
                  itemBuilder: (context, index) => ListTile(
                        title: Text(
                          transportStatusToString(
                              transports[index].statusTransport),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        trailing: Text(
                          transports[index].nbPersonne,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        leading: Text(
                          DateFormat('dd/MM/yyyy')
                              .format(transports[index].dateTime),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        onTap: () async {
                          final event = await context
                              .read(myEventRepositoryProvider)
                              .eventFuture(transports.elementAt(index).eventId);

                          ExtendedNavigator.of(context).push(
                              Routes.transportDetailScreen,
                              arguments: TransportDetailScreenArguments(
                                  myTransport: transports.elementAt(index),
                                  addressArriver: [
                                    ...event.adresseRue,
                                    ...event.adresseZone
                                  ].join(' ')));
                        },
                      ))
              : Center(
                  child: Text(
                    'Pas de transports',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
          loading: () => Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary)),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Erreur',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          right: 30,
          child: FloatingActionButton.extended(
            onPressed: () {
              ExtendedNavigator.of(context).push(Routes.transportOnly);
            },
            label: const Text('Demande de devis'),
          ),
        ),
      ],
    );
  }
}

String transportStatusToString(StatusTransport statusTransport) {
  switch (statusTransport) {
    case StatusTransport.submitted:
      return 'Soumis';
      break;
    case StatusTransport.acceptedByVtc:
      return 'accepté par un chauffeur';
      break;
    case StatusTransport.invoiceSent:
      return 'facture envoyé';
      break;
    case StatusTransport.holdOnCard:
      return 'Authorisation CB accepté';
      break;
    case StatusTransport.captureFunds:
      return 'Paiement Ok';
      break;
    case StatusTransport.refunded:
      return 'Remboursé';
      break;
    case StatusTransport.cancelledByVTC:
      return 'Annulé par Vtc';
      break;
    case StatusTransport.cancelledByCustomer:
      return 'Annulé par le Client';
      break;
    default:
      return 'Soumis';
      break;
  }
}
