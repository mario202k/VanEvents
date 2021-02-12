// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../presentation/pages/about_screen.dart';
import '../../presentation/pages/admin_event.dart';
import '../../presentation/pages/admin_organisateur.dart';
import '../../presentation/pages/base_screen.dart';
import '../../presentation/pages/billet_details.dart';
import '../../presentation/pages/call_screen.dart';
import '../../presentation/pages/cgu_cgv.dart';
import '../../presentation/pages/cgu_cgv_accept.dart';
import '../../presentation/pages/details.dart';
import '../../presentation/pages/formula_choice.dart';
import '../../presentation/pages/full_photo.dart';
import '../../presentation/pages/login/login_screen.dart';
import '../../presentation/pages/monitoring_scanner.dart';
import '../../presentation/pages/other_profil.dart';
import '../../presentation/pages/pick_up_screen.dart';
import '../../presentation/pages/refund_screen.dart';
import '../../presentation/pages/reset_password.dart';
import '../../presentation/pages/screen_chat_room.dart';
import '../../presentation/pages/search_user_event.dart';
import '../../presentation/pages/settings.dart';
import '../../presentation/pages/splash_screen.dart';
import '../../presentation/pages/stripe_profile/screen_stripe_profile.dart';
import '../../presentation/pages/transport_details_screen.dart';
import '../../presentation/pages/transport_screen.dart';
import '../../presentation/pages/upload_event.dart';
import '../../presentation/pages/walkthrough.dart';
import '../../route_authentication.dart';
import '../models/event.dart';
import '../models/formule.dart';
import '../models/my_transport.dart';
import '../models/my_user.dart';

