import 'package:van_events_project/domain/models/transfer.dart';

class ListTransfer {
  String object;
  bool hasMore;
  List<Transfer> data;

  ListTransfer({this.object, this.hasMore, this.data});


  Map toJson() => {
        "object": object,
        "has_more": hasMore,
        "data": data,
      };

  factory ListTransfer.fromMap(dynamic map) {
    if (null == map) return null;
    var temp;
    return ListTransfer(
      object: map['object']?.toString(),
      hasMore: null == (temp = map['hasMore'])
          ? null
          : (temp is bool
              ? temp
              : (temp is num
                  ? 0 != temp.toInt()
                  : ('true' == temp.toString()))),
      data: null == (temp = map['data'])
          ? []
          : (temp is List
              ? temp.map((map) => Transfer.fromMap(map as Map<String,dynamic>)).toList()
              : []),
    );
  }
}
