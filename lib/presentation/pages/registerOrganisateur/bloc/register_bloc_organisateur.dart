import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/bloc/register_event_organisateur.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/bloc/register_state_organisateur.dart';
import 'package:van_events_project/providers/authentication_cubit/authentication_cubit.dart';
import 'package:van_events_project/providers/toggle_bool_chat_room.dart';


class RegisterBlocOrganisateur
    extends Bloc<RegisterEventOrganisateur, RegisterStateOrganisateur> {
  final BuildContext _context;

  RegisterBlocOrganisateur(this._context) : super(null);

  @override
  RegisterStateOrganisateur get initialState =>
      RegisterStateOrganisateur.initial();

  @override
  Stream<RegisterStateOrganisateur> mapEventToState(
    RegisterEventOrganisateur event,
  ) async* {
    if (event is RegisterSubmitted) {
      yield* _mapRegisterSubmittedToState(
          event.nomSociete,
          event.email,
          event.supportEmail,
          event.phone,
          event.url,
          event.city,
          event.line1,
          event.line2,
          event.postal_code,
          event.state,
          event.account_holder_name,
          event.account_holder_type,
          event.account_number,
          event.business_type,
          event.password,
          event.nom,
          event.prenom,
          event.SIREN,
          event.date_of_birth, event.boolToggleRead,event.stripeRepository,event.myUserRepository);
    }
  }

  Stream<RegisterStateOrganisateur> _mapRegisterSubmittedToState(
      String nomSociete,
      String email,
      String supportEmail,
      String phone,
      String url,
      String city,
      String line1,
      String line2,
      String postal_code,
      String state,
      String account_holder_name,
      String account_holder_type,
      String account_number,
      String business_type,
      String password,
      String nom,
      String prenom,
      String SIREN,
      String date_of_birth,
      BoolToggle boolToggleRead,
      StripeRepository stripeRepository,MyUserRepository myUserRepository) async* {
    yield RegisterStateOrganisateur.loading();

    print('RegisterStateOrganisateur');

    HttpsCallableResult stripeRep =
        await stripeRepository
            .createStripeAccount(
                nomSociete,
                email,
                supportEmail,
                phone,
                url,
                city,
                line1,
                line2,
                postal_code,
                state,
                account_holder_name,
                account_holder_type,
                account_number,
                business_type,
                password,
                nom,
                prenom,
                SIREN,
                date_of_birth);

    if (stripeRep != null) {
      print(stripeRep.data['stripeAccount']);

      String rep = await myUserRepository.signUp(
          image: boolToggleRead.imageProfil,
          email: email,
          password: password,
          typeDeCompte: TypeOfAccount.organizer,
          stripeAccount: stripeRep.data['stripeAccount'],
          person: stripeRep.data['person'],
          nomPrenom: prenom + ' ' + nom);
      print(rep);

      if (rep == 'Un email de validation a été envoyé') {
        yield RegisterStateOrganisateur.success(rep);
      } else {


        try {
          final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
            functionName: 'deleteStripeAccount',
          );
          await callable.call(
            <String, dynamic>{
              'stripeAccount': stripeRep.data['stripeAccount'],
            },
          );
        } on CloudFunctionsException catch (e) {
          print(e);
        } catch (e) {
          print(e);
        }

        yield RegisterStateOrganisateur.failure(
            'Impossible de créer le compte');
      }
    } else {
      yield RegisterStateOrganisateur.failure(
          'Impossible de créer le compte stripe');
    }
  }
}
