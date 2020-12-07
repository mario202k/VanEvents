import 'package:cloud_firestore/cloud_firestore.dart';

enum MyMessageType { text, image, reply }
enum MyMessageReplyType { text, image }

class MyMessage {
  final String id;
  final String idFrom;
  final String idTo;
  final String message;
  final DateTime date;
  final MyMessageType type;
  final String replyMessageId;
  final MyMessageReplyType replyType;

  MyMessage(
      {this.id,
      this.idFrom,
      this.idTo,
      this.message,
      this.date,
      this.type,
      this.replyMessageId,
      this.replyType});

  factory MyMessage.fromMap(Map<String, dynamic> map) {
    Timestamp time = map['date'] ?? '';

    MyMessageType myMessageType;
    switch (map['type'] as String) {
      case 'MyMessageType.text':
        myMessageType = MyMessageType.text;
        break;
      case 'MyMessageType.image':
        myMessageType = MyMessageType.image;
        break;
      case 'MyMessageType.reply':
        myMessageType = MyMessageType.reply;
        break;
    }

    MyMessageReplyType myMessageReplyType;
    switch (map['replyType'] as String) {
      case 'MyMessageReplyType.text':
        myMessageReplyType = MyMessageReplyType.text;
        break;
      case 'MyMessageReplyType.image':
        myMessageReplyType = MyMessageReplyType.image;
        break;
    }

    return MyMessage(
      id: map['id'] as String,
      idFrom: map['idFrom'] as String,
      idTo: map['idTo'] as String,
      message: map['message'] as String,
      date: time.toDate() ?? DateTime.now(),
      type: myMessageType,
      replyMessageId: map['replyMessageId'] as String,
      replyType: myMessageReplyType,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'id': this.id,
      'idFrom': this.idFrom,
      'idTo': this.idTo,
      'message': this.message,
      'date': FieldValue.serverTimestamp(),
      'type': this.type.toString(),
      'replyMessageId': this.replyMessageId ?? '',
      'replyType': this.replyType.toString() ?? '',
    } as Map<String, dynamic>;
  }

  factory MyMessage.fromIosFcm(Map data) {

    MyMessageType myMessageType;
    switch (data['type'] as String) {
      case 'MyMessageType.text':
        myMessageType = MyMessageType.text;
        break;
      case 'MyMessageType.image':
        myMessageType = MyMessageType.image;
        break;
      case 'MyMessageType.reply':
        myMessageType = MyMessageType.reply;
        break;
    }
    MyMessageReplyType myMessageReplyType;
    switch (data['replyType'] as String) {
      case 'MyMessageReplyType.text':
        myMessageReplyType = MyMessageReplyType.text;
        break;
      case 'MyMessageReplyType.image':
        myMessageReplyType = MyMessageReplyType.image;
        break;
    }
    return MyMessage(
        id: data['id'] ?? '',
        idFrom: data['idFrom'] ?? '',
        idTo: data['idTo'] ?? '',
        message: data['aps'] != null
            ? data['aps']['alert']['body']
            : data['notification']['body'],
        date: DateTime.parse(data['date']) ?? DateTime.now(),
        type: myMessageType,
        replyMessageId: data['replyMessageId'],
        replyType: myMessageReplyType);
  }

  factory MyMessage.fromAndroidFcm(Map data) {
    MyMessageType myMessageType;
    switch (data['data']['type'] as String) {
      case 'MyMessageType.text':
        myMessageType = MyMessageType.text;
        break;
      case 'MyMessageType.image':
        myMessageType = MyMessageType.image;
        break;
      case 'MyMessageType.reply':
        myMessageType = MyMessageType.reply;
        break;
    }

    MyMessageReplyType myMessageReplyType;
    switch (data['data']['replyType'] as String) {
      case 'MyMessageReplyType.text':
        myMessageReplyType = MyMessageReplyType.text;
        break;
      case 'MyMessageReplyType.image':
        myMessageReplyType = MyMessageReplyType.image;
        break;
    }

    return MyMessage(
        id: data['data']['id'] ?? '',
        idFrom: data['data']['idFrom'] ?? '',
        idTo: data['data']['idTo'] ?? '',
        message: data['notification']['body'] ?? '',
        date: DateTime.parse(data['data']['date'])  ?? DateTime.now() ,
        type: myMessageType,
        replyType: myMessageReplyType,
        replyMessageId: data['data']['replyMessageId']);
  }

  @override
  String toString() {
    return 'MyMessage{id: $id, idFrom: $idFrom, idTo: $idTo, message: $message, date: $date, type: $type, replyMessageId: $replyMessageId, replyType: $replyType}';
  }
}
