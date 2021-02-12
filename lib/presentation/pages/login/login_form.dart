import 'package:auto_route/auto_route.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/pages/login/bloc/bloc.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/register_screen_organisateur.dart';
import 'package:van_events_project/presentation/pages/reset_password.dart';
import 'package:van_events_project/presentation/widgets/create_account_button.dart';
import 'package:van_events_project/presentation/widgets/google_login_button.dart';
import 'package:van_events_project/presentation/widgets/login_button.dart';
import 'package:van_events_project/providers/authentication_cubit/authentication_cubit.dart';
import 'package:van_events_project/providers/settings_change_notifier.dart';
import 'package:van_events_project/providers/toggle_bool.dart';

class LoginForm extends HookWidget {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final FocusScopeNode _nodesEmail = FocusScopeNode();
  final FocusScopeNode _nodePassword = FocusScopeNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FlareControls flareControl = FlareControls();
  final String myEmail;

  LoginForm({this.myEmail});

  @override
  Widget build(BuildContext context) {

    final boolToggle = useProvider(boolToggleProvider);
    final myUserRepo = useProvider(myUserRepository);

    _emailController.text = myEmail ?? '';

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.rep,
                      style: Theme.of(context).textTheme.button.copyWith(
                            color: Theme.of(context).colorScheme.onError,
                          ),
                    ),
                    Icon(
                      Icons.error,
                      color: Theme.of(context).colorScheme.onError,
                    )
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
        if (state.isSuccess) {
          ExtendedNavigator.of(context).pushAndRemoveUntil(Routes.routeAuthentication, (route) => false);
          // Navigator.of(context)
          //     .pushReplacementNamed(Routes.routeAuthentication);

          BlocProvider.of<AuthenticationCubit>(context)
              .authenticationLoggedIn(myUserRepo);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {

          return Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 650,
              child: LimitedBox(
                maxWidth: 500,
                child: Stack(
                  overflow: Overflow.visible,
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: -310,
                      child: Hero(
                        tag: 'logo',
                        child: LimitedBox(
                          maxHeight: 800,
                          maxWidth: 500,
                          child: FlareActor(
                            'assets/animations/logo.flr',
                            animation: 'disparaitre',
                            fit: BoxFit.fitHeight,
                            callback: (str) {

                              flareControl.play('dance');
                            },
                            controller: flareControl,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 90,
                      child: LimitedBox(
                        maxHeight: 800,
                        maxWidth: 500,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 80) ,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FormBuilder(
                                key: _fbKey,
                                //autovalidate: false,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FormBuilderTextField(
                                        keyboardType: TextInputType.emailAddress,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                        cursorColor: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                        name: 'Email',
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
                                        focusNode: _nodesEmail,
                                        onEditingComplete: () {
                                          if (_fbKey.currentState.fields['Email']
                                              .validate()) {
                                            _nodesEmail.unfocus();
                                            FocusScope.of(context)
                                                .requestFocus(_nodePassword);
                                          }
                                        },
                                        controller: _emailController,
                                        onChanged: (val) {
                                          if (_emailController.text.isEmpty) {
                                            _emailController.clear();
                                          }
                                        },
                                        validator: FormBuilderValidators.compose([
                                          FormBuilderValidators.required(context,
                                              errorText: 'Champs requis'),
                                          FormBuilderValidators.email(context,
                                              errorText: 'email non valide')
                                        ]),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Consumer(
                                          builder: (context, watch, child) {
                                            return FormBuilderTextField(
                                              keyboardType: TextInputType.text,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onBackground),
                                              cursorColor: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                              name: 'Mot de passe',
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
                                                  onPressed: () => boolToggle
                                                      .setObscureTextLogin(),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onBackground,
                                                  iconSize: 20,
                                                  icon: const Icon(FontAwesomeIcons.eye),
                                                ),
                                              ),
                                              focusNode: _nodePassword,
                                              onEditingComplete: () {
                                                if (_fbKey.currentState.validate()) {
                                                  _nodePassword.unfocus();
                                                  _onFormSubmitted(
                                                      context, myUserRepo);
                                                }
                                              },
                                              controller: _passwordController,
                                              onChanged: (val) {
                                                if (_passwordController.text.isEmpty) {
                                                  _passwordController.clear();
                                                }
                                              },
                                              validator:
                                              FormBuilderValidators.compose([
                                                FormBuilderValidators.required(
                                                    context,
                                                    errorText: 'Champs requis'),
                                                FormBuilderValidators.match(context,
                                                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d.*)[a-zA-Z0-9\S]{8,15}$',
                                                    errorText:
                                                    '1 majuscule, 1 chiffre, 8 caractères')
                                              ]),
                                            );
                                          }),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    if (!state.isSubmitting) LoginButton(
                                      onPressed: () => _onFormSubmitted(
                                          context, myUserRepo),
                                    ) else Center(
                                      child: CircularProgressIndicator(
                                          valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary)),
                                    ),
                                    GoogleLoginButton(),
                                    Consumer(builder: (context, watch, child) {
                                      return SignInWithAppleButton(
                                        borderRadius:
                                        const BorderRadius.all(Radius.circular(25)),
                                        text: 'avec Apple',
                                        style: watch(settingsProvider)
                                            .onGoingTheme ==
                                            MyThemes.Dracula
                                            ? SignInWithAppleButtonStyle.white
                                            : SignInWithAppleButtonStyle.black,
                                        onPressed: () {
                                          BlocProvider.of<LoginBloc>(context).add(
                                            LoginWithApplePressed(myUserRepo),
                                          );
                                        },
                                      );
                                    }),
                                    CreateAccountButton(),
                                    RaisedButton(
                                      onPressed: () {
                                        BlocProvider.of<LoginBloc>(context)
                                            .add(LoginWithAnonymous(myUserRepo));
                                      },
                                      child: const Text('Anonyme'),
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                            return ResetPassword();
                                          }),
                                        );
                                      },
                                      child: Text(
                                        'Mot de passe oublié',
                                        style:
                                        Theme.of(context).textTheme.headline5,
                                      ),
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                            return RegisterScreenOrganisateur();
                                          }),
                                        );
                                      },
                                      child: const Text('J\'organise'),
                                    ),
                                    Hero(
                                      tag: 'vanevents',
                                      child: Text(
                                        'Van e.vents',
                                        textAlign: TextAlign.center,
                                        style:
                                        Theme.of(context).textTheme.caption,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onFormSubmitted(
      BuildContext context, MyUserRepository myUserRepository) {
    if (_fbKey.currentState.validate()) {
      BlocProvider.of<LoginBloc>(context).add(
        LoginWithCredentialsPressed(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            myUserRepository: myUserRepository),
      );
    }
  }
}
