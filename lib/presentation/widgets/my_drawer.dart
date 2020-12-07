import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/providers/authentication_cubit/authentication_cubit.dart';

import 'custom_drawer.dart';

class MyDrawer extends HookWidget {
  @override
  Widget build(BuildContext context) {
    print('buildMyDrawer');
    final myUser = useProvider(myUserProvider);
    final myUserRepo = useProvider(myUserRepository);

    return SizedBox(
        width: 300,
        height: double.infinity,
        child: Material(
          color: Theme.of(context).colorScheme.secondary,
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: 30, left: 15, right: 15, bottom: 80),
                      child: Stack(
                        children: <Widget>[
                          FractionalTranslation(
                            translation: Offset(0.0, 2.1),
                            child: RawMaterialButton(
                              onPressed: () {
                                // BlocProvider.of<NavigationBloc>(context)
                                //     .add(NavigationEvents.Profil);

                                CustomDrawer.of(context).close();
                              },
                              elevation: 10,
                              shape: StadiumBorder(),
                              child: Container(
                                padding:
                                EdgeInsets.only(left: 20.0, right: 20.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                // child: SizedBox(
                                //     width: constraints.maxWidth,
                                //     height: 50,
                                //     child: myUserStream.when(
                                //         data: (myUser) {
                                //           return Center(
                                //               child: Text(
                                //             myUser.nom ?? '',
                                //             style: Theme.of(context)
                                //                 .textTheme
                                //                 .headline6,
                                //           ));
                                //         },
                                //         loading: () => Shimmer.fromColors(
                                //               baseColor: Colors.white,
                                //               highlightColor: Theme.of(context)
                                //                   .colorScheme
                                //                   .primary,
                                //               child: Container(
                                //                 width: 220,
                                //                 height: 220,
                                //                 //color: Colors.white,
                                //                 decoration: BoxDecoration(
                                //                     borderRadius:
                                //                         BorderRadius.all(
                                //                             Radius.circular(
                                //                                 25)),
                                //                     color: Colors.white),
                                //               ),
                                //             ),
                                //         error: (err, stack) => SizedBox())),
                              ),
                            ),
                          ),
                          Align(
                              alignment: FractionalOffset(0.5, 0.0),
                              child: CircleAvatar(
                                radius: 59,
                                backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                                // child: myUserStream.when(
                                //     data: (myUser) => CircleAvatar(
                                //           backgroundImage: myUser
                                //                   .imageUrl.isNotEmpty
                                //               ? NetworkImage(myUser.imageUrl)
                                //               : AssetImage(
                                //                   'assets/img/normal_user_icon.png'),
                                //           radius: 57,
                                //           backgroundColor: Theme.of(context)
                                //               .colorScheme
                                //               .primary,
                                //           child: RawMaterialButton(
                                //             shape: const CircleBorder(),
                                //             onPressed: () {
                                //               BlocProvider.of<NavigationBloc>(
                                //                       context)
                                //                   .add(NavigationEvents.Profil);
                                //               CustomDrawer.of(context).close();
                                //             },
                                //             padding: const EdgeInsets.all(57.0),
                                //           ),
                                //         ),
                                //     loading: () => Shimmer.fromColors(
                                //           baseColor: Colors.white,
                                //           highlightColor: Theme.of(context)
                                //               .colorScheme
                                //               .primary,
                                //           child: CircleAvatar(
                                //             radius: 59,
                                //             backgroundColor: Theme.of(context)
                                //                 .colorScheme
                                //                 .secondary,
                                //           ),
                                //         ),
                                //     error: (err, stack) {
                                //       return CircleAvatar(
                                //         radius: 59,
                                //         backgroundColor: Theme.of(context)
                                //             .colorScheme
                                //             .secondary,
                                //       );
                                //     }),
                              )),
                        ],
                        //mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 60, left: 15, right: 15),
                      child: SizedBox(
                        height: 340,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: ListTile(
                                title: Text(
                                  'Chat',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                leading: Icon(
                                  FontAwesomeIcons.comments,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onTap: () {
                                  // BlocProvider.of<NavigationBloc>(context)
                                  //     .add(NavigationEvents.Chat);
                                  CustomDrawer.of(context).close();
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: ListTile(
                                title: Text(
                                  'Mes billets',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                leading: Icon(
                                  FontAwesomeIcons.ticketAlt,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onTap: () {
                                  // BlocProvider.of<NavigationBloc>(context)
                                  //     .add(NavigationEvents.Billets);
                                  CustomDrawer.of(context).close();
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: ListTile(
                                title: Text(
                                  'Inviter un ami',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                leading: Icon(
                                  FontAwesomeIcons.shareAlt,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: ListTile(
                                title: Text(
                                  'Paramètres',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                leading: Icon(
                                  FontAwesomeIcons.cog,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onTap: () {
                                  // ExtendedNavigator.of(context)
                                  //     .push(Routes.stripeProfile);
                                },
                              ),
                            ),
                            myUser.typeDeCompte ==
                                TypeOfAccount.organizer //organisateur
                                ? Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(25),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      'Profil Stripe',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6,
                                    ),
                                    leading: Icon(
                                      FontAwesomeIcons.funnelDollar,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    onTap: () {
                                      ExtendedNavigator.of(context)
                                          .push(Routes.stripeProfile);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 1,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(25),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      'Admin Events',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6,
                                    ),
                                    leading: Icon(
                                      FontAwesomeIcons.userCog,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    onTap: () {
                                      ExtendedNavigator.of(context)
                                          .push(Routes.adminEvents);
                                    },
                                  ),
                                ),
                              ],
                            )
                                : myUser.typeDeCompte == TypeOfAccount.owner
                                ? Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(25),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      'Admin Organisateur',
                                      style: Theme.of(context)
                                          .textTheme
                                          .button,
                                    ),
                                    leading: Icon(
                                      FontAwesomeIcons.userCog,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    onTap: () {
                                      ExtendedNavigator.of(context).push(
                                          Routes.adminOrganisateurs);
                                    },
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(25),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      'Transport',
                                      style: Theme.of(context)
                                          .textTheme
                                          .button,
                                    ),
                                    leading: Icon(
                                      FontAwesomeIcons.car,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    onTap: () {
                                      ExtendedNavigator.of(context).push(
                                          Routes.transportScreen);
                                    },
                                  ),
                                ),
                              ],
                            )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: ListTile(
                          title: Text(
                            "Se déconnecter",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          leading: Icon(
                            FontAwesomeIcons.signOutAlt,
                            size: 18,
                            color: Colors.white,
                          ),
                          onTap: () async {
                            myUserRepo.setInactive();
                            BlocProvider.of<AuthenticationCubit>(context).authenticationLoggedOut(myUserRepo);
                            // context
                            //     .bloc<AuthenticationBloc>()
                            //     .add(AuthenticationLoggedOut());
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ));
  }
}