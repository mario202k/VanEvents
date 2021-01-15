import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:van_events_project/app_life_cycle_manager.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/providers/authentication_cubit/authentication_cubit.dart';
import 'package:van_events_project/providers/settings_change_notifier.dart';
import 'package:van_events_project/route_authentication.dart';
import 'package:van_events_project/services/firebase_cloud_messaging.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  return NotificationHandler().showNotification(message);
}

class MyApp extends HookWidget {

  final FirebaseAnalytics analytics = FirebaseAnalytics();
  final SharedPreferences sharePref;
  MyApp(this.sharePref);

  @override
  Widget build(BuildContext context) {
    print('buildMyApp');
    final settings = useProvider(settingsProvider);
    settings.initial(sharePref);
    final colorScheme = settings.onGoingcolorScheme;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
          AuthenticationCubit(),
        ),
      ],
      child: Material(
          color: colorScheme.surface,
          child: AppLifeCycleManager(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              color: colorScheme.background,
              localizationsDelegates: [
                // ... app-specific localization delegate[s] here
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                const Locale('fr', 'FR'), // English, no country code
              ],
              theme: ThemeData(
                colorScheme: colorScheme,
                primaryColor: colorScheme.primary,
                accentColor: colorScheme.primary,
                backgroundColor: colorScheme.background,
                toggleableActiveColor: colorScheme.primary,
                unselectedWidgetColor: colorScheme.onSurface,
                dialogTheme: DialogTheme(
                  backgroundColor: colorScheme.surface,
                  contentTextStyle: GoogleFonts.poiretOne(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  titleTextStyle: GoogleFonts.poiretOne(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                shadowColor: colorScheme.background,
                textTheme: TextTheme(
                  headline1: GoogleFonts.poiretOne(
                    fontSize: 96.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                  headline2: GoogleFonts.poiretOne(
                    fontSize: 60.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                  headline3: GoogleFonts.poiretOne(//Menu drawer
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                  headline4: GoogleFonts.poiretOne(//App bar
                    fontSize: 34.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                  headline5: GoogleFonts.poiretOne(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                  headline6: GoogleFonts.poiretOne(//Card Fourmula
                    //App Bar alertdialog.title
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  subtitle1: GoogleFonts.poiretOne(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                  subtitle2: GoogleFonts.poiretOne(//cardParticipant
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                  bodyText1: GoogleFonts.poiretOne(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                  bodyText2: GoogleFonts.poiretOne(//onPrimary
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                  button: GoogleFonts.poiretOne(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSecondary,
                  ),
                  caption: GoogleFonts.poiretOne(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                  overline: GoogleFonts.poiretOne(
                    fontSize: 14.0,
                    color: colorScheme.onBackground,
                  ),
                ),
                appBarTheme: AppBarTheme(
                    color: colorScheme.primary,
                    textTheme: TextTheme(
                        headline6: GoogleFonts.poiretOne(
                          //App Bar alertdialog.title
                          fontSize: 34.0,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        )),),
                iconTheme: IconThemeData(
                  color: colorScheme.onBackground,
                ),
                buttonTheme: ButtonThemeData(
                    textTheme: ButtonTextTheme.primary,
                    splashColor: colorScheme.secondaryVariant,
                    colorScheme: colorScheme,
                    buttonColor: colorScheme.secondary,
                    height: 40,

                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.transparent),
                cursorColor: colorScheme.onBackground,
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                    backgroundColor: colorScheme.secondary,
                    splashColor: colorScheme.secondaryVariant,
                    foregroundColor: colorScheme.onSecondary),
                inputDecorationTheme: InputDecorationTheme(
//                  filled: true,
//                  fillColor: Color(0xFFF2F2F2),

                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: colorScheme.onBackground,
                          style: BorderStyle.solid,
                          width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: colorScheme.onBackground,
                          style: BorderStyle.solid,
                          width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: colorScheme.onBackground,
                          style: BorderStyle.solid,
                          width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: colorScheme.onBackground,
                          style: BorderStyle.solid,
                          width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: colorScheme.error,
                          style: BorderStyle.solid,
                          width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: colorScheme.onBackground,
                          style: BorderStyle.solid,
                          width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  labelStyle: GoogleFonts.poiretOne(
                    fontSize: 17.0,
                    color: colorScheme.onBackground,
                  ),
                  counterStyle: GoogleFonts.poiretOne(
                    fontSize: 17.0,
                    color: colorScheme.onBackground,
                  ),
                  errorStyle: GoogleFonts.sourceCodePro(
                    fontSize: 11.0,
                    color: colorScheme.error,
                  ),
                ),
                cardTheme: CardTheme(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  elevation: 20,
                  color: colorScheme.surface,
                  shadowColor: colorScheme.onBackground,

                ),
                dividerTheme: DividerThemeData(
                    color: colorScheme.secondary,
                    thickness: 1,
                    indent: 30,
                    endIndent: 30),
              ),
              initialRoute: Routes.routeAuthentication,
              builder: ExtendedNavigator<MyRouter>(
                router: MyRouter(),
                initialRoute: Routes.routeAuthentication,
              ),
              home: RouteAuthentication(),
              navigatorObservers: [
                HeroController(),
                FirebaseAnalyticsObserver(analytics: analytics),
              ],
            ),
          )),
    );
  }
}