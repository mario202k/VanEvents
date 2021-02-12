import 'package:flutter/material.dart';

class RegisterButton extends StatelessWidget {
  final VoidCallback _onPressed;

  const RegisterButton({Key key, VoidCallback onPressed})
      : _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(

      onPressed: _onPressed,
      child: Text('S\'inscrire',style: Theme.of(context).textTheme.button,),
    );
  }
}
