import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationLoading());

  Future<void> authenticationStarted(
      MyUserRepository myUserRepository, BuildContext context) async {
    emit(AuthenticationLoading());

    // myUserRepository.signOut();

    await myUserRepository.checkDynamicLinkData(context);
    final isSignedIn = await myUserRepository.isSignedIn();
    if (isSignedIn) {
      final firebaseUser = myUserRepository.getFireBaseUser();

      final user = await myUserRepository.getMyUser(firebaseUser.uid);

      if (user != null && !user.hasAcceptedCGUCGV) {
        emit(AuthenticationCGUCGV(firebaseUser));
      } else {
        emit(AuthenticationSuccess(firebaseUser, user));
      }
    } else {
      emit(AuthenticationFailure(
          seenOnboarding:
              (await SharedPreferences.getInstance()).getBool('seen') ??
                  false));
    }
  }

  Future<void> authenticationLoggedIn(MyUserRepository myUserRepository) async {
    try {
      final firebaseUser = myUserRepository.getFireBaseUser();
      final user = await myUserRepository.getMyUser(firebaseUser.uid);

      if (user != null && !user.hasAcceptedCGUCGV) {
        emit(AuthenticationCGUCGV(firebaseUser));
      } else {
        emit(AuthenticationSuccess(firebaseUser, user));
      }
    } catch (e) {
      emit(AuthenticationFailure(
          seenOnboarding:
              (await SharedPreferences.getInstance()).getBool('seen') ??
                  false));
    }
  }

  Future<void> authenticationLoggedOut(
      MyUserRepository myUserRepository) async {
    emit(AuthenticationFailure(
        seenOnboarding:
            (await SharedPreferences.getInstance()).getBool('seen') ?? false));
    myUserRepository.signOut();
  }

  void authenticationEmailLinkSuccess(String myEmail) {
    emit(AuthenticationEmailLinkSuccess(myEmail));
  }
}
