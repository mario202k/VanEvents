import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/my_transport.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';

final myTransportRepositoryProvider = Provider.autoDispose<MyTransportRepository>((ref) {
  return MyTransportRepository();
});

final myStreamTransportUpcomingProvider =
    StreamProvider.autoDispose<List<MyTransport>>((ref) {
  return ref.read(myTransportRepositoryProvider).streamTransportsVtcUpcoming();
});

final myStreamTransportNonTraiterProvider =
    StreamProvider.autoDispose<List<MyTransport>>((ref) {
  return ref
      .read(myTransportRepositoryProvider)
      .streamTransportsVtcNonTraiter();
});

final myStreamTransportDoneProvider = StreamProvider.autoDispose<List<MyTransport>>((ref) {
  return ref.read(myTransportRepositoryProvider).streamTransportsVtcDone();
});

class MyTransportRepository {
  final _service = FirestoreService.instance;

  String uid;

  MyTransportRepository({this.uid});

  Future uploadTransport(MyTransport transport) async {
    return _service.setData(
        path: MyPath.transport(transport.id), data: transport.toMap());
  }

  Stream<List<MyTransport>> streamTransportsUser() {
    return _service.collectionStream(
        path: MyPath.transports(),
        queryBuilder: (query) => query.where('userId', isEqualTo: uid),
        builder: (data) => MyTransport.fromMap(data));
  }

  Stream<List<MyTransport>> streamTransportsVtcNonTraiter() {
    return _service.collectionStream(
        path: MyPath.transports(),
        queryBuilder: (query) =>
            query.where('statusTransport', isEqualTo: 'submitted').where('userId',isEqualTo:uid),
        builder: (data) => MyTransport.fromMap(data));
  }

  Stream<List<MyTransport>> streamTransportsVtcUpcoming() {
    return _service.collectionStream(
        path: MyPath.transports(),
        queryBuilder: (query) => query.where('statusTransport',
            whereIn: ['acceptedByVtc', 'invoiceSent', 'holdOnCard', 'scanOK']).where('userId',isEqualTo:uid),
        builder: (data) => MyTransport.fromMap(data));
  }

  Stream<List<MyTransport>> streamTransportsVtcDone() {
    return _service.collectionStream(
        path: MyPath.transports(),
        queryBuilder: (query) => query.where('statusTransport', whereIn: [
              'captureFunds',
              'refunded',
              'cancelledByVTC',
              'cancelledByCustomer',
              'Error'
            ]).where('userId',isEqualTo:uid),
        builder: (data) => MyTransport.fromMap(data));
  }

  Stream<MyTransport> streamTransport(String id) {
    return _service.documentStream(
        path: MyPath.transport(id), builder: (data) => MyTransport.fromMap(data));
  }

  Future cancelTransport(String idTransport, bool isCustomer) async {
    return  _service.updateData(path: MyPath.transport(idTransport), data: {
      'statusTransport': isCustomer ? 'CancelledByCustomer' : 'CancelledByVTC'
    });
  }

  Future setTransportAccepted(String transportId, String prix) async {
    return  _service.setData(
        path: MyPath.transport(transportId),
        data: {'statusTransport': 'accepted', 'amount': double.parse(prix)});
  }

  Future setTransportRefuserParVtc(String transportId) async {
    return _service.updateData(
        path: MyPath.transport(transportId),
        data: {'statusTransport': 'cancelledByVTC'});
  }

  Future setTransportRefuserParClient(String transportId) async {
    return  _service.updateData(
        path: MyPath.transport(transportId),
        data: {'statusTransport': 'cancelledByCustomer'});
  }

  Future setTransportFactureEnvoyer(String transportId) async {
    return  _service.updateData(
        path: MyPath.transport(transportId),
        data: {'statusTransport': 'invoiceSent'});
  }

  Future setTransportPaymentIntentId(
      String transportId, String paymentIntentId) async {
    return  _service.setData(path: MyPath.transport(transportId), data: {
      'paymentIntentId': paymentIntentId,
      'statusTransport': 'holdOnCard'
    });
  }


}
