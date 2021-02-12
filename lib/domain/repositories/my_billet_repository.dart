import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/billet.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';

final myBilletRepositoryProvider = Provider<MyBilletRepository>((ref) {
  return MyBilletRepository(ref.watch(myUserProvider).id);
});

class MyBilletRepository {
  final _service = FirestoreService.instance;
  String uid;

  MyBilletRepository(this.uid);

  Future billetValidated(String id) async {
    return _service
        .updateData(path: MyPath.billet(id), data: {'status': 'check'});
  }

  Future addNewBillet(Billet billet) async {
    return _service.setData(
        path: MyPath.billet(billet.id), data: billet.toMap());
  }

  Stream<List<Billet>> streamBilletsMyUser() {
    return _service.collectionStream(
        path: MyPath.billets(),
        queryBuilder: (query)=>query.where('uid',isEqualTo: uid),
        builder: (map) => Billet.fromMap(map));
  }

  Stream<List<Billet>> streamBilletsAdmin(String eventId) {
    return _service.collectionStream(
        path: MyPath.billets(),
        queryBuilder: (query) => query.where('eventId', isEqualTo: eventId),
        builder: (map) => Billet.fromMap(map));
  }

  Stream<List<Billet>> streamBillet(String data) {
    return _service.collectionStream(
        path: MyPath.billets(),
        queryBuilder: (query) => query.where('id', isEqualTo: data),
        builder: (map) => Billet.fromMap(map));
  }

  Future<List<Billet>> futureBilletParticipation({String otherUid}) {
    return _service.collectionFuture(
        path: MyPath.billets(),
        builder: (map) => Billet.fromMap(map),
        queryBuilder: (query) => query.where('uid', isEqualTo: otherUid ?? uid));
  }

  Future setToggleisHere(Map participant, String qrResult, int index) async {
    final String key = participant.keys.toList()[index].toString();
    final List<dynamic> val = participant[key] as List<dynamic>;
    bool isHere = val.removeAt(1) as bool;
    isHere = !isHere;
    val.insert(1, isHere);

    return _service.updateData(
        path: MyPath.billet(qrResult), data: {'participant.$key': val});
  }

  Future toutValider(Billet onGoing) async {
    for (int i = 0; i < onGoing.participants.length; i++) {
      await setToggleisHere(onGoing.participants, onGoing.id, i);
    }
  }

  Future<void> setStatusRefunded(String billetId) {
    return _service.updateData(
        path: MyPath.billet(billetId), data: {'status': 'refunded'});
  }

  Future<List<Billet>> getBillet(String paymentIntentId) async {
    return _service.collectionFuture(
        path: MyPath.billets(),
        queryBuilder: (query) =>
            query.where('paymentIntentId', isEqualTo: paymentIntentId),
        builder: (map) => Billet.fromMap(map));
  }

  Future<void> setStatusRefused(String billetId) {
    return _service.updateData(
        path: MyPath.billet(billetId), data: {'status': 'refund_refused'});
  }

  Future<void> setStatusRefundAsked(String billetId) {
    return _service.updateData(
        path: MyPath.billet(billetId), data: {'status': 'refund_asked'});
  }

  Future<void> setStatusCancelAsking(String billetId) {
    return _service.updateData(
        path: MyPath.billet(billetId), data: {'status': 'refund_cancelled'});

  }
}
