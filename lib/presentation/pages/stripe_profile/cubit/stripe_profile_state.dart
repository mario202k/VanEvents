part of 'stripe_profile_cubit.dart';

@immutable
abstract class StripeProfileState extends Equatable {
  @override
  List<Object> get props => [];
}

class StripeProfileInitial extends StripeProfileState {

}
class StripeProfileLoading extends StripeProfileState {

}
class StripeProfileSuccess extends StripeProfileState {
  final ConnectedAccount result;
  final Balance balance;
  final Person person;
  final ListPayout payoutList;
  final ListTransfer transferList;
  StripeProfileSuccess({this.result,this.balance,this.person,this.payoutList,this.transferList});

  @override
  // TODO: implement props
  List<Object> get props => [result];
}

class StripeProfileFailed extends StripeProfileState {
  final String message;

  StripeProfileFailed(this.message);
}