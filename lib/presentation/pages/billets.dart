import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share/share.dart';
import 'package:van_events_project/domain/models/billet.dart';
import 'package:van_events_project/domain/models/refund.dart';
import 'package:van_events_project/domain/repositories/my_billet_repository.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';

class Billets extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final myBilletRepo = useProvider(myBilletRepositoryProvider);
    return ModelBody(
      child: StreamBuilder<List<Billet>>(
        stream: myBilletRepo.streamBilletsMyUser(),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error.toString());
            return const Center(
              child: Text('Erreur de connexion'),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.secondary)),
            );
          }

          final List<Billet> billets = <Billet>[];
          billets.addAll(snapshot.data);

          return billets.isNotEmpty
              ? ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  itemCount: billets.length,
                  itemBuilder: (context, index) {
                    return Slidable(
                      actionPane: const SlidableDrawerActionPane(),
                      actionExtentRatio: 0.15,
                      actions: <Widget>[
                        IconSlideAction(
                          caption: 'Rembourser',
                          color: Theme.of(context).colorScheme.secondary,
                          icon: FontAwesomeIcons.moneyBillWave,
                          onTap: () async {
                            await askRefund(context, billets[index]);
                          },
                        ),
                      ],
                      secondaryActions: <Widget>[
                        IconSlideAction(
                            caption: 'Partager',
                            color: Theme.of(context).colorScheme.primaryVariant,
                            icon: FontAwesomeIcons.shareAlt,
                            onTap: () => sharePdf(
                                billets.elementAt(index).paymentIntentId))
                      ],
                      child: ListTile(
                        leading: dateDachat(
                            billets.elementAt(index).dateTime, context),
                        title: Text(
                          toNormalBilletStatus(billets.elementAt(index).status),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        trailing: Icon(
                          FontAwesomeIcons.qrcode,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        onTap: () => ExtendedNavigator.of(context).push(
                            Routes.billetDetails,
                            arguments: BilletDetailsArguments(
                                billetId: billets.elementAt(index).id)),
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
                    'Pas de billets',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                );
        },
      ),
    );
  }

  Widget dateDachat(DateTime dateTime, BuildContext context) {
    final date = DateFormat(
      'dd/MM/yy',
    );

    return Text(
      date.format(dateTime),
      style: Theme.of(context).textTheme.bodyText1,
    );
  }

  String toNormalBilletStatus(BilletStatus status) {
    switch (status) {
      case BilletStatus.upComing:
        return 'À venir';
        break;
      case BilletStatus.check:
        return 'Vérifié';
        break;
      case BilletStatus.refundAsked:
        return 'Remboursement demandé';
        break;
      case BilletStatus.refundCancelled:
        return 'Demande annulé';
        break;
      case BilletStatus.refundRefused:
        return 'Remboursement refusé';
        break;
      default: //BilletStatus.refunded
        return 'Remboursé';
        break;
    }
  }
}

Future askRefund(BuildContext context, Billet billet) async {
  final rep = await Show.showAreYouSureModel(
      context: context,
      title: 'Remboursement',
      content: 'Êtes-vous sûr de vouloir demander le remboursement?');
  if (rep != null && rep) {
    context.read(myBilletRepositoryProvider).setStatusRefundAsked(billet.id);
    final Refund myRefund = Refund(
      id: FirestoreService.instance
          .getDocId(path: MyPath.refunds(billet.organisateurId)),
      amount: billet.amount,
      paymentIntent: billet.paymentIntentId,
      status: RefundStatus.new_demand,
      reason: RefundReason.requested_by_customer,
    );
    context
        .read(stripeRepositoryProvider)
        .setNewRefund(myRefund, billet.organisateurId);
  }
}

Future<void> sharePdf(String id) async {
  final pdf = pw.Document();

  pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.BarcodeWidget(
              data: id,
              barcode: pw.Barcode.qrCode(),
              backgroundColor: PdfColor.fromInt(Colors.white.value)),
        ); // Center
      })); //

  final directory = Platform.isAndroid
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();
  final String tempPath = directory.path;

  final file = File('$tempPath/QrCode.pdf');
  await file.writeAsBytes(await pdf.save());

  Share.shareFiles(['$tempPath/QrCode.pdf'], text: 'Mon billet');
}
