import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/event.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_event_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/presentation/widgets/show.dart';

class AdminEvents extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final eventRepo = useProvider(myEventRepositoryProvider);
    final myUser = useProvider(myUserProvider);

    return ModelScreen(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('Admin'),
        ),
        body: ModelBody(
          child: StreamBuilder<List<MyEvent>>(
              stream: eventRepo.allEventsAdminStream(myUser.stripeAccount),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur de connection',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary)),
                  );
                }
                final List<MyEvent> events = <MyEvent>[];
                events.addAll(snapshot.data);

                return events.isNotEmpty
                    ? ListView.separated(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return Slidable(
                            actionPane: const SlidableDrawerActionPane(),
                            actionExtentRatio: 0.15,
                            actions: <Widget>[
                              IconSlideAction(
                                caption: 'Annuler',
                                color: Theme.of(context).colorScheme.secondary,
                                icon: FontAwesomeIcons.calendarTimes,
                                onTap: () {
                                  Show.showAreYouSure(
                                      context, eventRepo, index, events);
                                },
                              ),
                            ],
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption: 'Update',
                                color:
                                    Theme.of(context).colorScheme.primaryVariant,
                                icon: FontAwesomeIcons.search,
                                onTap: () => ExtendedNavigator.of(context).push(
                                    Routes.uploadEvent,
                                    arguments: UploadEventArguments(
                                        myEvent: events.elementAt(index))),
                              )
                            ],
                            child: ListTile(
                              leading: Text(
                                events.elementAt(index).titre,
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                              ),
                              title: Text(
                                events.elementAt(index).status,
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                              ),
                              trailing: Icon(
                                FontAwesomeIcons.qrcode,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                              onTap: () => ExtendedNavigator.of(context).push(
                                  Routes.monitoringScanner,
                                  arguments: MonitoringScannerArguments(
                                      eventId: events.elementAt(index).id)),
                            ),
                          );
                        },
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).colorScheme.secondary,
                          thickness: 1,
                        ),
                      )
                    : Center(
                        child: Text(
                          'Pas d\'évenements',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      );
              }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              ExtendedNavigator.of(context).push(Routes.uploadEvent),
          child: Icon(
            FontAwesomeIcons.plus,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }
}
