import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:van_events_project/domain/models/my_transport.dart';
import 'package:van_events_project/domain/repositories/my_event_repository.dart';
import 'package:intl/intl.dart';
import 'package:van_events_project/domain/repositories/my_transport_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'new.dart';

class OnGoing extends StatelessWidget {
  final streamTransport = useProvider(myStreamTransportUpcomingProvider);
  @override
  Widget build(BuildContext context) {
    return streamTransport.when(
      data: (transports) => transports.isNotEmpty
          ? ListView.builder(
          itemCount: transports.length,
          itemBuilder: (context, index) {
            sendInvoice(transports[index],context);
            return ListTile(
            title: Text(
              transportStatusToString(transports[index].statusTransport),
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
          );
          })
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
    );
  }

  void sendInvoice(MyTransport transport, BuildContext context) {


    if (transport.statusTransport == StatusTransport.acceptedByVtc &&
        transport.dateTime.difference(DateTime.now()).inDays <= 7) {
      context
          .read(myTransportRepositoryProvider)
          .setTransportFactureEnvoyer(transport.id);
    }
  }
}
