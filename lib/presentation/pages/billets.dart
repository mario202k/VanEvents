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
import 'package:share_extend/share_extend.dart';
import 'package:van_events_project/domain/models/billet.dart';
import 'package:van_events_project/domain/repositories/my_billet_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/show.dart';


class Billets extends HookWidget {
  @override
  Widget build(BuildContext context) {
    print('buildBillet');
    final myBilletRepo = useProvider(myBilletRepositoryProvider);
    return StreamBuilder(
      stream: myBilletRepo.streamBilletsMyUser(),
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur de connexion'),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary)),
          );
        }

        List<Billet> billets = List<Billet>();
        billets.addAll(snapshot.data);

        return billets.isNotEmpty
            ? ListView.separated(
                physics: ClampingScrollPhysics(),
                itemCount: billets.length,
                itemBuilder: (context, index) {
                  return Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.15,
                    actions: <Widget>[
                      IconSlideAction(
                        caption: 'Rembourser',
                        color: Theme.of(context).colorScheme.secondary,
                        icon: FontAwesomeIcons.moneyBillWave,
                        onTap: () => Show.showRembouser(context),
                      ),
                    ],
                    secondaryActions: <Widget>[

                      IconSlideAction(
                          caption: 'Partager',
                          color: Theme.of(context).colorScheme.primaryVariant,
                          icon: FontAwesomeIcons.shareAlt,
                          onTap: () => partager(billets.elementAt(index).id))
                    ],
                    child: ListTile(
                      leading: dateDachat(
                          billets.elementAt(index).dateTime, context),
                      title: Text(
                        billets.elementAt(index).status,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      trailing: Icon(
                        FontAwesomeIcons.qrcode,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      onTap: () => ExtendedNavigator.of(context).push(
                          Routes.qrCode,
                          arguments: QrCodeArguments(
                              data: billets.elementAt(index).id)),
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
    );
  }

  Widget dateDachat(DateTime dateTime, BuildContext context) {
    final date = DateFormat(
      'dd/MM/yy',
    );

    return Text(
      date.format(dateTime),
      style: Theme.of(context).textTheme.headline5,
    );
  }

  partager(String id) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.QrCodeWidget(
                data: id,
                size: 320,
                backgroundColor: PdfColor.fromInt(Colors.white.value)),
          ); // Center
        })); //

    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    String tempPath = directory.path;

    final file = File('$tempPath/QrCode.pdf');
    await file.writeAsBytes(pdf.save());

    ShareExtend.share(file.path, "file");
  }
}
