import 'package:cloud_firestore/cloud_firestore.dart';

enum BilletStatus {
  up_coming,
  check,
  refund_asked,
  refund_cancelled,
  refund_refused,
  refunded,
}

class Billet {
  final String id; //paymentIntentId
  final BilletStatus status;
  final String paymentIntentId;
  final String uid;
  final String eventId;
  final String imageUrl;
  final Map participants;
  final int amount;
  final DateTime dateTime;
  final String organisateurId;

  Billet(
      {this.id,
      this.status,
      this.paymentIntentId,
      this.uid,
      this.eventId,
      this.imageUrl,
      this.participants,
      this.amount,
      this.dateTime,
      this.organisateurId});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'status': this
          .status
          .toString()
          .substring(this.status.toString().indexOf('.') + 1),
      'uid': this.uid,
      'eventId': this.eventId,
      'imageUrl': this.imageUrl,
      'participant': this.participants,
      'amount': this.amount,
      'dateTime': this.dateTime,
      'organisateur': this.organisateurId,
      'paymentIntentId':this.paymentIntentId
    };
  }

  factory Billet.fromMap(Map<String, dynamic> map) {
    Timestamp time = map['dateTime'] ?? '';

    BilletStatus billetStatus;

    switch (map['status']) {
      case 'up_coming':
        billetStatus = BilletStatus.up_coming;
        break;
      case 'check':
        billetStatus = BilletStatus.check;
        break;
      case 'refund_asked':
        billetStatus = BilletStatus.refund_asked;
        break;
      case 'refund_refused':
        billetStatus = BilletStatus.refund_refused;
        break;
      case 'refunded':
        billetStatus = BilletStatus.refunded;
        break;
    }

    return Billet(
        id: map['id'] as String,
        status: billetStatus,
        uid: map['uid'] as String,
        eventId: map['eventId'] as String,
        imageUrl: map['imageUrl'] as String,
        participants: map['participant'] as Map,
        amount: map['amount'] as int,
        dateTime: time.toDate(),
        organisateurId: map['organisateur'],
        paymentIntentId: map['paymentIntentId']);
  }
}
