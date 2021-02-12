import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginWithGooglePressed extends LoginEvent {
  final MyUserRepository myUserRepository;

  const LoginWithGooglePressed(this.myUserRepository);
}

class LoginWithApplePressed extends LoginEvent {
  final MyUserRepository myUserRepository;

  const LoginWithApplePressed(this.myUserRepository);
}

class LoginWithAnonymous extends LoginEvent {
  final MyUserRepository myUserRepository;

  const LoginWithAnonymous(this.myUserRepository);
}

class LoginWithCredentialsPressed extends LoginEvent {
  final String email;
  final String password;
  final MyUserRepository myUserRepository;

  const LoginWithCredentialsPressed({
    @required this.email,
    @required this.password,
    @required this.myUserRepository

  });

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'LoginWithCredentialsPressed { email: $email, password: $password }';
  }
}
