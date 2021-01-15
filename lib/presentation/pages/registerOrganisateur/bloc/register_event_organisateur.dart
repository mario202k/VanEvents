import 'package:equatable/equatable.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/providers/toggle_bool.dart';

abstract class RegisterEventOrganisateur extends Equatable {
  const RegisterEventOrganisateur();

  @override
  List<Object> get props => [];
}

class RegisterSubmitted extends RegisterEventOrganisateur {
  final String nomSociete;
  final String email;
  final String supportEmail;
  final String phone;
  final String url;
  final String city;
  final String line1;
  final String line2;
  final String postal_code;
  final String state;
  final String account_holder_name;
  final String account_number;
  final String password;
  final String nom;
  final String prenom;
  final String SIREN;
  final String date_of_birth;
  final BoolToggle boolToggleRead;
  final StripeRepository stripeRepository;
  final MyUserRepository myUserRepository;

  RegisterSubmitted(
      {this.nomSociete,
      this.email,
      this.supportEmail,
      this.phone,
      this.url,
      this.city,
      this.line1,
      this.line2,
      this.postal_code,
      this.state,
      this.account_holder_name,
      this.account_number,
      this.password,
      this.nom,
      this.prenom,
      this.SIREN,
      this.date_of_birth,
      this.boolToggleRead,this.stripeRepository,this.myUserRepository});

  @override
  List<Object> get props => [
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
        account_number,
        password,
        nom,
        prenom,
        SIREN,
        date_of_birth
      ];

  @override
  String toString() {
    return 'RegisterSubmitted{nomSociete: $nomSociete, email: $email, supportEmail: $supportEmail, phone: $phone, url: $url, city: $city, line1: $line1, line2: $line2, postal_code: $postal_code, state: $state, account_holder_name: $account_holder_name, account_number: $account_number, password: $password, nom: $nom, prenom: $prenom, SIREN: $SIREN, date_of_birth: $date_of_birth, boolToggleRead: $boolToggleRead, stripeRepository: $stripeRepository, myUserRepository: $myUserRepository}';
  }
}
