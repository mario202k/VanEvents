class Payout {
  String id;
  String object;
  int amount;
  int arrivalDate;
  bool automatic;
  String balanceTransaction;
  int created;
  String currency;
  String description;
  String destination;
  dynamic failureBalanceTransaction;
  dynamic failureCode;
  dynamic failureMessage;
  bool livemode;

  String method;
  String sourceType;
  dynamic statementDescriptor;
  String status;
  String type;

  static Payout fromMap(Map map) {
    if (map == null) return null;
    Payout payout = Payout();
    payout.id = map['id'];
    payout.object = map['object'];
    payout.amount = map['amount'];
    payout.arrivalDate = map['arrival_date'];
    payout.automatic = map['automatic'];
    payout.balanceTransaction = map['balance_transaction'];
    payout.created = map['created'];
    payout.currency = map['currency'];
    payout.description = map['description'];
    payout.destination = map['destination'];
    payout.failureBalanceTransaction = map['failure_balance_transaction'];
    payout.failureCode = map['failure_code'];
    payout.failureMessage = map['failure_message'];
    payout.livemode = map['livemode'];
    payout.method = map['method'];
    payout.sourceType = map['source_type'];
    payout.statementDescriptor = map['statement_descriptor'];
    payout.status = map['status'];
    payout.type = map['type'];
    return payout;
  }

  Map toJson() => {
    "id": id,
    "object": object,
    "amount": amount,
    "arrival_date": arrivalDate,
    "automatic": automatic,
    "balance_transaction": balanceTransaction,
    "created": created,
    "currency": currency,
    "description": description,
    "destination": destination,
    "failure_balance_transaction": failureBalanceTransaction,
    "failure_code": failureCode,
    "failure_message": failureMessage,
    "livemode": livemode,
    "method": method,
    "source_type": sourceType,
    "statement_descriptor": statementDescriptor,
    "status": status,
    "type": type,
  };
}
