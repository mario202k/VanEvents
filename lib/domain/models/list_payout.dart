class ListPayout {
  String object;
  String url;
  bool hasMore;
  List data;


  ListPayout({this.object, this.url, this.hasMore, this.data});

  factory ListPayout.fromMap(Map map) {
    return ListPayout(
      object: map['object'] as String,
      url: map['url'] as String,
      hasMore: map['hasMore'] as bool,
      data: map['data'] as List,
    );
  }

  Map toJson() => {
    "object": object,
    "url": url,
    "has_more": hasMore,
    "data": data,
  };
}

class Data {
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


  Data({
      this.id,
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

  factory Data.fromMap(Map<String, dynamic> map) {
    return Data(
      id: map['id'] as String,
      object: map['object'] as String,
      amount: map['amount'] as int,
      arrivalDate: map['arrivalDate'] as int,
      automatic: map['automatic'] as bool,
      balanceTransaction: map['balanceTransaction'] as String,
      created: map['created'] as int,
      currency: map['currency'] as String,
      description: map['description'] as String,
      destination: map['destination'] as String,
      failureBalanceTransaction: map['failureBalanceTransaction'] as dynamic,
      failureCode: map['failureCode'] as dynamic,
      failureMessage: map['failureMessage'] as dynamic,
      livemode: map['livemode'] as bool,
      method: map['method'] as String,
      sourceType: map['sourceType'] as String,
      statementDescriptor: map['statementDescriptor'] as dynamic,
      status: map['status'] as String,
      type: map['type'] as String,
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
