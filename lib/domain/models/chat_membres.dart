import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMembre{
  final String id;
  final DateTime lastReading;
  final bool isReading;
  final bool isWriting;

  ChatMembre({
      this.id, this.lastReading, this.isReading,this.isWriting});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'lastReading': this.lastReading,
      'isReading': this.isReading,
      'isWriting': this.isWriting,
    };
  }

  factory ChatMembre.fromMap(Map<String, dynamic> map)  {
    Timestamp lastReading = map['lastReading'] ?? Timestamp.now();

    return new ChatMembre(
      id: map['id'] as String,
      lastReading: lastReading?.toDate(),
      isReading: map['isReading'] as bool,
      isWriting: map['isWriting'] as bool,
    );
  }

  @override
  String toString() {
    return 'ChatMembre{id: $id, lastReading: $lastReading, isReading: $isReading, isWriting: $isWriting}';
  }
}