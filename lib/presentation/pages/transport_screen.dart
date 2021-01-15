import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:majascan/majascan.dart';
import 'package:van_events_project/domain/repositories/my_transport_repository.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/presentation/widgets/transports/done.dart';
import 'package:van_events_project/presentation/widgets/transports/new.dart';
import 'package:van_events_project/presentation/widgets/transports/on_going.dart';

class TransportScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 3);
    return Scaffold(
      appBar: AppBar(
        title: Text('Transport'),
        bottom: TabBar(
          tabs: [
            Tab(
              text: 'Nouveau(x)',
            ),
            Tab(
              text: 'En cours',
            ),
            Tab(
              text: 'Traité',
            ),
          ],
          controller: tabController,
        ),
      ),
      body: TabBarView(
          physics: AlwaysScrollableScrollPhysics(),
          controller: tabController,
          children: [
            New(),
            OnGoing(),
            Done()
          ]),

    );
  }

}
