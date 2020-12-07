import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/domain/models/balance.dart';
import 'package:van_events_project/domain/models/listPayout.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/models/transfer.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/presentation/pages/stripe_profile/cubit/stripe_profile_cubit.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/providers/toggle_bool_chat_room.dart';


class StripeProfile extends HookWidget {
  final String stripeAccount;

  StripeProfile({this.stripeAccount});

  @override
  Widget build(BuildContext context) {
    final myUserRead = useProvider(myUserProvider);
    final db = useProvider(stripeRepositoryProvider);
    final boolToggleRead = useProvider(boolToggleProvider);

    return ModelScreen(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text('Profile stripe'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: BlocProvider<StripeProfileCubit>(
            create: (context) => StripeProfileCubit(context),
            child: BlocListener<StripeProfileCubit, StripeProfileState>(
              listener: (context, state) {
                if (state is StripeProfileLoading) {
                  showSnackBar(context, 'Chargement...');
                } else if (state is StripeProfileFailed) {
                  showSnackBar(context, state.message);
                } else if (state is StripeProfileSuccess) {
                  Scaffold.of(context)..hideCurrentSnackBar();
                }
              },
              //cubit:StripeProfileCubit(context) ,
              child: BlocBuilder<StripeProfileCubit, StripeProfileState>(
                builder: (context, state) {
                  if (state is StripeProfileInitial) {
                    BlocProvider.of<StripeProfileCubit>(context)
                        .fetchStripeProfile(
                            stripeAccount ?? myUserRead.stripeAccount, myUserRead.person);
                  }

                  if (state is StripeProfileSuccess) {
                    final st = state.payoutList.data;
                    return Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          direction: Axis.horizontal,
                          children: [
                            Text(state.result.businessProfile.name),
                            FittedBox(
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: state.person.verification.status ==
                                            'verified'
                                        ? Colors.greenAccent
                                        : Colors.grey,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text(buildStatus(state),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(fontSize: 22)),
                                        state.person.verification.status ==
                                                'verified'
                                            ? Icon(FontAwesomeIcons.check)
                                            : SizedBox()
                                      ],
                                    ),
                                  )),
                            )
                          ],
                        ),
                        Divider(),
                        Card(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            direction: Axis.vertical,
                            children: [
                              Text(
                                'Solde non disponible :',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(fontSize: 22),
                              ),
                              Text(
                                toNormalAmount(
                                    toTotalPending(state.balance.pending)),
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              Text(
                                'Solde disponible :',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(fontSize: 22),
                              ),
                              Text(
                                toNormalAmount(
                                    toTotalAvailable(state.balance.available)),
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              Text(
                                'En transit vers la banque :',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(fontSize: 22),
                              ),
                              Text(
                                toTotalEnTransit(state.payoutList.data),
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              // Text(
                              //   'Volume total :',
                              //   style: Theme.of(context)
                              //       .textTheme
                              //       .bodyText1
                              //       .copyWith(fontSize: 22),
                              // ),
                              // Text(
                              //   toTotalVolume(state.transferList.data),
                              //   style: Theme.of(context).textTheme.headline4,
                              // ),
                            ],
                          ),
                        ),
                        Divider(),
                        Text('Virements'),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: st.length,
                              itemBuilder: (context, index) {
                                final payout = st[index];
                                return Card(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Montant : ' +
                                            toNormalAmount(payout.amount),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(fontSize: 22),
                                      ),
                                      Text(
                                        'Le : ' +
                                            DateFormat('dd/MM/yyyy').format(
                                                Timestamp
                                                        .fromMillisecondsSinceEpoch(
                                                            state
                                                                    .payoutList
                                                                    .data[index]
                                                                    .created *
                                                                1000)
                                                    .toDate()),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(fontSize: 22),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: payout.status == 'paid'
                                              ? Colors.greenAccent.shade100
                                              : Colors.grey,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Status : ' + payout.status,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                    color:
                                                        Colors.green.shade900),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                        Divider(),
                        Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // direction: Axis.vertical,
                            children: [
                              Text(
                                'Créer le : ' +
                                    DateFormat('dd/MM/yyyy').format(
                                        Timestamp.fromMillisecondsSinceEpoch(
                                                state.person.created * 1000)
                                            .toDate()),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(fontSize: 22),
                              ),
                              Text(
                                  'SIREN : ' +
                                      isProvided(
                                          state.result.company.taxIdProvided),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(fontSize: 22)),
                              Text(
                                  'Site internet : ' +
                                      isProvided(
                                          state.result.businessProfile.url !=
                                              null),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(fontSize: 22)),
                              Center(
                                child: Text(
                                  'Numéro de téléphone : ' +
                                      state.result.businessProfile.supportPhone,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(fontSize: 22),
                                  overflow: TextOverflow.fade,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                  'Adresse: ' +
                                      state.result.company.address.line1 +
                                      ' ' +
                                      state.result.company.address.postalCode +
                                      ' ' +
                                      state.result.company.address.city,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(fontSize: 22),
                                  textAlign: TextAlign.center),
                              Text(
                                  'Compte Bancaire : ...' +
                                      state.result.externalAccounts.data
                                          .first['last4'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(fontSize: 22),
                                  textAlign: TextAlign.center),
                              Text(
                                  'Représentant : ' +
                                      state.person.firstName +
                                      ' ' +
                                      state.person.lastName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(fontSize: 22),
                                  textAlign: TextAlign.center),
                              Text('Status : ' + buildStatus(state),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(fontSize: 22),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        Divider(),
                        Text(
                          'Document d\'indentité recto',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        InkWell(
                          onTap: () async {
                            await sendDocument(boolToggleRead, context,
                                myUserRead, db, 'idFront', 'front');
                          },
                          child: Consumer(builder: (context, watch, child) {
                            print(watch(boolToggleProvider).showSpinner);
                            print('////');
                            print(watch(boolToggleProvider).onGoingUpload);
                            if (watch(boolToggleProvider).showSpinner &&
                                watch(boolToggleProvider).onGoingUpload ==
                                    'idFront') {
                              return Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary)),
                              );
                            }
                            return watch(boolToggleProvider).urlIdFront !=
                                        null ||
                                    myUserRead.idRectoUrl.isNotEmpty
                                ? buildCachedNetworkImage(
                                    boolToggleRead.urlIdFront,
                                    myUserRead.idRectoUrl)
                                : Icon(
                                    FontAwesomeIcons.image,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 220,
                                  );
                          }),
                        ),
                        Text(
                          'Document d\'indentité verso',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        InkWell(
                          onTap: () async {
                            await sendDocument(boolToggleRead, context,
                                myUserRead, db, 'idBack', 'back');
                          },
                          child: Consumer(builder: (context, watch, child) {
                            print(watch(boolToggleProvider).showSpinner);
                            print('////');
                            print(watch(boolToggleProvider).onGoingUpload);
                            if (watch(boolToggleProvider).showSpinner &&
                                watch(boolToggleProvider).onGoingUpload ==
                                    'idBack') {
                              return Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary)),
                              );
                            }

                            return watch(boolToggleProvider).urlIdBack !=
                                        null ||
                                    myUserRead.idVersoUrl.isNotEmpty
                                ? buildCachedNetworkImage(
                                    boolToggleRead.urlIdBack,
                                    myUserRead.idVersoUrl)
                                : Icon(
                                    FontAwesomeIcons.image,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 220,
                                  );
                          }),
                        ),
                        Text(
                          'Justificatif de domicile',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        InkWell(
                          onTap: () async {
                            await sendDocument(
                                boolToggleRead,
                                context,
                                myUserRead,
                                db,
                                'justificatifDomicile',
                                'justificatifDomicile');
                          },
                          child: Consumer(builder: (context, watch, child) {
                            if (watch(boolToggleProvider).showSpinner &&
                                watch(boolToggleProvider).onGoingUpload ==
                                    'justificatifDomicile') {
                              return Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary)),
                              );
                            }
                            return watch(boolToggleProvider).urlJD != null ||
                                    myUserRead.proofOfAddress.isNotEmpty
                                ? buildCachedNetworkImage(boolToggleRead.urlJD,
                                    myUserRead.proofOfAddress)
                                : Icon(
                                    FontAwesomeIcons.image,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 220,
                                  );
                          }),
                        ),
                      ],
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary)),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  CachedNetworkImage buildCachedNetworkImage(String url, String urlFromMyUser) {
    return CachedNetworkImage(
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: Theme.of(context).colorScheme.primary,
        child: Container(height: 900, width: 600, color: Colors.white),
      ),
      imageBuilder: (context, imageProvider) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
        child: Image(
          image: imageProvider,
          fit: BoxFit.contain,
        ),
      ),
      errorWidget: (context, url, error) => Material(
        child: Image.asset(
          'assets/img/img_not_available.jpeg',
          width: 300.0,
          height: 300.0,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        clipBehavior: Clip.hardEdge,
      ),
      imageUrl: url ?? urlFromMyUser,
      fit: BoxFit.scaleDown,
    );
  }

