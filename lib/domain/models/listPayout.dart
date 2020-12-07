class ListPayout {
  String object;
  String url;
  bool hasMore;
  List<Data> data;

  static ListPayout fromMap(Map map) {
    if (map == null) return null;

    ListPayout listPayout = ListPayout();
    listPayout.object = map['object'];
    listPayout.url = map['url'];
    listPayout.hasMore = map['has_more'];
    listPayout.data = List()..addAll(
      (map['data'] as List ?? []).map((o) => Data.fromMap(o))
    );

    return listPayout;
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

  static Data fromMap(Map map) {
    if (map == null) return null;
    Data data = Data();
    data.id = map['id'];
    data.object = map['object'];
    data.amount = map['amount'];
    data.arrivalDate = map['arrival_date'];
    data.automatic = map['automatic'];
    data.balanceTransaction = map['balance_transaction'];
    data.created = map['created'];
    data.currency = map['currency'];
    data.description = map['description'];
    data.destination = map['destination'];
    data.failureBalanceTransaction = map['failure_balance_transaction'];
    data.failureCode = map['failure_code'];
    data.failureMessage = map['failure_message'];
    data.livemode = map['livemode'];
    data.method = map['method'];
    data.sourceType = map['source_type'];
    data.statementDescriptor = map['statement_descriptor'];
    data.status = map['status'];
    data.type = map['type'];
    return data;
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
