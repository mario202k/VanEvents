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

  static BankAccount fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    BankAccount bankAccount = BankAccount();
    bankAccount.id = map['id'];
    bankAccount.object = map['object'];
    bankAccount.account = map['account'];
    bankAccount.accountHolderName = map['account_holder_name'];
    bankAccount.accountHolderType = map['account_holder_type'];
    bankAccount.availablePayoutMethods = List()..addAll(
      (map['available_payout_methods'] as List ?? []).map((o) => o.toString())
    );
    bankAccount.bankName = map['bank_name'];
    bankAccount.country = map['country'];
    bankAccount.currency = map['currency'];
    bankAccount.fingerprint = map['fingerprint'];
    bankAccount.last4 = map['last4'];
    bankAccount.routingNumber = map['routing_number'];
    bankAccount.status = map['status'];
    return bankAccount;
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