class Routes {
  static const String routeAuthentication = '/';
  static const String resetPassword = '/reset-password';
  static const String baseScreens = '/base-screens';
  static const String chatRoom = '/chat-room';
  static const String fullPhoto = '/full-photo';
  static const String uploadEvent = '/upload-event';
  static const String details = '/Details';
  static const String formulaChoice = '/formula-choice';
  static const String billetDetails = '/billet-details';
  static const String monitoringScanner = '/monitoring-scanner';
  static const String adminEvents = '/admin-events';
  static const String adminOrganisateurs = '/admin-organisateurs';
  static const String mySplashScreen = '/my-splash-screen';
  static const String walkthrough = '/Walkthrough';
  static const String cguCgvAccept = '/cgu-cgv-accept';
  static const String cguCgv = '/cgu-cgv';
  static const String stripeProfile = '/stripe-profile';
  static const String transportDetailScreen = '/transport-detail-screen';
  static const String loginScreen = '/login-screen';
  static const String searchUserEvent = '/search-user-event';
  static const String transportScreen = '/transport-screen';
  static const String settings = '/Settings';
  static const String aboutScreen = '/about-screen';
  static const String refundScreen = '/refund-screen';
  static const String otherProfile = '/other-profile';
  static const String pickupScreen = '/pickup-screen';
  static const String callScreen = '/call-screen';
  static const all = <String>{
    routeAuthentication,
    resetPassword,
    baseScreens,
    chatRoom,
    fullPhoto,
    uploadEvent,
    details,
    formulaChoice,
    billetDetails,
    monitoringScanner,
    adminEvents,
    adminOrganisateurs,
    mySplashScreen,
    walkthrough,
    cguCgvAccept,
    cguCgv,
    stripeProfile,
    transportDetailScreen,
    loginScreen,
    searchUserEvent,
    transportScreen,
    settings,
    aboutScreen,
    refundScreen,
    otherProfile,
    pickupScreen,
    callScreen,
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
    RouteDef(Routes.billetDetails, page: BilletDetails),
    RouteDef(Routes.monitoringScanner, page: MonitoringScanner),
    RouteDef(Routes.adminEvents, page: AdminEvents),
    RouteDef(Routes.adminOrganisateurs, page: AdminOrganisateurs),
    RouteDef(Routes.mySplashScreen, page: MySplashScreen),
    RouteDef(Routes.walkthrough, page: Walkthrough),
    RouteDef(Routes.cguCgvAccept, page: CguCgvAccept),
    RouteDef(Routes.cguCgv, page: CguCgv),
    RouteDef(Routes.stripeProfile, page: StripeProfile),
    RouteDef(Routes.transportDetailScreen, page: TransportDetailScreen),
    RouteDef(Routes.loginScreen, page: LoginScreen),
    RouteDef(Routes.searchUserEvent, page: SearchUserEvent),
    RouteDef(Routes.transportScreen, page: TransportScreen),
    RouteDef(Routes.settings, page: Settings),
    RouteDef(Routes.aboutScreen, page: AboutScreen),
    RouteDef(Routes.refundScreen, page: RefundScreen),
    RouteDef(Routes.otherProfile, page: OtherProfile),
    RouteDef(Routes.pickupScreen, page: PickupScreen),
    RouteDef(Routes.callScreen, page: CallScreen),
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
          args.myEvent,
        ),
        settings: data,
        fullscreenDialog: true,
      );
    },
    BilletDetails: (data) {
      final args = data.getArgs<BilletDetailsArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => BilletDetails(args.billetId),
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
        builder: (context) => const MySplashScreen(),
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
    CguCgv: (data) {
      final args = data.getArgs<CguCgvArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => CguCgv(args.cguOuCgv),
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
    TransportDetailScreen: (data) {
      final args = data.getArgs<TransportDetailScreenArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => TransportDetailScreen(
          args.myTransport,
          args.addressArriver,
        ),
        settings: data,
        fullscreenDialog: true,
      );
    },
    LoginScreen: (data) {
      final args = data.getArgs<LoginScreenArguments>(
        orElse: () => LoginScreenArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => LoginScreen(myEmail: args.myEmail),
        settings: data,
        fullscreenDialog: true,
      );
    },
    SearchUserEvent: (data) {
      final args = data.getArgs<SearchUserEventArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => SearchUserEvent(isEvent: args.isEvent),
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
    Settings: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => Settings(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    AboutScreen: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => AboutScreen(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    RefundScreen: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => RefundScreen(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    OtherProfile: (data) {
      final args = data.getArgs<OtherProfileArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => OtherProfile(args.myUser),
        settings: data,
        fullscreenDialog: true,
      );
    },
    PickupScreen: (data) {
      final args = data.getArgs<PickupScreenArguments>(
        orElse: () => PickupScreenArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => PickupScreen(
          imageUrl: args.imageUrl,
          nom: args.nom,
        ),
        settings: data,
        fullscreenDialog: true,
      );
    },
    CallScreen: (data) {
      final args = data.getArgs<CallScreenArguments>(
        orElse: () => CallScreenArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => CallScreen(
          imageUrl: args.imageUrl,
          nom: args.nom,
        ),
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
  final MyEvent myEvent;

  FormulaChoiceArguments({@required this.formulas, @required this.myEvent});
}

/// BilletDetails arguments holder class
class BilletDetailsArguments {
  final String billetId;

  BilletDetailsArguments({@required this.billetId});
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

/// CguCgv arguments holder class
class CguCgvArguments {
  final String cguOuCgv;

  CguCgvArguments({@required this.cguOuCgv});
}

/// StripeProfile arguments holder class
class StripeProfileArguments {
  final String stripeAccount;

  StripeProfileArguments({this.stripeAccount});
}

/// TransportDetailScreen arguments holder class
class TransportDetailScreenArguments {
  final MyTransport myTransport;
  final String addressArriver;

  TransportDetailScreenArguments(
      {@required this.myTransport, @required this.addressArriver});
}

/// LoginScreen arguments holder class
class LoginScreenArguments {
  final String myEmail;

  LoginScreenArguments({this.myEmail});
}

/// SearchUserEvent arguments holder class
class SearchUserEventArguments {
  final bool isEvent;

  SearchUserEventArguments({@required this.isEvent});
}

/// OtherProfile arguments holder class
class OtherProfileArguments {
  final MyUser myUser;

  OtherProfileArguments({@required this.myUser});
}

/// PickupScreen arguments holder class
class PickupScreenArguments {
  final String imageUrl;
  final String nom;

  PickupScreenArguments({this.imageUrl, this.nom});
}

/// CallScreen arguments holder class
class CallScreenArguments {
  final String imageUrl;
  final String nom;

  CallScreenArguments({this.imageUrl, this.nom});
}
