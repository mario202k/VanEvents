import 'package:flutter/material.dart';
import 'package:van_events_project/presentation/pages/register/register_screen.dart';

class CreateAccountButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return RegisterScreen();
          }),
        );
      },
      child: Text(
        'Créer un compte',style: Theme.of(context).textTheme.headline5
      ),
    );
  }
}