  Future sendDocument(
      BoolToggle boolToggleRead,
      BuildContext context,
      MyUser myUserRead,
      StripeRepository db,
      String idFront,
      String front) async {
    File file = await showDialogSource(context, idFront, boolToggleRead);
    boolToggleRead.setShowSpinner();
    if (file != null) {
      firebase_storage.TaskSnapshot taskSnapshot  = await firebase_storage.FirebaseStorage.instance.ref()

          .child(front + myUserRead.id)
          .putFile(file);

      HttpsCallableResult response = await db.uploadFileToStripe(
          taskSnapshot.metadata.name,
          myUserRead.stripeAccount,
          myUserRead.person);
      String url;
      if (response != null) {
        url = await taskSnapshot.ref.getDownloadURL();

        switch (front) {
          case 'front':
            boolToggleRead.setUrlFront(url);
            db.setUrlFront(url);
            break;
          case 'back':
            boolToggleRead.setUrlBack(url);
            db.setUrlBack(url);
            break;
          case 'justificatifDomicile':
            boolToggleRead.setUrljustificatifDomicile(url);
            db.setUrljustificatifDomicile(url);
            break;
        }

      }
    }
    boolToggleRead.setShowSpinner();
  }

  Future<File> showDialogSource(
      BuildContext context, String type, BoolToggle boolToggleRead) {
    print('showDialogSource');
    print(type);
    return showDialog<File>(
      context: context,
      builder: (BuildContext context) => Platform.isAndroid
          ? AlertDialog(
              title: Text('Source?'),
              content: Text('Veuillez choisir une source'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Caméra'),
                  onPressed: () async {
                    File file = await boolToggleRead.getImageCamera(type);
                    Navigator.of(context).pop(file);
                  },
                ),
                FlatButton(
                  child: Text('Galerie'),
                  onPressed: () async {
                    File file = await boolToggleRead.getImageGallery(type);

                    Navigator.of(context).pop(file);
                  },
                ),
              ],
            )
          : CupertinoAlertDialog(
              title: Text('Source?'),
              content: Text('Veuillez choisir une source'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Caméra'),
                  onPressed: () async {
                    File file = await boolToggleRead.getImageCamera(type);
                    Navigator.of(context).pop(file);
                  },
                ),
                FlatButton(
                  child: Text('Galerie'),
                  onPressed: () async {
                    File file = await boolToggleRead.getImageGallery(type);
                    Navigator.of(context).pop(file);
                  },
                ),
              ],
            ),
    );
  }

  String buildStatus(StripeProfileSuccess state) =>
      state.person.verification.status == 'verified'
          ? 'Vérifié'
          : 'Non vérifié';

  String toNormalAmount(int amount) {
    return (amount / 100).toStringAsFixed(
            (amount / 100).truncateToDouble() == (amount / 100) ? 0 : 2) +
        ' €';
  }

  void showSnackBar(BuildContext context, String content) {
    Scaffold.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(content),
              content == 'Chargement du profil...'
                  ? CircularProgressIndicator()
                  : SizedBox(),
            ],
          ),
          duration: Duration(minutes: 1),
        ),
      );
  }

  String isProvided(bool taxIdProvided) {
    return taxIdProvided ? 'Fournie' : 'Non Fournie';
  }

  int toTotalPending(List<Pending> pending) {
    int total = 0;
    for (int i = 0; i < pending.length; i++) {
      total += pending.elementAt(i).amount;
    }

    return total;
  }

  int toTotalAvailable(List<Available> available) {
    int total = 0;
    for (int i = 0; i < available.length; i++) {
      total += available.elementAt(i).amount;
    }

    return total;
  }

  String toTotalEnTransit(List<Data> data) {
    int total = 0;

    for (int i = 0; i < data.length; i++) {
      if (data.elementAt(i).status == 'in_transit') {
        total += data.elementAt(i).amount;
      }
    }

    return toNormalAmount(total * 100);
  }

  String toTotalVolume(List<Transfer> data) {
    int total = 0;

    for (final nb in data) {
      print(nb.amount);
      total += nb.amount;
    }

    return toNormalAmount(total);
  }
}
