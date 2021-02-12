import 'package:cloud_firestore/cloud_firestore.dart';

enum BilletStatus {
  upComing,
  check,
  refundAsked,
  refundCancelled,
  refundRefused,
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
      'id': id,
      'status': status
          .toString()
          .substring(status.toString().indexOf('.') + 1),
      'uid': uid,
      'eventId': eventId,
      'imageUrl': imageUrl,
      'participant': participants,
      'amount': amount,
      'dateTime': dateTime,
      'organisateur': organisateurId,
      'paymentIntentId':paymentIntentId
    };
  }

  factory Billet.fromMap(Map<String, dynamic> map) {

    BilletStatus billetStatus;

    switch (map['status'] as String ) {
      case 'up_coming':
        billetStatus = BilletStatus.upComing;
        break;
      case 'check':
        billetStatus = BilletStatus.check;
        break;
      case 'refund_asked':
        billetStatus = BilletStatus.refundAsked;
        break;
      case 'refund_refused':
        billetStatus = BilletStatus.refundRefused;
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
        dateTime: (map['dateTime'] as Timestamp).toDate(),
        organisateurId: map['organisateur'] as String,
        paymentIntentId: map['paymentIntentId'] as String);
  }
}
