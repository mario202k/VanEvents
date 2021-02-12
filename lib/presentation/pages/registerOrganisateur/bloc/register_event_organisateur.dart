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
  final String supportEmail;
  final String phone;
  final String city;
  final String line1;
  final String line2;
  final String postalCode;
  final String state;
  final String accountHolderName;
  final String accountNumber;
  final String siren;
  final String dateOfBirth;
  final BoolToggle boolToggleRead;
  final StripeRepository stripeRepository;
  final MyUserRepository myUserRepository;

  const RegisterSubmitted(
      {this.nomSociete,
      this.supportEmail,
      this.phone,
      this.city,
      this.line1,
      this.line2,
      this.postalCode,
      this.state,
      this.accountHolderName,
      this.accountNumber,
      this.siren,
      this.dateOfBirth,
      this.boolToggleRead,this.stripeRepository,this.myUserRepository});

  @override
  List<Object> get props => [
        nomSociete,
        supportEmail,
        phone,
        city,
        line1,
        line2,
        postalCode,
        state,
        accountHolderName,
        accountNumber,
        siren,
        dateOfBirth
      ];

  @override
  String toString() {
    return 'RegisterSubmitted{nomSociete: $nomSociete, supportEmail: $supportEmail, phone: $phone, city: $city, line1: $line1, line2: $line2, postal_code: $postalCode, state: $state, account_holder_name: $accountHolderName, account_number: $accountNumber, SIREN: $siren, date_of_birth: $dateOfBirth, boolToggleRead: $boolToggleRead, stripeRepository: $stripeRepository, myUserRepository: $myUserRepository}';
  }
}
