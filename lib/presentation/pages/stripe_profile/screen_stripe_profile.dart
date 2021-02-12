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
import 'package:van_events_project/domain/models/list_payout.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/models/payout.dart';
import 'package:van_events_project/domain/models/transfer.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/presentation/pages/stripe_profile/cubit/stripe_profile_cubit.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/toggle_bool.dart';
import 'package:van_events_project/services/firestore_path.dart';

class StripeProfile extends HookWidget {
  final String stripeAccount;

  const StripeProfile({this.stripeAccount});

  @override
  Widget build(BuildContext context) {
    final myUserRead = useProvider(myUserProvider);
    final db = useProvider(stripeRepositoryProvider);
    final boolToggleRead = useProvider(boolToggleProvider);

    return ModelScreen(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('Profile stripe'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: BlocProvider<StripeProfileCubit>(
            create: (context) => StripeProfileCubit(context),
            child: BlocListener<StripeProfileCubit, StripeProfileState>(
              listener: (context, state) {
                if (state is StripeProfileLoading) {
                  showSnackBar(context, 'Chargement...');
                } else if (state is StripeProfileFailed) {
                  showSnackBar(context, state.message);
                } else if (state is StripeProfileSuccess) {
                  Scaffold.of(context).hideCurrentSnackBar();

                }

              },
              //cubit:StripeProfileCubit(context) ,
              child: BlocBuilder<StripeProfileCubit, StripeProfileState>(
                builder: (context, state) {
                  if (state is StripeProfileInitial) {
                    BlocProvider.of<StripeProfileCubit>(context)
                        .fetchStripeProfile(
                            stripeAccount ?? myUserRead.stripeAccount,
                            myUserRead.person);
                  }

                  if (state is StripeProfileSuccess) {
                    final payoutList = state.payoutList.data;
                    return Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              state.result.businessProfile?.name ?? '',
                              style: Theme.of(context).textTheme.headline5,
                            ),
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
                                        if (state.person.verification.status ==
                                            'verified')
                                          const Icon(FontAwesomeIcons.check)
                                        else
                                          const SizedBox()
                                      ],
                                    ),
                                  )),
                            )
                          ],
                        ),
                        const Divider(),
                        Card(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            direction: Axis.vertical,
                            children: [
                              Text('Solde non disponible :',
                                  style: Theme.of(context).textTheme.headline5),
                              Text(
                                toNormalAmount(
                                    toTotalPending(state.balance.pending)),
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              Text('Solde disponible :',
                                  style: Theme.of(context).textTheme.headline5),
                              Text(
                                toNormalAmount(
                                    toTotalAvailable(state.balance.available)),
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              Text('En transit vers la banque :',
                                  style: Theme.of(context).textTheme.headline5),
                              Text(
                                toTotalEnTransit(state.payoutList.data),
                                style: Theme.of(context).textTheme.bodyText1,
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
                        const Divider(),
                        Text('Virements',
                            style: Theme.of(context).textTheme.headline5),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: payoutList.length,
                              itemBuilder: (context, index) {
                                final payout = payoutList[index];
                                return Card(
                                  child: Column(
                                    children: [
                                      Text(
                                          'Montant : ${toNormalAmount(payout['amount'] as int)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1),
                                      Text(
                                          // ignore: unnecessary_parenthesis
                                          'Le : ${DateFormat('dd/MM/yyyy').format(Timestamp.fromMillisecondsSinceEpoch((state.payoutList.data[index]['created'] * 1000) as int).toDate())}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: payout['status'] == 'paid'
                                              ? Colors.greenAccent.shade100
                                              : Colors.grey,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Status : ${payout['status'] }',
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
                        const Divider(),
                        Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // direction: Axis.vertical,
                            children: [
                              Text(
                                  'Créer le : ${DateFormat('dd/MM/yyyy').format(Timestamp.fromMillisecondsSinceEpoch(state.person.created * 1000).toDate())}',
                                  style: Theme.of(context).textTheme.bodyText1),
                              Text(
                                  'SIREN : ${isProvided(state.result.company.taxIdProvided)}',
                                  style: Theme.of(context).textTheme.bodyText1),
                              Text(
                                  'Site internet : ${isProvided(state.result.businessProfile.url != null)}',
                                  style: Theme.of(context).textTheme.bodyText1),
                              Center(
                                child: Text(
                                  'Numéro de téléphone : ${state.result.businessProfile.supportPhone}',
                                  style: Theme.of(context).textTheme.bodyText1,
                                  overflow: TextOverflow.fade,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text('''
                              Adresse: ${state.result.company.address.line1} ${state.result.company.address.postalCode} ${state.result.company.address.city} ''',
                                  style: Theme.of(context).textTheme.bodyText1,
                                  textAlign: TextAlign.center),
                              Text('''
                              Compte Bancaire : ...${state.result.externalAccounts.data.first['last4']}''',
                                  style: Theme.of(context).textTheme.bodyText1,
                                  textAlign: TextAlign.center),
                              Text('''
                              Représentant : ${state.person.firstName} ${state.person.lastName}''',
                                  style: Theme.of(context).textTheme.bodyText1,
                                  textAlign: TextAlign.center),
                              Text('Status : ${buildStatus(state)}',
                                  style: Theme.of(context).textTheme.bodyText1,
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        const Divider(),
                        Text(
                          'Document d\'identité recto',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        InkWell(
                          onTap: () async {
                            await sendDocument(boolToggleRead, context,
                                myUserRead, db, 'front');
                          },
                          child: Consumer(builder: (context, watch, child) {
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
                          'Document d\'identité verso',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        InkWell(
                          onTap: () async {
                            await sendDocument(boolToggleRead, context,
                                myUserRead, db, 'back');
                          },
                          child: Consumer(builder: (context, watch, child) {
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
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        InkWell(
                          onTap: () async {
                            await sendDocument(boolToggleRead, context,
                                myUserRead, db, 'justificatifDomicile');
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
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.asset(
          'assets/img/img_not_available.jpeg',
          width: 300.0,
          height: 300.0,
          fit: BoxFit.cover,
        ),
      ),
      imageUrl: url ?? urlFromMyUser,
      fit: BoxFit.scaleDown,
    );
  }

  Future sendDocument(BoolToggle boolToggleRead, BuildContext context,
      MyUser myUserRead, StripeRepository db, String type) async {
    boolToggleRead.setOnGoingUpload(type);

    final File file = await Show.showDialogSource(context);

    boolToggleRead.setShowSpinner();
    if (file != null) {
      final bool rep = await Show.showAreYouSurePhotoModel(
          context: context,
          content: file,
          title: 'Êtes-vous sûr de vouloir envoyer cette image?');
      if (rep != null && rep) {
        final firebase_storage.TaskSnapshot taskSnapshot =
            await firebase_storage.FirebaseStorage.instance
                .ref()
                .child(MyPath.stripeDocs(myUserRead.id, type))
                .putFile(file);

        final HttpsCallableResult response = await db.uploadFileToStripe(
            MyPath.stripeDocs(myUserRead.id, type),
            myUserRead.stripeAccount,
            myUserRead.person);
        String url;
        if (response != null) {
          url = await taskSnapshot.ref.getDownloadURL();

          switch (type) {
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
    }
    boolToggleRead.setShowSpinner();
  }

  String buildStatus(StripeProfileSuccess state) =>
      state.person.verification.status == 'verified'
          ? 'Vérifié'
          : 'Non vérifié';

  String toNormalAmount(int amount) {
    return '${(amount / 100).toStringAsFixed((amount / 100).truncateToDouble() == (amount / 100) ? 0 : 2)} €';
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
              if (content == 'Chargement du profil...')
                const CircularProgressIndicator()
              else
                const SizedBox(),
            ],
          ),
          duration: const Duration(minutes: 1),
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

  String toTotalEnTransit(List data) {
    int total = 0;

    for (int i = 0; i < data.length; i++) {
      if ((data.elementAt(i) as Map)['status'] == 'in_transit') {
        total += (data.elementAt(i) as Data).amount;
      }
    }

    return toNormalAmount(total * 100);
  }

  String toTotalVolume(List<Transfer> data) {
    int total = 0;

    for (final nb in data) {
      total += nb.amount;
    }

    return toNormalAmount(total);
  }
}
