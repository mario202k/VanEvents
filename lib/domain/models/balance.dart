class Balance {
  String object;
  List<Available> available;
  List<Connect_reserved> connectReserved;
  bool livemode;
  List<Pending> pending;

  static Balance fromMap(Map map) {
    if (map == null) return null;
    Balance balance = Balance();
    balance.object = map['object'];
    balance.available = List()
      ..addAll(
          (map['available'] as List ?? []).map((o) => Available.fromMap(o)));
    balance.connectReserved = List()
      ..addAll((map['connect_reserved'] as List ?? [])
          .map((o) => Connect_reserved.fromMap(o)));
    balance.livemode = map['livemode'];
    balance.pending = List()
      ..addAll((map['pending'] as List ?? []).map((o) => Pending.fromMap(o)));
    return balance;
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
  Source_types sourceTypes;

  static Pending fromMap(Map map) {
    if (map == null) return null;
    Pending pending = Pending();
    pending.amount = map['amount'];
    pending.currency = map['currency'];
    pending.sourceTypes = Source_types.fromMap(map['source_types']);
    return pending;
  }

  Map toJson() => {
        "amount": amount,
        "currency": currency,
        "source_types": sourceTypes,
      };
}

class Source_types {
  int card;

  static Source_types fromMap(Map map) {
    if (map == null) return null;
    Source_types source_types = Source_types();
    source_types.card = map['card'];
    return source_types;
  }

  Map toJson() => {
        "card": card,
      };
}

class Connect_reserved {
  int amount;
  String currency;

  static Connect_reserved fromMap(Map map) {
    if (map == null) return null;
    Connect_reserved connect_reserved = Connect_reserved();
    connect_reserved.amount = map['amount'];
    connect_reserved.currency = map['currency'];
    return connect_reserved;
  }

  Map toJson() => {
        "amount": amount,
        "currency": currency,
      };
}

class Available {
  int amount;
  String currency;
  Source_types sourceTypes;

  static Available fromMap(Map map) {
    if (map == null) return null;
    Available available = Available();
    available.amount = map['amount'];
    available.currency = map['currency'];
    available.sourceTypes = Source_types.fromMap(map['source_types']);
    return available;
  }

  Map toJson() => {
        "amount": amount,
        "currency": currency,
        "source_types": sourceTypes,
      };
}
