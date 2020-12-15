import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe_payment/flutter_stripe_payment.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/constants/credentials.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';

final stripeRepositoryProvider = Provider<StripeRepository>((ref) {
  return StripeRepository(ref.watch(myUserProvider).id);
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

  Future<dynamic> paymentIntentBillet(double amount, String stripeAccount,
      String description, int length) async {
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
        final HttpsCallable callablePaymentIntent =
            FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
          'paymentIntent',
        );
        intentResponse = await callablePaymentIntent.call(
          <String, dynamic>{
            'amount': (amount).toInt(),
            'stripeAccount': stripeAccount,
            'description': description,
            'paymentMethodId': paymentMethodId,
            'nbParticipant': length
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

  Future<dynamic> paymentIntentVtc(double amount, String description) async {
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
        final HttpsCallable callablePaymentIntent =
            FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
          'paymentIntent',
        );
        intentResponse = await callablePaymentIntent.call(
          <String, dynamic>{
            'amount': (amount).toInt(),
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
        final HttpsCallable callablePaymentIntent =
            FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
          'paymentIntentUploadEvents',
        );
        intentResponse = await callablePaymentIntent.call(
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
      String fileName, String stripeAccount, String person) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'uploadFileToStripe',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'fileName': fileName,
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
      String url,
      String city,
      String line1,
      String line2,
      String postalCode,
      String state,
      String accountHolderName,
      String accountNumber,
      String password,
      String nom,
      String prenom,
      String siren,
      String dateOfBirth) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callablePaymentIntent =
          FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
        'createStripeAccount',
      );
      stripeResponse = await callablePaymentIntent.call(
        <String, dynamic>{
          'nomSociete': nomSociete,
          'email': email,
          'support_email': supportEmail,
          'phone': phone,
          'url': url,
          'city': city,
          'line1': line1,
          'line2': line2,
          'postal_code': postalCode,
          'state': state,
          'account_holder_name': accountHolderName,
          'account_holder_type': 'company',
          'account_number': accountNumber,
          'business_type': 'company',
          'password': password,
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

  Future setUrlFront(String url) async {
    return _service.updateData(path: Path.user(uid), data: {'idRectoUrl': url});
  }

  Future setUrlBack(String url) async {
    return _service.updateData(path: Path.user(uid), data: {'idVersoUrl': url});
  }

  Future setUrljustificatifDomicile(String url) {
    return _service
        .updateData(path: Path.user(uid), data: {'proofOfAddress': url});
  }
}
