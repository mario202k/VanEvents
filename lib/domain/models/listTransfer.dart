import 'package:van_events_project/domain/models/transfer.dart';

class ListTransfer {
  String object;
  bool hasMore;
  List<Transfer> data;

  static ListTransfer fromMap(Map map) {
    if (map == null) return null;
    ListTransfer listPayout = ListTransfer();
    listPayout.object = map['object'];
    listPayout.hasMore = map['has_more'];
    listPayout.data = List()..addAll(
        (map['data'] as List ?? []).map((o) => Transfer.fromMap(o))
    );
    return listPayout;
  }

  Map toJson() => {
    "object": object,
    "has_more": hasMore,
    "data": data,
  };
}
