import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/refund.dart';
import 'package:van_events_project/domain/repositories/my_billet_repository.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/presentation/pages/refund_screen.dart';
import 'package:van_events_project/presentation/widgets/show.dart';

class NewDemand extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final streamNewDemand = useProvider(newRefundStreamProvider);
    return streamNewDemand.when(
        data: (refunds) => refunds.isNotEmpty
            ? ListView.builder(
                itemCount: refunds.length,
                itemBuilder: (context, index) => ListTile(
                      title: Text(
                        toNormalStatus(refunds[index].status),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      trailing: Text(
                        toNormalReason(refunds[index].reason),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      leading: Text(
                        toNormalAmount(refunds[index].amount),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      onTap: () async {
                        await refundProcess(context, refunds, index);
                      },
                    ))
            : Center(
                child: Text(
                  'Pas de nouvelle demande',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
        loading: () => Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary)),
            ),
        error: (e, s) => Center(
              child: Text(
                'Erreur',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ));
  }
}

Future refundProcess(
    BuildContext context, List<Refund> refunds, int index) async {
  final response = await Show.showRembourser(context);
  if (response != null && response) {
    final amount = refunds[index].amount.toDouble() / 100;
    final map = await Show.showRembourserClient(context, amount);

    if(map == null){
      return;
    }
    final String pI = refunds[index].paymentIntent;
    final String reason = map['reason']
        .toString()
        .substring(map['reason'].toString().indexOf('.') + 1);
    final int myAmount = ((map['amount'] as int) * 100).toInt();

    Show.showSnackBar('Chargement...', keyRefundScreen);
    final rep = await context
        .read(stripeRepositoryProvider)
        .refundBillet(pI, reason, myAmount);
    if (rep != null && rep.data['status'] == 'succeeded') {
      final billet = await context
          .read(myBilletRepositoryProvider)
          .getBillet(refunds[index].paymentIntent);

      await context
          .read(myBilletRepositoryProvider)
          .setStatusRefunded(billet.first.id);

      await Show.showDialogToDismiss(
          context, 'Remboursement', 'Remboursement effectué.', 'Ok');

      final myRefund = Refund.fromStripeMap(
          rep.data as Map<dynamic, dynamic>, refunds[index].id);
      context
          .read(stripeRepositoryProvider)
          .setRefundFromStripe(myRefund, refunds[index].id);
    } else {
      Show.showDialogToDismiss(context, 'Remboursement',
          'Impossible d\'effectué le remboursement.', 'Ok');
    }
  } else if (response != null && !response) {
    final billet = await context
        .read(myBilletRepositoryProvider)
        .getBillet(refunds[index].paymentIntent);

    await context
        .read(myBilletRepositoryProvider)
        .setStatusRefused(billet.first.id);

    context.read(stripeRepositoryProvider).setRefundRefused(refunds[index]);
  }
}
