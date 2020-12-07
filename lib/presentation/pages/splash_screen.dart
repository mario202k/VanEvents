import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:van_events_project/presentation/pages/login/login_screen.dart';
import 'package:van_events_project/presentation/widgets/appPageRoute.dart';


class MySplashScreen extends StatelessWidget {
  MySplashScreen();

  @override
  Widget build(BuildContext context) {
    print('MySplashScreen');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Hero(
            tag: 'logo',
            child: FlareActor(
              'assets/animations/logo.flr',
              alignment: Alignment.center,
              animation: 'start',
              fit: BoxFit.fitHeight,

              callback: (str){
                
                // ExtendedNavigator.of(context).pushAndRemoveUntil(Routes.loginScreen,
                //         (route) => false);

                // Navigator.pushReplacement(
                //   context,
                //   PageRouteBuilder(
                //     transitionDuration: Duration(milliseconds: 2950),
                //     pageBuilder: (_, __, ___) => LoginScreen(),
                //   ),
                // );

                Navigator.of(context).pushReplacement(AppPageRoute(
                    builder: (BuildContext context) => LoginScreen()));
              },
            ),
          ),
          Positioned(
            bottom: 90,
            child: Column(
              children: <Widget>[
                Hero(
                  tag: 'vanevents',
                  child: Text(
                    'Van e.vents',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: 45),
                  ),
                ),
                Text(
                  'Partager votre événement ',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }


}
