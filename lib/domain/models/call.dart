import 'package:cloud_firestore/cloud_firestore.dart';

enum CallStatus {
  callSent,
  callReceived,
  unreachable,
  notRespond,
  pickUp,
  hangUp,
  refused
}

class Call {
  final String id;
  final String chatId;
  final String idFrom;
  final String idTo;
  final bool hasVideo;
  final DateTime date;
  final String duration;
  final CallStatus callStatus;

  Call(
      {this.id,
      this.chatId,
      this.idFrom,
      this.idTo,
      this.hasVideo,
      this.date,
      this.duration,
      this.callStatus});

  factory Call.fromMap(Map<String, dynamic> map) {
    CallStatus callStatus;

    switch (map['callStatus'].toString()) {
      case 'callSent':
        callStatus = CallStatus.callSent;
        break;
      case 'callReceived':
        callStatus = CallStatus.callReceived;
        break;
      case 'unreachable':
        callStatus = CallStatus.unreachable;
        break;
      case 'notRespond':
        callStatus = CallStatus.notRespond;
        break;
      case 'pickUp':
        callStatus = CallStatus.pickUp;
        break;
      case 'hangUp':
        callStatus = CallStatus.hangUp;
        break;
      case 'refused':
        callStatus = CallStatus.refused;
        break;
    }


    return Call(
      id: map['id'] as String,
      chatId: map['chatId'] as String,
      idFrom: map['idFrom'] as String,
      idTo: map['idTo'] as String,
      hasVideo: map['hasVideo'] == "true",
      date: (map['date'] as Timestamp).toDate(),
      duration: map['duration'] as String,
      callStatus: callStatus,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'id': id,
      'chatId': chatId,
      'idFrom': idFrom,
      'idTo': idTo,
      'hasVideo': hasVideo.toString(),
      'date': FieldValue.serverTimestamp(),
      'duration': duration,
      'callStatus': callStatus
          .toString()
          .substring(callStatus.toString().indexOf('.') + 1),
    } as Map<String, dynamic>;
  }

  @override
  String toString() {
    return 'Call{id: $id, chatId: $chatId, idFrom: $idFrom, idTo: $idTo, hasVideo: $hasVideo, date: $date, duration: $duration, callStatus: $callStatus}';
  }
}
