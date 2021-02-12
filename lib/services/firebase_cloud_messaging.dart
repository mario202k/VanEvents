import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:van_events_project/domain/models/message.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/providers/toggle_bool.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';

FirebaseMessaging _fcm = FirebaseMessaging();

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  debugPrint('coucou!!!!!');
  debugPrint(message.toString());
  if (message['data']['caller_id'] != null) {
    var payload = message['data'];
    var callerId = payload['caller_id'] as String;
    final callerName = payload['caller_name'] as String;
    var uuid = payload['uuid'] as String;
    var imageUrl = payload['imageUrl'] as String;

    ExtendedNavigator.root.push(Routes.pickupScreen,
        arguments: PickupScreenArguments(nom: callerName, imageUrl: imageUrl));

    return null;
  } else {
    String chatId = message["chatId"] as String;
    String idTo = message['idTo'] as String;
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('chatMembres')
        .doc(idTo)
        .update({'lastReceived': DateTime.now()});
    return NotificationHandler().showNotificationChatMessage(message);
  }
}

class NotificationHandler {
  final String _platformVersion = 'Unknown';

  FirebaseFirestore db = FirebaseFirestore.instance;

  String chatId = '';
  BuildContext context;
  String uid;
  StreamSubscription iosSubscription;
  static final NotificationHandler _singleton = NotificationHandler._internal();

  factory NotificationHandler() {
    return _singleton;
  }

  NotificationHandler._internal();

  String get platformVersion => _platformVersion;

