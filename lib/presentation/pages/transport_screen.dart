import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:intl/intl.dart';
import 'package:van_events_project/domain/models/my_transport.dart';
import 'package:van_events_project/domain/repositories/my_event_repository.dart';
import 'package:van_events_project/domain/repositories/my_transport_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';

final myStreamTransportProvider = StreamProvider<List<MyTransport>>((ref) {
  return ref.read(myTransportRepositoryProvider).streamTransportsVtc();
});

class TransportScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final streanTransport = useProvider(myStreamTransportProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Transport Admin'),
      ),
      body: streanTransport.when(
        data: (transports) => transports.isNotEmpty
            ? ListView.builder(
                itemCount: transports.length,
                itemBuilder: (context, index) => ListTile(
                      title: Text(
                        transports[index].statusTransport.toString(),
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      trailing: Text(
                        transports[index].nbPersonne,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      leading: Text(
                        DateFormat('dd/MM/yyyy').format(transports[index].dateTime),
                        style: Theme.of(context).textTheme.headline5,
                      ),
                  onTap: ()async{
                    final event = await context
                        .read(myEventRepositoryProvider)
                        .eventFuture(
                        transports.elementAt(index).eventId);

                    ExtendedNavigator.of(context).push(
                        Routes.transportDetail,
                        arguments: TransportDetailArguments(
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
                  style: Theme.of(context).textTheme.headline5,
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
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
      ),
    );
  }
}
