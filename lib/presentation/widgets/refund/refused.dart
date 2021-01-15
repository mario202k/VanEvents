import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/presentation/pages/refund_screen.dart';

import 'new_demand.dart';

class Refused extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final streamRefused = useProvider(refusedRefundStreamProvider);
    return streamRefused.when(
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
                  'Pas de remboursement refusé',
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