  initializeFcmNotification(String myUid, BuildContext context) async {
    this.context = context;
    uid = myUid;

    initLocalNotification();

    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        //_saveDeviceToken(uid);
        // save the token  OR subscribe to a topic here
      });

      _fcm.requestNotificationPermissions();
    } else {
      //_saveDeviceToken(uid);
    }

    _saveDeviceToken(uid);

    _fcm.configure(
      onBackgroundMessage:
          Platform.isAndroid ? myBackgroundMessageHandler : null,
      onMessage: (Map<String, dynamic> message) async {
        // await AwesomeNotifications().createNotification(
        //     content: NotificationContent(
        //         id: 10,
        //         channelKey: 'basic_channel',
        //         title: 'Simple Notification',
        //         body: 'Simple body'
        //     )
        // );

        // if (message.containsKey('chatId') ||
        //     message['data']['chatId'] != null) {
        //   MyMessage myMessage;
        //   String chatId = '';
        //   if (Platform.isAndroid) {
        //     myMessage = MyMessage.fromAndroidFcm(message);
        //     chatId = message['data']['chatId'];
        //   } else {
        //     myMessage = MyMessage.fromIosFcm(message);
        //     chatId = message['chatId'];
        //   }
        //
        //   print(chatId);
        //   print(context.read(chatRoomProvider).chatId);
        //   if (myMessage.idFrom != uid &&
        //       context.read(chatRoomProvider).chatId == null) {
        //     FirebaseFirestore.instance
        //         .collection('chats')
        //         .doc(chatId)
        //         .collection('chatMembres')
        //         .doc(uid)
        //         .update({'lastReceived': DateTime.now()});
        //   } else if (myMessage.idFrom != uid &&
        //       context.read(chatRoomProvider).chatId == chatId) {
        //     print('!!!!!');
        //     context.read(chatRoomProvider).myNewMessages(myMessage);
        //   }
        // } else if (message['from'] == 'topics/newEvent' ||
        //     message['notification']['title']
        //         .toString()
        //         .startsWith('Nouvel évènement')) {
        //   showNotificationChatMessage(message);
        // } else {
        //   showCall(message);
        // }
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (message['from'] == 'topics/newEvent' ||
            message['notification']['title']
                .toString()
                .startsWith('Nouvel évènement')) {
          showNotificationChatMessage(message);
          return;
        }
        String chatId = '';
        if (Platform.isAndroid) {
          chatId = message['data']['chatId'] as String;
        } else {
          chatId = message['chatId'] as String;
        }
        if (chatId != null) {
          ExtendedNavigator.of(context).pushAndRemoveUntil(
            Routes.chatRoom,
            ModalRoute.withName(Routes.routeAuthentication),
            arguments: ChatRoomArguments(chatId: chatId),
          );
        }
      },
      onResume: (Map<String, dynamic> message) async {
        if (message['from'] == 'topics/newEvent' ||
            message['notification']['title']
                .toString()
                .startsWith('Nouvel évènement')) {
          showNotificationChatMessage(message);
          return;
        }
        String chatId = '';
        if (Platform.isAndroid) {
          chatId = message['data']['chatId'] as String;
        } else {
          chatId = message['chatId'] as String;
        }

//        Navigator.popUntil(context, ModalRoute.withName(Routes.authWidget));

        ExtendedNavigator.of(context).pushAndRemoveUntil(
          Routes.chatRoom,
          ModalRoute.withName(Routes.routeAuthentication),
          arguments: ChatRoomArguments(chatId: chatId),
        );
//        ExtendedNavigator.ofRouter<Router>().popUntil((route) => route.toString() == Routes.baseScreens);
//        ExtendedNavigator.ofRouter<Router>().pushNamed(
//            Routes.chatRoom,
//            arguments: ChatRoomArguments(chatId: chatId));
      },
    );
  }

  // Future<void> initializeFirebaseService() async {
  //   String firebaseAppToken;
  //   bool isFirebaseAvailable;
  //
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     isFirebaseAvailable = await AwesomeNotifications().isFirebaseAvailable;
  //
  //     if(isFirebaseAvailable){
  //       try {
  //         firebaseAppToken = await AwesomeNotifications().firebaseAppToken;
  //         debugPrint('Firebase token: $firebaseAppToken');
  //       } on Exception {
  //         firebaseAppToken = 'failed';
  //         debugPrint('Firebase failed to get token');
  //       }
  //     }
  //     else {
  //       firebaseAppToken = 'unavailable';
  //       debugPrint('Firebase is not available on this project');
  //     }
  //
  //   } on Exception {
  //     isFirebaseAvailable = false;
  //     firebaseAppToken = 'Firebase is not available on this project';
  //   }
  //
  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted){
  //     _firebaseAppToken = firebaseAppToken;
  //     return;
  //   }
  //
  //   setState(() {
  //     _firebaseAppToken = firebaseAppToken;
  //   });
  // }

  Future<void> initLocalNotification() async {
    // // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    // const AndroidInitializationSettings initializationSettingsAndroid =
    // AndroidInitializationSettings('app_icon');
    // final IOSInitializationSettings initializationSettingsIOS =
    // IOSInitializationSettings(
    //     onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    //
    // final InitializationSettings initializationSettings = InitializationSettings(
    //     android: initializationSettingsAndroid,
    //     iOS: initializationSettingsIOS);
    // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //     onSelectNotification: onSelectNotification);

    // AwesomeNotifications().initialize(
    //     null,
    //     [
    //       NotificationChannel(
    //           channelKey: 'basic_channel',
    //           channelName: 'Basic notifications',
    //           channelDescription: 'Notification channel for basic tests',
    //           defaultColor: Color(0xFF9D50DD),
    //           ledColor: Colors.white
    //       )
    //
    //     ]
    // );
    //
    // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    //   if (!isAllowed) {
    //     // Insert here your friendly dialog box before call the request method
    //     // This is very important to not harm the user experience
    //     AwesomeNotifications().requestPermissionToSendNotifications();
    //   }
    // });
    //
    // AwesomeNotifications().actionStream.listen(
    //         (receivedNotification){
    //           print(receivedNotification.payload);
    //
    //           //
    //           // ExtendedNavigator.root.push(Routes.pickupScreen,
    //           //     arguments: PickupScreenArguments(nom: callerName, imageUrl: imageUrl));
    //
    //
    //         }
    // );
  }

  void setMessageReceived(String chatId, String uid, QuerySnapshot docs) {
    List<MyMessage> myList =
        List.from(docs.docs.map((e) => MyMessage.fromMap(e.data())));

    myList.sort((a, b) => a.date.compareTo(b.date));

    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('chatMembres')
        .doc(uid)
        .update({'lastReceived': myList.last.date});
  }

  Future<void> showNotificationChatMessage(Map<String, dynamic> message) async {
    if (!context.read(boolToggleProvider).isNextEvents &&
        message.containsKey('newEventId')) {
      return;
    }
    if (!context.read(boolToggleProvider).isMessages &&
        message.containsKey('chatId')) {
      return;
    }

    String title, type, body, chatId;

    if (Platform.isIOS) {
      title = message['aps'] != null
          ? message['aps']['alert']['title'] as String
          : message['notification']['title'] as String;
      type = message['type'] as String;
      body = message['aps'] != null
          ? message['aps']['alert']['body'] as String
          : message['notification']['body'] as String;
      chatId = message['chatId'] as String;
    } else {
      title = message['notification']['title'] as String;
      type = message['data']['type'] as String;
      body = message['notification']['body'] as String;
      chatId = message['data']['chatId'] as String;
    }

    if (message['from'] == 'topics/newEvent' ||
        message['notification']['title']
            .toString()
            .startsWith('Nouvel évènement')) {
      type = MyMessageType.text.toString();
    }

    // var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    //     'com.vanevents.VanEvents', 'VanEvents', 'VanEvents notification',
    //     playSound: true,
    //     sound: RawResourceAndroidNotificationSound(
    //         'android/app/src/main/res/raw/sonnerie.aac'),
    //     enableVibration: true,
    //     importance: Importance.max,
    //     priority: Priority.high,
    //     ticker: 'ticker');
    // var iOSPlatformChannelSpecifics = IOSNotificationDetails(
    //     badgeNumber: 0,
    //     presentAlert: true,
    //     presentBadge: true,
    //     presentSound: true);
    // var platformChannelSpecifics = NotificationDetails(
    //     android: androidPlatformChannelSpecifics,
    //     iOS: iOSPlatformChannelSpecifics);
    //
    // await flutterLocalNotificationsPlugin.show(
    //     0,
    //     title,
    //     type == MyMessageType.text.toString() ? body : 'image',
    //     platformChannelSpecifics,
    //     payload: chatId);

    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('chatMembres')
        .doc(uid)
        .update({'lastReceived': DateTime.now()});
  }

  Future<void> _saveDeviceToken(String uid) async {
    await _fcm.getToken().then((token) async {
      await db //supprimer s'il en reste
          .collection('users')
          .doc(uid)
          .collection('tokens')
          .get()
          .then((docs) async {
        if (docs.docs.isNotEmpty) {
          docs.docs.forEach((doc) async {
            await db
                .collection('users')
                .doc(uid)
                .collection('tokens')
                .doc(doc.id)
                .delete();
          });
        }

        await db
            .collection('users')
            .doc(uid)
            .collection('tokens')
            .doc(token)
            .set({
          'token': token,
          'createAt': FieldValue.serverTimestamp(),
          'platform': Platform.operatingSystem,
        }, SetOptions(merge: true));
      });
    }).catchError((err) {
      debugPrint(err.toString());
    });

    // subscribeTo();
  }

//
//  Future<void> _showBigPictureNotification(message) async {
//    var rng = new Random();
//    var notifId = rng.nextInt(100);
//
//    var largeIconPath = await _downloadAndSaveImage(
//        'https://cdn.pixabay.com/photo/2019/04/21/21/29/pattern-4145023_960_720.jpg',
//        'largeIcon');
//    var bigPicturePath = await _downloadAndSaveImage(
//        'https://cdn.pixabay.com/photo/2019/04/21/21/29/pattern-4145023_960_720.jpg',
//        'bigPicture');
//    var bigPictureStyleInformation = BigPictureStyleInformation(
//        bigPicturePath, BitmapSource.FilePath,
//        largeIcon: largeIconPath,
//        largeIconBitmapSource: BitmapSource.FilePath,
//        contentTitle: message['data']['title'],
//        htmlFormatContentTitle: true,
//        summaryText: message['data']['body'],
//        htmlFormatSummaryText: true);
//    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//        '12', 'trading_id', message['data']['body'],
//        importance: Importance.High,
//        priority: Priority.High,
//        style: AndroidNotificationStyle.BigPicture,
//        styleInformation: bigPictureStyleInformation);
//    var platformChannelSpecifics =
//    NotificationDetails(androidPlatformChannelSpecifics, null);
//    await flutterLocalNotificationsPlugin.show(
//        notifId,
//        message['data']['title'],
//        message['data']['body'],
//        platformChannelSpecifics,
//        payload: message['data']['body']);
//  }
//
//  Future<void> _showBigTextNotification(message) async {
//    var rng = new Random();
//    var notifId = rng.nextInt(100);
//    var bigTextStyleInformation = BigTextStyleInformation(
//        message['data']['body'],
//        htmlFormatBigText: true,
//        contentTitle: message['data']['title'],
//        htmlFormatContentTitle: true,
//        summaryText: message['data']['body'],
//        htmlFormatSummaryText: true);
//    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//        '12', 'trading_id', '',
//        importance: Importance.High,
//        priority: Priority.High,
//        style: AndroidNotificationStyle.BigText,
//        styleInformation: bigTextStyleInformation);
//    var platformChannelSpecifics =
//    NotificationDetails(androidPlatformChannelSpecifics, null);
//    await flutterLocalNotificationsPlugin.show(
//        notifId,
//        message['data']['title'],
//        message['data']['body'],
//        platformChannelSpecifics,
//        payload: message['data']['body']);
//  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      final newRouteName = Routes.chatRoom;
      bool isNewRouteSameAsCurrent = false;

      Navigator.popUntil(context, (route) {
        if (route.settings.name == newRouteName) {
          isNewRouteSameAsCurrent = true;
        }
        return true;
      });

      if (!isNewRouteSameAsCurrent) {
        await ExtendedNavigator.of(context).push(
          Routes.chatRoom,
          arguments: ChatRoomArguments(chatId: payload),
        );
      }
    } else {
      await ExtendedNavigator.of(context).push(Routes.routeAuthentication);
    }
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) => CupertinoAlertDialog(
    //     title: Text(title),
    //     content: Text(body),
    //     actions: [
    //       CupertinoDialogAction(
    //         isDefaultAction: true,
    //         child: Text('Ok'),
    //         onPressed: () async {
    //           Navigator.of(context, rootNavigator: true).pop();
    //           await Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => ChatRoom(payload),
    //             ),
    //           );
    //         },
    //       )
    //     ],
    //   ),
    // );
    //onSelectNotification(payload);
  }

  Future showCall(Map<String, dynamic> message) {
    var payload = message['data'];
    var callerId = payload['caller_id'] as String;
    var callerName = payload['caller_name'] as String;
    var uuid = payload['uuid'] as String;
    var imageUrl = payload['imageUrl'] as String;

    final callUUID = uuid ?? Uuid().v4();

    ExtendedNavigator.root.push(Routes.pickupScreen,
        arguments: PickupScreenArguments(nom: callerName, imageUrl: imageUrl));

    return Future.value();
  }

//
//  Future<String> _downloadAndSaveImage(String url, String fileName) async {
//    var directory = await getApplicationDocumentsDirectory();
//    var filePath = '${directory.path}/$fileName';
//    var response = await http.get(url);
//    var file = File(filePath);
//    await file.writeAsBytes(response.bodyBytes);
//    return filePath;
//  }
}
