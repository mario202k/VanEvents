import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/providers/toggle_bool.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final String prenomNom;
  final String email;
  final String password;
  final BoolToggle boolToggleRead;
  final MyUserRepository myUserRepository;

  const RegisterSubmitted({
    @required this.prenomNom,
    @required this.email,
    @required this.password,
    @required this.boolToggleRead,
    @required this.myUserRepository
  });

  @override
  List<Object> get props => [prenomNom,email, password];

  @override
  String toString() {
    return 'Submitted { email: $email, password: $password }';
  }
}
