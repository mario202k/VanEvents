import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/presentation/pages/login/bloc/login_bloc.dart';
import 'package:van_events_project/presentation/pages/login/bloc/login_event.dart';


class GoogleLoginButton extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final myUserRepo = useProvider(myUserRepository);
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      icon: Icon(FontAwesomeIcons.google, color: Colors.white),
      onPressed: () {
        BlocProvider.of<LoginBloc>(context).add(
          LoginWithGooglePressed(myUserRepo),
        );
      },
      label: Text('avec Google', style: TextStyle(color: Colors.white)),
      color: Colors.redAccent,
    );
  }
}
