import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:van_events_project/domain/models/billet.dart';
import 'package:van_events_project/domain/models/event.dart';
import 'package:van_events_project/domain/models/formule.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';

final myEventRepositoryProvider = Provider<MyEventRepository>((ref) {
  return MyEventRepository();
});

class MyEventRepository {
  final _service = FirestoreService.instance;
  final geo = Geoflutterfire();

  Future<MyEvent> eventFuture(String id) {
    return _service.getDoc(
        path: MyPath.event(id), builder: (map) => MyEvent.fromMap(map));
  }

  Future<List<String>> loadPhotos(
      List<Asset> images, String idEvent, MyEvent old) async {
    final List<String> urlPhotos = <String>[];

    if (old != null) {
      for (int i = 0; i < old.imagePhotos.length; i++) {
        await _service.deleteImg(
            path: MyPath.eventPhotos(idEvent, i.toString()),
            contentType: 'image/jpeg');
      }
    }

    for (int i = 0; i < images.length; i++) {
      final byteData = await images[i].getByteData();

      final File file =
          await File('${(await getTemporaryDirectory()).path}/$i.jpg')
              .writeAsBytes(byteData.buffer
                  .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      urlPhotos.add(await _service.uploadImg(
          file: file,
          path: MyPath.eventPhotos(idEvent, i.toString()),
          contentType: 'image/jpeg'));
    }

    return urlPhotos;
  }

  Future uploadEvent(
      {DateTime dateDebut,
      DateTime dateFin,
      List<AddressComponent> adresse,
      Coords coords,
      String titre,
      String description,
      File flyer,
      List<Formule> formules,
      // BuildContext context,
      Map<String, bool> type,
      Map<String, bool> genre,
      List<Asset> images,
      String stripeAccount,
      bool isAffiche,
      DateTime dateFinAffiche,
      DateTime dateDebutAffiche,
      String oldId,
      String oldIdChatRoom,
      MyEvent myOldEvent}) async {
    final Map<String, bool> types = <String, bool>{};
    final Map<String, bool> genres = <String, bool>{};
    types.addAll(type);
    genres.addAll(genre);

    types.removeWhere((key, value) => value == false);
    genres.removeWhere((key, value) => value == false);

    final GeoFirePoint myLocation =
        geo.point(latitude: coords.latitude, longitude: coords.longitude);

    final List<AddressComponent> rue = <AddressComponent>[];
    if (adresse != null) {
      rue.addAll(adresse);

      rue.removeWhere((element) =>
          element.types[0] == "locality" ||
          element.types[0] == "administrative_area_level_2" ||
          element.types[0] == "administrative_area_level_1" ||
          element.types[0] == "country" ||
          element.types[0] == "postal_code");

      adresse.removeWhere((element) =>
          element.types[0] == "floor" ||
          element.types[0] == "street_number" ||
          element.types[0] == "route" ||
          element.types[0] == 'country');
    }

    // _service.getDocId(path: Path.events());

    final String docId = oldId ?? _service.getDocId(path: MyPath.events());

    await _service.setData(path: MyPath.event(docId), data: {
      "id": docId,
      'uploadedDate': DateTime.now(),
      "dateDebut": dateDebut,
      "dateFin": dateFin,
      "adresseRue": adresse != null
          ? List<String>.generate(rue.length, (index) => rue[index].longName)
          : myOldEvent.adresseRue,
      "adresseZone": adresse != null
          ? List<String>.generate(
              adresse.length, (index) => adresse[index].longName)
          : myOldEvent.adresseZone,
      'position': myLocation.data,
      "titre": titre,
      'status': 'A venir',
      "description": description,
      'types': types.keys.toList(),
      'genres': genres.keys.toList(),
      'stripeAccount': stripeAccount,
      'dateFinAffiche': dateFinAffiche,
      'dateDebutAffiche': dateDebutAffiche
    }).then((doc) async {
      String urlFlyer;

      if (flyer != null) {
        //création du path pour le flyer

        if (myOldEvent != null) {
          await _service.deleteImg(
              path: MyPath.flyer(docId), contentType: 'image/jpeg');
        }

        urlFlyer = await _service.uploadImg(
            file: flyer, path: MyPath.flyer(docId), contentType: 'image/jpeg');
      }

      final List<String> urlPhotos =
          await loadPhotos(images, docId, myOldEvent);

      //creation id chat
      //création d'un chatRoom

      final String idChatRoom =
          oldIdChatRoom ?? _service.getDocId(path: MyPath.chats());

      await _service.setData(data: {
        'id': idChatRoom,
        'createdAt': FieldValue.serverTimestamp(),
        'isGroupe': true,
        'titre': titre,
        'imageFlyerUrl': urlFlyer,
      }, path: MyPath.chat(idChatRoom));

      if (flyer == null && images == null) {
        await _service.setData(data: {
          'chatId': idChatRoom,
        }, path: MyPath.event(docId));
      } else if (flyer != null && images == null) {
        await _service.setData(data: {
          'chatId': idChatRoom,
          'imageFlyerUrl': urlFlyer,
        }, path: MyPath.event(docId));
      } else if (flyer == null && images != null) {
        await _service.setData(data: {
          'chatId': idChatRoom,
          'imagePhotos': urlPhotos,
        }, path: MyPath.event(docId));
      } else if (flyer != null && images != null) {
        //Mise a niveau
        await _service.setData(data: {
          'chatId': idChatRoom,
          'imageFlyerUrl': urlFlyer,
          'imagePhotos': urlPhotos,
        }, path: MyPath.event(docId));
      }

      //supprimer des éventuelles formule en trop si on en retire
      await _service
          .collectionFuture(
              path: MyPath.formules(docId),
              builder: (data) => Formule.fromMap(data))
          .then((value) async {
        if (value.length > formules.length) {
          for (int i = formules.length; i <= value.length; i++) {
            await _service.deleteData(path: MyPath.formule(docId, '$i'));
          }
        }
      });

      formules.forEach((f) async {
        await _service.setData(path: MyPath.formule(docId, f.id), data: {
          "id": f.id,
          "prix": f.prix,
          "title": f.title,
          "nb": f.nombreDePersonne,
        });
      });
    });
    return;
  }

  Future<List<Future<MyUser>>> participantsEvent(String eventId) {
    return _service
        .collectionFuture(
            path: MyPath.billets(),
            builder: (data) => Billet.fromMap(data),
            queryBuilder: (query) => query.where('eventId', isEqualTo: eventId))
        .then((value) => value
            .map((e) => _service.getDoc(
                path: MyPath.user(e.uid),
                builder: (data) => MyUser.fromMap(data)))
            .toList());
  }

  Future<List<Formule>> getFormulasList(String id) async {
    return _service.collectionFuture(
        path: MyPath.formules(id), builder: (data) => Formule.fromMap(data));
  }

  Future cancelEvent(String id) {
    return _service
        .updateData(path: MyPath.event(id), data: {'status': 'Annuler'});
  }

  bool dateCompriEntre(MyEvent event, DateTime start, DateTime end) {
    return event.dateDebut.compareTo(start) > 0 &&
        event.dateDebut.compareTo(end) < 0;
  }

  Stream<List<MyEvent>> allEventsAdminStream(String stripeAccount) =>
      _service.collectionStream(
          path: MyPath.events(),
          builder: (data) => MyEvent.fromMap(data),
          queryBuilder: (query) =>
              query.where('stripeAccount', isEqualTo: stripeAccount));

  Stream<List<MyEvent>> allEvents() => _service.collectionStream(
      path: MyPath.events(), builder: (data) => MyEvent.fromMap(data));

  Stream<List<MyEvent>> eventsStreamAffiche() => _service.collectionStream(
      path: MyPath.events(),
      builder: (data) => MyEvent.fromMap(data),
      queryBuilder: (query) => query
          .where('status', isEqualTo: 'A venir')
          // .where('dateDebutAffiche', isLessThan: Timestamp.now())
          .where('dateFinAffiche', isGreaterThan: Timestamp.now())

      //.where('dateFin', isGreaterThanOrEqualTo: FieldValue.serverTimestamp())
      );

  Stream<MyEvent> eventStream(String id) => _service.documentStream(
      path: MyPath.event(id), builder: (data) => MyEvent.fromMap(data));

  Stream<List<MyEvent>> eventStreamMaSelectionType(
      List types, List listLieu, List listQuand, GeoPoint position) {
    if (types.isEmpty) {
      types = ['none'];
    }

    if (listLieu.isEmpty && listQuand.isEmpty) {
      return allTypes(types);
    }

    if (listLieu.isEmpty && listQuand.isNotEmpty) {
      switch (listQuand[0] as String) {
        case 'date':
          final date = (listQuand[1] as Timestamp)?.toDate() ?? DateTime.now();
          final dateTimePlusUn = date.add(const Duration(days: 1));

          return dateCompriType(types, date, dateTimePlusUn);
          break;
        case 'ceSoir':
          final date = DateTime.now();
          final dateTimePlusUn = date.add(const Duration(days: 1));

          return dateCompriType(types, date, dateTimePlusUn);
          break;
        case 'demain':
          final date = DateTime.now();
          date.add(const Duration(days: 1));
          final dateTimePlusUn = date.add(const Duration(days: 1));

          return dateCompriType(types, date, dateTimePlusUn);
          break;
        default:
          return allTypes(types);
          break;
      }
    }

    if (listQuand.isEmpty && listLieu.isNotEmpty) {
      switch (listLieu[0] as String) {
        case 'address':
          return addresZoneType(types, listLieu);
          break;
        case 'aroundMe':
          if (position != null) {
            final Query ref = _service.getQuery(
                path: MyPath.events(),
                queryBuilder: (query) =>
                    query.where('types', arrayContainsAny: types));

            final GeoFirePoint center = geo.point(
                latitude: position.latitude, longitude: position.longitude);

            final Stream<List<DocumentSnapshot>> stream = geo
                .collection(collectionRef: ref)
                .within(
                    center: center,
                    radius: (listLieu[1] as int)?.toDouble() ?? 700,
                    field: 'position');

            return stream.map((docs) =>
                docs.map((doc) => MyEvent.fromMap(doc.data())).toList());
          } else {
            return allTypes(types);
          }

          break;
      }
    }

    switch (listLieu[0] as String) {
      case 'address':
        switch (listQuand[0] as String) {
          case 'date':
            final date =
                (listQuand[1] as Timestamp)?.toDate() ?? DateTime.now();
            final dateTimePlusUn = date?.add(const Duration(days: 1));

            adzonDateComType(types, listLieu, date, dateTimePlusUn);

            return date != null && listLieu[1] != null
                ? map2Types(types, listLieu, date, dateTimePlusUn)
                : date != null && listLieu[1] == null
                    ? map23Types(types, date, dateTimePlusUn)
                    : date == null && listLieu[1] != null
                        ? map2Types(types, listLieu, date, dateTimePlusUn)
                        : map23Types(types, date, dateTimePlusUn);
            break;
          case 'ceSoir':
            final date = DateTime.now();
            final dateTimePlusUn = date.add(const Duration(days: 1));

            adzonDateComType(types, listLieu, date, dateTimePlusUn);

            return listLieu[1] != null
                ? map2Types(types, listLieu, date, dateTimePlusUn)
                : map23Types(types, date, dateTimePlusUn);
            break;
          case 'demain':
            final date = DateTime.now();
            date.add(const Duration(days: 1));
            final dateTimePlusUn = date.add(const Duration(days: 1));

            adzonDateComType(types, listLieu, date, dateTimePlusUn);

            return listLieu[1] != null
                ? map2Types(types, listLieu, date, dateTimePlusUn)
                : map23Types(types, date, dateTimePlusUn);
            break;
          default: //A venir
            adreZonType(types, listLieu);
            return listLieu[1] != null
                ? map2adreType(types, listLieu)
                : collectionStreamTypes(types);
            break;
        }
        break;

      case 'aroundMe':
        switch (listQuand[0] as String) {
          case 'date':
            final date =
                (listQuand[1] as Timestamp)?.toDate() ?? DateTime.now();
            final dateTimePlusUn = date.add(const Duration(days: 1));

            if (position != null) {
              final Query ref = _service.getQuery(
                  path: MyPath.events(),
                  queryBuilder: (query) =>
                      query.where('types', arrayContainsAny: types));

              final GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);

              final Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                      center: center,
                      radius: (listLieu[1] as int)?.toDouble() ?? 700,
                      field: 'position',
                      strictMode: true);

              return stream.map((docs) => docs
                  .map((doc) => MyEvent.fromMap(doc.data()))
                  .where((element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                  .toList());
            } else {
              return collectionStreamTypes(types).map((event) => event
                  .where((element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                  .toList());
            }
            break;

          case 'ceSoir':
            final date = DateTime.now();
            final dateTimePlusUn = date.add(const Duration(days: 1));

            if (position != null) {
              final Query ref = _service.getQuery(
                  path: MyPath.events(),
                  queryBuilder: (query) =>
                      query.where('types', arrayContainsAny: types));

              final GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);

              final Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                      center: center,
                      radius: (listLieu[1] as int)?.toDouble() ?? 700,
                      field: 'position',
                      strictMode: true);

              return stream.map((docs) => docs
                  .map((doc) => MyEvent.fromMap(doc.data()))
                  .where((element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                  .toList());
            } else {
              return collectionStreamTypes(types).map((event) => event
                  .where((element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                  .toList());
            }

            break;
          case 'demain':
            final date = DateTime.now();
            date.add(const Duration(days: 1));
            final dateTimePlusUn = date.add(const Duration(days: 1));

            if (position != null) {
              final Query ref = _service.getQuery(
                  path: MyPath.events(),
                  queryBuilder: (query) =>
                      query.where('types', arrayContainsAny: types));

              final GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);

              final Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                      center: center,
                      radius: (listLieu[1] as int)?.toDouble() ?? 700,
                      field: 'position',
                      strictMode: true);

              return stream.map((docs) => docs
                  .map((doc) => MyEvent.fromMap(doc.data()))
                  .where((element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                  .toList());
            } else {
              return dateCompriType(types, date, dateTimePlusUn);
            }

            break;
          default:
            if (position != null) {
              final Query ref = _service.getQuery(
                  path: MyPath.events(),
                  queryBuilder: (query) =>
                      query.where('types', arrayContainsAny: types));

              final GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);

              final Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                      center: center,
                      radius: (listLieu[1] as int)?.toDouble() ?? 700,
                      field: 'position',
                      strictMode: true);

              return stream.map((docs) =>
                  docs.map((doc) => MyEvent.fromMap(doc.data())).toList());
            } else {
              return allTypes(types);
            }

            break;
        }
        break;

      default:
        return allTypes(types);
        break;
    }
  }

  Stream<List<MyEvent>> collectionStreamTypes(List types) {
    return _service.collectionStream(
        path: MyPath.events(),
        queryBuilder: (query) => query
            .where('types', arrayContainsAny: types)
            .where('dateDebut', isGreaterThanOrEqualTo: DateTime.now()),
        builder: (map) => MyEvent.fromMap(map));
  }

  Stream<List<MyEvent>> map2adreType(List types, List listLieu) {
    return collectionStreamTypes(types).map((event) => List.of(event
        .where((event) => event.adresseZone.contains(listLieu[1] as String))));
  }

  void adreZonType(List types, List listLieu) {
    map2adreType(types, listLieu);
  }

  Stream<List<MyEvent>> map23Types(
      List types, DateTime date, DateTime dateTimePlusUn) {
    return _service
        .collectionStream(
            path: MyPath.events(),
            queryBuilder: (query) =>
                query.where('types', arrayContainsAny: types),
            builder: (map) => MyEvent.fromMap(map))
        .map((event) => event
            .where((element) => dateCompriEntre(element, date, dateTimePlusUn))
            .toList());
  }

  Stream<List<MyEvent>> map2Types(
      List types, List listLieu, DateTime date, DateTime dateTimePlusUn) {
    return _service
        .collectionStream(
            path: MyPath.events(),
            queryBuilder: (query) =>
                query.where('types', arrayContainsAny: types),
            builder: (map) => MyEvent.fromMap(map))
        .map((event) => event
            .where((event) => event.adresseZone.contains(listLieu[1]))
            .where((element) => dateCompriEntre(element, date, dateTimePlusUn))
            .toList());
  }

  void adzonDateComType(
      List types, List listLieu, DateTime date, DateTime dateTimePlusUn) {
    map2Types(types, listLieu, date, dateTimePlusUn);
  }

  Stream<List<MyEvent>> addresZoneType(List types, List listLieu) {
    return _service
        .collectionStream(
            path: MyPath.events(),
            queryBuilder: (query) =>
                query.where('types', arrayContainsAny: types),
            builder: (map) => MyEvent.fromMap(map))
        .map((event) =>
        List.of(event.where((event) => event.adresseZone.contains(listLieu[1]))));
  }

  Stream<List<MyEvent>> allTypes(List types) {
    if (types.contains(null)) {
      return const Stream.empty();
    }
    return _service.collectionStream(
        path: MyPath.events(),
        queryBuilder: (query) => query.where('types', arrayContainsAny: types),
        builder: (map) => MyEvent.fromMap(map));
  }

  Stream<List<MyEvent>> dateCompriType(
      List types, DateTime date, DateTime dateTimePlusUn) {
    return map23Types(types, date, dateTimePlusUn);
  }

  Stream<List<MyEvent>> eventStreamMaSelectionGenre(
      List<String> genres, List listLieu, List listQuand, GeoPoint position) {
    if (genres.isEmpty) {
      genres = ['none'];
    }

    if (listLieu.isEmpty && listQuand.isEmpty) {
      return allGenres(genres);
    }

    if (listLieu.isEmpty && listQuand.isNotEmpty) {
      switch (listQuand[0] as String) {
        case 'date':
          final date = (listQuand[1] as Timestamp)?.toDate() ?? DateTime.now();
          final dateTimePlusUn = date.add(const Duration(days: 1));

          return dateCompriGenre(genres, date, dateTimePlusUn);
          break;
        case 'ceSoir':
          final date = DateTime.now();
          final dateTimePlusUn = date.add(const Duration(days: 1));

          return dateCompriGenre(genres, date, dateTimePlusUn);
          break;
        case 'demain':
          final date = DateTime.now();
          date.add(const Duration(days: 1));
          final dateTimePlusUn = date.add(const Duration(days: 1));

          return dateCompriGenre(genres, date, dateTimePlusUn);
          break;
        default:
          return allGenres(genres);
          break;
      }
    }

    if (listQuand.isEmpty && listLieu.isNotEmpty) {
      switch (listLieu[0] as String) {
        case 'address':
          return addresZoneGenre(genres, listLieu);
          break;
        case 'aroundMe':
          if (position != null) {
            final Query ref = _service.getQuery(
                path: MyPath.events(),
                queryBuilder: (query) =>
                    query.where('genres', arrayContainsAny: genres));

            final GeoFirePoint center = geo.point(
                latitude: position.latitude, longitude: position.longitude);

            final Stream<List<DocumentSnapshot>> stream = geo
                .collection(collectionRef: ref)
                .within(
                    center: center,
                    radius: (listLieu[1] as int)?.toDouble() ?? 700,
                    field: 'position');

            return stream.map((docs) =>
                docs.map((doc) => MyEvent.fromMap(doc.data())).toList());
          } else {
            return allGenres(genres);
          }

          break;
      }
    }

    switch (listLieu[0] as String) {
      case 'address':
        switch (listQuand[0] as String) {
          case 'date':
            final date =
                (listQuand[1] as Timestamp)?.toDate() ?? DateTime.now();
            final dateTimePlusUn = date?.add(const Duration(days: 1));

            adzonDateComGenre(genres, listLieu, date, dateTimePlusUn);

            return date != null && listLieu[1] != null
                ? map2Genres(genres, listLieu, date, dateTimePlusUn)
                : date != null && listLieu[1] == null
                    ? map23Genres(genres, date, dateTimePlusUn)
                    : date == null && listLieu[1] != null
                        ? map2Genres(genres, listLieu, date, dateTimePlusUn)
                        : map23Genres(genres, date, dateTimePlusUn);
            break;
          case 'ceSoir':
            final date = DateTime.now();
            final dateTimePlusUn = date.add(const Duration(days: 1));

            adzonDateComGenre(genres, listLieu, date, dateTimePlusUn);

            return listLieu[1] != null
                ? map2Genres(genres, listLieu, date, dateTimePlusUn)
                : map23Genres(genres, date, dateTimePlusUn);
            break;
          case 'demain':
            final date = DateTime.now();
            date.add(const Duration(days: 1));
            final dateTimePlusUn = date.add(const Duration(days: 1));

            adzonDateComGenre(genres, listLieu, date, dateTimePlusUn);

            return listLieu[1] != null
                ? map2Genres(genres, listLieu, date, dateTimePlusUn)
                : map23Genres(genres, date, dateTimePlusUn);
            break;
          default: //A venir
            // adreZonGenre(genres, listLieu);
            return listLieu[1] != null
                ? map2adreGenre(genres, listLieu)
                : collectionStreamGenres(genres);
            break;
        }
        break;

      case 'aroundMe':
        switch (listQuand[0] as String) {
          case 'date':
            final date =
                (listQuand[1] as Timestamp)?.toDate() ?? DateTime.now();
            final dateTimePlusUn = date.add(const Duration(days: 1));

            if (position != null) {
              final Query ref = _service.getQuery(
                  path: MyPath.events(),
                  queryBuilder: (query) =>
                      query.where('genres', arrayContainsAny: genres));

              final GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);

              final Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                      center: center,
                      radius: (listLieu[1] as int)?.toDouble() ?? 700,
                      field: 'position',
                      strictMode: true);

              return stream.map((docs) => docs
                  .map((doc) => MyEvent.fromMap(doc.data()))
                  .where((element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                  .toList());
            } else {
              return collectionStreamGenres(genres).map((event) => List.of(event.where(
                  (element) => dateCompriEntre(element, date, dateTimePlusUn))));
            }
            break;

          case 'ceSoir':
            final date = DateTime.now();
            final dateTimePlusUn = date.add(const Duration(days: 1));

            if (position != null) {
              final Query ref = _service.getQuery(
                  path: MyPath.events(),
                  queryBuilder: (query) =>
                      query.where('genres', arrayContainsAny: genres));

              final GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);

              final Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                      center: center,
                      radius: (listLieu[1] as int)?.toDouble() ?? 700,
                      field: 'position',
                      strictMode: true);

              return stream.map((docs) => docs
                  .map((doc) => MyEvent.fromMap(doc.data()))
                  .where((element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                  .toList());
            } else {
              return collectionStreamGenres(genres).map((event) => List.of(event.where(
                  (element) => dateCompriEntre(element, date, dateTimePlusUn))));
            }

            break;
          case 'demain':
            final date = DateTime.now();
            date.add(const Duration(days: 1));
            final dateTimePlusUn = date.add(const Duration(days: 1));

            if (position != null) {
              final Query ref = _service.getQuery(
                  path: MyPath.events(),
                  queryBuilder: (query) =>
                      query.where('genres', arrayContainsAny: genres));

              final GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);

              final Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                      center: center,
                      radius: (listLieu[1] as int)?.toDouble() ?? 700,
                      field: 'position',
                      strictMode: true);

              return stream.map((docs) => docs
                  .map((doc) => MyEvent.fromMap(doc.data()))
                  .where((element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                  .toList());
            } else {
              return dateCompriGenre(genres, date, dateTimePlusUn);
            }

            break;
          default:
            if (position != null) {
              final Query ref = _service.getQuery(
                  path: MyPath.events(),
                  queryBuilder: (query) =>
                      query.where('genres', arrayContainsAny: genres));

              final GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);

              final Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                      center: center,
                      radius: (listLieu[1] as int)?.toDouble() ?? 700,
                      field: 'position',
                      strictMode: true);

              return stream.map((docs) =>
                  docs.map((doc) => MyEvent.fromMap(doc.data())).toList());
            } else {
              return allGenres(genres);
            }

            break;
        }
        break;

      default:
        return allGenres(genres);
        break;
    }
  }

  Stream<List<MyEvent>> collectionStreamGenres(List genres) {
    return _service.collectionStream(
        path: MyPath.events(),
        queryBuilder: (query) => query
            .where('genres', arrayContainsAny: genres)
            .where('dateDebut', isGreaterThanOrEqualTo: DateTime.now()),
        builder: (map) => MyEvent.fromMap(map));
  }

  Stream<List<MyEvent>> map2adreGenre(List genres, List listLieu) {
    return collectionStreamGenres(genres).map((event) =>
        List.of(event.where((event) => event.adresseZone.contains(listLieu[1]))));
  }

  void adreZonGenre(List genres, List listLieu) {
    map2adreGenre(genres, listLieu);
  }

  Stream<List<MyEvent>> map23Genres(
      List genres, DateTime date, DateTime dateTimePlusUn) {
    return _service
        .collectionStream(
            path: MyPath.events(),
            queryBuilder: (query) =>
                query.where('genres', arrayContainsAny: genres),
            builder: (map) => MyEvent.fromMap(map))
        .map((event) => event
            .where((element) => dateCompriEntre(element, date, dateTimePlusUn))
            .toList());
  }

  Stream<List<MyEvent>> map2Genres(
      List genres, List listLieu, DateTime date, DateTime dateTimePlusUn) {
    return _service
        .collectionStream(
            path: MyPath.events(),
            queryBuilder: (query) =>
                query.where('genres', arrayContainsAny: genres),
            builder: (map) => MyEvent.fromMap(map))
        .map((event) => event
            .where((event) => event.adresseZone.contains(listLieu[1]))
            .where((element) => dateCompriEntre(element, date, dateTimePlusUn))
            .toList());
  }

  void adzonDateComGenre(
      List genres, List listLieu, DateTime date, DateTime dateTimePlusUn) {
    map2Genres(genres, listLieu, date, dateTimePlusUn);
  }

  Stream<List<MyEvent>> addresZoneGenre(List genres, List listLieu) {


    return _service
        .collectionStream(
            path: MyPath.events(),
            queryBuilder: (query) =>
                query.where('genres', arrayContainsAny: genres),
            builder: (map) => MyEvent.fromMap(map))
        .map((event) =>
            List.of(event.where((event) => event.adresseZone.contains(listLieu[1] as String)))
    );
  }

  Stream<List<MyEvent>> allGenres(List genres) {
    if (genres.contains(null)) {
      return const Stream.empty();
    }

    return _service.collectionStream(
        path: MyPath.events(),
        queryBuilder: (query) =>
            query.where('genres', arrayContainsAny: genres),
        builder: (map) => MyEvent.fromMap(map));
  }

  Stream<List<MyEvent>> dateCompriGenre(
      List genres, DateTime date, DateTime dateTimePlusUn) {
    return map23Genres(genres, date, dateTimePlusUn);
  }

  Future<int> nbEvents(String stripeAccount) async {
    return _service.nbDocuments(
        path: MyPath.events(),
        queryBuilder: (query) =>
            query.where('stripeAccount', isEqualTo: stripeAccount));
  }

  Future<int> nbOrganizer() async {
    return _service.nbDocuments(
        path: MyPath.users(),
        queryBuilder: (query) =>
            query.where('typeDeCompte', isEqualTo: 'TypeOfAccount.organizer'));
  }
}
