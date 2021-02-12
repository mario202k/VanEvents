import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/domain/models/billet.dart';
import 'package:van_events_project/domain/models/refund.dart';
import 'package:van_events_project/domain/repositories/my_billet_repository.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/pages/billets.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';

class BilletDetails extends HookWidget {
  final String billetId;
  final GlobalKey<ScaffoldState> scaffolKey = GlobalKey<ScaffoldState>();

  BilletDetails(this.billetId);

  @override
  Widget build(BuildContext context) {
    final streamBillet =
        context.read(myBilletRepositoryProvider).streamBillet(billetId);
    return ModelScreen(
      child: SafeArea(
        child: Scaffold(
          key: scaffolKey,
          appBar: AppBar(
            title: const Text('Détails'),
          ),
          body: ModelBody(
            child: Column(
              children: [
                StreamBuilder<List<Billet>>(
                    stream: streamBillet,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.secondary)),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Erreur de connexion',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        );
                      } else if (!snapshot.hasData) {
                        return const Center(
                          child: Text('Erreur de connexion'),
                        );
                      }

                      final Billet billet = snapshot.data.first;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                ExtendedNavigator.of(context).push(
                                    Routes.fullPhoto,
                                    arguments: FullPhotoArguments(
                                        url: billet.imageUrl));
                              },
                              child: CachedNetworkImage(
                                imageUrl: billet.imageUrl,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: 84,
                                  width: 84,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(84)),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.white,
                                  highlightColor:
                                      Theme.of(context).colorScheme.primary,
                                  child: const CircleAvatar(
                                    radius: 42,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                          if (snapshot.data.isNotEmpty)
                            Stack(
                              children: <Widget>[
                                Align(
                                  child: QrImage(
                                    data: billet.paymentIntentId,
                                    size: 320,
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    gapless: false,
                                  ),
                                ),
                                Visibility(
                                  visible: billet.status == BilletStatus.check,
                                  child: const FlareActor(
                                    'assets/animations/ok.flr',
                                    animation: 'Checkmark Appear',
                                  ),
                                )
                              ],
                            )
                          else
                            Center(
                              child: Text(
                                'Erreur de connexion',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                          handleStatus(
                              context, billet, billet.status, billet.id),
                        ],
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget handleStatus(
      BuildContext context, Billet billet, BilletStatus status, String id) {
    switch (status) {
      case BilletStatus.upComing:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FlatButton(
                onPressed: () async {
                  await askRefund(context, billet);
                },
                child: const Text('Rembourser')),
            FloatingActionButton.extended(
              onPressed: () {
                sharePdf(id);
              },
              label: const Text('Partager'),
              icon: const FaIcon(FontAwesomeIcons.share),
            ),
          ],
        );
        break;
      case BilletStatus.check:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FlatButton(
                onPressed: () async {
                  await askRefund(context, billet);
                },
                child: const Text('Rembourser')),
            FloatingActionButton.extended(
              onPressed: () {
                sharePdf(id);
              },
              label: const Text('Partager'),
              icon: const FaIcon(FontAwesomeIcons.share),
            ),
          ],
        );
        break;
      case BilletStatus.refundAsked:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
                onPressed: () async {
                  await cancelAsking(context, billet);
                },
                child: const Text('Annuler ma demande')),
          ],
        );
        break;
      case BilletStatus.refundCancelled:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FlatButton(
                onPressed: () async {
                  await askRefund(context, billet);
                },
                child: const Text('Rembourser')),
            FloatingActionButton.extended(
              onPressed: () {
                sharePdf(id);
              },
              label: const Text('Partager'),
              icon: const FaIcon(FontAwesomeIcons.share),
            ),
          ],
        );
        break;
      case BilletStatus.refundRefused:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FlatButton(
                onPressed: () async {
                  await askRefund(context, billet);
                },
                child: const Text('Rembourser')),
            FloatingActionButton.extended(
              onPressed: () {
                sharePdf(id);
              },
              label: const Text('Partager'),
              icon: const FaIcon(FontAwesomeIcons.share),
            ),
          ],
        );
        break;
      default: // BilletStatus.refunded
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                sharePdf(id);
              },
              label: const Text('Partager'),
              icon: const FaIcon(FontAwesomeIcons.share),
            ),
          ],
        );
        break;
    }
  }

  Future cancelAsking(BuildContext context, Billet billet) async {
    final rep = await Show.showAreYouSureModel(
        context: context,
        title: 'Remboursement',
        content: 'Êtes-vous sûr de vouloir annuler le remboursement?');
    if (rep != null && rep) {
      context.read(myBilletRepositoryProvider).setStatusCancelAsking(billet.id);
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
}
