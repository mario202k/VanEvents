import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:van_events_project/presentation/widgets/transports/done.dart';
import 'package:van_events_project/presentation/widgets/transports/new.dart';
import 'package:van_events_project/presentation/widgets/transports/on_going.dart';

class TransportScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 3);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Transport'),
        bottom: TabBar(
          tabs: const [
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
          physics: const AlwaysScrollableScrollPhysics(),
          controller: tabController,
          children: [
            New(),
            OnGoing(),
            Done()
          ]),

    );
  }

}
