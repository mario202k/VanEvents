import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:van_events_project/presentation/pages/register/register_button.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/bloc/blocOrganisateur.dart';
import 'package:van_events_project/providers/toggle_bool_chat_room.dart';

class RegisterFormOrganisateur extends HookWidget {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  final List<FocusScopeNode> listFocusNode =
      List.generate(19, (index) => FocusScopeNode());

  @override
  Widget build(BuildContext context) {

    final boolToggleRead = useProvider(boolToggleProvider);
    return BlocListener<RegisterBlocOrganisateur, RegisterStateOrganisateur>(
      listener: (context, state) {
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
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(state.rep),
                  ],
                ),
              ),
            );
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
                backgroundColor: Colors.red,
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
                  Consumer(

                    builder: (context, watch,child) {
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
                        Card(
                          child: Column(
                            children: <Widget>[
                              Text('Votre société'),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[0],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'nomSociete',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'Nom de la société',
                                    icon: Icon(
                                      FontAwesomeIcons.user,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                                    FormBuilderValidators.match(context, r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ. ]{2,60}$')]),
                                  onEditingComplete: () {
                                    if (_fbKey.currentState.fields['nomSociete']

                                        .validate()) {
                                      listFocusNode[0].unfocus();
                                    }
                                  },
                                ),
                              ), //nomSociete
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderDropdown(
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  name: 'business_type',
                                  initialValue: 'Entreprise',
                                  decoration: InputDecoration(
                                    labelText: 'Type de business',
                                    icon: Icon(
                                      FontAwesomeIcons.building,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  items: [
                                    'Entreprise',
                                    'Entité gouvernementale',
                                    'Particulier',
                                    'Association'
                                  ]
                                      .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(
                                            "$e",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                            overflow: TextOverflow.ellipsis,
                                          )))
                                      .toList(),
                                ),
                              ), //type de business
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[1],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'city',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'Ville',
                                    icon: Icon(
                                      Icons.my_location,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey
                                        .currentState.fields['city']
                                        .validate()) {
                                      listFocusNode[1].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[2]);
                                    }
                                  },
                                  validator: 
                                    (val) {
                                      RegExp regex = RegExp(
                                          r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ\- ]{2,60}$');

                                      if (regex.allMatches(val).length == 0) {
                                        return 'Non valide';
                                      }
                                      return null;
                                    },

                                ),
                              ), //ville
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[2],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'line1',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'Adresse - Ligne 1',
                                    icon: Icon(
                                      Icons.my_location,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey
                                        .currentState.fields['line1']
                                        .validate()) {
                                      listFocusNode[2].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[3]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                                    FormBuilderValidators.match(context, r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ. ]{2,60}$')]),

                                ),
                              ), //line1
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[3],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'line2',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'Adresse - Ligne 2',
                                    icon: Icon(
                                      Icons.my_location,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey
                                        .currentState.fields['line2']
                                        .validate()) {
                                      listFocusNode[3].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[4]);
                                    }
                                  },
                                ),
                              ), //line2
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.number,
                                  focusNode: listFocusNode[4],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'postal_code',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'Code postal',
                                    icon: Icon(
                                      Icons.my_location,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey.currentState.fields['postal_code']

                                        .validate()) {
                                      listFocusNode[4].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[5]);
                                    }
                                  },
                                  validator: FormBuilderValidators.numeric(context),
                                ),
                              ), //code postal
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[5],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'state',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'Région',
                                    icon: Icon(
                                      Icons.my_location,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey
                                        .currentState.fields['state']
                                        .validate()) {
                                      listFocusNode[5].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[6]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                                    FormBuilderValidators.match(context, r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ. ]{2,60}$')]),

                                ),
                              ), //region
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.phone,
                                  focusNode: listFocusNode[6],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'phone',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'Téléphone',
                                    icon: Icon(
                                      Icons.phone,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey
                                        .currentState.fields['phone']
                                        .validate()) {
                                      listFocusNode[6].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[7]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                                    FormBuilderValidators.match(context, r'(^(?:[+0]9)?[0-9]{10,12}$)')]),

                                ),
                              ), //phone
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.emailAddress,
                                  focusNode: listFocusNode[7],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'support_email',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'Email support',
                                    icon: Icon(
                                      FontAwesomeIcons.at,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey.currentState
                                        .fields['support_email']
                                        .validate()) {
                                      listFocusNode[7].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[8]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                                    FormBuilderValidators.email(context)]),

                                ),
                              ), //support email
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.url,
                                  focusNode: listFocusNode[8],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'url',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'URL',
                                    icon: Icon(
                                      FontAwesomeIcons.at,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey
                                        .currentState.fields['url']
                                        .validate()) {
                                      listFocusNode[8].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[9]);
                                    }
                                  },
                                  validator: 
                                    FormBuilderValidators.url(
                                        context
                                            ),
                                ),
                              ), //url
                              //support url
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[9],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'account_holder_name',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'Titulaire du compte bancaire',
                                    icon: Icon(
                                      Icons.person,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey
                                        .currentState
                                        .fields['account_holder_name']
                                        .validate()) {
                                      listFocusNode[10].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[11]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                                    FormBuilderValidators.match(context, r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ. ]{2,60}$')]),

                                ),
                              ), //Detenteur du compte bancaire
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderDropdown(
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  name: 'account_holder_type',
                                  decoration: InputDecoration(
                                    labelText: 'Type de compte bancaire',
                                    icon: Icon(
                                      Icons.description,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  initialValue: 'Entreprise',
                                  items: ['Entreprise', 'Individuel']
                                      .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(
                                            "$e",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                            overflow: TextOverflow.ellipsis,
                                          )))
                                      .toList(),
                                ),
                              ), //type de compte bancaire
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[11],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'account_number',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'IBAN',
                                    icon: Icon(
                                      FontAwesomeIcons.moneyCheckAlt,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey.currentState
                                        .fields['account_number']
                                        .validate()) {
                                      listFocusNode[11].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[12]);
                                    }
                                  },

                                  validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                                    FormBuilderValidators.match(context, r'^[a-zA-Z]{2}[0-9]{2}\s?[a-zA-Z0-9]{4}\s?[0-9]{4}\s?[0-9]{3}([a-zA-Z0-9]\s?[a-zA-Z0-9]{0,4}\s?[a-zA-Z0-9]{0,4}\s?[a-zA-Z0-9]{0,4}\s?[a-zA-Z0-9]{0,3})?$')]),

                                ),
                              ), //IBAN
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[12],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'SIREN',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'SIREN',
                                    icon: Icon(
                                      FontAwesomeIcons.moneyCheckAlt,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey
                                        .currentState.fields['SIREN']
                                        .validate()) {
                                      listFocusNode[12].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[13]);
                                    }
                                  },
                                  validator: 
                                    FormBuilderValidators.required(
                                        context),
                                ),
                              ), //SIREN
                            ],
                          ),
                        ), //Societe/personne Physique

                        Card(
                          child: Column(
                            children: <Widget>[
                              Text('Sur vous'),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[13],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'Prénom',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'Prénom',
                                    icon: Icon(
                                      FontAwesomeIcons.user,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey.currentState.fields['Prénom']
                                        .validate()) {
                                      listFocusNode[13].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[14]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                                    FormBuilderValidators.match(context, r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ. ]{2,60}$')]),


                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[14],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'Nom',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'Nom',
                                    icon: Icon(
                                      FontAwesomeIcons.user,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey
                                        .currentState.fields['Nom']
                                        .validate()) {
                                      listFocusNode[14].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[15]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                                    FormBuilderValidators.match(context, r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ. ]{2,60}$')]),

                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderDateTimePicker(
                                  locale: Locale('fr'),
                                  name: "date_of_birth",
                                  focusNode: listFocusNode[15],
                                  style: Theme.of(context).textTheme.headline5,
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  inputType: InputType.date,
                                  format: DateFormat("dd/MM/yyyy"),
                                  decoration: InputDecoration(
                                    labelText: 'Date de naissance',
                                    icon: Icon(
                                      FontAwesomeIcons.calendarAlt,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  validator: 
                                    FormBuilderValidators.required(
                                        context)

                                ),
                              ), //Nom
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.emailAddress,
                                  focusNode: listFocusNode[16],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onBackground,
                                  name: 'email',
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    icon: Icon(
                                      FontAwesomeIcons.at,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey
                                        .currentState.fields['email']
                                        .validate()) {
                                      listFocusNode[16].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[17]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                                    FormBuilderValidators.email(context)]),

                                ),
                              ), //email
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Consumer(
                                    builder: (context, watch,child) {
                                    return FormBuilderTextField(
                                      keyboardType: TextInputType.text,
                                      focusNode: listFocusNode[17],
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground),
                                      cursorColor:
                                          Theme.of(context).colorScheme.onBackground,
                                      name: 'password',
                                      maxLines: 1,
                                      obscureText: watch(boolToggleProvider)
                                          .obscureTextLogin,
                                      decoration: InputDecoration(
                                        labelText: 'Mot de passe',
                                        icon: Icon(
                                          FontAwesomeIcons.key,
                                          size: 22.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () => boolToggleRead
                                              .setObscureTextLogin(),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          iconSize: 20,
                                          icon: Icon(FontAwesomeIcons.eye),
                                        ),
                                      ),
                                      onEditingComplete: () {
                                        if (_fbKey.currentState.fields['password']
                                            .validate()) {
                                          listFocusNode[17].unfocus();
                                          FocusScope.of(context)
                                              .requestFocus(listFocusNode[18]);
                                        }
                                      },
                                      validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                                        FormBuilderValidators.match(context, r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d.*)[a-zA-Z0-9\S]{8,15}$')]),

                                    );
                                  }
                                ),
                              ), //password
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Consumer(
                                  builder: (context, watch,child) {
                                    return FormBuilderTextField(
                                      keyboardType: TextInputType.text,
                                      focusNode: listFocusNode[18],
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground),
                                      cursorColor:
                                          Theme.of(context).colorScheme.onBackground,
                                      name: 'Confirmation',
                                      maxLines: 1,
                                      obscureText: watch(boolToggleProvider)
                                          .obscuretextRegister,
                                      decoration: InputDecoration(
                                        labelText: 'Confirmation',
                                        icon: Icon(
                                          FontAwesomeIcons.key,
                                          size: 22.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () => boolToggleRead
                                              .setObscureTextRegister(),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          iconSize: 20,
                                          icon: Icon(FontAwesomeIcons.eye),
                                        ),
                                      ),
                                      onEditingComplete: () {
                                        if (_fbKey.currentState.fields['Confirmation']
                                            .validate()) {
                                          listFocusNode[18].unfocus();
                                          //FocusScope.of(context).requestFocus(listFocusNode[14]);

                                          _onFormSubmitted(context,boolToggleRead);
                                        }
                                      },
                                      validator: 

                                        (val) {
                                          if (_fbKey
                                                  .currentState
                                                  .fields['Confirmation']
                                                  .value
                                                  .toString() !=
                                              _fbKey.currentState.fields['password']
                                                  .value
                                                  .toString()) {
                                            return 'Pas identique';
                                          }
                                          return null;
                                        },

                                    );
                                  }
                                ),
                              ),
                              //confirmation
                            ],
                          ),
                        ), //mot de passe
                      ],
                    ),
                  ),
                  SizedBox(height: 12,),
                  Consumer(
                      builder: (context, watch,child) {
                    return CheckboxListTile(
                      onChanged: (bool val) => boolToggleRead.changeCGUCGV(),
                      value: watch(boolToggleProvider).cguCgv,
                      activeColor: Theme.of(context).colorScheme.primary,
                      title: Wrap(
                        children: <Widget>[
                          Text('J\'ai lu et j\'accepte les',
                              style: Theme.of(context).textTheme.headline5),

                          InkWell(
                            onTap: () async {
                              const url = 'https://stripe.com/fr/legal';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Text(
                                'Conditions d\'utilisation du service Stripe ',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(color: Colors.blue)),
                          ),
                          Text('et le ',
                              style: Theme.of(context).textTheme.headline5),
                          InkWell(
                            onTap: () async {
                              const url =
                                  'https://stripe.com/fr/connect-account/legal';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Text('Contrat de compte connecté ',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(color: Colors.blue)),
                          ),
                          Text(
                              ', ainsi que de recevoir les SMS automatisés envoyés par Stripe. Vous certifiez également que les informations que vous avez fournies à Stripe sont complètes et exactes',
                              style: Theme.of(context).textTheme.headline5),
                        ],
                      ),
                    );
                  }),
                  RegisterButton(
                    onPressed: () => _onFormSubmitted(context,boolToggleRead),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onPressImage(BuildContext context, BoolToggle boolToggleRead) async {
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

  void _onFormSubmitted(BuildContext context,BoolToggle boolToggleRead) {
    if (!boolToggleRead.cguCgv) {
      Scaffold.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Veuillez accepter les CGU et CGV'),
              ],
            ),
          ),
        );

      return;
    }

    if (_fbKey.currentState.validate()) {
      final state = _fbKey.currentState;
      print(state.fields['date_of_birth'].value);
      String dob = state.fields['date_of_birth'].value.toString();

      BlocProvider.of<RegisterBlocOrganisateur>(context).add(
            RegisterSubmitted(
              email: state.fields['email'].value.toString().trim(),
              account_holder_name: state
                  .fields['account_holder_name'].value
                  .toString()
                  .trim(),
              account_holder_type: state
                  .fields['account_holder_type'].value
                  .toString()
                  .trim(),
              account_number: state.fields['account_number'].value
                  .toString()
                  .trim(),
              business_type: state.fields['business_type'].value
                  .toString()
                  .trim(),
              city: state.fields['city'].value.toString().trim(),
              line1: state.fields['line1'].value.toString().trim(),
              line2: state.fields['line2'].value.toString().trim(),
              nomSociete: state.fields['nomSociete'].value
                  .toString()
                  .trim(),
              password:
                  state.fields['password'].value.toString().trim(),
              phone: parsePhoneNumber(
                  state.fields['phone'].value.toString().trim()),
              postal_code: state.fields['postal_code'].value
                  .toString()
                  .trim(),
              state: state.fields['state'].value.toString().trim(),
              supportEmail: state.fields['support_email'].value
                  .toString()
                  .trim(),
              url: state.fields['url'] != null
                  ? state.fields['url'].value.toString().trim()
                  : '',
              nom: state.fields['Nom'].value.toString().trim(),
              prenom:
                  state.fields['Prénom'].value.toString().trim(),
              SIREN: state.fields['SIREN'].value.toString().trim(),
              date_of_birth: dob.substring(0, dob.indexOf(' ')),
                boolToggleRead:boolToggleRead
            ),
          );
    }
  }

  String parsePhoneNumber(String value) {
    return value.replaceFirst('0', '+33');
  }
}
