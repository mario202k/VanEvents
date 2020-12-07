import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:van_events_project/domain/models/balance.dart';
import 'package:van_events_project/domain/models/connected_account.dart';
import 'package:van_events_project/domain/models/listPayout.dart';
import 'package:van_events_project/domain/models/listTransfer.dart';
import 'package:van_events_project/domain/models/person.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';

part 'stripe_profile_state.dart';

class StripeProfileCubit extends Cubit<StripeProfileState> {
  final BuildContext _context;

  StripeProfileCubit(this._context) : super(StripeProfileInitial());

  void fetchStripeProfile(String stripeAccount, String person) async {
    emit(StripeProfileLoading());
    final stripeRepo = _context
        .read(stripeRepositoryProvider);

    HttpsCallableResult httpsCallableResultPayoutList = await stripeRepo
        .payoutList(stripeAccount);

    HttpsCallableResult httpsCallableResultTransfersList = await stripeRepo
        .transfersList(stripeAccount);

    HttpsCallableResult httpsCallableResultAccount = await stripeRepo
        .retrieveStripeAccount(stripeAccount);
    HttpsCallableResult httpsCallableResultBalance = await stripeRepo
        .organisateurBalance(stripeAccount);
    HttpsCallableResult httpsCallableResultPerson = await stripeRepo
        .retrievePerson(stripeAccount, person);

    if (httpsCallableResultAccount == null ||
        httpsCallableResultBalance == null ||
        httpsCallableResultPerson == null ||
        httpsCallableResultPayoutList == null ||
        httpsCallableResultTransfersList == null) {
      emit(StripeProfileFailed('Impossible de charger le profil'));
      return;
    }
    print(httpsCallableResultTransfersList.data);

    emit(StripeProfileSuccess(
        payoutList: ListPayout.fromMap(httpsCallableResultPayoutList.data),
        result: ConnectedAccount.fromMap(httpsCallableResultAccount.data),
        balance: Balance.fromMap(httpsCallableResultBalance.data),
        person: Person.fromMap(httpsCallableResultPerson.data),
        transferList:
            ListTransfer.fromMap(httpsCallableResultTransfersList.data)));
  }
}
