import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/refund.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/presentation/pages/refund_screen.dart';


class ForStripe extends StatefulWidget {
  @override
  _ForStripeState createState() => _ForStripeState();
}

class _ForStripeState extends State<ForStripe> {
  @override
  void initState() {

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Refund>>(
        future: context.read(stripeRepositoryProvider).refundListFromFirestore(),
        builder: (context, data) {
          if (data.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary)),
            );
          }

          if (!data.hasData) {
            return Center(
              child: Text(
                'Pas de remboursement',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            );
          }

          List<Refund> refundList = data.data;

          return refundList.isNotEmpty
              ? ListView.builder(
                  itemCount: refundList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final refund = refundList[index];
                    return ListTile(
                      title: Text(
                        toNormalStatus(refund.status),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      trailing: Text(toNormalAmount(refund.amount),
                          style: Theme.of(context).textTheme.bodyText1),
                      leading: Text(toNormalReason(refund.reason),
                          style: Theme.of(context).textTheme.bodyText1),
                    );
                  })
              : Center(
                  child: Text(
                    'Pas de remboursement',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                );
        });
  }
}
