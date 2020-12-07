import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/route_authentication.dart';

class MyApp extends StatelessWidget {
  final ColorScheme colorScheme = ColorScheme(
      primary: const Color(0xFFaf0b0b),
      primaryVariant: const Color(0xFFdf78ef),
      secondary: const Color(0xFFffcccb),
      secondaryVariant: const Color(0xFF039be5),
      background: const Color(0xFFFFFFFF),
      surface: const Color(0xFF039be5),
//      secondary: const Color(0xFF218b0e),
//      secondaryVariant: const Color(0xFF00600f),
//      background: const Color(0xFF790e8b),
//      surface: const Color(0xFF00600f),
      onBackground: const Color(0xFF000000),
      error: const Color(0xFF039be5),
      onError: const Color(0xFFFFFFFF),
      onPrimary: const Color(0xFFFFFFFF),
      onSecondary: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF000000),
      brightness: Brightness.light);

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          color: Colors.white,
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
            textTheme: TextTheme(
              bodyText1: GoogleFonts.poiretOne(
                fontSize: 25.0,
                fontWeight: FontWeight.w600,
                color: colorScheme.onBackground,
              ),
              bodyText2: GoogleFonts.poiretOne(
                fontSize: 32.0,
                fontWeight: FontWeight.w600,
                color: colorScheme.onBackground,
              ),
              caption: GoogleFonts.poiretOne(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: colorScheme.onBackground,
              ),
              headline6: GoogleFonts.poiretOne(
                //App Bar alertdialog.title
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimary,
              ),
              headline5: GoogleFonts.poiretOne(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: colorScheme.onBackground,
              ),

              headline4: GoogleFonts.poiretOne(
                fontSize: 29.0,
                color: colorScheme.onBackground,
              ),
              headline1: GoogleFonts.poiretOne(
                fontSize: 30.0,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimary,
              ),
              overline: GoogleFonts.poiretOne(
                fontSize: 11.0,
                color: colorScheme.onPrimary,
              ),
              button: GoogleFonts.poiretOne(
                fontSize: 17.0,
                color: colorScheme.onPrimary,
              ),
              subtitle2: GoogleFonts.poiretOne(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: colorScheme.onBackground,
              ),
            ),
            appBarTheme: AppBarTheme(
                color: colorScheme.primary,
                textTheme: TextTheme(
                    headline6: GoogleFonts.poiretOne(
                      //App Bar alertdialog.title
                      fontSize: 31.0,

                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ))),
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            buttonTheme: ButtonThemeData(
                textTheme: ButtonTextTheme.primary,
                splashColor: colorScheme.primary,
                colorScheme: colorScheme,
                buttonColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            cursorColor: colorScheme.onBackground,
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.primary),
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
              //color: colorScheme.secondary,
            ),
            dividerTheme: DividerThemeData(
                color: colorScheme.primary,
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
          ],
        ));
  }
}