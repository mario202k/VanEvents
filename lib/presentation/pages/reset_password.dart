import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/toggle_bool_chat_room.dart';


class ResetPassword extends StatelessWidget {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ModelScreen(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Reset',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: ModelBody(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Card(
                    child: SizedBox(
                      height: 220,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FormBuilder(
                          key: _fbKey,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Veuillez saisir votre adresse email',
                                  style:
                                      Theme.of(context).textTheme.headline5,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                FormBuilderTextField(
                                  keyboardType: TextInputType.emailAddress,
                                  onEditingComplete: () async {
                                    await submit(context);
                                  },
                                  name: 'email',
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(context,),
                                    FormBuilderValidators.email(context),]),
                                ),
                              ]),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    bottom: -20,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Consumer(builder: (context, watch, child) {
                        return !watch(boolToggleProvider).showSpinner
                            ? RaisedButton(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'Envoyer l\'email',
                              ),
                            ),
                            onPressed: () async {
                              await submit(context);
                            })
                            : CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary));
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future submit(BuildContext context) async {
    context.read(boolToggleProvider).setShowSpinner();
    _fbKey.currentState.save();
    if (_fbKey.currentState.validate()) {
      try {
        await context
            .read(myUserRepository)
            .resetEmail(_fbKey.currentState.fields['email'].value);
        Show.showDialogToDismiss(
            context, 'Reset', 'Un email a été envoyé', 'Ok');
      } catch (e) {
        Show.showSnackBarError(context,_scaffoldKey, 'Email inconnu');
      }
    }
    context.read(boolToggleProvider).setShowSpinner();
  }
}