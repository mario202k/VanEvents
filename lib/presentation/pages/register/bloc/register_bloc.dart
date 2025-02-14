import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/presentation/pages/register/bloc/bloc.dart';
import 'package:van_events_project/providers/toggle_bool.dart';


class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {

  RegisterBloc() : super(null);

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is RegisterSubmitted) {
      yield* _mapRegisterSubmittedToState(
          event.prenomNom, event.email, event.password, event.boolToggleRead,event.myUserRepository);
    }
  }

  Stream<RegisterState> _mapRegisterSubmittedToState(
    String nomPrenom,
    String email,
    String password,
    BoolToggle boolToggleRead,
      MyUserRepository myUserRepository
  ) async* {
    yield RegisterState.loading();

    final String rep = await myUserRepository
        .signUp(
            image: boolToggleRead.imageProfil,
            email: email,
            password: password,
            nomPrenom: nomPrenom,
            typeDeCompte: TypeOfAccount.userNormal);

    if (rep == 'Un email de validation a été envoyé') {
      yield RegisterState.success(rep);
    } else {
      yield RegisterState.failure(rep);
    }
  }
}
