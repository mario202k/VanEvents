import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMembre {
  final String id;
  final DateTime lastReading;
  final DateTime lastReceived;
  final bool isReading;
  final bool isWriting;

  ChatMembre(
      {this.id,
      this.lastReading,
      this.lastReceived,
      this.isReading,
      this.isWriting});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastReading': lastReading,
      'lastReceived': lastReceived,
      'isReading': isReading,
      'isWriting': isWriting,
    };
  }

  factory ChatMembre.fromMap(Map<String, dynamic> map) {
    return ChatMembre(
      id: map['id'] as String,
      lastReading:
          (map['lastReading'] as Timestamp ?? Timestamp.now())?.toDate(),
      lastReceived:
          (map['lastReceived'] as Timestamp ?? Timestamp.now())?.toDate(),
      isReading: map['isReading'] as bool,
      isWriting: map['isWriting'] as bool,
    );
  }

  @override
  String toString() {
    return 'ChatMembre{id: $id, lastReading: $lastReading, lastReceived: $lastReceived, isReading: $isReading, isWriting: $isWriting}';
  }
}
