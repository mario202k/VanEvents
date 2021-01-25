import 'package:cloud_functions/cloud_functions.dart';
import 'package:flare_flutter/flare_cache.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/material/scaffold.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_stripe_payment/flutter_stripe_payment.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/constants/credentials.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/models/refund.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';

final stripeRepositoryProvider = Provider<StripeRepository>((ref) {
  return StripeRepository(ref.watch(myUserProvider).id);
});

final newRefundStreamProvider = StreamProvider<List<Refund>>((ref) {
  return ref.read(stripeRepositoryProvider).getNewRefund();
});

final refusedRefundStreamProvider = StreamProvider<List<Refund>>((ref) {
  return ref.read(stripeRepositoryProvider).getRefusedRefund();
});

class StripeRepository {
  final _service = FirestoreService.instance;
  final String uid;

  StripeRepository(this.uid);

  Future<HttpsCallableResult> retrievePromotionCode(String codePromo) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'retrievePromotionCode',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'code': codePromo,
        },
      );
    } on FirebaseFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
    return stripeResponse;
  }

  Future<HttpsCallableResult> retrieveStripeCouponList() async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'retrieveCouponList',
      );
      stripeResponse = await callable.call();
    } on FirebaseFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }
  //firebase deploy --only functions:addMessage,functions:makeUppercase

  Future<dynamic> paymentIntentBillet(double amount, String stripeAccount,
      String description, int length, int nbEvents, int nbOrganizer, BuildContext context ) async {

    // precache
    final assetProvider = AssetFlare(bundle: rootBundle, name: 'assets/animations/paymentProcess.flr');
    cachedActor(assetProvider);

    final stripePayment = FlutterStripePayment();

    stripePayment.onCancel = () {
      print("User Cancelled the Payment Method Form");
    };
    stripePayment.setStripeSettings(PK_TEST, 'merchant.com.vanina.vanevents');

    var paymentResponse = await stripePayment.addPaymentMethod();


    String paymentMethodId = paymentResponse.paymentMethodId;

    if (paymentResponse.status == PaymentResponseStatus.succeeded) {
      Show.showProgress(context);
      HttpsCallableResult intentResponse;
      try {
        final HttpsCallable callable =
            FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
          'paymentIntentBillet',
        );
        intentResponse = await callable.call(
          <String, dynamic>{
            'amount': (amount).toInt(),
            'stripeAccount': stripeAccount,
            'description': description,
            'paymentMethodId': paymentMethodId,
            'nbParticipant': length,
            'nbEvents':nbEvents,
            'nbOrganizer':nbOrganizer
          },
        );
      } on FirebaseFunctionsException catch (e) {
        print(e);

        return 'Paiement refusé';
      } catch (e) {
        print(e);

        return 'Paiement refusé';
      }
      final paymentIntentX = intentResponse.data;
      final status = paymentIntentX['status'];

      if (status == 'succeeded') {
        return paymentIntentX;
      } else {
        //step 4: there is a need to authenticate
        //StripePayment.setStripeAccount(strAccount);

        var intentResponse = await stripePayment.confirmPaymentIntent(
            paymentIntentX['client_secret'],
            paymentResponse.paymentMethodId,
            amount);

        if (intentResponse.status == PaymentResponseStatus.succeeded) {
          return paymentIntentX;
        } else if (intentResponse.status == PaymentResponseStatus.failed) {
          return 'Paiement refusé';
        } else {
          return 'Paiement refusé';
        }
      }
    } else {
      return 'Paiement annulé';
    }
  }

  Future<dynamic> paymentIntentAuthorize(
      double amount, String description) async {
    final stripePayment = FlutterStripePayment();

    stripePayment.onCancel = () {
      print("User Cancelled the Payment Method Form");
    };
    stripePayment.setStripeSettings(PK_TEST, 'merchant.com.vanina.vanevents');

    var paymentResponse = await stripePayment.addPaymentMethod();

    String paymentMethodId = paymentResponse.paymentMethodId;

    if (paymentResponse.status == PaymentResponseStatus.succeeded) {
      HttpsCallableResult intentResponse;
      try {
        final HttpsCallable callable =
            FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
          'paymentIntentAuthorize',
        );
        intentResponse = await callable.call(
          <String, dynamic>{
            'amount': (amount * 100).toInt(),
            'description': description,
            'paymentMethodId': paymentMethodId,
          },
        );
      } on FirebaseFunctionsException catch (e) {
        print(e);

        return 'Paiement refusé';
      } catch (e) {
        print(e);

        return 'Paiement refusé';
      }

      final paymentIntentX = intentResponse.data;
      final status = paymentIntentX['status'];

      if (status == 'requires_capture') {
        return paymentIntentX;
      } else {
        //step 4: there is a need to authenticate
        //StripePayment.setStripeAccount(strAccount);
        var intentResponse = await stripePayment.confirmPaymentIntent(
            paymentIntentX['client_secret'],
            paymentResponse.paymentMethodId,
            amount);

        if (intentResponse.status == PaymentResponseStatus.succeeded) {
          return paymentIntentX;
        } else if (intentResponse.status == PaymentResponseStatus.failed) {
          return 'Paiement refusé';
        } else {
          return 'Paiement refusé';
        }
      }
    } else {
      return 'Paiement annulé';
    }
  }

  Future<dynamic> paymentIntentUploadEvents(
      double amount, String description, String idPromotionCode) async {
    final stripePayment = FlutterStripePayment();

    stripePayment.onCancel = () {
      print("User Cancelled the Payment Method Form");
    };
    stripePayment.setStripeSettings(PK_TEST, 'merchant.com.vanina.vanevents');

    var paymentResponse = await stripePayment.addPaymentMethod();
    print('coucou!!!!!');

    if (paymentResponse.status == PaymentResponseStatus.succeeded) {
      HttpsCallableResult intentResponse;
      try {
        final HttpsCallable callable =
            FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
          'paymentIntentUploadEvents',
        );
        intentResponse = await callable.call(
          <String, dynamic>{
            'amount': (amount * 100).toInt(),
            'idPromotionCode': idPromotionCode,
            'description': description,
            'paymentMethodId': paymentResponse.paymentMethodId
          },
        );
      } on FirebaseFunctionsException catch (e) {
        print(e);
        return 'Paiement refusé';
      } catch (e) {
        print(e);
        return 'Paiement refusé';
      }
      final paymentIntentX = intentResponse.data;
      final status = paymentIntentX['status'];

      if (status == 'succeeded') {
        return paymentIntentX;
      } else {
        //step 4: there is a need to authenticate
        //StripePayment.setStripeAccount(strAccount);

        var intentResponse = await stripePayment.confirmPaymentIntent(
            paymentIntentX['client_secret'],
            paymentResponse.paymentMethodId,
            amount);

        if (intentResponse.status == PaymentResponseStatus.succeeded) {
          return paymentIntentX;
        } else if (intentResponse.status == PaymentResponseStatus.failed) {
          return 'Paiement refusé';
        } else {
          return 'Paiement refusé';
        }
      }
    } else {
      print('!!!!!!!!!!!!!!');
      return 'Paiement annulé';
    }
  }

  Future<HttpsCallableResult> uploadFileToStripe(
      String filePath, String stripeAccount, String person) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'uploadFileToStripe',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'filePath': filePath,
          'stripeAccount': stripeAccount,
          'person': person
        },
      );
    } on FirebaseFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  Future<HttpsCallableResult> retrievePerson(
      String stripeAccount, String person) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'retrievePerson',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{'stripeAccount': stripeAccount, 'person': person},
      );
    } on FirebaseFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  Future<HttpsCallableResult> payoutList(String stripeAccount) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'payoutList',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'stripeAccount': stripeAccount,
        },
      );
    } on FirebaseFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
    return stripeResponse;
  }

  Future<HttpsCallableResult> transfersList(String stripeAccount) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'transfersList',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'stripeAccount': stripeAccount,
        },
      );
    } on FirebaseFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
    return stripeResponse;
  }

  Future<HttpsCallableResult> createStripeAccount(
      String nomSociete,
      String email,
      String supportEmail,
      String phone,
      String city,
      String line1,
      String line2,
      String postalCode,
      String state,
      String accountHolderName,
      String accountNumber,
      String nom,
      String prenom,
      String siren,
      String dateOfBirth) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'createStripeAccount',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'nomSociete': nomSociete,
          'email': email,
          'support_email': supportEmail,
          'phone': phone,
          'city': city,
          'line1': line1,
          'line2': line2,
          'postal_code': postalCode,
          'state': state,
          'account_holder_name': accountHolderName,
          'account_holder_type': 'company',
          'account_number': accountNumber,
          'business_type': 'company',
          'siren': siren,
          'first_name': prenom,
          'last_name': nom,
          'date_of_birth': dateOfBirth
        },
      );
    } on FirebaseFunctionsException catch (e) {
      print(e);
      print(e.details);
      print(e.message);
      print(e.stackTrace);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  Future<HttpsCallableResult> allStripeAccounts() async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'allStripeAccounts',
      );
      stripeResponse = await callable.call();
    } on FirebaseFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  Future<HttpsCallableResult> deleteStripeAccount(String id) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'deleteStripeAccount',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'stripeAccount': id,
        },
      );
    } on FirebaseFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  Future<HttpsCallableResult> organisateurBalance(String id) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'balance',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'stripeAccount': id,
        },
      );
    } on FirebaseFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  Future<HttpsCallableResult> retrieveStripeAccount(String stripeId) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'retrieveStripeAccount',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'stripeAccount': stripeId,
        },
      );
    } on FirebaseFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  Future<HttpsCallableResult> refundBillet(
      String paymentIntentId, String reason, int amount) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable =
      FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'refundBillet',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'paymentIntentId': paymentIntentId,
          'reason':reason,
          'amount':amount
        },
      );
    } on FirebaseFunctionsException catch (e) {
      print(e);
      print('llllll');

      return null;
    } catch (e) {
      print(e);

      return null;
    }
    return stripeResponse;
  }


  Future setUrlFront(String url) async {
    return _service
        .setData(path: MyPath.user(uid), data: {'idRectoUrl': url});
  }

  Future setUrlBack(String url) async {
    return _service
        .setData(path: MyPath.user(uid), data: {'idVersoUrl': url});
  }

  Future setUrljustificatifDomicile(String url) {
    return _service
        .setData(path: MyPath.user(uid), data: {'proofOfAddress': url});
  }

  Future<HttpsCallableResult> refundList() async {
    HttpsCallableResult intentResponse;
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'refundList',
      );
      intentResponse = await callable.call();
    } on FirebaseFunctionsException catch (e) {
      print(e);

      return null;
    } catch (e) {
      print(e);

      return null;
    }
    return intentResponse;
  }


  Stream<List<Refund>> getNewRefund() {
    return _service.collectionStream(
        path: MyPath.refunds(uid),
        builder: (map) => Refund.fromMap(map),
        queryBuilder: (query) =>
            query.where('status', isEqualTo: 'new_demand'));
  }

  Future<void> setNewRefund(Refund refund, String organisateur) async {
    return await _service.setData(
        path: MyPath.refund(organisateur, refund.id), data: refund.toMap());
  }

  Stream<List<Refund>> getRefusedRefund() {
    return _service.collectionStream(
        path: MyPath.refunds(uid),
        builder: (map) => Refund.fromMap(map),
        queryBuilder: (query) => query.where('status', isEqualTo: 'refused'));
  }

  Future<void> setRefundRefused(Refund refund) async {
    return await _service.updateData(
        path: MyPath.refund(uid, refund.id), data: {'status': 'refused'});
  }

  Future<List<Refund>> refundListFromFirestore() async {
    return await _service.collectionFuture(
        path: MyPath.refunds(uid),
        queryBuilder: (query)=>query.where('stripeId',isGreaterThan: ''),
        builder: (map) => Refund.fromMap(map));
  }

  Future<void> setRefundFromStripe(Refund myRefund, String id) async {
    return await _service.setData(
        path: MyPath.refund(uid, id), data: myRefund.toMap());
  }
}
