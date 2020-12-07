import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMembre{
  final String id;
  final DateTime lastReading;
  final bool isReading;

  ChatMembre({
      this.id, this.lastReading, this.isReading});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'lastReading': this.lastReading,
      'isReading': this.isReading,
    };
  }

  factory ChatMembre.fromMap(Map<String, dynamic> map)  {
    Timestamp lastReading = map['lastReading'] ?? '';

    return new ChatMembre(
      id: map['id'] as String,
      lastReading: lastReading.toDate(),
      isReading: map['isReading'] as bool,
    );
  }

  @override
  String toString() {
    return 'ChatMembre{id: $id, lastReading: $lastReading, isReading: $isReading}';
  }
}