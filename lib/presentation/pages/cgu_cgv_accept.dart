import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/providers/authentication_cubit/authentication_cubit.dart';


class CguCgvAccept extends HookWidget {
  final String uid;

  const CguCgvAccept(this.uid);

  @override
  Widget build(BuildContext context) {
    final myUserRepo = useProvider(myUserRepository);
    myUserRepo.setUid(uid);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('CGU CGV'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

            Wrap(
              children: <Widget>[
                Text(
                  'Acceptez-vous les',
                  style: Theme.of(context).textTheme.headline5,
                ),
                InkWell(
                    onTap: () {
                      ExtendedNavigator.of(context).push(Routes.aboutScreen);
                    },
                    child: Text(
                      'Conditions générales d\'utilisation ',
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(color: Colors.blue),
                    )),
                Text(
                  'et les',
                  style: Theme.of(context).textTheme.headline5,
                ),
                InkWell(
                    onTap: () {
                      ExtendedNavigator.of(context).push(Routes.aboutScreen);
                    },
                    child: Text(
                      'Conditions générales de vente',
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(color: Colors.blue),
                    )),
                Text(
                  ' ?',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                    onPressed: () {


                      BlocProvider.of<AuthenticationCubit>(context)
                          .authenticationLoggedOut(myUserRepo);
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.mySplashScreen);
                    },
                    child: const Text('Non')),
                RaisedButton(
                    onPressed: () async {

                      await myUserRepo
                          .setIsAcceptCGUCGV(uid);
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.routeAuthentication);
                      BlocProvider.of<AuthenticationCubit>(context)
                          .authenticationLoggedIn(myUserRepo);

                    },
                    child: const Text('Oui')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
