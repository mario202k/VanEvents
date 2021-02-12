class Balance {
  String object;
  List<Available> available;
  List<ConnectReserved> connectReserved;
  bool livemode;
  List<Pending> pending;

  Balance({this.object, this.available, this.connectReserved, this.livemode,
      this.pending});

  factory Balance.fromMap(Map map) {
    return  Balance(
      object: map['object'] as String,
      available: [...(map['available'] as List ?? []).map((o) => Available.fromMap(o as Map))],
      connectReserved: [...(map['connect_reserved'] as List ?? [])
          .map((o) => ConnectReserved.fromMap(o as Map))],
      livemode: map['livemode'] as bool,
      pending: [...(map['pending'] as List ?? []).map((o) => Pending.fromMap(o as Map))],
    );
  }


  Map toJson() => {
        "object": object,
        "available": available,
        "connect_reserved": connectReserved,
        "livemode": livemode,
        "pending": pending,
      };
}

class Pending {
  int amount;
  String currency;
  SourceTypes sourceTypes;

  Pending({this.amount, this.currency, this.sourceTypes});

  factory Pending.fromMap(Map map) {
    return Pending(
      amount: map['amount'] as int,
      currency: map['currency'] as String,
      sourceTypes: SourceTypes.fromMap(map['source_types'] as Map),
    );
  }


  Map toJson() => {
        "amount": amount,
        "currency": currency,
        "source_types": sourceTypes,
      };
}

class SourceTypes {
  int card;

  SourceTypes({this.card});

  factory SourceTypes.fromMap(Map map) {
    return SourceTypes(
      card: map['card'] as int,
    );
  }

  Map toJson() => {
        "card": card,
      };
}

class ConnectReserved {
  int amount;
  String currency;

  ConnectReserved({this.amount, this.currency});

  factory ConnectReserved.fromMap(Map map) {
    return  ConnectReserved(
      amount: map['amount'] as int,
      currency: map['currency'] as String,
    );
  }

  Map toJson() => {
        "amount": amount,
        "currency": currency,
      };
}

class Available {
  final int amount;
  final String currency;
  final SourceTypes sourceTypes;


  Available({this.amount, this.currency, this.sourceTypes});

  factory Available.fromMap(Map map) {
    return Available(
      amount: map['amount'] as int,
      currency: map['currency'] as String,
      sourceTypes: map['sourceTypes'] as SourceTypes,
    );
  }

  Map toJson() => {
        "amount": amount,
        "currency": currency,
        "source_types": sourceTypes,
      };
}
