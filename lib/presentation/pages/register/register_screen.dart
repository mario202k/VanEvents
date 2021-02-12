import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:van_events_project/presentation/pages/register/bloc/bloc.dart';
import 'package:van_events_project/presentation/pages/register/register_form.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';


class RegisterScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ModelScreen(
      child: Scaffold(
        appBar: AppBar(title: Text('Inscription',style: Theme.of(context).textTheme.headline4,),),
        body: ModelBody(
          child: BlocProvider<RegisterBloc>(
            create: (context) => RegisterBloc(),
            child: RegisterForm(),
          ),
        ),
      ),
    );
  }

}
