
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationLoading());

  void authenticationStarted(MyUserRepository myUserRepository, BuildContext context) async {
    print('authenticationStarted');
    emit(AuthenticationLoading());

    final userCredential = await myUserRepository.checkDynamicLinkData(context);
    final isSignedIn = userCredential != null? true:await myUserRepository.isSignedIn();
    if (isSignedIn) {
      final firebaseUser =  myUserRepository.getFireBaseUser();

      final user = await myUserRepository.getMyUser(firebaseUser.uid);

      if (user != null && !user.hasAcceptedCGUCGV ) {
        emit(AuthenticationCGUCGV(firebaseUser));
      } else {

        emit(AuthenticationSuccess(firebaseUser, user));
      }
    } else {

      emit(AuthenticationFailure(
          (await SharedPreferences.getInstance()).getBool('seen') ?? false));
    }
  }

  void authenticationLoggedIn(MyUserRepository myUserRepository) async {
    try {
      final firebaseUser =  myUserRepository.getFireBaseUser();
      final user = await myUserRepository.getMyUser(firebaseUser.uid);

      if (user != null && !user.hasAcceptedCGUCGV) {
        emit(AuthenticationCGUCGV(firebaseUser));
      } else {
        emit(AuthenticationSuccess(firebaseUser, user));
      }
    } catch (e) {
      emit(AuthenticationFailure(
          (await SharedPreferences.getInstance()).getBool('seen') ?? false));
    }
  }

  void authenticationLoggedOut(MyUserRepository myUserRepository) async {
    emit(AuthenticationFailure(
        (await SharedPreferences.getInstance()).getBool('seen') ?? false));
    myUserRepository.signOut();
  }
}
