import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:callkeep/callkeep.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:system_alert_window/system_alert_window.dart';
import 'package:uuid/uuid.dart';
import 'package:van_events_project/domain/models/message.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/providers/chat_room_change_notifier.dart';
import 'package:van_events_project/providers/toggle_bool.dart';
import 'package:van_events_project/services/firestore_path.dart';
import 'package:van_events_project/services/firestore_service.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';

FirebaseMessaging _fcm = FirebaseMessaging();
final FlutterCallkeep _callKeep = FlutterCallkeep();
bool _callKeepInited = false,
_isShowingWindow = false,
_isUpdatedWindow = false;



Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  await Firebase.initializeApp();
  print(message);
  if (message['data']['caller_id'] != null) {
    final payload = message['data'];
    final callerId = payload['caller_id'] as String;
    final callerName = payload['caller_name'] as String;
    final hasVideo = payload['has_video'] == "true";



    bool appIsOpened = await _callKeep.backToForeground();
    print(appIsOpened);
    print('appIsOpened');
    if (appIsOpened) {

      print('APP is opened, use callkeep display incoming call now.');

      // NotificationHandler().showCall(message);

      print('test!!!');

    } else {
      print('APP is closed, wake it up and use callkeep to display incoming calls.');
    }



    return null;
  } else if(message["data"]["chatId"] != null) {

    return NotificationHandler().showNotificationChatMessage(message);
  }
}

class Call {
  Call(this.number);

  String number;
  bool held = false;
  bool muted = false;
}

class NotificationHandler {
  final String _platformVersion = 'Unknown';

  FirebaseFirestore db = FirebaseFirestore.instance;
  BuildContext context;
  String chatId = '';
  MyUser myUserFromCall;
  bool hasVideo;

  String uid;
  StreamSubscription iosSubscription;
  Map<String, Call> calls = {};
  Timer timeOutTimer;
  bool isTalking = false;

  String newUUID() => Uuid().v4();
  static final NotificationHandler _singleton = NotificationHandler._internal();

  factory NotificationHandler() {
    return _singleton;
  }

  NotificationHandler._internal();

  String get platformVersion => _platformVersion;

