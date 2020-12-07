import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/message.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/providers/chat_room_change_notifier.dart';
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  return NotificationHandler().showNotification(message);
}

class NotificationHandler {
  String _platformVersion = 'Unknown';


  FirebaseFirestore db = FirebaseFirestore.instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  FirebaseMessaging _fcm = FirebaseMessaging();
  String chatId = '';
  BuildContext context;
  StreamSubscription iosSubscription;
  static final NotificationHandler _singleton =
      new NotificationHandler._internal();

  factory NotificationHandler() {
    return _singleton;
  }

  NotificationHandler._internal();

  String get platformVersion => _platformVersion;

  initializeFcmNotification(String uid, BuildContext context) async {
    this.context = context;

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(
        requestSoundPermission: true,
        requestAlertPermission: true,
        requestBadgePermission: true,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        //_saveDeviceToken(uid);
        // save the token  OR subscribe to a topic here
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings(
          provisional: false, sound: true, badge: true, alert: true));
    } else {
      //_saveDeviceToken(uid);
    }

    _saveDeviceToken(uid);

    _fcm.configure(
      onBackgroundMessage:
          Platform.isAndroid ? myBackgroundMessageHandler : null,
      onMessage: (Map<String, dynamic> message) async {
        print(message);
        MyMessage myMessage;
        String chatId = '';
        if (Platform.isAndroid) {
          myMessage = MyMessage.fromAndroidFcm(message);
          chatId = message['data']['chatId'];
        } else {
          myMessage = MyMessage.fromIosFcm(message);
          chatId = message['chatId'];
        }
        if (myMessage.idFrom != uid ) {
          showNotification(message);
        }
        if(myMessage.idFrom != uid && context.read(chatRoomProvider).chatId == chatId){
          context.read(chatRoomProvider).myNewMessages(myMessage);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        String chatId = '';
        if (Platform.isAndroid) {
          chatId = message['data']['chatId'];
        } else {
          chatId = message['chatId'];
        }

        ExtendedNavigator.of(context).pushAndRemoveUntil(
          Routes.chatRoom,
          ModalRoute.withName(Routes.routeAuthentication),
          arguments: ChatRoomArguments(chatId: chatId),
        );
      },
      onResume: (Map<String, dynamic> message) async {
        String chatId = '';
        if (Platform.isAndroid) {
          chatId = message['data']['chatId'];
        } else {
          chatId = message['chatId'];
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

  void showNotification(Map<String, dynamic> message) async {
    // if(context.read(boolToggleProvider).isEnableNotificationMessagerie != null &&
    //     context.read(boolToggleProvider).isEnableNotificationMessagerie  == false){
    //   return;
    // }

    String title, type, body, chatId;

    if (Platform.isIOS) {
      title = message['aps'] != null
          ? message['aps']['alert']['title']
          : message['notification']['title'];
      type = message['type'];
      body = message['aps'] != null
          ? message['aps']['alert']['body']
          : message['notification']['body'];
      chatId = message['chatId'];
    } else {
      title = message['notification']['title'];
      type = message['data']['type'];
      body = message['notification']['body'];
      chatId = message['data']['chatId'];
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.vaninamario.crossroads_events',
        'Crossroads Events',
        'your channel description',
        playSound: true,
        enableVibration: true,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        badgeNumber: 0,
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, title, type == MyMessageType.text.toString() ? body : 'image', platformChannelSpecifics,
        payload: chatId);
  }

  _saveDeviceToken(String uid) async {
    _fcm.getToken().then((token) async {
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
      print(err);
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
//    if (payload != null) {
//      debugPrint('notification payload: ' + payload);
//    }

    //await flutterLocalNotificationsPlugin.cancelAll();
    //Route route = MaterialPageRoute(builder: (context) => ChatRoom(chatId));
    // if(route.isActive){
    //   await ExtendedNavigator.of(context).push(
    //     Routes.chatRoom,
    //     arguments: ChatRoomArguments(chatId: payload),
    //   );
    // }

    // final routeName = route?.settings?.name;
    // print(routeName);
    // print('!!!!');
    // print(route.isCurrent);
    // print(route.isActive);
    // print(route.isFirst);
    // if (routeName != null && routeName == nav) {
    //   Navigator.of(context).pushNamed(nav);
    //   print(route.settings.name);
    // }
    //
    // await Navigator.of(context).pushNamedAndRemoveUntil
    //   (Routes.chatRoom, (route) => false,arguments: chatId);

    // await ExtendedNavigator.of(context).pushAndRemoveUntil(
    //   Routes.chatRoom,(route)=>
    //   ModalRoute.withName(Routes.authentication).,
    //   arguments: ChatRoomArguments(chatId: payload),
    // );

    //ExtendedNavigator.ofRouter<Router>().pushNamed(Routes.chatRoom,arguments: ChatRoomArguments(chatId: payload) );
    //await ExtendedNavigator(router: null).pushNamed(Routes.baseScreens);
    // await Navigator.push(
    //   context,
    //   new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
    // );
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
