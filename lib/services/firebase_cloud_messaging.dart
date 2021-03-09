import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:callkeep/callkeep.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:system_alert_window/system_alert_window.dart';

// import 'package:system_alert_window/system_alert_window.dart';
import 'package:uuid/uuid.dart';
import 'package:van_events_project/domain/models/call.dart';
import 'package:van_events_project/domain/models/message.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_chat_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/providers/chat_room_change_notifier.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';

FirebaseMessaging _fcm = FirebaseMessaging();
final FlutterCallkeep _callKeep = FlutterCallkeep();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
bool _callKeepInited = false;

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  await Firebase.initializeApp();

  return NotificationHandler().showNotification(message);
}

class NotificationHandler {
  final String _platformVersion = 'Unknown';

  FirebaseFirestore db = FirebaseFirestore.instance;
  BuildContext context;
  String chatId = '';
  MyUser myUserFromCall;
  bool hasVideo;
  String channel;
  String callId;

  Map<String, dynamic> messageBackground;
  String uid;
  StreamSubscription iosSubscription;
  Timer timeOutTimer;
  bool isTalking = false;

  String newUUID() => Uuid().v4();
  static final NotificationHandler _singleton = NotificationHandler._internal();

  factory NotificationHandler() {
    return _singleton;
  }

  NotificationHandler._internal();

  String get platformVersion => _platformVersion;

