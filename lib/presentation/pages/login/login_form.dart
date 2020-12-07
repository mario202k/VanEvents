import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/pages/login/bloc/bloc.dart';
import 'package:van_events_project/presentation/pages/registerOrganisateur/register_screen_organisateur.dart';
import 'package:van_events_project/presentation/pages/reset_password.dart';
import 'package:van_events_project/presentation/widgets/create_account_button.dart';
import 'package:van_events_project/presentation/widgets/google_login_button.dart';
import 'package:van_events_project/presentation/widgets/login_button.dart';
import 'package:van_events_project/providers/authentication_cubit/authentication_cubit.dart';
import 'package:van_events_project/providers/toggle_bool_chat_room.dart';



class LoginForm extends HookWidget {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final FocusScopeNode _nodesEmail = FocusScopeNode();
  final FocusScopeNode _nodePassword = FocusScopeNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FlareControls flareControl = FlareControls();

  @override
  Widget build(BuildContext context) {
    print('LoginForm');

    final boolToggle = useProvider(boolToggleProvider);
    final myUserRepo = useProvider(myUserRepository);

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        print(state);
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
                      style: Theme.of(context).textTheme.button,
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
          Navigator.of(context).pushReplacementNamed(Routes.routeAuthentication);

          BlocProvider.of<AuthenticationCubit>(context).authenticationLoggedIn(myUserRepo);

        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          print('BlocBuilder');

          return SingleChildScrollView(
            child: LayoutBuilder(
                builder: (context, constraints) {

                  return LimitedBox(
                    maxHeight: 800,
                    maxWidth: constraints.maxWidth ,
                    child: Stack(
                      fit: StackFit.loose,
                      overflow: Overflow.visible,
                      children: [
                        Positioned(
                          top: -210,
                          child: Hero(
                            tag: 'logo',
                            child: LimitedBox(
                              maxHeight: 800,
                              maxWidth: constraints.maxWidth ,
                              child: FlareActor(
                                'assets/animations/logo.flr',
                                alignment: Alignment.center,
                                animation: 'disparaitre',
                                fit: BoxFit.fitHeight,
                                callback: (str){
                                  print(str);
                                  print('//');
                                  flareControl.play('dance');
                                },
                                controller: flareControl,


                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: 190,
                          child: LimitedBox(
                            maxHeight: 800,
                            maxWidth: constraints.maxWidth ,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                              color:
                                              Theme.of(context).colorScheme.onBackground),
                                          cursorColor:
                                          Theme.of(context).colorScheme.onBackground,
                                          name: 'Email',
                                          maxLines: 1,
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
                                          controller: _emailController,
                                          onChanged: (val) {
                                            if (_emailController.text.length == 0) {
                                              _emailController.clear();
                                            }
                                          },

                                          validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                                            FormBuilderValidators.email(context)]),

                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Consumer(builder: (context, watch, child) {
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
                                                color:
                                                Theme.of(context).colorScheme.onBackground,
                                              ),
                                              suffixIcon: IconButton(
                                                onPressed: () =>
                                                    boolToggle.setObscureTextLogin(),
                                                color:
                                                Theme.of(context).colorScheme.onBackground,
                                                iconSize: 20,
                                                icon: Icon(FontAwesomeIcons.eye),
                                              ),
                                            ),
                                            focusNode: _nodePassword,
                                            onEditingComplete: () {
                                              if (_fbKey.currentState.validate()) {
                                                _nodePassword.unfocus();
                                                _onFormSubmitted(context,myUserRepo);
                                              }
                                            },
                                            controller: _passwordController,
                                            onChanged: (val) {
                                              if (_passwordController.text.length == 0) {
                                                _passwordController.clear();
                                              }
                                            },

                                            validator: FormBuilderValidators.compose([FormBuilderValidators.required(context),
                                              FormBuilderValidators.match(context, r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d.*)[a-zA-Z0-9\S]{8,15}$')]),

                                          );
                                        }),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      !state.isSubmitting?LoginButton(
                                        onPressed: () => _onFormSubmitted(context,myUserRepo),
                                      ):Center(
                                        child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).colorScheme.primary)),
                                      ),
                                      GoogleLoginButton(),
                                      CreateAccountButton(),
                                      RaisedButton(
                                        onPressed: () {
                                          BlocProvider.of<LoginBloc>(context)
                                              .add(LoginWithAnonymous(myUserRepo));
                                        },
                                        child: Text('Anonyme'),

                                      ),
                                      FlatButton(
                                        child: Text(
                                          'Mot de passe oublié',
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) {
                                              return ResetPassword();
                                            }),
                                          );
                                        },
                                      ),
                                      RaisedButton(
                                        color: Colors.redAccent,
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) {
                                              return RegisterScreenOrganisateur();
                                            }),
                                          );
                                        },
                                        child: Text('J\'organise'),
                                      ),
                                      Hero(
                                        tag: 'vanevents',
                                        child: Text(
                                          'Van e.vents',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .copyWith(
                                              color: Colors.black, fontSize: 15),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
              }
            ),
          );
        },
      ),
    );
  }


  void _onFormSubmitted(BuildContext context,MyUserRepository myUserRepository) {
    if (_fbKey.currentState.validate()) {
      BlocProvider.of<LoginBloc>(context).add(
            LoginWithCredentialsPressed(
              email: _emailController.text,
              password: _passwordController.text,
              myUserRepository: myUserRepository
            ),
          );
    }
  }
}
