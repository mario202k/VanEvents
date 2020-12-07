import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModelScreen extends StatelessWidget {
  final Widget child;

  ModelScreen({Key key, @required this.child})
      : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).colorScheme.primary,
      statusBarIconBrightness: Theme.of(context).colorScheme.brightness,
      systemNavigationBarColor: Theme.of(context).colorScheme.primary,
      systemNavigationBarIconBrightness:
          Theme.of(context).colorScheme.brightness,
    ));

    return Container(
        color: Theme.of(context).colorScheme.primary, child: SafeArea(child: child));
  }
}
