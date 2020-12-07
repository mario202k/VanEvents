// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../presentation/pages/admin_event.dart';
import '../../presentation/pages/admin_organisateur.dart';
import '../../presentation/pages/base_screen.dart';
import '../../presentation/pages/cgu_cgv_accept.dart';
import '../../presentation/pages/details.dart';
import '../../presentation/pages/formula_choice.dart';
import '../../presentation/pages/full_photo.dart';
import '../../presentation/pages/login/login_screen.dart';
import '../../presentation/pages/monitoring_scanner.dart';
import '../../presentation/pages/qr_code.dart';
import '../../presentation/pages/reset_password.dart';
import '../../presentation/pages/screen_chat_room.dart';
import '../../presentation/pages/search_user_event.dart';
import '../../presentation/pages/splash_screen.dart';
import '../../presentation/pages/stripe_profile/screen_stripe_profile.dart';
import '../../presentation/pages/transport.dart';
import '../../presentation/pages/transport_details.dart';
import '../../presentation/pages/transport_screen.dart';
import '../../presentation/pages/upload_event.dart';
import '../../presentation/pages/walkthrough.dart';
import '../../route_authentication.dart';
import '../models/event.dart';
import '../models/formule.dart';
import '../models/my_transport.dart';

class Routes {
  static const String routeAuthentication = '/';
  static const String resetPassword = '/reset-password';
  static const String baseScreens = '/base-screens';
  static const String chatRoom = '/chat-room';
  static const String fullPhoto = '/full-photo';
  static const String uploadEvent = '/upload-event';
  static const String details = '/Details';
  static const String formulaChoice = '/formula-choice';
  static const String qrCode = '/qr-code';
  static const String monitoringScanner = '/monitoring-scanner';
  static const String adminEvents = '/admin-events';
  static const String adminOrganisateurs = '/admin-organisateurs';
  static const String mySplashScreen = '/my-splash-screen';
  static const String walkthrough = '/Walkthrough';
  static const String cguCgvAccept = '/cgu-cgv-accept';
  static const String stripeProfile = '/stripe-profile';
  static const String transport = '/Transport';
  static const String transportDetail = '/transport-detail';
  static const String loginScreen = '/login-screen';
  static const String searchUserEvent = '/search-user-event';
  static const String transportScreen = '/transport-screen';

  static const all = <String>{
    routeAuthentication,
    resetPassword,
    baseScreens,
    chatRoom,
    fullPhoto,
    uploadEvent,
    details,
    formulaChoice,
    qrCode,
    monitoringScanner,
    adminEvents,
    adminOrganisateurs,
    mySplashScreen,
    walkthrough,
    cguCgvAccept,
    stripeProfile,
    transport,
    transportDetail,
    loginScreen,
    searchUserEvent,
    transportScreen,
  };
}

class MyRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.routeAuthentication, page: RouteAuthentication),
    RouteDef(Routes.resetPassword, page: ResetPassword),
    RouteDef(Routes.baseScreens, page: BaseScreens),
    RouteDef(Routes.chatRoom, page: ChatRoom),
    RouteDef(Routes.fullPhoto, page: FullPhoto),
    RouteDef(Routes.uploadEvent, page: UploadEvent),
    RouteDef(Routes.details, page: Details),
    RouteDef(Routes.formulaChoice, page: FormulaChoice),
    RouteDef(Routes.qrCode, page: QrCode),
    RouteDef(Routes.monitoringScanner, page: MonitoringScanner),
    RouteDef(Routes.adminEvents, page: AdminEvents),
    RouteDef(Routes.adminOrganisateurs, page: AdminOrganisateurs),
    RouteDef(Routes.mySplashScreen, page: MySplashScreen),
    RouteDef(Routes.walkthrough, page: Walkthrough),
    RouteDef(Routes.cguCgvAccept, page: CguCgvAccept),
    RouteDef(Routes.stripeProfile, page: StripeProfile),
    RouteDef(Routes.transport, page: Transport),
    RouteDef(Routes.transportDetail, page: TransportDetail),
    RouteDef(Routes.loginScreen, page: LoginScreen),
    RouteDef(Routes.searchUserEvent, page: SearchUserEvent),
    RouteDef(Routes.transportScreen, page: TransportScreen),
    RouteDef(Routes.loginScreen, page: LoginScreen),
    RouteDef(Routes.loginScreen, page: LoginScreen),
  ];
  @override
  Map<Type, AutoRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, AutoRouteFactory>{
    RouteAuthentication: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => RouteAuthentication(),
        settings: data,
      );
    },
    ResetPassword: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ResetPassword(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    BaseScreens: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => BaseScreens(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    ChatRoom: (data) {
      final args = data.getArgs<ChatRoomArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => ChatRoom(args.chatId),
        settings: data,
        fullscreenDialog: true,
      );
    },
    FullPhoto: (data) {
      final args = data.getArgs<FullPhotoArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => FullPhoto(
          key: args.key,
          url: args.url,
          file: args.file,
        ),
        settings: data,
        fullscreenDialog: true,
      );
    },
    UploadEvent: (data) {
      final args = data.getArgs<UploadEventArguments>(
        orElse: () => UploadEventArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => UploadEvent(myEvent: args.myEvent),
        settings: data,
        fullscreenDialog: true,
      );
    },
    Details: (data) {
      final args = data.getArgs<DetailsArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => Details(args.event),
        settings: data,
        fullscreenDialog: true,
      );
    },
    FormulaChoice: (data) {
      final args = data.getArgs<FormulaChoiceArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => FormulaChoice(
          args.formulas,
          args.eventId,
          args.imageUrl,
          args.stripeAccount,
          args.latLng,
          args.dateDebut,
        ),
        settings: data,
        fullscreenDialog: true,
      );
    },
    QrCode: (data) {
      final args = data.getArgs<QrCodeArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => QrCode(args.data),
        settings: data,
        fullscreenDialog: true,
      );
    },
    MonitoringScanner: (data) {
      final args = data.getArgs<MonitoringScannerArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => MonitoringScanner(args.eventId),
        settings: data,
        fullscreenDialog: true,
      );
    },
    AdminEvents: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => AdminEvents(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    AdminOrganisateurs: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => AdminOrganisateurs(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    MySplashScreen: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => MySplashScreen(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    Walkthrough: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => Walkthrough(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    CguCgvAccept: (data) {
      final args = data.getArgs<CguCgvAcceptArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => CguCgvAccept(args.uid),
        settings: data,
        fullscreenDialog: true,
      );
    },
    StripeProfile: (data) {
      final args = data.getArgs<StripeProfileArguments>(
        orElse: () => StripeProfileArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => StripeProfile(stripeAccount: args.stripeAccount),
        settings: data,
        fullscreenDialog: true,
      );
    },
    Transport: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => Transport(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    TransportDetail: (data) {
      final args = data.getArgs<TransportDetailArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => TransportDetail(
          args.myTransport,
          args.addressArriver,
        ),
        settings: data,
        fullscreenDialog: true,
      );
    },
    LoginScreen: (data) {
      return PageRouteBuilder<bool>(
        pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
        settings: data,
        transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
        transitionDuration: const Duration(milliseconds: 5000),
      );
    },
    SearchUserEvent: (data) {
      final args = data.getArgs<SearchUserEventArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => SearchUserEvent(args.isEvent),
        settings: data,
        fullscreenDialog: true,
      );
    },
    TransportScreen: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => TransportScreen(),
        settings: data,
        fullscreenDialog: true,
      );
    },
  };
}

/// ************************************************************************
/// Arguments holder classes
/// *************************************************************************

/// ChatRoom arguments holder class
class ChatRoomArguments {
  final String chatId;
  ChatRoomArguments({@required this.chatId});
}

/// FullPhoto arguments holder class
class FullPhotoArguments {
  final Key key;
  final String url;
  final File file;
  FullPhotoArguments({this.key, @required this.url, this.file});
}

/// UploadEvent arguments holder class
class UploadEventArguments {
  final MyEvent myEvent;
  UploadEventArguments({this.myEvent});
}

/// Details arguments holder class
class DetailsArguments {
  final MyEvent event;
  DetailsArguments({@required this.event});
}

/// FormulaChoice arguments holder class
class FormulaChoiceArguments {
  final List<Formule> formulas;
  final String eventId;
  final String imageUrl;
  final String stripeAccount;
  final LatLng latLng;
  final DateTime dateDebut;
  FormulaChoiceArguments(
      {@required this.formulas,
      @required this.eventId,
      @required this.imageUrl,
      @required this.stripeAccount,
      @required this.latLng,
      @required this.dateDebut});
}

/// QrCode arguments holder class
class QrCodeArguments {
  final String data;
  QrCodeArguments({@required this.data});
}

/// MonitoringScanner arguments holder class
class MonitoringScannerArguments {
  final String eventId;
  MonitoringScannerArguments({@required this.eventId});
}

/// CguCgvAccept arguments holder class
class CguCgvAcceptArguments {
  final String uid;
  CguCgvAcceptArguments({@required this.uid});
}

/// StripeProfile arguments holder class
class StripeProfileArguments {
  final String stripeAccount;
  StripeProfileArguments({this.stripeAccount});
}

/// TransportDetail arguments holder class
class TransportDetailArguments {
  final MyTransport myTransport;
  final String addressArriver;
  TransportDetailArguments(
      {@required this.myTransport, @required this.addressArriver});
}

/// SearchUserEvent arguments holder class
class SearchUserEventArguments {
  final bool isEvent;
  SearchUserEventArguments({@required this.isEvent});
}