  initializeFcmNotification(String myUid, BuildContext myContext) async {
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
        //_saveDeviceToken(uid);
        // save the token  OR subscribe to a topic here
      });

      _fcm.requestNotificationPermissions();
    } else {
      //_saveDeviceToken(uid);
    }




    _fcm.configure(
      onBackgroundMessage:
          Platform.isAndroid ? myBackgroundMessageHandler : null,
      onMessage: (Map<String, dynamic> message) async {
        print(message);


        if (message.containsKey('chatId') ||
            message['data']['chatId'] != null) {
          MyMessage myMessage;
          String chatId = '';
          if (Platform.isAndroid) {
            myMessage = MyMessage.fromAndroidFcm(message);
            chatId = message['data']['chatId'].toString();
          } else {
            myMessage = MyMessage.fromIosFcm(message);
            chatId = message['chatId'].toString();
          }

          print(chatId);
          print(myContext.read(chatRoomProvider).chatId);
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
            print('!!!!!');
            myContext.read(chatRoomProvider).myNewMessages(myMessage);
          }
        } else if (message['from'] == 'topics/newEvent' ||
            message['notification']['title']
                .toString()
                .startsWith('Nouvel évènement')) {
          showNotificationChatMessage(message);
        } else {
          showCall(message);
        }
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
          ExtendedNavigator.of(myContext).pushAndRemoveUntil(
            Routes.chatRoom,
            ModalRoute.withName(Routes.routeAuthentication),
            arguments: ChatRoomArguments(chatId: chatId),
          );
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume');
        print(message);
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

  void removeCall(String callUUID) {
    calls.remove(callUUID);
  }

  void setCallHeld(String callUUID, bool held) {
    calls[callUUID].held = held;
  }

  void setCallMuted(String callUUID, bool muted) {
    calls[callUUID].muted = muted;
  }

  Future<void> answerCall(CallKeepPerformAnswerCallAction event) async {
    final String callUUID = event.callUUID;
    final String number = calls[callUUID].number;
    print('[answerCall] $callUUID, number: $number');

    // _callKeep.startCall(event.callUUID, number, number);

    ExtendedNavigator.root.push(Routes.callScreen,
        arguments: CallScreenArguments(
            nom: myUserFromCall.nom,
            imageUrl: myUserFromCall.imageUrl,
            isVideoCall: hasVideo ?? false,
            channel: number));

    // Timer(const Duration(seconds: 1), () {
    //   print('[setCurrentCallActive] $callUUID, number: $number');
    //   _callKeep.setCurrentCallActive(callUUID);
    // });
  }

  Future<void> endCall(CallKeepPerformEndCallAction event) async {
    print('endCall: ${event.callUUID}');
    removeCall(event.callUUID);
  }

  Future<void> didPerformDTMFAction(CallKeepDidPerformDTMFAction event) async {
    print('[didPerformDTMFAction] ${event.callUUID}, digits: ${event.digits}');
  }

  Future<void> didReceiveStartCallAction(
      CallKeepDidReceiveStartCallAction event) async {
    // ExtendedNavigator.root.push(Routes.pickupScreen,
    //     arguments: PickupScreenArguments(
    //         nom: callerName.toString(),
    //         imageUrl: imageUrl.toString(),
    //         channel: callUUID));
    if (event.handle == null) {
      print('didReceiveStartCallAction');
      // @TODO: sometime we receive `didReceiveStartCallAction` with handle` undefined`
      return;
    }
    // final String callUUID = event.callUUID ?? newUUID();
    // calls[callUUID] = Call(event.handle);
    // print('[didReceiveStartCallAction] $callUUID, number: ${event.handle}');
    //
    // _callKeep.startCall(callUUID, event.handle, event.handle);
    //
    // Timer(const Duration(seconds: 1), () {
    //   print('[setCurrentCallActive] $callUUID, number: ${event.handle}');
    //   _callKeep.setCurrentCallActive(callUUID);
    // });
  }

  Future<void> didPerformSetMutedCallAction(
      CallKeepDidPerformSetMutedCallAction event) async {
    final String number = calls[event.callUUID].number;
    print(
        '[didPerformSetMutedCallAction] ${event.callUUID}, number: $number (${event.muted})');

    setCallMuted(event.callUUID, event.muted);
  }

  Future<void> didToggleHoldCallAction(
      CallKeepDidToggleHoldAction event) async {
    final String number = calls[event.callUUID].number;
    print(
        '[didToggleHoldCallAction] ${event.callUUID}, number: $number (${event.hold})');

    setCallHeld(event.callUUID, event.hold);
  }

  Future<void> hangup(String callUUID) async {
    _callKeep.endCall(callUUID);
    removeCall(callUUID);
  }

  Future<void> setOnHold(String callUUID, bool held) async {
    _callKeep.setOnHold(callUUID, held);
    final String handle = calls[callUUID].number;
    print('[setOnHold: $held] $callUUID, number: $handle');
    setCallHeld(callUUID, held);
  }

  Future<void> setMutedCall(String callUUID, bool muted) async {
    _callKeep.setMutedCall(callUUID, muted);
    final String handle = calls[callUUID].number;
    print('[setMutedCall: $muted] $callUUID, number: $handle');
    setCallMuted(callUUID, muted);
  }

  Future<void> updateDisplay(String callUUID) async {
    final String number = calls[callUUID].number;
    // Workaround because Android doesn't display well displayName, se we have to switch ...
    if (isIOS) {
      _callKeep.updateDisplay(callUUID,
          displayName: 'New Name', handle: number);
    } else {
      _callKeep.updateDisplay(callUUID,
          displayName: number, handle: 'New Name');
    }

    print('[updateDisplay: $number] $callUUID');
  }

  Future<void> displayIncomingCallDelayed(String number) async {
    Timer(const Duration(seconds: 3), () {
      displayIncomingCall(number);
    });
  }

  Future<void> displayIncomingCall(String number) async {
    final String callUUID = newUUID();
    calls[callUUID] = Call(number);
    print('Display incoming call now');
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

    print('[displayIncomingCall] $callUUID number: $number');
    _callKeep.displayIncomingCall(callUUID, number,
        handleType: 'number', hasVideo: false);
  }

  Future<void> didDisplayIncomingCall(CallKeepDidDisplayIncomingCall event) async {
    var callUUID = event.callUUID;
    var number = event.handle;
    hasVideo = event.hasVideo;
    print(event.fromPushKit);
    print('[displayIncomingCall] $callUUID number: $number');

    myUserFromCall = await FirestoreService.instance
        .getDoc(path: MyPath.user(number),builder: (map)=>MyUser.fromMap(map));

    calls[callUUID] = Call(number);
  }

  void onPushKitToken(CallKeepPushKitToken event) {
    print('[onPushKitToken] token => ${event.token}');
    _saveDeviceToken(uid, event.token);
  }

  Future<void> initLocalNotification() async {
    // _initPlatformState();
    // _requestPermissions();
    // SystemAlertWindow.registerOnClickListener(callBack);
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

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initPlatformState() async {
    // String platformVersion;
    // // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    //   platformVersion = await SystemAlertWindow.platformVersion;
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }
    //
    //
    // print(platformVersion);
  }

  // Future<void> _requestPermissions() async {
  //   await SystemAlertWindow.requestPermissions;
  // }

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

  // void _showOverlayWindow(String callerNmae) {
  //   if (!_isShowingWindow) {
  //     SystemWindowHeader header = SystemWindowHeader(
  //         title: SystemWindowText(text: "Incoming Call", fontSize: 10, textColor: Colors.black45),
  //         padding: SystemWindowPadding.setSymmetricPadding(12, 12),
  //         subTitle: SystemWindowText(text: "9898989899", fontSize: 14, fontWeight: FontWeight.BOLD, textColor: Colors.black87),
  //         decoration: SystemWindowDecoration(startColor: Colors.grey[100]),
  //         button: SystemWindowButton(text: SystemWindowText(text: "Personal", fontSize: 10, textColor: Colors.black45), tag: "personal_btn"),
  //         buttonPosition: ButtonPosition.TRAILING);
  //     SystemWindowBody body = SystemWindowBody(
  //       rows: [
  //         EachRow(
  //           columns: [
  //             EachColumn(
  //               text: SystemWindowText(text: "Some body", fontSize: 12, textColor: Colors.black45),
  //             ),
  //           ],
  //           gravity: ContentGravity.CENTER,
  //         ),
  //         EachRow(columns: [
  //           EachColumn(
  //               text: SystemWindowText(text: "Long data of the body", fontSize: 12, textColor: Colors.black87, fontWeight: FontWeight.BOLD),
  //               padding: SystemWindowPadding.setSymmetricPadding(6, 8),
  //               decoration: SystemWindowDecoration(startColor: Colors.black12, borderRadius: 25.0),
  //               margin: SystemWindowMargin(top: 4)),
  //         ], gravity: ContentGravity.CENTER),
  //         EachRow(
  //           columns: [
  //             EachColumn(
  //               text: SystemWindowText(text: "Notes", fontSize: 10, textColor: Colors.black45),
  //             ),
  //           ],
  //           gravity: ContentGravity.LEFT,
  //           margin: SystemWindowMargin(top: 8),
  //         ),
  //         EachRow(
  //           columns: [
  //             EachColumn(
  //               text: SystemWindowText(text: "Some random notes.", fontSize: 13, textColor: Colors.black54, fontWeight: FontWeight.BOLD),
  //             ),
  //           ],
  //           gravity: ContentGravity.LEFT,
  //         ),
  //       ],
  //       padding: SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
  //     );
  //     SystemWindowFooter footer = SystemWindowFooter(
  //         buttons: [
  //           SystemWindowButton(
  //             text: SystemWindowText(text: "Simple button", fontSize: 12, textColor: Color.fromRGBO(250, 139, 97, 1)),
  //             tag: "simple_button",
  //             padding: SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
  //             width: 0,
  //             height: SystemWindowButton.WRAP_CONTENT,
  //             decoration: SystemWindowDecoration(startColor: Colors.white, endColor: Colors.white, borderWidth: 0, borderRadius: 0.0),
  //           ),
  //           SystemWindowButton(
  //             text: SystemWindowText(text: "Focus button", fontSize: 12, textColor: Colors.white),
  //             tag: "focus_button",
  //             width: 0,
  //             padding: SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
  //             height: SystemWindowButton.WRAP_CONTENT,
  //             decoration: SystemWindowDecoration(
  //                 startColor: Color.fromRGBO(250, 139, 97, 1), endColor: Color.fromRGBO(247, 28, 88, 1), borderWidth: 0, borderRadius: 30.0),
  //           )
  //         ],
  //         padding: SystemWindowPadding(left: 16, right: 16, bottom: 12),
  //         decoration: SystemWindowDecoration(startColor: Colors.white),
  //         buttonsPosition: ButtonPosition.CENTER);
  //     SystemAlertWindow.showSystemWindow(
  //         height: 230,
  //         header: header,
  //         body: body,
  //         footer: footer,
  //         margin: SystemWindowMargin(left: 8, right: 8, top: 200, bottom: 0),
  //         gravity: SystemWindowGravity.TOP,
  //         notificationTitle: "Appel entrant",
  //         notificationBody: callerNmae);
  //     _isShowingWindow = true;
  //   } else if (!_isUpdatedWindow) {
  //     SystemWindowHeader header = SystemWindowHeader(
  //         title: SystemWindowText(text: "Outgoing Call", fontSize: 10, textColor: Colors.black45),
  //         padding: SystemWindowPadding.setSymmetricPadding(12, 12),
  //         subTitle: SystemWindowText(text: "8989898989", fontSize: 14, fontWeight: FontWeight.BOLD, textColor: Colors.black87),
  //         decoration: SystemWindowDecoration(startColor: Colors.grey[100]),
  //         button: SystemWindowButton(text: SystemWindowText(text: "Personal", fontSize: 10, textColor: Colors.black45), tag: "personal_btn"),
  //         buttonPosition: ButtonPosition.TRAILING);
  //     SystemWindowBody body = SystemWindowBody(
  //       rows: [
  //         EachRow(
  //           columns: [
  //             EachColumn(
  //               text: SystemWindowText(text: "Updated body", fontSize: 12, textColor: Colors.black45),
  //             ),
  //           ],
  //           gravity: ContentGravity.CENTER,
  //         ),
  //         EachRow(columns: [
  //           EachColumn(
  //               text: SystemWindowText(text: "Updated long data of the body", fontSize: 12, textColor: Colors.black87, fontWeight: FontWeight.BOLD),
  //               padding: SystemWindowPadding.setSymmetricPadding(6, 8),
  //               decoration: SystemWindowDecoration(startColor: Colors.black12, borderRadius: 25.0),
  //               margin: SystemWindowMargin(top: 4)),
  //         ], gravity: ContentGravity.CENTER),
  //         EachRow(
  //           columns: [
  //             EachColumn(
  //               text: SystemWindowText(text: "Notes", fontSize: 10, textColor: Colors.black45),
  //             ),
  //           ],
  //           gravity: ContentGravity.LEFT,
  //           margin: SystemWindowMargin(top: 8),
  //         ),
  //         EachRow(
  //           columns: [
  //             EachColumn(
  //               text: SystemWindowText(text: "Updated random notes.", fontSize: 13, textColor: Colors.black54, fontWeight: FontWeight.BOLD),
  //             ),
  //           ],
  //           gravity: ContentGravity.LEFT,
  //         ),
  //       ],
  //       padding: SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
  //     );
  //     SystemWindowFooter footer = SystemWindowFooter(
  //         buttons: [
  //           SystemWindowButton(
  //             text: SystemWindowText(text: "Updated Simple button", fontSize: 12, textColor: Color.fromRGBO(250, 139, 97, 1)),
  //             tag: "updated_simple_button",
  //             padding: SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
  //             width: 0,
  //             height: SystemWindowButton.WRAP_CONTENT,
  //             decoration: SystemWindowDecoration(startColor: Colors.white, endColor: Colors.white, borderWidth: 0, borderRadius: 0.0),
  //           ),
  //           SystemWindowButton(
  //             text: SystemWindowText(text: "Focus button", fontSize: 12, textColor: Colors.white),
  //             tag: "focus_button",
  //             width: 0,
  //             padding: SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
  //             height: SystemWindowButton.WRAP_CONTENT,
  //             decoration: SystemWindowDecoration(
  //                 startColor: Color.fromRGBO(250, 139, 97, 1), endColor: Color.fromRGBO(247, 28, 88, 1), borderWidth: 0, borderRadius: 30.0),
  //           )
  //         ],
  //         padding: SystemWindowPadding(left: 16, right: 16, bottom: 12),
  //         decoration: SystemWindowDecoration(startColor: Colors.white),
  //         buttonsPosition: ButtonPosition.CENTER);
  //     SystemAlertWindow.updateSystemWindow(
  //         height: 230,
  //         header: header,
  //         body: body,
  //         footer: footer,
  //         margin: SystemWindowMargin(left: 8, right: 8, top: 200, bottom: 0),
  //         gravity: SystemWindowGravity.TOP,
  //         notificationTitle: "Outgoing Call",
  //         notificationBody: "+1 646 980 4741");
  //     _isUpdatedWindow = true;
  //   } else {
  //     _isShowingWindow = false;
  //     _isUpdatedWindow = false;
  //     SystemAlertWindow.closeSystemWindow();
  //   }
  // }

  Future<void> _saveDeviceToken(String uid, String voIPToken) async {
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
          'voIPToken': voIPToken,
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
    final payload = message['data'];
    final callerId = payload['caller_id'] as String;
    final callerNmae = payload['caller_name'] as String;
    final uuid = payload['uuid'] as String;
    final hasVideo = payload['has_video'] == "true";
    final imageUrl = payload['imageUrl'] == "true";
    final callUUID = uuid ?? Uuid().v4();

    // _showOverlayWindow(callerNmae);

    // ExtendedNavigator.root.push(Routes.pickupScreen,
    //     arguments: PickupScreenArguments(
    //         nom: callerNmae.toString(),
    //         imageUrl: imageUrl.toString(),
    //         channel: callUUID));

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

  ///
  /// Whenever a button is clicked, this method will be invoked with a tag (As tag is unique for every button, it helps in identifying the button).
  /// You can check for the tag value and perform the relevant action for the button click
  ///
  void callBack(String tag) {
    print(tag);
    switch (tag) {
      case "simple_button":
      case "updated_simple_button":
        // SystemAlertWindow.closeSystemWindow();
        break;
      case "focus_button":
        print("Focus button has been called");
        break;
      default:
        print("OnClick event of $tag");
    }
  }

}
