class Call{
  final String id;
  final String uuid;
  final String idFrom;
  final String idTo;
  final bool hasVideo;
  final DateTime date;
  final Duration duration;
  final bool hasRefused;


  Call({this.id, this.uuid, this.idFrom, this.idTo, this.hasVideo, this.date,
      this.duration, this.hasRefused});

  factory Call.fromMap(Map<String, dynamic> map) {
    return Call(
      id: map['id'] as String,
      uuid: map['uuid'] as String,
      idFrom: map['idFrom'] as String,
      idTo: map['idTo'] as String,
      hasVideo: map['hasVideo'] as bool,
      date: map['date'] as DateTime,
      duration: map['duration'] as Duration,
      hasRefused: map['hasRefused'] as bool,
    );
  }



  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'id': id,
      'uuid': uuid,
      'idFrom': idFrom,
      'idTo': idTo,
      'hasVideo': hasVideo.toString(),
      'date': date,
      'duration': duration,
      'hasRefused': hasRefused,
    } as Map<String, dynamic>;
  }

  @override
  String toString() {
    return 'Call{id: $id, uuid: $uuid, idFrom: $idFrom, idTo: $idTo, hasVideo: $hasVideo, date: $date, duration: $duration, hasRefused: $hasRefused}';
  }
}