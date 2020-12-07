import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

enum StatusTransport {
  submitted,
  cancelledByVTC,
  accepted,
  invoiceSent,
  cancelledByCustomer,
  holdOnCard,
  scanOK,
  refunded,
  captureFunds
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
    GeoFirePoint myLocation = Geoflutterfire().point(
        latitude: this.position.latitude, longitude: this.position.longitude);
    return {
      'id':this.id,
      'car': this.car,
      'adresseZone': this.adresseZone,
      'adresseRue': this.adresseRue,
      'position': myLocation.data,
      'distance': this.distance,
      'nbPersonne': this.nbPersonne,
      'dateTime': this.dateTime,
      'paymentIntentId': this.paymentIntentId,
      'amount': this.amount,
      'statusTransport': this
          .statusTransport
          .toString()
          .substring(this.statusTransport.toString().indexOf('.') + 1),
      'userId': this.userId,
      'eventId': this.eventId
    };
  }

  factory MyTransport.fromMap(Map<String, dynamic> map) {
    Timestamp dateDebut = map['dateTime'];
    Map geo = map['position'] as Map;
    GeoPoint coords = geo['geopoint'];

    StatusTransport myStatusTransport;

    for (StatusTransport statusTransport in StatusTransport.values) {
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
      position: coords,
      distance: map['distance'] as double,
      nbPersonne: map['nbPersonne'] as String,
      dateTime: dateDebut.toDate(),
      paymentIntentId: map['paymentIntentId'] as String,
      amount: map['amount'] as double,
      statusTransport: myStatusTransport,
      eventId: map['eventId'],
      userId: map['userId'],
    );
  }
}
