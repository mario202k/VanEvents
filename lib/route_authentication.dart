import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/presentation/pages/base_screen.dart';
import 'package:van_events_project/presentation/widgets/custom_drawer.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/providers/authentication_cubit/authentication_cubit.dart';

import 'domain/routing/route.gr.dart';

class RouteAuthentication extends HookWidget {
  @override
  Widget build(BuildContext context) {
    print('buildAuthentication');

    final myUser = useProvider(myUserProvider);
    final myUserRepo = useProvider(myUserRepository);

    BlocProvider.of<AuthenticationCubit>(context)
        .authenticationStarted(myUserRepo, context);

    return ModelScreen(
      child: BlocListener<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationFailure) {
            if (state.seenOnboarding) {
              Navigator.of(context).pushReplacementNamed(Routes.mySplashScreen);
            } else {
              Navigator.of(context).pushReplacementNamed(Routes.walkthrough);
            }
          } else if (state is AuthenticationCGUCGV) {
            Navigator.of(context).pushReplacementNamed(Routes.cguCgvAccept,
                arguments: CguCgvAcceptArguments(uid: state.firebaseUser.uid));
          } else if (state is AuthenticationEmailLinkSuccess) {
            print('AuthenticationEmailLinkSuccess');
            print('!!!!!!!!!!!!');
            Navigator.of(context).pushReplacementNamed(Routes.loginScreen,
                arguments: LoginScreenArguments(myEmail: state.myEmail));
          }
        },
        child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationSuccess) {
              myUserRepo.setUid(state.firebaseUser.uid);
              myUser.setUser(state.myUser);

              return CustomDrawer(state.firebaseUser.uid, child: BaseScreens());
            }
            return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary)),
            );
          },
        ),
      ),
    );
  }
}
