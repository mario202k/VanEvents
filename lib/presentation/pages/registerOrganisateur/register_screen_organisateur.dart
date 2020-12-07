import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/bloc/register_bloc_organisateur.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/register_form_organisateur.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';


class RegisterScreenOrganisateur extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ModelScreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Organisateur',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: BlocProvider<RegisterBlocOrganisateur>(
          create: (context) => RegisterBlocOrganisateur(context),
          child: RegisterFormOrganisateur(),
        ),
      ),
    );
  }
}
