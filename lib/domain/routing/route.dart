import 'package:auto_route/auto_route.dart';
import 'package:auto_route/auto_route_annotations.dart';
import 'package:van_events_project/presentation/pages/about_screen.dart';
import 'package:van_events_project/presentation/pages/admin_event.dart';
import 'package:van_events_project/presentation/pages/admin_organisateur.dart';
import 'package:van_events_project/presentation/pages/base_screen.dart';
import 'package:van_events_project/presentation/pages/cguCgv.dart';
import 'package:van_events_project/presentation/pages/cgu_cgv_accept.dart';
import 'package:van_events_project/presentation/pages/details.dart';
import 'package:van_events_project/presentation/pages/formula_choice.dart';
import 'package:van_events_project/presentation/pages/full_photo.dart';
import 'package:van_events_project/presentation/pages/login/login_screen.dart';
import 'package:van_events_project/presentation/pages/monitoring_scanner.dart';
import 'package:van_events_project/presentation/pages/billet_details.dart';
import 'package:van_events_project/presentation/pages/other_profil.dart';
import 'package:van_events_project/presentation/pages/refund_screen.dart';
import 'package:van_events_project/presentation/pages/reset_password.dart';
import 'package:van_events_project/presentation/pages/screen_chat_room.dart';
import 'package:van_events_project/presentation/pages/search_user_event.dart';
import 'package:van_events_project/presentation/pages/settings.dart';
import 'package:van_events_project/presentation/pages/splash_screen.dart';
import 'package:van_events_project/presentation/pages/stripe_profile/screen_stripe_profile.dart';
import 'package:van_events_project/presentation/pages/transport_details_screen.dart';
import 'package:van_events_project/presentation/pages/transport_screen.dart';
import 'package:van_events_project/presentation/pages/upload_event.dart';
import 'package:van_events_project/presentation/pages/walkthrough.dart';
import 'package:van_events_project/route_authentication.dart';


//flutter packages pub run build_runner build
//flutter packages pub run build_runner clean

@MaterialAutoRouter(routes: <AutoRoute>[
  MaterialRoute(page: RouteAuthentication, initial: true),
  MaterialRoute(page: ResetPassword, fullscreenDialog: true, initial: false),
  MaterialRoute(page: BaseScreens, fullscreenDialog: true, initial: false),
  MaterialRoute(page: ChatRoom, fullscreenDialog: true, initial: false),
  MaterialRoute(page: FullPhoto, fullscreenDialog: true, initial: false),
  MaterialRoute(page: UploadEvent, fullscreenDialog: true, initial: false),
  MaterialRoute(page: Details, fullscreenDialog: true, initial: false),
  MaterialRoute(page: FormulaChoice, fullscreenDialog: true, initial: false),
  MaterialRoute(page: BilletDetails, fullscreenDialog: true, initial: false),
  MaterialRoute(
      page: MonitoringScanner, fullscreenDialog: true, initial: false),
  MaterialRoute(page: AdminEvents, fullscreenDialog: true, initial: false),
  MaterialRoute(
      page: AdminOrganisateurs, fullscreenDialog: true, initial: false),
  MaterialRoute(page: MySplashScreen, fullscreenDialog: true, initial: false),
  MaterialRoute(page: Walkthrough, fullscreenDialog: true, initial: false),
  MaterialRoute(page: CguCgvAccept, fullscreenDialog: true, initial: false),
  MaterialRoute(page: CguCgv, fullscreenDialog: true, initial: false),
  MaterialRoute(page: StripeProfile, fullscreenDialog: true, initial: false),
  MaterialRoute(page: TransportDetailScreen, fullscreenDialog: true, initial: false),
  MaterialRoute(page: LoginScreen, fullscreenDialog: true, initial: false),
  MaterialRoute(page: SearchUserEvent, fullscreenDialog: true, initial: false),
  MaterialRoute(page: TransportScreen, fullscreenDialog: true, initial: false),
  MaterialRoute(page: Settings, fullscreenDialog: true, initial: false),
  MaterialRoute(page: AboutScreen, fullscreenDialog: true, initial: false),
  MaterialRoute(page: RefundScreen, fullscreenDialog: true, initial: false),
  MaterialRoute(page: OtherProfile, fullscreenDialog: true, initial: false),
  //This route returns result of type [bool]
  // CupertinoRoute(page: LoginScreen, fullscreenDialog: true),
  // CustomRoute<bool>(page: LoginScreen, transitionsBuilder: TransitionsBuilders.slideLeftWithFade,durationInMilliseconds: 5000),

  // This should be at the end of your routes list
  // wildcards are represented by '*'
  //MaterialRoute(path: "*", page: UnknownRouteScreen)
])


class $Router {
//flutter packages pub run build_runner build
//  @initial
//  Authentication authentication;
//
//  LoginForm login;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  ResetPassword resetPassword;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  SignUp signUp;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  BaseScreens baseScreens;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  ChatRoom chatRoom;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  FullPhoto fullPhoto;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  UploadEvent uploadEvent;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  Details details;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  FormulaChoice formulaChoice;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  QrCode qrCode;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  MonitoringScanner monitoringScanner;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  AdminEvents adminEvents;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  AdminOrganisateurs adminOrganisateurs;
//
//  MySplashScreen splashScreen;
//
//  Walkthrough walkthrough;
//
//  CguCgvAccept cguCgvAccept;

}
