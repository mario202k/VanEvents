import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/billet.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';

final myBilletRepositoryProvider = Provider<MyBilletRepository>((ref) {

  return MyBilletRepository(ref.watch(myUserProvider).id);
});


class MyBilletRepository{
  final _service = FirestoreService.instance;
  String uid;

  MyBilletRepository(this.uid);

  Future billetValidated(String id) async{
    return await _service.updateData(path: Path.billet(id), data: {'status': 'Validé'});
  }

  Future addNewBillet(Billet billet) async {

    return await _service.setData(path: Path.billet(billet.id), data: billet.toMap());
  }

  Stream<List<Billet>> streamBilletsMyUser() {
    return _service.collectionStream(
        path: Path.billets(),
        builder: (map)=>Billet.fromMap(map));
  }

  Stream<List<Billet>> streamBilletsAdmin(String eventId) {

    return _service.collectionStream(
        path: Path.billets(),
        queryBuilder: (query)=>query.where('eventId', isEqualTo: eventId),
        builder: (map)=>Billet.fromMap(map));
  }

  Stream<Billet> streamBillet(String data) {

    return _service.collectionStream(
        path: Path.billets(),
        queryBuilder: (query)=>query.where('id', isEqualTo: data),
        builder: (map)=>Billet.fromMap(map)).map((event) => event.first);
  }

  Future<List<Billet>> futureBilletParticipation() {

    return _service.collectionFuture(path: Path.billets(), builder: (map)=>Billet.fromMap(map),
        queryBuilder: (query)=>query.where('uid', isEqualTo: uid));
  }

  Future setToggleisHere(Map participant, String qrResult, int index) async{
    String key = participant.keys.toList()[index];
    List val = participant[key];
    bool isHere = val.removeAt(1);
    isHere = !isHere;
    val.insert(1, isHere);

    return await _service.updateData(path: Path.billet(qrResult), data: {'participant.$key': val});
  }

  Future toutValider(Billet onGoing) async{
    for (int i = 0; i < onGoing.participants.length; i++) {
      await setToggleisHere(onGoing.participants, onGoing.id, i);
    }
  }


}