import 'package:cloud_firestore/cloud_firestore.dart';
enum BilletStatus{
  check,
  checkByVtc,
  refunded,
  paid,
}
class Billet{
  final String id;
  final String status;
  final String uid;
  final String eventId;
  final String imageUrl;
  final Map participants;
  final int amount;
  final DateTime dateTime;


  Billet({this.id,this.status,this.uid, this.eventId, this.imageUrl, this.participants,
      this.amount, this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'status':this.status,
      'uid': this.uid,
      'eventId': this.eventId,
      'imageUrl': this.imageUrl,
      'participant': this.participants,
      'amount': this.amount,
      'dateTime': this.dateTime,

    };
  }

  factory Billet.fromMap(Map<String, dynamic> map) {
    Timestamp time = map['dateTime'] ?? '';

    return Billet(
      id: map['id'] as String,
      status: map['status'] as String,
      uid: map['uid'] as String,
      eventId: map['eventId'] as String,
      imageUrl: map['imageUrl'] as String,
      participants: map['participant'] as Map,
      amount: map['amount'] as int,
      dateTime: time.toDate(),
    );
  }
}