import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:van_events_project/domain/models/my_chat.dart';
import 'package:van_events_project/domain/models/refund.dart';
import 'package:van_events_project/domain/repositories/my_chat_repository.dart';
import 'package:van_events_project/presentation/widgets/lieu_quand_alertdialog.dart';
import 'package:van_events_project/providers/settings_change_notifier.dart';

final boolToggleProvider = ChangeNotifierProvider.autoDispose<BoolToggle>((ref) {
  return BoolToggle(ref.read(settingsProvider).sharePref);
});

class BoolToggle with ChangeNotifier {
  RefundReason reason;
  final amountList = ['La totalité', 'Une partie'];
  String amount = 'La totalité';

  bool playEffectTocTocToc = false, playEffect = false;
  File imageProfil, idFront, idBack, justificatifDomicile;
  String onGoingUpload;
  double eventCost = 0;
  double eventCostDiscounted;
  List<Asset> images;
  Map<String, int> chatNbMsgNonLu = <String, int>{};
  StreamSubscription<List<MyChat>> streamSubscriptionListChat;
  List<StreamSubscription<Stream<int>>> streamSubscriptionListStream;
  List<StreamSubscription<int>> streamSubscriptionNbMsgNonLu;
  BuildContext progressContext;
  int nbPhotos = 0;
  List<Prediction> suggestions = <Prediction>[];
  Stream<List<MyChat>> streamListChat;
  Lieu lieu;
  Quand quand;
  DateTime dateQuand;
  Position position;
  Map<int, ImageProvider> imageProviderDetail = <int, ImageProvider>{};
  Map<String, ImageProvider> imageProviderEvent = <String, ImageProvider>{};
  Map<String, bool> genre = {
    'Classique': false,
    'Dancehall/Reggae/Soca': false,
    'Électro': false,
    'Jazz': false,
    'Pop': false,
    'RAP': false,
    'RnB': false,
    'Rock': false,
    'Variété française': false,
    'Zouk/Kompa': false,
  };

  Map<String, bool> type = {
    'Concert': false,
    'Dîner': false,
    'Festival': false,
    'Foire': false,
    'Kids': false,
    'Salon': false,
    'Soirée clubbing': false,
    'Spectacle': false,
  };

  DateTime dateDebut, dateFin;
  bool cguCgv = false;
  bool showSpinner = false;
  bool obscureTextLogin = true;
  bool obscuretextRegister = true;
  bool isNewsVanEvents, isNextEvents, isMessages;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  Map<String, int> listTempMessages =
      <String, int>{}; //-1 error; 0 loading; 1 success
  Map<String, File> listPhoto = <String, File>{};

  String selectedAdress;

  DateTime date;

  double zone = 1 / 3;

  String urlIdFront, urlIdBack, urlJD;

  final SharedPreferences sharePref;

  BoolToggle(this.sharePref);

  void setShowSpinner() {
    showSpinner = !showSpinner;
    notifyListeners();
  }

  void initGenre({List genres}) {
    genre = genres == null
        ? {
            'Classique': false,
            'Dancehall/Reggae/Soca': false,
            'Électro': false,
            'Jazz': false,
            'Pop': false,
            'RAP': false,
            'RnB': false,
            'Rock': false,
            'Variété française': false,
            'Zouk/Kompa': false,
          }
        : {
            'Classique': genres.contains('Classique'),
            'Dancehall/Reggae/Soca': genres.contains('Dancehall/Reggae/Soca'),
            'Électro': genres.contains('Électro'),
            'Jazz': genres.contains('Jazz'),
            'Pop': genres.contains('Pop'),
            'RAP': genres.contains('RAP'),
            'RnB': genres.contains('RnB'),
            'Rock': genres.contains('Rock'),
            'Variété française': genres.contains('Variété française'),
            'Zouk/Kompa': genres.contains('Zouk/Kompa'),
          };

  }

  void initType({List types}) {
    type = types == null
        ? {
            'Concert': false,
            'Dîner': false,
            'Spectacle': false,
            'Foire': false,
            'Salon': false,
            'Soirée clubbing': false,
            'Festival': false,
            'Kids': false,
          }
        : {
            'Concert': types.contains('Concert'),
            'Dîner': types.contains('Dîner'),
            'Spectacle': types.contains('Spectacle'),
            'Foire': types.contains('Foire'),
            'Salon': types.contains('Salon'),
            'Soirée clubbing': types.contains('Soirée clubbing'),
            'Festival': types.contains('Festival'),
            'Kids': types.contains('Kids'),
          };
  }

  void modificationDateDebut(DateTime dateDebut) {
    this.dateDebut = dateDebut;
    notifyListeners();
  }

  void modificationGenre(String key) {
    genre[key] = !genre[key];
    notifyListeners();
  }

  void modificationType(String key) {
    type[key] = !type[key];
    notifyListeners();
  }

  void modificationGenreNONotif(String key) {
    genre[key] = !genre[key];
  }

  void modificationTypeNONotif(String key) {
    type[key] = !type[key];
  }

