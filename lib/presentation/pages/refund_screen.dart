import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:van_events_project/domain/models/refund.dart';
import 'package:van_events_project/presentation/widgets/refund/for_stripe.dart';
import 'package:van_events_project/presentation/widgets/refund/new_demand.dart';
import 'package:van_events_project/presentation/widgets/refund/refused.dart';

GlobalKey<ScaffoldState> keyRefundScreen = GlobalKey<ScaffoldState>();

class RefundScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 3);

    return Scaffold(
      key: keyRefundScreen,
      appBar: AppBar(
        title: Text('Remboursement'),
        bottom: TabBar(
          tabs: [
            Tab(
              text: 'Nouveau(x)',
            ),
            Tab(
              text: 'Refusé',
            ),
            Tab(
              text: 'Pour Stripe',
            ),
          ],
          controller: tabController,
        ),
      ),
      body: TabBarView(
          physics: AlwaysScrollableScrollPhysics(),
          controller: tabController,
          children: [NewDemand(), Refused(), ForStripe()]),
    );
  }
}

String toNormalStatus(RefundStatus status) {
  switch (status) {
    case RefundStatus.pending:
      return 'En attente';
      break;
    case RefundStatus.succeeded:
      return 'Effectué';
      break;
    case RefundStatus.failed:
      return 'Échec';
      break;
    case RefundStatus.canceled:
      return 'Annulé';
      break;
    case RefundStatus.refused:
      return 'Refusé';
      break;
    default: // RefundStatus.new_demand
      return 'Demande au marchand';
      break;
  }
}

String toNormalReason(RefundReason reason) {
  switch (reason) {
    case RefundReason.duplicate:
      return 'Doublon';
      break;
    case RefundReason.fraudulent:
      return 'Frauduleux';
      break;
    case RefundReason.requested_by_customer:
      return 'Demande du client';
      break;
    default: //RefundReason.expired_uncaptured_charge
      return 'Non capturé';
      break;
  }
}

String toNormalAmount(int montant) {
  double amount = montant.toDouble() / 100;
  return '${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)} €';
}
