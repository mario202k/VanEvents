import 'package:cloud_firestore/cloud_firestore.dart';

enum MyMessageType { text, image, reply, call }
enum MyMessageReplyType { text, image }


class MyMessage {
  final String id;//channelId
  final String idFrom;
  final String idTo;
  final String message;
  final DateTime date;
  final MyMessageType type;
  final String replyMessageId;
  final MyMessageReplyType replyType;

  MyMessage({
      this.id,
      this.idFrom,
      this.idTo,
      this.message,
      this.date,
      this.type,
      this.replyMessageId,
      this.replyType,
  });

  factory MyMessage.fromMap(Map<String, dynamic> map) {

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
      case 'MyMessageType.call':
        myMessageType = MyMessageType.call;
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
      date: (map['date'] as Timestamp).toDate() ?? DateTime.now(),
      type: myMessageType,
      replyMessageId: map['replyMessageId'] as String,
      replyType: myMessageReplyType,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'id': id,
      'idFrom': idFrom,
      'idTo': idTo,
      'message': message,
      'date': FieldValue.serverTimestamp(),
      'type': type.toString(),
      'replyMessageId': replyMessageId ?? '',
      'replyType': replyType.toString() ?? '',
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
      case 'MyMessageType.call':
        myMessageType = MyMessageType.call;
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
        id: data['id'] as String,
        idFrom: data['idFrom'] as String,
        idTo: data['idTo'] as String,
        message: data['aps'] != null
            ? data['aps']['alert']['body'] as String
            : data['notification']['body'] as String,
        date: DateTime.parse(data['date'] as String) ?? DateTime.now(),
        type: myMessageType,
        replyMessageId: data['replyMessageId'] as String,
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
      case 'MyMessageType.call':
        myMessageType = MyMessageType.call;
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
        id: data['data']['id'] as String,
        idFrom: data['data']['idFrom'] as String,
        idTo: data['data']['idTo'] as String,
        message: data['notification']['body'] as String,
        date: DateTime.parse(data['data']['date'] as String)  ?? DateTime.now() ,
        type: myMessageType,
        replyType: myMessageReplyType,
        replyMessageId: data['data']['replyMessageId']as String,);
  }

  @override
  String toString() {
    return 'MyMessage{id: $id, idFrom: $idFrom, idTo: $idTo, message: $message, date: $date, type: $type, replyMessageId: $replyMessageId, replyType: $replyType}';
  }
}
