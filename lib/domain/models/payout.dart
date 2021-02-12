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

  Payout(
      {this.id,
      this.object,
      this.amount,
      this.arrivalDate,
      this.automatic,
      this.balanceTransaction,
      this.created,
      this.currency,
      this.description,
      this.destination,
      this.failureBalanceTransaction,
      this.failureCode,
      this.failureMessage,
      this.livemode,
      this.method,
      this.sourceType,
      this.statementDescriptor,
      this.status,
      this.type});

  factory Payout.fromMap(dynamic map) {
    if (null == map) return null;
    var temp;
    return Payout(
      id: map['id']?.toString(),
      object: map['object']?.toString(),
      amount: null == (temp = map['amount'])
          ? null
          : (temp is num ? temp.toInt() : int.tryParse(temp as String)),
      arrivalDate: null == (temp = map['arrivalDate'])
          ? null
          : (temp is num ? temp.toInt() : int.tryParse(temp as String)),
      automatic: null == (temp = map['automatic'])
          ? null
          : (temp is bool
              ? temp
              : (temp is num
                  ? 0 != temp.toInt()
                  : ('true' == temp.toString()))),
      balanceTransaction: map['balanceTransaction']?.toString(),
      created: null == (temp = map['created'])
          ? null
          : (temp is num ? temp.toInt() : int.tryParse(temp as String)),
      currency: map['currency']?.toString(),
      description: map['description']?.toString(),
      destination: map['destination']?.toString(),
      failureBalanceTransaction: map['failureBalanceTransaction'],
      failureCode: map['failureCode'],
      failureMessage: map['failureMessage'],
      livemode: null == (temp = map['livemode'])
          ? null
          : (temp is bool
              ? temp
              : (temp is num
                  ? 0 != temp.toInt()
                  : ('true' == temp.toString()))),
      method: map['method']?.toString(),
      sourceType: map['sourceType']?.toString(),
      statementDescriptor: map['statementDescriptor'],
      status: map['status']?.toString(),
      type: map['type']?.toString(),
    );
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
