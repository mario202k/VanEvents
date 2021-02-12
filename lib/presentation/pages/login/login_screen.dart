import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:van_events_project/presentation/pages/login/bloc/bloc.dart';
import 'package:van_events_project/presentation/pages/login/login_form.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';

class LoginScreen extends StatelessWidget {
  final String myEmail;

  const LoginScreen({this.myEmail});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final bool result = await _onPressBackButton(context);

        return Future.value(result);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: ModelBody(
          child: BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(),
            child: LoginForm(myEmail: myEmail),
          ),
        ),
      ),
    );
  }

  Future<bool> _onPressBackButton(BuildContext context) async {
    return await showDialog(
            context: context,
            builder: (_) => Platform.isAndroid
                ? AlertDialog(
                    title: const Text('Quitter?'),
                    content: const Text('Etes vous sur de vouloir quitter'),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Non'),
                      ),
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Oui'),
                      ),
                    ],
                  )
                : CupertinoAlertDialog(
                    title: const Text('Quitter?'),
                    content: const Text('Etes vous sur de vouloir quitter'),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Non'),
                      ),
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Oui'),
                      ),
                    ],
                  )) ??
        false;
  }
}
