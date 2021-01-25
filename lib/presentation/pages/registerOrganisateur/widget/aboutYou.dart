import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/bloc/blocOrganisateur.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/toggle_bool.dart';

class AboutYou extends HookWidget {
  final GlobalKey<FormBuilderState> _fbKeyAboutYou = GlobalKey<FormBuilderState>();

  final List<FocusScopeNode> listFocusNode =
      List.generate(6, (index) => FocusScopeNode());
  final PageController _pageController;

  AboutYou(this._pageController);

  @override
  Widget build(BuildContext context) {
    final boolToggleRead = useProvider(boolToggleProvider);
    return BlocListener<RegisterBlocOrganisateur, RegisterStateOrganisateur>(
      listener: (context, state) async {
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                duration: Duration(minutes: 3),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('En cours...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          final result = await Show.showDialogToDismiss(
                  context, 'Email envoyé', 'Veuillez vérifier vos emails', 'Ok')
              .then((_) async => await OpenMailApp.openMailApp());

          if (!result.didOpen && !result.canOpen) {
            Show.showDialogToDismiss(context, 'Oops',
                'Pas d\'application de messagerie installée', 'Ok');
          } else if (!result.didOpen && result.canOpen) {
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
                    Icon(Icons.error),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      },
      child: BlocBuilder<RegisterBlocOrganisateur, RegisterStateOrganisateur>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Consumer(builder: (context, watch, child) {
                    return CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        backgroundImage:
                            watch(boolToggleProvider).imageProfil != null
                                ? FileImage(boolToggleRead.imageProfil)
                                : AssetImage('assets/img/normal_user_icon.png'),
                        radius: 50,
                        child: RawMaterialButton(
                          shape: const CircleBorder(),
                          //splashColor: Colors.black45,
                          onPressed: () =>
                              _onPressImage(context, boolToggleRead),
                          padding: const EdgeInsets.all(50.0),
                        ));
                  }),
                  FormBuilder(
                    key: _fbKeyAboutYou,
                    //autovalidate: false,
                    child: Column(
                      children: <Widget>[
                        Card(
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Sur vous',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[0],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  name: 'Prénom',
                                  decoration: InputDecoration(
                                    labelText: 'Prénom*',
                                    icon: Icon(
                                      FontAwesomeIcons.user,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKeyAboutYou.currentState.fields['Prénom']
                                        .validate()) {
                                      listFocusNode[0].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[1]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(context,
                                        errorText: 'Champs requis'),
                                    FormBuilderValidators.match(context,
                                        r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ. ]{2,60}$',
                                        errorText: 'Erreur de saisie')
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[1],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  name: 'Nom',
                                  decoration: InputDecoration(
                                    labelText: 'Nom*',
                                    icon: Icon(
                                      FontAwesomeIcons.user,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKeyAboutYou.currentState.fields['Nom']
                                        .validate()) {
                                      listFocusNode[1].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[2]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(context,
                                        errorText: 'Champs requis'),
                                    FormBuilderValidators.match(context,
                                        r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ. ]{2,60}$',
                                        errorText: 'Erreur de saisie')
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderDateTimePicker(
                                    locale: Locale('fr'),
                                    name: "date_of_birth",
                                    focusNode: listFocusNode[2],
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    cursorColor: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    inputType: InputType.date,
                                    format: DateFormat("dd/MM/yyyy"),
                                    decoration: InputDecoration(
                                      labelText: 'Date de naissance*',
                                      icon: Icon(
                                        FontAwesomeIcons.calendarAlt,
                                        size: 22.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                    validator: (val) {
                                      if(val == null){
                                        return 'Requis';
                                      }
                                      if (val != null && (DateTime.now().year - val.year) <
                                          18) {
                                        return '18 ans minimum';
                                      }

                                      return null;
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.emailAddress,
                                  focusNode: listFocusNode[3],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  name: 'email',
                                  decoration: InputDecoration(
                                    labelText: 'Email*',
                                    icon: Icon(
                                      FontAwesomeIcons.at,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKeyAboutYou.currentState.fields['email']
                                        .validate()) {
                                      listFocusNode[3].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[4]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(context,
                                        errorText: 'Champs requis'),
                                    FormBuilderValidators.email(context,
                                        errorText: 'Email non valide')
                                  ]),
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
                                        maxLines: 1,
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
                                            icon: Icon(FontAwesomeIcons.eye),
                                          ),
                                        ),
                                        focusNode: listFocusNode[4],
                                        onEditingComplete: () {
                                          if (_fbKeyAboutYou.currentState.fields['Mot de passe']

                                              .validate()) {
                                            listFocusNode[4].unfocus();
                                            FocusScope.of(context)
                                                .requestFocus(listFocusNode[5]);
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
                                          maxLines: 1,
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
                                              icon: Icon(FontAwesomeIcons.eye),
                                            ),
                                          ),
                                          focusNode: listFocusNode[5],
                                          onEditingComplete: () {
                                            if (_fbKeyAboutYou.currentState.fields['Confirmation']

                                                .validate()) {
                                              listFocusNode[5].unfocus();
                                            }
                                          },
                                          validator:(val){
                                            if(val == null){
                                              return 'Requis';
                                            }
                                            if(val != _fbKeyAboutYou.currentState.fields['Mot de passe']
                                                .value){
                                              return 'Pas idendtique';
                                            }
                                            return null;
                                          }

                                      );
                                    }
                                ),
                              ),//email
                              //confirmation
                            ],
                          ),
                        ), //mot de passe
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  RaisedButton.icon(
                      onPressed: () {
                        if (_fbKeyAboutYou.currentState.validate()) {
                          final state = _fbKeyAboutYou.currentState;
                          String dob = state.fields['date_of_birth'].value.toString();

                          BlocProvider.of<RegisterBlocOrganisateur>(context).aboutYou(
                            nom: state.fields['Nom'].value.toString().trim(),
                            prenom: state.fields['Prénom'].value.toString().trim(),
                            date_of_birth: dob.substring(0, dob.indexOf(' ')),
                            email: state.fields['email'].value.toString().trim(),
                            password: state.fields['Mot de passe'].value.toString().trim(),
                          );
                          print('!!!!!');

                          // _pageController.animateToPage(1,
                          //     duration: Duration(milliseconds: 300),
                          //     curve: Curves.easeInOutBack);

                          _pageController.jumpToPage(1);
                        }

                      },
                      icon: FaIcon(FontAwesomeIcons.arrowRight),
                      label: Text('Suivant')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onPressImage(
      BuildContext context, BoolToggle boolToggleRead) async {
    return await showDialog(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
                title: Text('Source?'),
                content: Text('Veuillez choisir une source'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Caméra'),
                    onPressed: () {
                      boolToggleRead.getImageCamera('Profil');
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Galerie'),
                    onPressed: () {
                      boolToggleRead.getImageGallery('Profil');
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            : CupertinoAlertDialog(
                title: Text('Source?'),
                content: Text('Veuillez choisir une source'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Caméra'),
                    onPressed: () {
                      boolToggleRead.getImageCamera('Profil');
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Galerie'),
                    onPressed: () {
                      boolToggleRead.getImageGallery('Profil');
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
  }
}
