import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/my_transport.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';

final myTransportRepositoryProvider = Provider<MyTransportRepository>((ref) {
  return MyTransportRepository();
});

class MyTransportRepository{
  final _service = FirestoreService.instance;

  String uid;

  MyTransportRepository({this.uid});

  Future uploadTransport(MyTransport transport) async {
    return await _service.setData(path: Path.transport(transport.id), data: transport.toMap());
  }

  Stream<List<MyTransport>> streamTransportsUser() {

    return _service.collectionStream(path: Path.transports(),
        queryBuilder: (query)=>query.where('userId', isEqualTo: uid),
        builder: (data)=>MyTransport.fromMap(data));
  }

  Stream<List<MyTransport>> streamTransportsVtc() {
    return _service.collectionStream(path: Path.transports(),
        builder: (data)=>MyTransport.fromMap(data));

  }

  Stream<MyTransport> streamTransport(String id) {
    return _service.documentStream(path: Path.transport(id),
        builder: (data)=>MyTransport.fromMap(data));
  }

  Future cancelTransport(String idTransport, bool isCustomer) async {

    return await _service.updateData(path: Path.transport(idTransport), data: {
      'statusTransport': isCustomer ? 'CancelledByCustomer' : 'CancelledByVTC'
    });
  }

  Future setTransportAccepted(String transportId, String prix) async {

    return await _service.setData(path: Path.transport(transportId),
        data: {'statusTransport': 'accepted', 'amount': double.parse(prix)});
  }

  Future setTransportRefuserParVtc(String transportId) async {

    return await _service.updateData(path: Path.transport(transportId),
        data: {'statusTransport': 'cancelledByVTC'});
  }

  Future setTransportRefuserParClient(String transportId) async {


    return await _service.updateData(path: Path.transport(transportId),
        data: {'statusTransport': 'cancelledByCustomer'});
  }

  Future setTransportFactureEnvoyer(String transportId) async {
    _service.updateData(path: Path.transport(transportId),
        data: {'statusTransport': 'invoiceSent'});
    return await _service.updateData(path: Path.transport(transportId),
        data: {'statusTransport': 'invoiceSent'});
  }


}