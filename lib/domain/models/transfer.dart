class Transfer {
  String id;
  String object;
  int amount;
  int amountReversed;
  String balanceTransaction;
  int created;
  String currency;
  dynamic description;
  String destination;
  String destinationPayment;
  bool livemode;

  Reversals reversals;
  bool reversed;
  String sourceTransaction;
  String sourceType;
  String transferGroup;

  static Transfer fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    Transfer transfer = Transfer();
    transfer.id = map['id'];
    transfer.object = map['object'];
    transfer.amount = map['amount'];
    transfer.amountReversed = map['amount_reversed'];
    transfer.balanceTransaction = map['balance_transaction'];
    transfer.created = map['created'];
    transfer.currency = map['currency'];
    transfer.description = map['description'];
    transfer.destination = map['destination'];
    transfer.destinationPayment = map['destination_payment'];
    transfer.livemode = map['livemode'];
    transfer.reversals = Reversals.fromMap(map['reversals']);
    transfer.reversed = map['reversed'];
    transfer.sourceTransaction = map['source_transaction'];
    transfer.sourceType = map['source_type'];
    transfer.transferGroup = map['transfer_group'];
    return transfer;
  }

  Map toJson() => {
    "id": id,
    "object": object,
    "amount": amount,
    "amount_reversed": amountReversed,
    "balance_transaction": balanceTransaction,
    "created": created,
    "currency": currency,
    "description": description,
    "destination": destination,
    "destination_payment": destinationPayment,
    "livemode": livemode,

    "reversals": reversals,
    "reversed": reversed,
    "source_transaction": sourceTransaction,
    "source_type": sourceType,
    "transfer_group": transferGroup,
  };
}

class Reversals {
  String object;
  List<dynamic> data;
  bool hasMore;
  String url;

  static Reversals fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    Reversals reversals = Reversals();
    reversals.object = map['object'];
    reversals.data = map['data'];
    reversals.hasMore = map['has_more'];
    reversals.url = map['url'];
    return reversals;
  }

  Map toJson() => {
    "object": object,
    "data": data,
    "has_more": hasMore,
    "url": url,
  };
}