  Future<void> initializeFcmNotification(
      String myUid, BuildContext myContext) async {
    if (Platform.isAndroid) {
      await SystemAlertWindow.requestPermissions;
    }

    context = myContext;
    uid = myUid;

    _callKeep.on(CallKeepDidDisplayIncomingCall(), didDisplayIncomingCall);
    _callKeep.on(CallKeepPerformAnswerCallAction(), answerCall);
    _callKeep.on(CallKeepDidPerformDTMFAction(), didPerformDTMFAction);
    _callKeep.on(
        CallKeepDidReceiveStartCallAction(), didReceiveStartCallAction);
    _callKeep.on(CallKeepDidToggleHoldAction(), didToggleHoldCallAction);
    _callKeep.on(
        CallKeepDidPerformSetMutedCallAction(), didPerformSetMutedCallAction);
    _callKeep.on(CallKeepPerformEndCallAction(), endCall);
    _callKeep.on(CallKeepPushKitToken(), onPushKitToken);

    _callKeep.setup(<String, dynamic>{
      'ios': {
        'appName': 'CallKeepDemo',
      },
      'android': {
        'alertTitle': 'Permissions required',
        'alertDescription':
            'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'ok',
      },
    });

    initLocalNotification();

    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        _saveDeviceToken(uid);
        // save the token  OR subscribe to a topic here
      });

      _fcm.requestNotificationPermissions();
    } else {
      _saveDeviceToken(uid);
    }

    // if (Platform.isAndroid) {
    //   _saveDeviceToken(uid);
    // }

    _fcm.configure(
      onBackgroundMessage:
          Platform.isAndroid ? myBackgroundMessageHandler : null,
      onMessage: (Map<String, dynamic> message) async {
        if (message.toString().contains('chatId')) {
          MyMessage myMessage;
          String chatId = '';
          if (Platform.isAndroid) {
            myMessage = MyMessage.fromAndroidFcm(message);
            chatId = message['data']['chatId'].toString();
          } else {
            myMessage = MyMessage.fromIosFcm(message);
            chatId = message['chatId'].toString();
          }

          if (myMessage.idFrom != uid &&
              myContext.read(chatRoomProvider).chatId == null) {
            FirebaseFirestore.instance
                .collection('chats')
                .doc(chatId)
                .collection('chatMembres')
                .doc(uid)
                .update({'lastReceived': DateTime.now()});
          } else if (myMessage.idFrom != uid &&
              myContext.read(chatRoomProvider).chatId == chatId) {
            myContext.read(chatRoomProvider).myNewMessages(myMessage);
          }
        } else if (message.toString().contains('caller_id')) {
          if (Platform.isAndroid) {
            showCall(message);
          }
        } else if (message['from'] == 'topics/newEvent' ||
            message['notification']['title']
                .toString()
                .startsWith('Nouvel évènement')) {
          showNotification(message);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (message['from'] == 'topics/newEvent' ||
            message['notification']['title']
                .toString()
                .startsWith('Nouvel évènement')) {
          showNotification(message);
          return;
        }
        String chatId = '';
        if (Platform.isAndroid) {
          chatId = message['data']['chatId'] as String;
        } else {
          chatId = message['chatId'] as String;
        }
        if (chatId != null) {
          ExtendedNavigator.of(myContext).pushAndRemoveUntil(
            Routes.chatRoom,
            ModalRoute.withName(Routes.routeAuthentication),
            arguments: ChatRoomArguments(chatId: chatId),
          );
        } else if (message.toString().contains('caller_id')) {
          if (Platform.isAndroid) {
            showCall(message);
          }
        }
      },
      onResume: (Map<String, dynamic> message) async {
        if (message['from'] == 'topics/newEvent' ||
            message['notification']['title']
                .toString()
                .startsWith('Nouvel évènement')) {
          showNotification(message);
          return;
        }
        if (message.toString().contains('caller_id')) {
          if (Platform.isAndroid) {
            showCall(message);
          }
        }

//        Navigator.popUntil(context, ModalRoute.withName(Routes.authWidget));
//
//         ExtendedNavigator.of(context).pushAndRemoveUntil(
//           Routes.chatRoom,
//           ModalRoute.withName(Routes.routeAuthentication),
//           arguments: ChatRoomArguments(chatId: chatId),
//         );

//        ExtendedNavigator.ofRouter<Router>().popUntil((route) => route.toString() == Routes.baseScreens);
//        ExtendedNavigator.ofRouter<Router>().pushNamed(
//            Routes.chatRoom,
//            arguments: ChatRoomArguments(chatId: chatId));
      },
    );
  }

  Future<void> answerCall(CallKeepPerformAnswerCallAction event) async {
    final Call myCall = await FirestoreService.instance.getDoc(
        path: MyPath.call(chatId, callId), builder: (map) => Call.fromMap(map));

    if (myCall.callStatus == CallStatus.callSent) {
      await ExtendedNavigator.root.push(Routes.callScreen,
          arguments: CallScreenArguments(
              nom: myUserFromCall.nom,
              imageUrl: myUserFromCall.imageUrl,
              isVideoCall: hasVideo ?? false,
              isCaller: false,
              chatId: chatId,
              callId: callId));
    }
    //
    // ExtendedNavigator.root.push(Routes.callScreen,
    //     arguments: CallScreenArguments(
    //         nom: myUserFromCall.nom,
    //         imageUrl: myUserFromCall.imageUrl,
    //         isVideoCall: hasVideo ?? false,
    //         isCaller: false,
    //         chatId: chatId,
    //         channel: callId));

    // Timer(const Duration(seconds: 1), () {
    //   _callKeep.setCurrentCallActive(callUUID);
    // });
  }

  Future<void> endCall(CallKeepPerformEndCallAction event) async {}

  Future<void> didPerformDTMFAction(CallKeepDidPerformDTMFAction event) async {}

  Future<void> didReceiveStartCallAction(
      CallKeepDidReceiveStartCallAction event) async {
    // ExtendedNavigator.root.push(Routes.pickupScreen,
    //     arguments: PickupScreenArguments(
    //         nom: callerName.toString(),
    //         imageUrl: imageUrl.toString(),
    //         channel: callUUID));
    if (event.handle == null) {
      // @TODO: sometime we receive `didReceiveStartCallAction` with handle` undefined`
      return;
    }
    // final String callUUID = event.callUUID ?? newUUID();
    // calls[callUUID] = Call(event.handle);
    //
    // _callKeep.startCall(callUUID, event.handle, event.handle);
    //
    // Timer(const Duration(seconds: 1), () {
    //   _callKeep.setCurrentCallActive(callUUID);
    // });
  }

  Future<void> didPerformSetMutedCallAction(
      CallKeepDidPerformSetMutedCallAction event) async {}

  Future<void> didToggleHoldCallAction(
      CallKeepDidToggleHoldAction event) async {}

  Future<void> hangup(String callUUID) async {
    _callKeep.endCall(callUUID);
  }

  Future<void> setOnHold(String callUUID, bool held) async {
    _callKeep.setOnHold(callUUID, held);
  }

  Future<void> setMutedCall(String callUUID, bool muted) async {
    _callKeep.setMutedCall(callUUID, muted);
  }

  Future<void> displayIncomingCallDelayed(String number) async {
    Timer(const Duration(seconds: 3), () {
      displayIncomingCall(number);
    });
  }

  Future<void> displayIncomingCall(String number) async {
    final bool hasPhoneAccount = await _callKeep.hasPhoneAccount();
    if (!hasPhoneAccount) {
      await _callKeep.hasDefaultPhoneAccount(context, <String, dynamic>{
        'alertTitle': 'Permissions required',
        'alertDescription':
            'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'ok',
      });
    }
  }

  Future<void> didDisplayIncomingCall(
      CallKeepDidDisplayIncomingCall event) async {
    final number = event.handle;
    hasVideo = event.hasVideo;

    final String idUserfrom = number.substring(0, number.indexOf('/'));
    callId = number.substring(number.indexOf('/') + 1, number.indexOf('!'));
    chatId = number.substring(number.indexOf('!') + 1);

    context
        .read(myChatRepositoryProvider)
        .setCallReceived(chatId: chatId, callId: callId);

    myUserFromCall = await FirestoreService.instance.getDoc(
        path: MyPath.user(idUserfrom), builder: (map) => MyUser.fromMap(map));
  }

  void onPushKitToken(CallKeepPushKitToken event) {
    _saveDeviceToken(uid, voIPToken: event.token);
  }

  Future<void> initLocalNotification() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('launcher_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void setMessageReceived(String chatId, String uid, QuerySnapshot docs) {
    final List<MyMessage> myList =
        List.from(docs.docs.map((e) => MyMessage.fromMap(e.data())));

    myList.sort((a, b) => a.date.compareTo(b.date));

    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('chatMembres')
        .doc(uid)
        .update({'lastReceived': myList.last.date});
  }

  Future<void> showNotification(Map<String, dynamic> message) async {
    // if (!context.read(boolToggleProvider).isNextEvents &&
    //     message.containsKey('newEventId') &&
    //     message['data']['newEventId'] != null) {
    //   return;
    // }
    // if (!context.read(boolToggleProvider).isMessages &&
    //     message.containsKey('chatId') &&
    //     message['data']['chatId'] != null) {
    //   return;
    // }

    String title, type, body, chatId, idTo;
    if (Platform.isIOS) {
      return;
    }
    if (message['data']['chatId'] != null) {
      //chat msg
      title = message['data']['title'] as String;
      type = message['data']['type'] as String;
      body = message['data']['body'] as String;
      chatId = message['data']['chatId'] as String;
      idTo = message['data']['idTo'] as String;

      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'com.vanevents.VanEvents', 'VanEvents', 'VanEvents notification',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
      const iOSPlatformChannelSpecifics = IOSNotificationDetails(
          badgeNumber: 0,
          presentAlert: true,
          presentBadge: true,
          presentSound: true);
      const platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
      String myBody;
      if (type != null) {
        myBody = type == MyMessageType.text.toString() ? body : 'image';
      }
      if (idTo != null) {
        FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('chatMembres')
            .doc(idTo)
            .set({'lastReceived': FieldValue.serverTimestamp()},
                SetOptions(merge: true));
      }

      await flutterLocalNotificationsPlugin.show(
          0, title, myBody, platformChannelSpecifics,
          payload: message.toString());
    } else if (message['data']['caller_id'] != null) {
      _callKeep.backToForeground();
      final payload = message['data'];
      // final callerId = payload['caller_id'] as String;
      final callerName = payload['caller_name'] as String;
      final hasVideo = payload['has_video'] == "true";

      final String isVideo =
          hasVideo ? 'Appel video de : ' : 'Appel audio de : ';

      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'com.vanevents.VanEvents', 'VanEvents', 'VanEvents notification',
          sound: RawResourceAndroidNotificationSound('sonnerie'),
          importance: Importance.max,
          priority: Priority.max,
          ticker: 'ticker');
      const iOSPlatformChannelSpecifics = IOSNotificationDetails(
          badgeNumber: 0,
          presentAlert: true,
          presentBadge: true,
          presentSound: true);
      const platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
          0, 'Appel', isVideo + callerName, platformChannelSpecifics,
          payload: message.toString());
    }

    // if (message['from'] == 'topics/newEvent' ||
    //     message['notification']['title']
    //         .toString()
    //         .startsWith('Nouvel évènement')) {
    //   type = MyMessageType.text.toString();
    // }
  }

  Future<void> _saveDeviceToken(String uid, {String voIPToken}) async {
    await _fcm.getToken().then((token) async {
      await db //supprimer s'il en reste
          .collection('users')
          .doc(uid)
          .collection('tokens')
          .get()
          .then((docs) async {
        if (docs.docs.isNotEmpty) {
          for (final doc in docs.docs) {
            await db
                .collection('users')
                .doc(uid)
                .collection('tokens')
                .doc(doc.id)
                .delete();
          }
        }

        await db
            .collection('users')
            .doc(uid)
            .collection('tokens')
            .doc(token)
            .set(
                voIPToken != null
                    ? {
                        'token': token,
                        'voIPToken': voIPToken,
                        'createAt': FieldValue.serverTimestamp(),
                        'platform': Platform.operatingSystem,
                      }
                    : {
                        'token': token,
                        'createAt': FieldValue.serverTimestamp(),
                        'platform': Platform.operatingSystem,
                      },
                SetOptions(merge: true));
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
      if (payload.contains('chatId')) {
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
            arguments: ChatRoomArguments(
                chatId: payload.substring(payload.indexOf('chatId: ') + 8,
                    payload.indexOf(', idFrom'))),
          );
        }
      } else if (payload.contains('caller_id')) {
        //call

        final callerId = payload.substring(payload.indexOf('caller_id: ') + 11,
            payload.indexOf(', has_video'));
        final callerName = payload.substring(
            payload.indexOf('caller_name: ') + 13, payload.indexOf('}}'));
        final hasVideo = payload.substring(payload.indexOf('has_video: ') + 11,
                payload.indexOf(', caller_id_type')) ==
            "true";

        final newRouteName = Routes.callScreen;
        bool isNewRouteSameAsCurrent = false;

        Navigator.popUntil(context, (route) {
          if (route.settings.name == newRouteName) {
            isNewRouteSameAsCurrent = true;
          }
          return true;
        });

        if (!isNewRouteSameAsCurrent) {
          final String idUserfrom =
              callerId.substring(0, callerId.indexOf('/'));
          final String callId = callerId.substring(
              callerId.indexOf('/') + 1, callerId.indexOf('!'));
          final String chatId = callerId.substring(callerId.indexOf('!') + 1);

          myUserFromCall = await FirestoreService.instance.getDoc(
              path: MyPath.user(idUserfrom),
              builder: (map) => MyUser.fromMap(map));

          final Call myCall = await FirestoreService.instance.getDoc(
              path: MyPath.call(chatId, callId),
              builder: (map) => Call.fromMap(map));

          if (myCall.callStatus == CallStatus.callSent) {
            await ExtendedNavigator.root.push(Routes.callScreen,
                arguments: CallScreenArguments(
                    nom: callerName,
                    imageUrl: myUserFromCall.imageUrl,
                    isVideoCall: hasVideo ?? false,
                    isCaller: false,
                    chatId: chatId,
                    callId: callId));
          }
        }
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

  Future showCall(Map<String, dynamic> message) async {
    final payload = message['data'];
    final callerId = payload['caller_id'] as String; //idUserFrom/callId
    final callerName = payload['caller_name'] as String;
    final hasVideo = payload['has_video'] == "true";

    final String idUserfrom = callerId.substring(0, callerId.indexOf('/'));
    final String callId =
        callerId.substring(callerId.indexOf('/') + 1, callerId.indexOf('!'));
    final String chatId = callerId.substring(callerId.indexOf('!') + 1);

    myUserFromCall = await FirestoreService.instance.getDoc(
        path: MyPath.user(idUserfrom), builder: (map) => MyUser.fromMap(map));

    final Call myCall = await FirestoreService.instance.getDoc(
        path: MyPath.call(chatId, callId), builder: (map) => Call.fromMap(map));

    if (myCall.callStatus == CallStatus.callSent) {
      await ExtendedNavigator.root.push(Routes.callScreen,
          arguments: CallScreenArguments(
              nom: callerName,
              imageUrl: myUserFromCall.imageUrl,
              isVideoCall: hasVideo ?? false,
              isCaller: false,
              chatId: chatId,
              callId: callId));
    }

    return Future.value();
  }

  void setMessageBackground(Map<String, dynamic> message) {
    messageBackground = message;
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