  void setOnGoingUpload(String type) {
    onGoingUpload = type;
    notifyListeners();
  }

  Future<dynamic> getImageGallery(String type) async {
    final _picker = ImagePicker();
    onGoingUpload = type;
    switch (type) {
      case 'Profil':
        final String str =
            (await _picker.getImage(source: ImageSource.gallery))?.path;
        if (str == null) {
          return;
        }
        imageProfil = File(str);
        notifyListeners();
        break;

      case 'idFront':
        final String str =
            (await _picker.getImage(source: ImageSource.gallery))?.path;
        if (str == null) {
          return;
        }
        idFront = File(str);
        return idFront;
      case 'idBack':
        final String str =
            (await _picker.getImage(source: ImageSource.gallery))?.path;
        if (str == null) {
          return;
        }
        idBack = File(str);
        return idBack;
      case 'justificatifDomicile':
        final String str =
            (await _picker.getImage(source: ImageSource.gallery))?.path;
        if (str == null) {
          return;
        }
        justificatifDomicile = File(str);
        return justificatifDomicile;
    }
    notifyListeners();
  }

  Future<dynamic> getImageCamera(String type) async {
    final _picker = ImagePicker();
    onGoingUpload = type;
    switch (type) {
      case 'Profil':
        final String str = (await _picker.getImage(source: ImageSource.camera))?.path;
        if (str == null) {
          return;
        }
        imageProfil = File(str);
        return imageProfil;

      case 'idFront':
        final String str = (await _picker.getImage(source: ImageSource.camera))?.path;
        if (str == null) {
          return;
        }
        idFront = File(str);
        return idFront;
      case 'idBack':
        final String str = (await _picker.getImage(source: ImageSource.camera))?.path;
        if (str == null) {
          return;
        }
        idBack = File(str);
        return idBack;
      case 'justificatifDomicile':
        final String str = (await _picker.getImage(source: ImageSource.camera))?.path;
        if (str == null) {
          return;
        }
        justificatifDomicile = File(str);
        return justificatifDomicile;

      case 'Photos':
        break;
    }
    notifyListeners();
  }

  void setObscureTextRegister() {
    obscuretextRegister = !obscuretextRegister;
    notifyListeners();
  }

  void setObscureTextLogin() {
    obscureTextLogin = !obscureTextLogin;
    notifyListeners();
  }

  void addTempMessage(String id) {
    listTempMessages.addAll({id: 0});
    notifyListeners();
  }

  void setTempMessageToError(String id) {
    listTempMessages[id] = -1;
    notifyListeners();
  }

  void setTempMessageToloaded(String id) {
    listTempMessages[id] = 1;
    notifyListeners();
  }

  void addListPhoto(String path, File image) {
    listPhoto.addAll({path: image});
    notifyListeners();
  }

  void changeCGUCGV() {
    cguCgv = !cguCgv;
    notifyListeners();
  }

  void modificationDateFinAffiche(DateTime dt) {}

  void setSuggestions(List<Prediction> suggestions) {
    this.suggestions = suggestions;
    notifyListeners();
  }

  void setLieux(Lieu value) {
    lieu = value;

    notifyListeners();
  }

  void setSelectedAdress(String e) {
    selectedAdress = e;
    notifyListeners();
  }

  void setQuand(Quand value) {
    quand = value;
    notifyListeners();
  }

  void initLieuQuandGeo({List listLieu, List listQuand}) {

    Quand quand;

    switch (listQuand[0] as String) {
      case 'date':
        quand = Quand.date;
        dateQuand = (listQuand[1] as Timestamp)?.toDate();
        break;
      case 'ceSoir':
        quand = Quand.ceSoir;
        break;
      case 'demain':
        quand = Quand.demain;
        break;
      case 'avenir':
        quand = Quand.avenir;
        break;
      default:
        quand = Quand.avenir;
    }

    Lieu lieu;
    //address, aroundMe

    switch (listLieu[0] as String) {
      case 'address':
        lieu = Lieu.address;
        setSelectedAdress(listLieu[1] as String);
        break;
      case 'aroundMe':
        lieu = Lieu.aroundMe;
        break;
      default:
        lieu = Lieu.address;
    }

    this.lieu = lieu;
    this.quand = quand;

    notifyListeners();
  }

  void modificationLieuEtDate(List<String> myLieu, List<String> myQuand) {}

  void setSelectedDate(DateTime date) {
    this.date = date;
  }

  void initSelectedAdress(String e) {
    selectedAdress = e;
  }

  void newZone(double newZone) {
    zone = newZone;
    notifyListeners();
  }

  void setPosition(Position position) {
    this.position = position;
  }

  void setUrlFront(String url) {
    urlIdFront = url;
    notifyListeners();
  }

  void setJD(String url) {
    urlJD = url;
    notifyListeners();
  }

  void setUrlBack(String url) {
    urlIdBack = url;
    notifyListeners();
  }

  void setUrljustificatifDomicile(String url) {
    urlJD = url;
    notifyListeners();
  }

