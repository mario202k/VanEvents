class BankAccount {
  String id;
  String object;
  String account;
  String accountHolderName;
  String accountHolderType;
  List<String> availablePayoutMethods;
  String bankName;
  String country;
  String currency;
  String fingerprint;
  String last4;
  String routingNumber;
  String status;


  BankAccount({
      this.id,
      this.object,
      this.account,
      this.accountHolderName,
      this.accountHolderType,
      this.availablePayoutMethods,
      this.bankName,
      this.country,
      this.currency,
      this.fingerprint,
      this.last4,
      this.routingNumber,
      this.status});

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      id: map['id'] as String,
      object: map['object'] as String,
      account: map['account'] as String,
      accountHolderName: map['accountHolderName'] as String,
      accountHolderType: map['accountHolderType'] as String,
      availablePayoutMethods: map['availablePayoutMethods'] as List<String>,
      bankName: map['bankName'] as String,
      country: map['country'] as String,
      currency: map['currency'] as String,
      fingerprint: map['fingerprint'] as String,
      last4: map['last4'] as String,
      routingNumber: map['routingNumber'] as String,
      status: map['status'] as String,
    );
  }



  Map toJson() => {
    "id": id,
    "object": object,
    "account": account,
    "account_holder_name": accountHolderName,
    "account_holder_type": accountHolderType,
    "available_payout_methods": availablePayoutMethods,
    "bank_name": bankName,
    "country": country,
    "currency": currency,
    "fingerprint": fingerprint,
    "last4": last4,
    "routing_number": routingNumber,
    "status": status,
  };
}
