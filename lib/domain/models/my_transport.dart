import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

enum StatusTransport {
  submitted,//Non Traiter
  acceptedByVtc,
  invoiceSent,
  holdOnCard,
  captureFunds,//Done
  refunded,//Done
  cancelledByVTC,//Done
  cancelledByCustomer,//Done
  error//Done Capture too late etc...
}

class MyTransport {
  final String id;
  final String car;
  final List adresseZone;
  final List adresseRue;
  final GeoPoint position;
  final double distance;
  final String nbPersonne;
  final DateTime dateTime;
  final String paymentIntentId;
  final double amount;
  final StatusTransport statusTransport;
  final String userId;
  final String eventId;

  MyTransport(
      {this.id,
        this.car,
      this.adresseZone,
      this.adresseRue,
      this.position,
      this.distance,
      this.nbPersonne,
      this.dateTime,
      this.paymentIntentId,
      this.amount,
      this.statusTransport,
      this.userId,
      this.eventId});

  Map<String, dynamic> toMap() {
    final GeoFirePoint myLocation = Geoflutterfire().point(
        latitude: position.latitude, longitude: position.longitude);
    return {
      'id':id,
      'car': car,
      'adresseZone': adresseZone,
      'adresseRue': adresseRue,
      'position': myLocation.data,
      'distance': distance,
      'nbPersonne': nbPersonne,
      'dateTime': dateTime,
      'paymentIntentId': paymentIntentId,
      'amount': amount,
      'statusTransport': statusTransport
          .toString()
          .substring(statusTransport.toString().indexOf('.') + 1),
      'userId': userId,
      'eventId': eventId
    };
  }

  factory MyTransport.fromMap(Map<String, dynamic> map) {

    StatusTransport myStatusTransport;

    for (final StatusTransport statusTransport in StatusTransport.values) {
      if (statusTransport
              .toString()
              .substring(statusTransport.toString().indexOf('.') + 1) ==
          map['statusTransport'] as String) {
        myStatusTransport = statusTransport;
      }
    }
    return MyTransport(
      id: map['id'] as String,
      car: map['car'] as String ?? '',
      adresseZone: map['adresseZone'] as List ?? [],
      adresseRue: map['adresseRue'] as List ?? [],
      position: map['position']['geopoint'] as GeoPoint,
      distance: map['distance'] as double,
      nbPersonne: map['nbPersonne'] as String,
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      paymentIntentId: map['paymentIntentId'] as String,
      amount: map['amount'] as double,
      statusTransport: myStatusTransport,
      eventId: map['eventId'] as String,
      userId: map['userId'] as String,
    );
  }
}
