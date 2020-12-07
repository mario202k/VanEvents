import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/pages/cguCgv.dart';
import 'package:van_events_project/providers/authentication_cubit/authentication_cubit.dart';


class CguCgvAccept extends HookWidget {
  final String uid;

  CguCgvAccept(this.uid);

  @override
  Widget build(BuildContext context) {
    final myUserRepo = useProvider(myUserRepository);
    return Scaffold(
      appBar: AppBar(
        title: Text('CGU CGV'),
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
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CguCgv('cgu')));
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
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CguCgv('cgv')));
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
                    child: Text('Non'),
                    onPressed: () {

                      myUserRepo.setInactive();
                      BlocProvider.of<AuthenticationCubit>(context)
                          .authenticationLoggedOut(myUserRepo);
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.mySplashScreen);
                    }),
                RaisedButton(
                    child: Text('Oui'),
                    onPressed: () async {

                      await myUserRepo
                          .setIsAcceptCGUCGV(uid);
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.routeAuthentication);
                      BlocProvider.of<AuthenticationCubit>(context)
                          .authenticationLoggedIn(myUserRepo);

                    }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
