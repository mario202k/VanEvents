import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/authentication_cubit/authentication_cubit.dart';
import 'package:van_events_project/providers/settings_change_notifier.dart';
import 'package:van_events_project/providers/toggle_bool.dart';

class Settings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final myUserRepo = useProvider(myUserRepository);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paramètres',
        ),
      ),
      body: ModelBody(
        child: Column(
          children: [
            MyTheme(),
            MyAccountSettings(myUserRepo),
            NotificationsSettings(myUserRepo),
            FlatButton(
                child: Text('Supprimer mon compte'),
                onPressed: () async {
                  bool b = await Show.showAreYouSureModel(
                          title: 'Supprimer',
                          content:
                              'Êtes vous sûr de vouloir supprimer votre compte?',
                          context: context) ??
                      false;

                  if (b) {
                    await myUserRepo.supprimerCompte().catchError((e) {
                      print(e);

                      Show.showDialogToDismiss(
                          context,
                          'Reconnecter',
                          'Veuillez-vous reconnecter afin de supprimer votre compte.',
                          'Ok');
                    }).then((value) async {
                      BlocProvider.of<AuthenticationCubit>(context).authenticationLoggedOut(myUserRepo);
                    });
                  }
                })
          ],
        ),
      ),
    );
  }
}

class MyTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FaIcon(
                  FontAwesomeIcons.palette,
                  size: 20,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              Text(
                'Thèmes',
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        ),
        Divider(),
        ...MyThemes.values
            .map((e) => Consumer(builder: (context, watch, child) {
                  final changeNotif = watch(settingsProvider);
                  return RadioListTile<MyThemes>(
                    title: Text(
                      e.toString().substring(e.toString().indexOf('.') + 1),
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    value: e,
                    onChanged: (myTheme) {
                      changeNotif.setTheme(myTheme);
                    },
                    groupValue: changeNotif.onGoingTheme,
                  );
                }))
      ],
    );
  }
}

class NotificationsSettings extends StatelessWidget {
  final myUserRepo;
  final List<String> settingsList;

  NotificationsSettings(this.myUserRepo)
      : settingsList = ['News VanEvents', 'Next Events', 'Messages'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FaIcon(
                  FontAwesomeIcons.volumeUp,
                  size: 20,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        ),
        Divider(),
        ...settingsList.map(
          (e) => Consumer(builder: (context, watch, child) {
            final changeNotif = watch(boolToggleProvider);
            return SwitchListTile(
              title: Text(
                e,
                style: Theme.of(context).textTheme.headline5,
              ),
              value: changeNotif.isEnableNotification(e),
              onChanged: (b) {
                changeNotif.setIsEnableNotification(b, e);
              },
            );
          }),
        )
      ],
    );
  }
}

class MyAccountSettings extends StatelessWidget {
  final MyUserRepository myUserRepo;
  final List<String> settingsList;

  MyAccountSettings(this.myUserRepo)
      : settingsList = ['Changer de mot de passe', 'A propos'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FaIcon(
                  FontAwesomeIcons.user,
                  size: 20,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              Text(
                'Mon compte',
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        ),
        Divider(),
        ...settingsList.map((e) => ListTile(
              leading: Text(
                e,
                style: Theme.of(context).textTheme.headline5,
              ),
              trailing: Icon(
                FontAwesomeIcons.chevronRight,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              onTap: () async {
                switch (e) {
                  case 'Changer de mot de passe':
                    final b = await Show.showAreYouSureModel(
                        context: context,
                        content:
                            'Êtes-vous sûr de vouloir change de mot de passe?',
                        title: 'Changer le mot de passe');
                    if (b) {
                      await myUserRepo.changePassword();
                      final result = await Show.showDialogToDismiss(
                              context,
                              'Email envoyé',
                              'Veuillez vérifier vos emails',
                              'Ok')
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
                    break;
                  case 'A propos':
                    ExtendedNavigator.of(context).push(Routes.aboutScreen);
                }
              },
            ))
      ],
    );
  }
}
