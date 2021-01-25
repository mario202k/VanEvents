import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/bloc/register_bloc_organisateur.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/widget/aboutYou.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/widget/compagny.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';


class RegisterScreenOrganisateur extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pageController = usePageController(initialPage: 0);
    return ModelScreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Organisateur',
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
        body: BlocProvider<RegisterBlocOrganisateur>(
          create: (context) => RegisterBlocOrganisateur(context),
          child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: pageController,
              children: [AboutYou(pageController),Company(pageController)]),
          //child: RegisterFormOrganisateur(),
        ),
      ),
    );
  }
}
