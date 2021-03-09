import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide ReadContext;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/repositories/stripe_repository.dart';
import 'package:van_events_project/presentation/pages/register/register_button.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/bloc/register_bloc_organisateur.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/bloc/register_state_organisateur.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/register_organisateur.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/toggle_bool.dart';

class Company extends StatefulWidget {
  final PageController _pageController;

  const Company(this._pageController);

  @override
  _CompanyState createState() => _CompanyState();
}

class _CompanyState extends State<Company> with AutomaticKeepAliveClientMixin {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  final List<FocusScopeNode> listFocusNode =
      List.generate(19, (index) => FocusScopeNode());

  @override
  Widget build(BuildContext context) {
    final boolToggleRead = context.read(boolToggleProvider);
    final myUserRepo = context.read(myUserRepository);
    final stripeRepo = context.read(stripeRepositoryProvider);

    return BlocListener<RegisterBlocOrganisateur, RegisterStateOrganisateur>(
      listener: (context, state) async {
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                duration: const Duration(minutes: 3),
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
          Scaffold.of(context)
            .hideCurrentSnackBar();
          final result = await Show.showDialogToDismiss(
                  context, 'Email envoyé', 'Veuillez vérifier vos emails', 'Ok')
              .then((_) async => OpenMailApp.openMailApp());

          if (!result.didOpen && !result.canOpen) {
            Scaffold.of(context)
              .hideCurrentSnackBar();
            Show.showDialogToDismiss(context, 'Oops',
                'Pas d\'application de messagerie installée', 'Ok');
          } else if (!result.didOpen && result.canOpen) {
            Scaffold.of(context)
              .hideCurrentSnackBar();
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
      child: BlocBuilder<RegisterBlocOrganisateur, RegisterStateOrganisateur>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  RaisedButton.icon(onPressed: (){
                    widget._pageController.jumpToPage(0);
                  }, icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                      label: const Text('Précédent')),
                  FormBuilder(
                    key: _fbKey,
                    //autovalidate: false,
                    child: Column(
                      children: <Widget>[
                        Card(
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Votre société',
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
                                  name: 'nomSociete',
                                  decoration: InputDecoration(
                                    labelText: 'Nom de la société*',
                                    icon: Icon(
                                      FontAwesomeIcons.user,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  validator: FormBuilderValidators.required(
                                      context,
                                      errorText: 'Champs requis'),
                                  onEditingComplete: () {
                                    if (_fbKey.currentState.fields['nomSociete']
                                        .validate()) {
                                      listFocusNode[0].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[1]);
                                    }
                                  },
                                ),
                              ), //nomSociete
                              //ville
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
                                  name: 'line1',
                                  decoration: InputDecoration(
                                    labelText: 'Adresse - Ligne 1*',
                                    icon: Icon(
                                      Icons.my_location,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey.currentState.fields['line1']
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
                                        r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ.-\d ]{2,160}$',
                                        errorText: 'Erreur de saisie')
                                  ]),
                                ),
                              ), //line1
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[2],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  name: 'line2',
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
                                    if (_fbKey.currentState.fields['line2']
                                        .validate()) {
                                      listFocusNode[2].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[3]);
                                    }
                                  },
                                  validator: FormBuilderValidators.match(
                                      context,
                                      r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ.-\d ]{0,160}$',
                                      errorText: 'Erreur de saisie'),
                                ),
                              ), //line2
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.number,
                                  focusNode: listFocusNode[3],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  name: 'postal_code',
                                  decoration: InputDecoration(
                                    labelText: 'Code postal*',
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
                                        .currentState.fields['postal_code']
                                        .validate()) {
                                      listFocusNode[3].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[4]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(context,
                                        errorText: 'Champs requis'),
                                    FormBuilderValidators.numeric(context,
                                        errorText: 'Erreur de saisie'),
                                    FormBuilderValidators.match(
                                        context, r'^[\d]{5}$',
                                        errorText: 'Erreur de saisie')
                                  ]),
                                ),
                              ), //code postal
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[4],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  name: 'city',
                                  decoration: InputDecoration(
                                    labelText: 'Ville*',
                                    icon: Icon(
                                      Icons.my_location,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey.currentState.fields['city']
                                        .validate()) {
                                      listFocusNode[4].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[5]);
                                    }
                                  },
                                  validator: (val) {
                                    final RegExp regex = RegExp(
                                        r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ\- ]{2,160}$');

                                    if (regex.allMatches(val).isEmpty) {
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
                                  focusNode: listFocusNode[5],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  name: 'region',
                                  decoration: InputDecoration(
                                    labelText: 'Région*',
                                    icon: Icon(
                                      Icons.my_location,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey.currentState.fields['region']
                                        .validate()) {
                                      listFocusNode[5].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[6]);
                                    }
                                  },
                                  validator: (val) {
                                    final RegExp regex = RegExp(
                                        r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ\- ]{2,160}$');

                                    if (regex.allMatches(val).isEmpty) {
                                      return 'Non valide';
                                    }
                                    return null;
                                  },
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
                                  cursorColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  name: 'phone',
                                  decoration: InputDecoration(
                                    labelText: 'Téléphone*',
                                    icon: Icon(
                                      Icons.phone,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey.currentState.fields['phone']
                                        .validate()) {
                                      listFocusNode[6].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[7]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(context,
                                        errorText: 'Champs requis'),
                                    FormBuilderValidators.match(context,
                                        r'(^(?:(?:\+)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$)',
                                        errorText: 'Erreur de saisie')
                                  ]),
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
                                  cursorColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  name: 'support_email',
                                  decoration: InputDecoration(
                                    labelText: 'Email support*',
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
                                        .currentState.fields['support_email']
                                        .validate()) {
                                      listFocusNode[7].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[8]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(context,
                                        errorText: 'Champs requis'),
                                    FormBuilderValidators.email(context,
                                        errorText: 'Email non valide')
                                  ]),
                                ),
                              ), //support email
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
                                  cursorColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  name: 'account_holder_name',
                                  decoration: InputDecoration(
                                    labelText: 'Titulaire du compte bancaire*',
                                    icon: Icon(
                                      Icons.person,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey.currentState
                                        .fields['account_holder_name']
                                        .validate()) {
                                      listFocusNode[10].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[11]);
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
                              ), //Detenteur du compte bancaire
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.text,
                                  focusNode: listFocusNode[11],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  cursorColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  name: 'account_number',
                                  decoration: InputDecoration(
                                    labelText: 'IBAN*',
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
                                        .currentState.fields['account_number']
                                        .validate()) {
                                      listFocusNode[11].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[12]);
                                    }
                                  },
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(context,
                                        errorText: 'Champs requis'),
                                    FormBuilderValidators.match(context,
                                        r'^[a-zA-Z]{2}[0-9]{2}\s?[a-zA-Z0-9]{4}\s?[0-9]{4}\s?[0-9]{3}([a-zA-Z0-9]\s?[a-zA-Z0-9]{0,4}\s?[a-zA-Z0-9]{0,4}\s?[a-zA-Z0-9]{0,4}\s?[a-zA-Z0-9]{0,3})?$',
                                        errorText: 'Erreur de saisie')
                                  ]),
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
                                  cursorColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  name: 'SIREN',
                                  decoration: InputDecoration(
                                    labelText: 'SIREN*',
                                    icon: Icon(
                                      FontAwesomeIcons.moneyCheckAlt,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    if (_fbKey.currentState.fields['SIREN']
                                        .validate()) {
                                      listFocusNode[12].unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(listFocusNode[13]);
                                    }
                                  },
                                  validator:
                                      FormBuilderValidators.required(context),
                                ),
                              ), //SIREN
                            ],
                          ),
                        ), //Societe/personne Physique
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Consumer(builder: (context, watch, child) {
                    return CheckboxListTile(
                      onChanged: (bool val) => boolToggleRead.changeCGUCGV(),
                      value: watch(boolToggleProvider).cguCgv,
                      activeColor: Theme.of(context).colorScheme.primary,
                      checkColor: Theme.of(context).colorScheme.background,
                      title: Wrap(
                        children: <Widget>[
                          Text('J\'ai lu et j\'accepte les',
                              style: Theme.of(context).textTheme.bodyText1),
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
                                    .bodyText1
                                    .copyWith(color: Colors.blue)),
                          ),
                          Text('et le ',
                              style: Theme.of(context).textTheme.bodyText1),
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
                                    .bodyText1
                                    .copyWith(color: Colors.blue)),
                          ),
                          Text(
                              ', ainsi que de recevoir les SMS automatisés envoyés par Stripe. Vous certifiez également que les informations que vous avez fournies à Stripe sont complètes et exactes',
                              style: Theme.of(context).textTheme.bodyText1),
                        ],
                      ),
                    );
                  }),
                  RegisterButton(
                    onPressed: () => _onFormSubmitted(
                        context, boolToggleRead, stripeRepo, myUserRepo),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onFormSubmitted(BuildContext context, BoolToggle boolToggleRead,
      StripeRepository stripeRepo, MyUserRepository myUserRepo) {
    if (!boolToggleRead.cguCgv) {
      Scaffold.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Veuillez accepter les CGU et CGV'),
              ],
            ),
          ),
        );

      return;
    }

    if (_fbKey.currentState.validate()) {
      final state = _fbKey.currentState;

      BlocProvider.of<RegisterBlocOrganisateur>(context).add(
        RegisterSubmitted(
            accountHolderName:
                state.fields['account_holder_name'].value.toString().trim(),
            accountNumber:
                state.fields['account_number'].value.toString().trim(),
            city: state.fields['city'].value.toString().trim(),
            line1: state.fields['line1'].value.toString().trim(),
            line2: state.fields['line2'].value.toString().trim(),
            nomSociete: state.fields['nomSociete'].value.toString().trim(),
            phone:
                parsePhoneNumber(state.fields['phone'].value.toString().trim()),
            postalCode: state.fields['postal_code'].value.toString().trim(),
            state: state.fields['region'].value.toString().trim(),
            supportEmail: state.fields['support_email'].value.toString().trim(),
            siren: state.fields['SIREN'].value.toString().trim(),
            stripeRepository: stripeRepo,
            myUserRepository: myUserRepo,
            boolToggleRead: boolToggleRead),
      );
    }
  }

  String parsePhoneNumber(String value) {
    return value.replaceFirst('0', '+33');
  }

  @override
  bool get wantKeepAlive => true;
}
