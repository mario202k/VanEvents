import 'package:meta/meta.dart';

@immutable
class LoginState {

  final bool isSubmitting;
  final bool isSuccess;
  final bool isFirstLogin;
  final bool isFailure;
  final String rep;


  LoginState({

    @required this.isSubmitting,
    @required this.isSuccess,
    @required this.isFirstLogin,
    @required this.isFailure,
    this.rep
  });

  factory LoginState.initial() {
    return LoginState(
      isSubmitting: false,
      isSuccess: false,
      isFirstLogin: false,
      isFailure: false,
    );
  }

  factory LoginState.loading() {
    return LoginState(
      isSubmitting: true,
      isSuccess: false,
      isFirstLogin: false,
      isFailure: false,
    );
  }

  factory LoginState.failure(String rep) {
    return LoginState(
      isSubmitting: false,
      isSuccess: false,
      isFirstLogin: false,
      isFailure: true,
      rep: rep,
    );
  }

  factory LoginState.success() {
    return LoginState(
      isSubmitting: false,
      isSuccess: true,
      isFirstLogin: false,
      isFailure: false,
    );
  }


  @override
  String toString() {
    return 'LoginState{isSubmitting: $isSubmitting, isSuccess: $isSuccess, isFirstLogin: $isFirstLogin, isFailure: $isFailure, rep: $rep}';
  }
}
