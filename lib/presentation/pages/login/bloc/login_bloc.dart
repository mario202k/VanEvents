import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/presentation/pages/login/bloc/bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  LoginBloc() : super(LoginState.initial());


  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginWithGooglePressed) {
      yield* _mapLoginWithGooglePressedToState(event.myUserRepository);
    } else if (event is LoginWithCredentialsPressed) {
      yield* _mapLoginWithCredentialsPressedToState(
        email: event.email,
        password: event.password,
        myUserRepository: event.myUserRepository
      );
    }else if(event is LoginWithAnonymous){
      yield* _mapLoginWithAnonymous(event.myUserRepository);
    }else if(event is LoginWithApplePressed){
      yield* _mapLoginWithApplePressedToState(event.myUserRepository);
    }
  }

  Stream<LoginState> _mapLoginWithGooglePressedToState(MyUserRepository myUserRepository) async* {
    try {

      final UserCredential authResult =
          await myUserRepository.signInWithGoogle();


      await myUserRepository
          .createOrUpdateUserOnDatabase(authResult.user);

      yield LoginState.success();

    } catch (e) {
      debugPrint(e.toString());
      yield LoginState.failure('Impossible de se connecter');
    }
  }

  Stream<LoginState> _mapLoginWithApplePressedToState(MyUserRepository myUserRepository) async* {
    try {

      final UserCredential authResult =
      await myUserRepository.signInWithApple();

      await myUserRepository
          .createOrUpdateUserOnDatabase(authResult.user);

      yield LoginState.success();

    } catch (e) {

      yield LoginState.failure('Impossible de se connecter');
    }
  }

  Stream<LoginState> _mapLoginWithCredentialsPressedToState({
    String email,
    String password,
    MyUserRepository myUserRepository
  }) async* {
    yield LoginState.loading();
    try {
      final UserCredential authResult = await myUserRepository
          .signInWithCredentials(email, password);


      if (authResult.user.emailVerified) {
        await myUserRepository
            .createOrUpdateUserOnDatabase(authResult.user);

        yield LoginState.success();
      } else {
        yield LoginState.failure('Email non vérifié');
      }
    } catch (e) {
      yield LoginState.failure('Impossible de se connecter');
    }
  }

  Stream<LoginState> _mapLoginWithAnonymous(MyUserRepository myUserRepository) async* {
    yield LoginState.loading();
    try {

      final UserCredential authResult = await myUserRepository.loginAnonymous();

      await myUserRepository
          .createOrUpdateUserOnDatabase(authResult.user);


      yield LoginState.success();
    } catch (e) {
      yield LoginState.failure('Impossible de se connecter');
    }
  }
}
