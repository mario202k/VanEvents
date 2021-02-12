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

  Transfer(
      {this.id,
      this.object,
      this.amount,
      this.amountReversed,
      this.balanceTransaction,
      this.created,
      this.currency,
      this.description,
      this.destination,
      this.destinationPayment,
      this.livemode,
      this.reversals,
      this.reversed,
      this.sourceTransaction,
      this.sourceType,
      this.transferGroup});

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

  factory Transfer.fromMap(dynamic map) {
    if (null == map) return null;
    var temp;
    return Transfer(
      id: map['id']?.toString(),
      object: map['object']?.toString(),
      amount: null == (temp = map['amount'])
          ? null
          : (temp is num ? temp.toInt() : int.tryParse(temp as String)),
      amountReversed: null == (temp = map['amountReversed'])
          ? null
          : (temp is num ? temp.toInt() : int.tryParse(temp as String)),
      balanceTransaction: map['balanceTransaction']?.toString(),
      created: null == (temp = map['created'])
          ? null
          : (temp is num ? temp.toInt() : int.tryParse(temp as String)),
      currency: map['currency']?.toString(),
      description: map['description'],
      destination: map['destination']?.toString(),
      destinationPayment: map['destinationPayment']?.toString(),
      livemode: null == (temp = map['livemode'])
          ? null
          : (temp is bool
              ? temp
              : (temp is num
                  ? 0 != temp.toInt()
                  : ('true' == temp.toString()))),
      reversals: Reversals.fromMap(map['reversals'] as Map<String, dynamic>),
      reversed: null == (temp = map['reversed'])
          ? null
          : (temp is bool
              ? temp
              : (temp is num
                  ? 0 != temp.toInt()
                  : ('true' == temp.toString()))),
      sourceTransaction: map['sourceTransaction']?.toString(),
      sourceType: map['sourceType']?.toString(),
      transferGroup: map['transferGroup']?.toString(),
    );
  }
}

class Reversals {
  String object;
  List<dynamic> data;
  bool hasMore;
  String url;

  Reversals({this.object, this.data, this.hasMore, this.url});

  factory Reversals.fromMap(dynamic map) {
    if (null == map) return null;
    var temp;
    return Reversals(
      object: map['object']?.toString(),
      data: null == (temp = map['data'])
          ? []
          : (temp is List ? temp.map((map) => map).toList() : []),
      hasMore: null == (temp = map['hasMore'])
          ? null
          : (temp is bool
              ? temp
              : (temp is num
                  ? 0 != temp.toInt()
                  : ('true' == temp.toString()))),
      url: map['url']?.toString(),
    );
  }

  Map toJson() => {
        "object": object,
        "data": data,
        "has_more": hasMore,
        "url": url,
      };
}