  Future<void> initial() async {
    if (isNewsVanEvents != null) {
      return;
    }

    isNewsVanEvents = sharePref.getBool('isNewsVanEvents');
    isNextEvents = sharePref.getBool('isNextEvents');
    isMessages = sharePref.getBool('isMessages');
    isNewsVanEvents ??= true;

    isNextEvents ??= true;

    isMessages ??= true;

    setIsEnableNotificationNoNotif(isNewsVanEvents, 'News VanEvents');
    setIsEnableNotificationNoNotif(isNextEvents, 'Next Events');
    setIsEnableNotificationNoNotif(isMessages, 'Messages');
  }

  bool isEnableNotification(String e) {
    switch (e) {
      case 'News VanEvents':
        return isNewsVanEvents;
      case 'Next Events':
        return isNextEvents;
      default:
        return isMessages;
    }
  }

  void setIsEnableNotification(bool b, String e) {
    switch (e) {
      case 'News VanEvents':
        isNewsVanEvents = b;
        sharePref.setBool('isNewsVanEvents', b);
        if (b) {
          firebaseMessaging.subscribeToTopic('VanEvent');
        } else {
          firebaseMessaging.unsubscribeFromTopic('VanEvent');
        }
        break;
      case 'Next Events':
        isNextEvents = b;
        sharePref.setBool('isNextEvents', b);
        if (b) {
          FirebaseMessaging().subscribeToTopic('newEvent');
        } else {
          FirebaseMessaging().unsubscribeFromTopic('newEvent');
        }

        break;
      default:
        isMessages = b; //Messages
        sharePref.setBool('isMessages', b);
    }
    notifyListeners();
  }

  void setIsEnableNotificationNoNotif(bool b, String e) {
    switch (e) {
      case 'News VanEvents':
        isNewsVanEvents = b;
        if (b) {
          firebaseMessaging.subscribeToTopic('VanEvent');
        } else {
          firebaseMessaging.unsubscribeFromTopic('VanEvent');
        }
        sharePref.setBool('isNewsVanEvents', b);
        break;
      case 'Next Events':
        isNextEvents = b;

        if (b) {
          FirebaseMessaging().subscribeToTopic('newEvent');
        } else {
          FirebaseMessaging().unsubscribeFromTopic('newEvent');
        }

        sharePref.setBool('isNextEvents', b);
        break;
      default:
        isMessages = b; //Messages

        sharePref.setBool('isMessages', b);
    }
  }

  void addDetailsPhotos(ImageProvider<Object> imageProvider, int index) {

    if (!imageProviderDetail.containsKey(index)) {
      imageProviderDetail.addAll({index: imageProvider});
    }
  }

  void addEventsPhotos(ImageProvider<Object> imageProvider, String url) {
    if (!imageProviderEvent.containsKey(url)) {
      imageProviderEvent.addAll({url: imageProvider});
    }
  }

  @override
  void dispose() {
    streamSubscriptionListChat?.cancel();
    for(final stream in streamSubscriptionListStream){
      stream?.cancel();
    }
    for(final stream in streamSubscriptionNbMsgNonLu){
      stream?.cancel();
    }

    super.dispose();
  }

  Future<void> setNbMsgNonLu(BuildContext context, String uid) async {
    if (streamListChat != null) {
      return;
    }

    final AudioCache audioCache = AudioCache();
    final AudioPlayer advancedPlayer = AudioPlayer();

    if (Platform.isIOS) {
      if (audioCache.fixedPlayer != null) {
        audioCache.fixedPlayer.startHeadlessService();
      }
      advancedPlayer.startHeadlessService();
    }

    streamListChat =
        context.read(myChatRepositoryProvider).chatRoomsStream(uid);

    streamSubscriptionListChat?.cancel();
    streamSubscriptionListChat = streamListChat.listen((myChat) {
      streamSubscriptionNbMsgNonLu = List<StreamSubscription<int>>.generate(
          myChat.length, (index) => null);
      streamSubscriptionListStream =
          List<StreamSubscription<Stream<int>>>.generate(
              myChat.length, (index) => null);

      for (int i = 0; i < myChat.length; i++) {
        final stream = context
            .read(myChatRepositoryProvider)
            .nbMessagesNonLu(myChat[i].id);
        streamSubscriptionListStream[i]?.cancel();
        streamSubscriptionListStream[i] = stream.listen((fluxStream) {
          streamSubscriptionNbMsgNonLu[i]?.cancel();
          streamSubscriptionNbMsgNonLu[i] = fluxStream.listen((event) async {
            chatNbMsgNonLu.addAll({myChat[i].id: event});

            if (chatNbMsgNonLu.keys.length == myChat.length) {
              if (event > 0) {
                audioCache.play('sound/TOC_TOC_TOC_.aac').catchError((e) {
                  debugPrint(e.toString());
                });
              }
            }
            notifyListeners();
          });
        });
      }
    });
  }

  void setRefundRaison(RefundReason val) {
    reason = val;
    notifyListeners();
  }

  void setAmount(String value) {
    amount = value;
    notifyListeners();
  }

  void setProgressContext(BuildContext context) {
    progressContext = context;
  }
}
