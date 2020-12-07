part of 'authentication_cubit.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {
  final User firebaseUser;
  final MyUser myUser;

  const AuthenticationSuccess(this.firebaseUser,this.myUser);

  @override
  List<Object> get props => [firebaseUser,myUser];

  @override
  String toString() => 'Authenticated { displayName: $firebaseUser }';
}

class AuthenticationCGUCGV extends AuthenticationState {

  final User firebaseUser;

  const AuthenticationCGUCGV(this.firebaseUser);

  @override
  List<Object> get props => [firebaseUser];

  @override
  String toString() => 'Authenticated { displayName: $firebaseUser }';

}

class AuthenticationFailure extends AuthenticationState {
  final bool seenOnboarding;

  const AuthenticationFailure(this.seenOnboarding);

  @override
  List<Object> get props => [seenOnboarding];

  @override
  String toString() {
    return 'AuthenticationFailure{seenOnboarding: $seenOnboarding}';
  }
}
