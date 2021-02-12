import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/presentation/pages/register/bloc/bloc.dart';
import 'package:van_events_project/presentation/pages/register/register_button.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/toggle_bool.dart';

class RegisterForm extends HookWidget {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final FocusScopeNode _nodeNom = FocusScopeNode();
  final FocusScopeNode _nodePrenom = FocusScopeNode();
  final FocusScopeNode _nodesEmail = FocusScopeNode();
  final FocusScopeNode _nodePassword = FocusScopeNode();
  final FocusScopeNode _nodeConfirmation = FocusScopeNode();

  @override
  Widget build(BuildContext context) {

    final boolToggleRead = useProvider(boolToggleProvider);
    final myUserRepo = useProvider(myUserRepository);

    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) async {
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('En cours...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }

        if (state.isSuccess) {
          final result = await Show.showDialogToDismiss(context, 'Email envoyé',
              'Veuillez vérifier vos emails', 'Ok')
              .then((_)async => OpenMailApp.openMailApp() );

          if (!result.didOpen && !result.canOpen){
            Show.showDialogToDismiss(context, 'Oops', 'Pas d\'application de messagerie installée', 'Ok');
          }else if(!result.didOpen && result.canOpen){
            showDialog(
              context: context,
              builder: (_) {
                return MailAppPickerDialog(
                  mailApps: result.options,
                );
              },
            );
          }

        }

        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(state.rep),
                    const Icon(Icons.error),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Consumer(
                  builder: (context, watch,child) {
                    final boolToggle = watch(boolToggleProvider);
                    return CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        backgroundImage: boolToggle.imageProfil != null
                            ? FileImage(boolToggle.imageProfil)
                            : const AssetImage('assets/img/normal_user_icon.png') as ImageProvider,
                        radius: 50,
                        child: RawMaterialButton(
                          shape: const CircleBorder(),
                          splashColor: Colors.black45,
                          onPressed: () => _onPressImage(context,boolToggleRead),
                          padding: const EdgeInsets.all(50.0),
                        ));
                  }
                ),
                FormBuilder(
                  key: _fbKey,
                  //autovalidate: false,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FormBuilderTextField(
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                              color:
                              Theme.of(context).colorScheme.onBackground),
                          cursorColor:
                          Theme.of(context).colorScheme.onBackground,
                          name: 'Prénom',
                          decoration: InputDecoration(
                            labelText: 'prenom',
                            icon: Icon(
                              FontAwesomeIcons.user,
                              size: 22.0,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          focusNode: _nodePrenom,
                          onEditingComplete: () {
                            if (_fbKey.currentState.fields['Prénom']

                                .validate()) {
                              _nodePrenom.unfocus();
                              FocusScope.of(context).requestFocus(_nodeNom);
                            }
                          },
                          validator: FormBuilderValidators.compose([FormBuilderValidators.required(context,errorText: 'Champs requis'),
                            FormBuilderValidators.match(context, r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ\- ]{2,60}$',errorText: 'Erreur de saisie')]),


                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FormBuilderTextField(
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                              color:
                              Theme.of(context).colorScheme.onBackground),
                          cursorColor:
                          Theme.of(context).colorScheme.onBackground,
                          name: 'Nom',
                          decoration: InputDecoration(
                            labelText: 'nom',
                            icon: Icon(
                              FontAwesomeIcons.user,
                              size: 22.0,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          focusNode: _nodeNom,
                          onEditingComplete: () {
                            if (_fbKey.currentState.fields['Nom']
                                .validate()) {
                              _nodeNom.unfocus();
                              FocusScope.of(context).requestFocus(_nodesEmail);
                            }
                          },

                          validator: FormBuilderValidators.compose([FormBuilderValidators.required(context,errorText: 'Champs requis'),
                            FormBuilderValidators.match(context, r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ\- ]{2,60}$',errorText: 'Erreur de saisie')]),

                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FormBuilderTextField(
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              color:
                              Theme.of(context).colorScheme.onBackground),
                          cursorColor:
                          Theme.of(context).colorScheme.onBackground,
                          name: 'Email',
                          decoration: InputDecoration(
                            labelText: 'Email',
                            icon: Icon(
                              FontAwesomeIcons.at,
                              size: 22.0,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          focusNode: _nodesEmail,
                          onEditingComplete: () {
                            if (_fbKey.currentState.fields['Email']
                                .validate()) {
                              _nodesEmail.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_nodePassword);
                            }
                          },
                          validator: FormBuilderValidators.compose([FormBuilderValidators.required(context,errorText: 'Champs requis'),
                            FormBuilderValidators.email(context,errorText: 'email non valide')]),


                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Consumer(
                            builder: (context, watch,child) {

                            return FormBuilderTextField(
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                  color:
                                  Theme.of(context).colorScheme.onBackground),
                              cursorColor:
                              Theme.of(context).colorScheme.onBackground,
                              name: 'Mot de passe',
                              obscureText:
                              watch(boolToggleProvider).obscureTextLogin,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                icon: Icon(
                                  FontAwesomeIcons.key,
                                  size: 22.0,
                                  color: Theme.of(context).colorScheme.onBackground,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () => boolToggleRead
                                      .setObscureTextLogin(),
                                  color: Theme.of(context).colorScheme.onBackground,
                                  iconSize: 20,
                                  icon: const Icon(FontAwesomeIcons.eye),
                                ),
                              ),
                              focusNode: _nodePassword,
                              onEditingComplete: () {
                                if (_fbKey.currentState.fields['Mot de passe']

                                    .validate()) {
                                  _nodePassword.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_nodeConfirmation);
                                }
                              },

                              validator: FormBuilderValidators.compose([FormBuilderValidators.required(context,errorText: 'Champs requis'),
                                FormBuilderValidators.match(context, r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d.*)[a-zA-Z0-9\S]{8,15}$',errorText: '1 majuscule, 1 chiffre, 8 caractères')]),

                            );
                          }
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Consumer(
                            builder: (context, watch,child) {
                            return FormBuilderTextField(
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                  color:
                                  Theme.of(context).colorScheme.onBackground),
                              cursorColor:
                              Theme.of(context).colorScheme.onBackground,
                              name: 'Confirmation',
                              obscureText:
                              watch(boolToggleProvider).obscuretextRegister,
                              decoration: InputDecoration(
                                labelText: 'Confirmation',
                                icon: Icon(
                                  FontAwesomeIcons.key,
                                  size: 22.0,
                                  color: Theme.of(context).colorScheme.onBackground,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () => boolToggleRead
                                      .setObscureTextRegister(),
                                  color: Theme.of(context).colorScheme.onBackground,
                                  iconSize: 20,
                                  icon: const Icon(FontAwesomeIcons.eye),
                                ),
                              ),
                              focusNode: _nodeConfirmation,
                              onEditingComplete: () {
                                if (_fbKey.currentState.fields['Confirmation']

                                    .validate()) {
                                  _nodeConfirmation.unfocus();
                                  _onFormSubmitted(context,boolToggleRead,myUserRepo);
                                }
                              },
                              validator:(val){
                                if(val != _fbKey.currentState.fields['Mot de passe']
                                    .value){
                                  return 'Pas idendtique';
                                }
                                return null;
                              }

                              // validator: FormBuilderValidators.compose([FormBuilderValidators.required(context,errorText: 'Champs requis'),
                              //   FormBuilderValidators.equal(context, _fbKey.currentState.fields['Mot de passe']
                              //       .value,errorText: 'Pas identique')]),


                            );
                          }
                        ),
                      ),
                    ],
                  ),
                ),
                RegisterButton(
                  onPressed: () => _onFormSubmitted(context,boolToggleRead,myUserRepo),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onPressImage(BuildContext context, BoolToggle boolToggleRead) async {
    return showDialog(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
          title: const Text('Source?'),
          content: const Text('Veuillez choisir une source'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                boolToggleRead.getImageCamera('Profil');
                Navigator.of(context).pop();
              },
              child: const Text('Caméra'),
            ),
            FlatButton(
              onPressed: () {
                boolToggleRead.getImageGallery('Profil');
                Navigator.of(context).pop();
              },
              child: const Text('Galerie'),
            ),
          ],
        )
            : CupertinoAlertDialog(
          title: const Text('Source?'),
          content: const Text('Veuillez choisir une source'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                boolToggleRead.getImageCamera('Profil');
                Navigator.of(context).pop();
              },
              child: const Text('Caméra'),
            ),
            FlatButton(
              onPressed: () {
                boolToggleRead.getImageGallery('Profil');
                Navigator.of(context).pop();
              },
              child: const Text('Galerie'),
            ),
          ],
        ));
  }

  void _onFormSubmitted(BuildContext context,BoolToggle boolToggleRead,
      MyUserRepository myUserRepository) {

    if(_fbKey.currentState.validate()){

      BlocProvider.of<RegisterBloc>(context).add(
        RegisterSubmitted(
          email: _fbKey.currentState.fields['Email'].value.toString().trim(),
          password: _fbKey.currentState.fields['Mot de passe'].value.toString().trim(),
          prenomNom: '${_fbKey.currentState.fields['Prénom'].value} ${_fbKey.currentState.fields['Nom'].value.toString().trim()}',
            boolToggleRead:boolToggleRead,
          myUserRepository: myUserRepository
        ),
      );
    }

  }
}