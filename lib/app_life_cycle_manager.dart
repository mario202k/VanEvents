import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';

class AppLifeCycleManager extends StatefulWidget {
  final Widget child;

  const AppLifeCycleManager({Key key, @required this.child}) : super(key: key);

  @override
  _AppLifeCycleManagerState createState() => _AppLifeCycleManagerState();
}

class _AppLifeCycleManagerState extends State<AppLifeCycleManager> with WidgetsBindingObserver {

  MyUserRepository myUserRepo;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if(myUserRepo == null){
      return;
    }
    switch (state) {
      case AppLifecycleState.paused:
        myUserRepo.setInactive();
        break;
      case AppLifecycleState.resumed:
        myUserRepo.setOnline();
        break;
      case AppLifecycleState.inactive:
        myUserRepo.setInactive();
        break;
      case AppLifecycleState.detached:
        myUserRepo.setInactive();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    myUserRepo = context.read(myUserRepository);
    return widget.child;
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
