import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/bloc/register_event_organisateur.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/bloc/register_state_organisateur.dart';
import 'package:van_events_project/providers/toggle_bool.dart';


class RegisterBlocOrganisateur
    extends Bloc<RegisterEventOrganisateur, RegisterStateOrganisateur> {

  String nom;
  String prenom;
  String dateOfBirth;
  String email;
  String password;

  RegisterBlocOrganisateur() : super(null);


  @override
  Stream<RegisterStateOrganisateur> mapEventToState(
    RegisterEventOrganisateur event,
  ) async* {
    if (event is RegisterSubmitted) {
      yield* _mapRegisterSubmittedToState(
          event.nomSociete,
          email,
          event.supportEmail,
          event.phone,
          event.city,
          event.line1,
          event.line2,
          event.postalCode,
          event.state,
          event.accountHolderName,
          event.accountNumber,
          password,
          nom,
          prenom,
          event.siren,
          dateOfBirth, event.boolToggleRead,event.stripeRepository,event.myUserRepository);
    }
  }

  Stream<RegisterStateOrganisateur> _mapRegisterSubmittedToState(
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
      String password,
      String nom,
      String prenom,
      String siren,
      String dateOfBirth,
      BoolToggle boolToggleRead,
      StripeRepository stripeRepository,MyUserRepository myUserRepository) async* {
    yield RegisterStateOrganisateur.loading();

    final HttpsCallableResult stripeRep =
        await stripeRepository
            .createStripeAccount(
                nomSociete,
                email,
                supportEmail,
                phone,
                city,
                line1,
                line2,
                postalCode,
                state,
                accountHolderName,
                accountNumber,
                nom,
                prenom,
                siren,
                dateOfBirth);

    if (stripeRep != null) {

      final String rep = await myUserRepository.signUp(
          image: boolToggleRead.imageProfil,
          email: email,
          password: password,
          typeDeCompte: TypeOfAccount.organizer,
          stripeAccount: stripeRep.data['stripeAccount'] as String,
          person: stripeRep.data['person'] as String,
          nomPrenom: '$prenom $nom');

      if (rep == 'Un email de validation a été envoyé') {
        yield RegisterStateOrganisateur.success(rep);
      } else {

        stripeRepository.deleteStripeAccount(stripeRep.data['stripeAccount'] as String);

        yield RegisterStateOrganisateur.failure(rep);
      }
    } else {
      yield RegisterStateOrganisateur.failure(
          'Impossible de créer le compte stripe');
    }
  }

  void aboutYou({String nom, String prenom, String dateOfBirth, String email, String password}) {
    this.nom = nom;
    this.prenom = prenom;
    this.dateOfBirth = dateOfBirth;
    this.email = email;
    this.password = password;
  }
}
