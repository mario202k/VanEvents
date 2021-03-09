import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMembre {
  final String id;
  final DateTime lastReading;
  final DateTime lastReceived;
  final bool isReading;
  final bool isWriting;
  final bool isSubscribeToTopic;

  ChatMembre(
      {this.id,
      this.lastReading,
      this.lastReceived,
      this.isReading,
      this.isWriting,this.isSubscribeToTopic});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastReading': lastReading,
      'lastReceived': lastReceived,
      'isReading': isReading,
      'isWriting': isWriting,
      'isSubscribeToTopic': isSubscribeToTopic
    };
  }

  factory ChatMembre.fromMap(Map<String, dynamic> map) {
    if(map == null){
      return null;
    }
    return ChatMembre(
      id: map['id'] as String,
      lastReading:
          (map['lastReading'] as Timestamp ?? Timestamp.now())?.toDate(),
      lastReceived:
          (map['lastReceived'] as Timestamp ?? Timestamp.now())?.toDate(),
      isReading: map['isReading'] as bool,
      isWriting: map['isWriting'] as bool,
      isSubscribeToTopic: map['isSubscribeToTopic'] as bool
    );
  }

  @override
  String toString() {
    return 'ChatMembre{id: $id, lastReading: $lastReading, lastReceived: $lastReceived, isReading: $isReading, isWriting: $isWriting, isSubscribeToTopic: $isSubscribeToTopic}';
  }
}
