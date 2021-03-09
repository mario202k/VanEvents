import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_cache_builder.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:van_events_project/constants/credentials.dart';
import 'package:van_events_project/domain/models/event.dart';
import 'package:van_events_project/domain/models/refund.dart';
import 'package:van_events_project/domain/repositories/my_event_repository.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/presentation/pages/refund_screen.dart';
import 'package:van_events_project/presentation/widgets/lieu_quand_alertdialog.dart';
import 'package:van_events_project/providers/toggle_bool.dart';
import 'package:van_events_project/providers/upload_event.dart';

class Show {
  static Future<PlacesDetailsResponse> showAddress(
      BuildContext context, String from) async {
    Timer _throttle;

    final String str = await showGeneralDialog<String>(
        barrierDismissible: true,
        barrierLabel: "Label",
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 500),
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
                .animate(anim1),
            child: child,
          );
        },
        context: context,
        pageBuilder: (BuildContext context, anim1, anim2) => Align(
              alignment: Alignment.topCenter,
              child: Container(
//color: Colors.white,
//height: 300,
                margin: const EdgeInsets.only(
                    bottom: 50, left: 12, right: 12, top: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),

                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FormBuilderTextField(
                        keyboardType: TextInputType.text,
                        autofocus: true,
                        onChanged: (value) {
                          if (_throttle?.isActive ?? false) {
                            _throttle.cancel();
                          }
                          _throttle = Timer(const Duration(milliseconds: 500),
                              () async {
                            if (value.toString().isEmpty) {
                              from == 'UploadEvent'
                                  ? context
                                      .read(uploadEventProvider)
                                      .setSuggestions(<Prediction>[])
                                  : context
                                      .read(boolToggleProvider)
                                      .setSuggestions(<Prediction>[]);

                              return;
                            }

                            final GoogleMapsPlaces _places =
                                GoogleMapsPlaces(apiKey: placesApiKey);

                            final PlacesAutocompleteResponse
                                placesAutocompleteResponse =
                                await _places.autocomplete(
                              value.toString(),
                              components: [Component(Component.country, "fr")],
                              language: 'fr',
                              types: ['address'],
                            );

                            if (placesAutocompleteResponse.isOkay) {
                              from == 'UploadEvent'
                                  ? context
                                      .read(uploadEventProvider)
                                      .setSuggestions(placesAutocompleteResponse
                                          .predictions)
                                  : context
                                      .read(boolToggleProvider)
                                      .setSuggestions(placesAutocompleteResponse
                                          .predictions);
                            } else {
                              from == 'UploadEvent'
                                  ? context
                                      .read(uploadEventProvider)
                                      .setSuggestions(null)
                                  : context
                                      .read(boolToggleProvider)
                                      .setSuggestions(null);
                            }
                          });
                        },
                        style: Theme.of(context).textTheme.bodyText1,
                        cursorColor: Theme.of(context).colorScheme.onBackground,
                        name: 'city',
                        decoration: InputDecoration(
//labelText: 'Ville',
                            hintText: 'Recherche',
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            disabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            icon: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: BackButtonIcon(),
                              ),
                            )
//
                            ),
                        validator: (val) {
                          final RegExp regex = RegExp(regExpNom);

                          if (regex.allMatches(val).isEmpty) {
                            return 'Non valide';
                          }
                          return null;
                        },
                      ),
                      const Divider(),
                      Consumer(builder: (context, watch, child) {
                        final myWatch = from == 'UploadEvent'
                            ? watch(uploadEventProvider).suggestions
                            : watch(boolToggleProvider).suggestions;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: myWatch
                                  ?.map((e) => ListTile(
                                      onTap: () {
                                        context
                                            .read(boolToggleProvider)
                                            .setSelectedAdress(e.description);
                                        Navigator.of(context).pop(e.placeId);
                                      },
                                      leading: const Icon(Icons.location_on),
                                      title: Text(
                                        e.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      )))
                                  ?.toList() ??
                              <Widget>[],
                        );
                      })
                    ],
                  ),
                ),
              ),
            ));

    final GoogleMapsPlaces _places =
        GoogleMapsPlaces(apiKey: placesApiKey); //Same API_KEY as above

    if (str == null) {
      return null;
    }

    return _places.getDetailsByPlaceId(str);
  }

  static void showSnackBarError(BuildContext context,
      GlobalKey<ScaffoldState> _scaffoldKey, String content) {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                content,
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(color: Theme.of(context).colorScheme.onError),
              ),
            ],
          ),
        ),
      );
  }

  static showSnackBar(String val, GlobalKey<ScaffoldState> myScaffold) {
    myScaffold.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          backgroundColor: const Color(0xFF26418f),
          duration: const Duration(seconds: 3),
          content: Text(
            val,
            textAlign: TextAlign.center,
            // style: TextStyle(color: Colors.white, fontSize: 16.0),
          )));
  }

  static Future<File> showDialogSource(BuildContext context) async {
    return showDialog<File>(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
                title: const Text('Source?'),
                content: const Text('Veuillez choisir une source'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () async {
                      await getImageFileCamera(context);
                    },
                    child: const Text('Caméra'),
                  ),
                  FlatButton(
                    onPressed: () async {
                      await getImageFileGallery(context);
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
                    onPressed: () async {
                      await getImageFileCamera(context);
                    },
                    child: const Text('Caméra'),
                  ),
                  FlatButton(
                    onPressed: () async {
                      await getImageFileGallery(context);
                    },
                    child: const Text('Galerie'),
                  ),
                ],
              ));
  }

  static Future<dynamic> getImageFileGallery(BuildContext context) async {
    final String str =
        (await ImagePicker().getImage(source: ImageSource.gallery))?.path;
    if (str == null) {
      Navigator.of(context).pop();
    }
    Navigator.of(context).pop(File(str));
  }

  static Future<dynamic> getImageFileCamera(BuildContext context) async {
    final String str =
        (await ImagePicker().getImage(source: ImageSource.camera))?.path;
    if (str == null) {
      Navigator.of(context).pop();
    }
    Navigator.of(context).pop(File(str));
  }

  static Future showDialogToDismiss(
      BuildContext context, String title, String content, String button) async {
    return showDialog(
        context: context,
        builder: (_) {
          if (!Platform.isIOS) {
            return AlertDialog(
              title: Text(
                title,
                style: Theme.of(context).textTheme.headline5,
              ),
              content: Text(
                content,
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(Future);
                  },
                  child: Text(
                    button,
                  ),
                ),
              ],
            );
          } else {
            return CupertinoAlertDialog(
                title: Text(
                  title,
                ),
                content: Text(
                  content,
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () {
                      Navigator.of(context).pop(Future);
                    },
                    child: Text(
                      button[0].toUpperCase() +
                          button.substring(1).toLowerCase(),
                    ),
                  )
                ]);
          }
        });
  }

  static Future showLieuQuandGenresEtTypes(
      BuildContext context,
      List userGenres,
      List userTypes,
      int indexStart,
      TabController tabController,
      List listLieu,
      List listQuand,
      GeoPoint geoPoint) async {
    Widget lieuQuandAlertDialog(BuildContext context) {
      return LieuQuandAlertDialog();
    }

    Widget genreAlertDialog(BuildContext context) {
      return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: context.read(boolToggleProvider).genre.keys.length,
          itemBuilder: (context, index) {
            final List<String> str =
                context.read(boolToggleProvider).genre.keys.toList();

            return Consumer(builder: (context, watch, build) {
              return CheckboxListTile(
                onChanged: (bool val) => context
                    .read(boolToggleProvider)
                    .modificationGenre(str[index]),
                value: watch(boolToggleProvider).genre[str[index]],
                title: Text(
                  str[index],
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
            });
          });
    }

    Widget typeAlertDialog(BuildContext context) {
      return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: context.read(boolToggleProvider).type.keys.length,
          itemBuilder: (context, index) {
            final List<String> str =
                context.read(boolToggleProvider).type.keys.toList();
            return Consumer(builder: (context, watch, child) {
              return CheckboxListTile(
                onChanged: (bool val) => context
                    .read(boolToggleProvider)
                    .modificationType(str[index]),
                value: watch(boolToggleProvider).type[str[index]],
                title: Text(
                  str[index],
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
            });
          });
    }

    // Widget genreCupertino(BuildContext context) {
    //   return SingleChildScrollView(
    //     physics: ClampingScrollPhysics(),
    //     child: Column(
    //       children: context
    //           .read(boolToggleProvider)
    //           .genre
    //           .keys
    //           .map((e) => Consumer(builder: (context, watch, child) {
    //         return CheckboxListTile(
    //           onChanged: (bool val) =>
    //               context.read(boolToggleProvider).modificationGenre(e),
    //           value: watch(boolToggleProvider).genre[e],
    //           activeColor: Theme.of(context).colorScheme.primary,
    //           title: Text(e,style: Theme.of(context).textTheme.bodyText1,),
    //         );
    //       }))
    //           .toList(),
    //     ),
    //   );
    // }
    //
    // Column typeCupertino(BuildContext context) {
    //   return Column(
    //     children: context
    //         .read(boolToggleProvider)
    //         .type
    //         .keys
    //         .map((e) => Consumer(builder: (context, watch, child) {
    //       return CheckboxListTile(
    //         onChanged: (bool val) =>
    //             context.read(boolToggleProvider).modificationType(e),
    //         value: watch(boolToggleProvider).type[e],
    //         activeColor: Theme.of(context).colorScheme.primary,
    //         title: Text(e,style: Theme.of(context).textTheme.bodyText1,),
    //       );
    //     }))
    //         .toList(),
    //   );
    // }

    // void modificationLieuEtDate(BuildContext context, List lieu, List quand) {
    //   if (lieu == null || lieu.isEmpty) {
    //     return;
    //   }
    //
    //   switch (lieu[0]) {
    //     case 'address':
    //       context.read(boolToggleProvider).setLieux(Lieu.address);
    //
    //       context.read(boolToggleProvider).setSelectedAdress(lieu[1]);
    //       break;
    //     case 'aroundMe':
    //       context.read(boolToggleProvider).setLieux(Lieu.aroundMe);
    //       break;
    //   }
    //   switch (quand[0]) {
    //     case 'date':
    //       context.read(boolToggleProvider).setQuand(Quand.date);
    //
    //       if (quand[1].toString() != 'null') {
    //         Timestamp time = quand[1] as Timestamp;
    //
    //         context.read(boolToggleProvider).setSelectedDate(time.toDate());
    //       }
    //
    //       break;
    //     case 'ceSoir':
    //       context.read(boolToggleProvider).setQuand(Quand.ceSoir);
    //       break;
    //     case 'demain':
    //       context.read(boolToggleProvider).setQuand(Quand.demain);
    //       break;
    //     case 'avenir':
    //       context.read(boolToggleProvider).setQuand(Quand.avenir);
    //       break;
    //   }
    // }
    final List<Widget> containersAlertDialog = [
      lieuQuandAlertDialog(context),
      genreAlertDialog(context),
      typeAlertDialog(context)
    ];
    // List<Widget> containersCupertino = [
    //   lieuQuandAlertDialog(context),
    //   genreCupertino(context),
    //   typeCupertino(context)
    // ];

    context.read(boolToggleProvider).initGenre(genres: userGenres);

    context
        .read(boolToggleProvider)
        .initLieuQuandGeo(listLieu: listLieu, listQuand: listQuand);

    context.read(boolToggleProvider).initType(types: userTypes);

    tabController.animateTo(indexStart);

    await showGeneralDialog<String>(
        barrierDismissible: true,
        barrierLabel: "Label",
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 500),
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
                .animate(anim1),
            child: child,
          );
        },
        context: context,
        pageBuilder: (BuildContext context, anim1, anim2) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.only(
                  bottom: 50, left: 50, right: 50, top: 50),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.primary,
                    child: TabBar(
                      tabs: const <Widget>[
                        Tab(
                          text: 'Lieu/Quand',
                        ),
                        Tab(
                          text: 'Genres',
                        ),
                        Tab(
                          text: 'Types',
                        )
                      ],
                      controller: tabController,
                    ),
                  ),
                  LimitedBox(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                    maxWidth: double.maxFinite,
                    child: TabBarView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: tabController,
                        children: containersAlertDialog),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Annuler'),
                          ),
                          RaisedButton(
                            onPressed: () {
                              context.read(myUserRepository).updateMyUserGenre(
                                  context.read(boolToggleProvider).genre);
                              context.read(myUserRepository).updateMyUserType(
                                  context.read(boolToggleProvider).type);

                              context
                                  .read(myUserRepository)
                                  .updateMyUserLieuQuand(
                                      context.read(boolToggleProvider).lieu,
                                      context
                                          .read(boolToggleProvider)
                                          .selectedAdress,
                                      context.read(boolToggleProvider).zone == 0
                                          ? 25
                                          : context
                                                      .read(boolToggleProvider)
                                                      .zone ==
                                                  1 / 3
                                              ? 50
                                              : context
                                                          .read(
                                                              boolToggleProvider)
                                                          .zone ==
                                                      2 / 3
                                                  ? 100
                                                  : null,
                                      context.read(boolToggleProvider).quand,
                                      context.read(boolToggleProvider).date);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Ok'),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  // static Future showDialogLieuQuandGenresEtTypes(BuildContext context,List userGenres,
  // List userTypes, int indexStart,TabController tabController, List listLieu,
  //     List listQuand, GeoPoint geoPoint){
  //   Widget lieuQuandAlertDialog(BuildContext context) {
  //     return LieuQuandAlertDialog();
  //   }
  //
  //   SizedBox genreAlertDialog(BuildContext context) {
  //     print("genreAlertDialog");
  //     return SizedBox(
  //       width: double.maxFinite,
  //       child: ListView.builder(
  //           itemCount: context.read(boolToggleProvider).genre.keys.length,
  //           itemBuilder: (context, index) {
  //             List<String> str =
  //             context.read(boolToggleProvider).genre.keys.toList();
  //
  //             return Consumer(builder: (context, watch, build) {
  //               return CheckboxListTile(
  //                 onChanged: (bool val) => context
  //                     .read(boolToggleProvider)
  //                     .modificationGenre(str[index]),
  //                 value: watch(boolToggleProvider).genre[str[index]],
  //                 activeColor: Theme.of(context).colorScheme.primary,
  //                 title: Text(str[index],style: Theme.of(context).textTheme.bodyText1,),
  //               );
  //             });
  //           }),
  //     );
  //   }
  //
  //   SizedBox typeAlertDialog(BuildContext context) {
  //     return SizedBox(
  //       width: double.maxFinite,
  //       child: ListView.builder(
  //           itemCount: context.read(boolToggleProvider).type.keys.length,
  //           itemBuilder: (context, index) {
  //             List<String> str =
  //             context.read(boolToggleProvider).type.keys.toList();
  //
  //             return Consumer(builder: (context, watch, child) {
  //               return CheckboxListTile(
  //                 onChanged: (bool val) => context
  //                     .read(boolToggleProvider)
  //                     .modificationType(str[index]),
  //                 value: watch(boolToggleProvider).type[str[index]],
  //                 title: Text(str[index],style: Theme.of(context).textTheme.bodyText1,),
  //               );
  //             });
  //           }),
  //     );
  //   }
  //
  //   Widget genreCupertino(BuildContext context) {
  //     return SingleChildScrollView(
  //       physics: ClampingScrollPhysics(),
  //       child: Column(
  //         children: context
  //             .read(boolToggleProvider)
  //             .genre
  //             .keys
  //             .map((e) => Consumer(builder: (context, watch, child) {
  //           return CheckboxListTile(
  //             onChanged: (bool val) =>
  //                 context.read(boolToggleProvider).modificationGenre(e),
  //             value: watch(boolToggleProvider).genre[e],
  //             activeColor: Theme.of(context).colorScheme.primary,
  //             title: Text(e,style: Theme.of(context).textTheme.bodyText1,),
  //           );
  //         }))
  //             .toList(),
  //       ),
  //     );
  //   }
  //
  //   Column typeCupertino(BuildContext context) {
  //     return Column(
  //       children: context
  //           .read(boolToggleProvider)
  //           .type
  //           .keys
  //           .map((e) => Consumer(builder: (context, watch, child) {
  //         return CheckboxListTile(
  //           onChanged: (bool val) =>
  //               context.read(boolToggleProvider).modificationType(e),
  //           value: watch(boolToggleProvider).type[e],
  //           activeColor: Theme.of(context).colorScheme.primary,
  //           title: Text(e,style: Theme.of(context).textTheme.bodyText1,),
  //         );
  //       }))
  //           .toList(),
  //     );
  //   }
  //
  //   // void modificationLieuEtDate(BuildContext context, List lieu, List quand) {
  //   //   if (lieu == null || lieu.isEmpty) {
  //   //     return;
  //   //   }
  //   //
  //   //   switch (lieu[0]) {
  //   //     case 'address':
  //   //       context.read(boolToggleProvider).setLieux(Lieu.address);
  //   //
  //   //       context.read(boolToggleProvider).setSelectedAdress(lieu[1]);
  //   //       break;
  //   //     case 'aroundMe':
  //   //       context.read(boolToggleProvider).setLieux(Lieu.aroundMe);
  //   //       break;
  //   //   }
  //   //   switch (quand[0]) {
  //   //     case 'date':
  //   //       context.read(boolToggleProvider).setQuand(Quand.date);
  //   //
  //   //       if (quand[1].toString() != 'null') {
  //   //         Timestamp time = quand[1] as Timestamp;
  //   //
  //   //         context.read(boolToggleProvider).setSelectedDate(time.toDate());
  //   //       }
  //   //
  //   //       break;
  //   //     case 'ceSoir':
  //   //       context.read(boolToggleProvider).setQuand(Quand.ceSoir);
  //   //       break;
  //   //     case 'demain':
  //   //       context.read(boolToggleProvider).setQuand(Quand.demain);
  //   //       break;
  //   //     case 'avenir':
  //   //       context.read(boolToggleProvider).setQuand(Quand.avenir);
  //   //       break;
  //   //   }
  //   // }
  //   List<Widget> containersAlertDialog = [
  //     lieuQuandAlertDialog(context),
  //     genreAlertDialog(context),
  //     typeAlertDialog(context)
  //   ];
  //   List<Widget> containersCupertino = [
  //     lieuQuandAlertDialog(context),
  //     genreCupertino(context),
  //     typeCupertino(context)
  //   ];
  //   print(userGenres);
  //   print('//');
  //   context.read(boolToggleProvider).initGenre(genres: userGenres);
  //
  //   context.read(boolToggleProvider).initLieuQuandGeo(listLieu: listLieu, listQuand: listQuand);
  //
  //   context.read(boolToggleProvider).initType(types: userTypes);
  //
  //   //context.read(boolToggleProvider).initLieuEtLieu();
  //
  //   // final myUserRead = context.read(myUserProvider);
  //
  //   //modificationLieuEtDate(context, myUserRead?.lieu, myUserRead?.quand);
  //
  //   // context.read(boolToggleProvider).initGenre();
  //   // for (int i = 0; i < (myUserRead.genres != null
  //   //     ? myUserRead.genres.toList()
  //   //     : []).length; i++) {
  //   //   if (context.read(boolToggleProvider).genre.containsKey(myUserRead.genres[i])) {
  //   //     context.read(boolToggleProvider).modificationGenre(myUserRead.genres[i]);
  //   //   }
  //   // }
  //   //
  //   // // context.read(boolToggleProvider).initType();
  //   // for (int i = 0; i < (myUserRead.types != null ? myUserRead.types.toList() : []).length; i++) {
  //   //   if (context.read(boolToggleProvider).type.containsKey(myUserRead.types[i])) {
  //   //     context.read(boolToggleProvider).modificationType(myUserRead.types[i]);
  //   //   }
  //   // }
  //
  //   tabController.animateTo(indexStart);
  //
  //   return showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) => Platform.isAndroid
  //         ? AlertDialog(
  //       title: Container(
  //         color: Theme.of(context).colorScheme.primary,
  //         child: TabBar(
  //           tabs: <Widget>[
  //             Tab(
  //               text: 'Lieu/Quand',
  //             ),
  //             Tab(
  //               text: 'Genres',
  //             ),
  //             Tab(
  //               text: 'Types',
  //             )
  //           ],
  //           controller: tabController,
  //         ),
  //       ),
  //       content: SizedBox(
  //         height: 450,
  //         width: double.maxFinite,
  //         child: TabBarView(
  //             controller: tabController, children: containersAlertDialog),
  //       ),
  //       actions: <Widget>[
  //         FlatButton(
  //           child: Text('Annuler'),
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //           },
  //         ),
  //         RaisedButton(
  //           child: Text('Ok'),
  //           onPressed: () {
  //             context.read(myUserRepository).updateMyUserGenre(
  //                 context.read(boolToggleProvider).genre);
  //             context.read(myUserRepository).updateMyUserType(
  //                 context.read(boolToggleProvider).type);
  //
  //             context
  //                 .read(myUserRepository)
  //                 .updateMyUserLieuQuand(
  //                 context.read(boolToggleProvider).lieu,
  //                 context.read(boolToggleProvider).selectedAdress,
  //                 context.read(boolToggleProvider).zone == 0
  //                     ? 25
  //                     : context.read(boolToggleProvider).zone == 1 / 3
  //                     ? 50
  //                     : context.read(boolToggleProvider).zone ==
  //                     2 / 3
  //                     ? 100
  //                     : null,
  //                 context.read(boolToggleProvider).quand,
  //                 context.read(boolToggleProvider).date);
  //             Navigator.of(context).pop();
  //           },
  //         ),
  //       ],
  //     )
  //         : CupertinoAlertDialog(
  //       title: Container(
  //         color: Theme.of(context).colorScheme.primary,
  //         child: TabBar(
  //           tabs: <Widget>[
  //             Tab(
  //               text: 'Lieu/Quand',
  //             ),
  //             Tab(
  //               text: 'Genres',
  //             ),
  //             Tab(
  //               text: 'Types',
  //             )
  //           ],
  //           controller: tabController,
  //         ),
  //       ),
  //       content: SizedBox(
  //         height: 450,
  //         child: TabBarView(
  //             controller: tabController, children: containersCupertino),
  //       ),
  //       actions: <Widget>[
  //         FlatButton(
  //           child: Text('Annuler'),
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //           },
  //         ),
  //         RaisedButton(
  //           child: Text('Ok'),
  //           onPressed: () {
  //             context.read(myUserRepository).updateMyUserGenre(
  //                 context.read(boolToggleProvider).genre);
  //             context.read(myUserRepository).updateMyUserType(
  //                 context.read(boolToggleProvider).type);
  //
  //             Navigator.of(context).pop();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  //
  // }

  static void showAreYouSure(BuildContext context, MyEventRepository eventRepo,
      int index, List<MyEvent> events) {
    showDialog(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
                title: const Text('Annuler?'),
                content:
                    const Text('Etes vous sur de vouloir annuler l\'events'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Non'),
                  ),
                  FlatButton(
                    onPressed: () {
                      eventRepo.cancelEvent(events.elementAt(index).id);
                    },
                    child: const Text('Oui'),
                  ),
                ],
              )
            : CupertinoAlertDialog(
                title: const Text('Annuler?'),
                content:
                    const Text('Etes vous sur de vouloir annuler l\'events'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Non'),
                  ),
                  FlatButton(
                    onPressed: () {
                      eventRepo.cancelEvent(events.elementAt(index).id);
                    },
                    child: const Text('Oui'),
                  ),
                ],
              ));
  }

  static Future<bool> showRembourser(BuildContext context) async {
    return showDialog<bool>(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
                title: const Text('Rembourser?'),
                content:
                    const Text('Que voulez-vous faire de ce remboursement??'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annuler'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Refuser'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Accepter'),
                  ),
                ],
              )
            : CupertinoAlertDialog(
                title: const Text('Rembourser?'),
                content:
                    const Text('Que voulez-vous faire de ce remboursement??'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annuler'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Refuser'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Accepter'),
                  ),
                ],
              ));
  }

  static Future<bool> showAreYouSureModel(
      {BuildContext context, String title, String content}) async {
    return showDialog<bool>(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Non'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Oui'),
                  ),
                ],
              )
            : CupertinoAlertDialog(
                title: Text(title),
                content: Text(content),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Non'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Oui'),
                  ),
                ],
              ));
  }

  static Future<Map> showRembourserClient(
      BuildContext context, double amoutOfItem) async {
    final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
    final Map response = {
      'reason': RefundReason.requestedByCustomer,
      'amount': null
    };
    final List<RefundReason> myList = List.from(RefundReason.values);
    myList.removeWhere(
        (element) => element == RefundReason.expiredUncapturedCharge);
    return showDialog<Map>(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
                title: const Text('Rembourser'),
                content: Column(
                  children: [
                    Consumer(builder: (context, watch, child) {
                      return DropdownButton<RefundReason>(
                          value: watch(boolToggleProvider).reason,
                          hint: Text('Selectionner une raison',
                              style: Theme.of(context).textTheme.bodyText1),
                          items: myList.map((val) {
                            return DropdownMenuItem(
                                value: val, child: Text(toNormalReason(val)));
                          }).toList(),
                          onChanged: (val) {
                            context
                                .read(boolToggleProvider)
                                .setRefundRaison(val);
                            response.addAll({'reason': val});
                          });
                    }),
                    ...context
                        .read(boolToggleProvider)
                        .amountList
                        .map((e) => Consumer(builder: (context, watch, child) {
                              return RadioListTile(
                                value: e,
                                groupValue: watch(boolToggleProvider).amount,
                                onChanged: (value) {
                                  context
                                      .read(boolToggleProvider)
                                      .setAmount(value as String);
                                  if (value == 'La totalité') {
                                    response.addAll({'amount': null});
                                  }
                                },
                                title: Text(
                                  e,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              );
                            }))
                        .toList(),
                    Consumer(builder: (context, watch, child) {
                      return Visibility(
                          visible:
                              watch(boolToggleProvider).amount == 'Une partie',
                          child: FormBuilder(
                            key: _fbKey,
                            child: FormBuilderTextField(
                              name: 'amount',
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              cursorColor:
                                  Theme.of(context).colorScheme.onSurface,
                              decoration: const InputDecoration(
                                labelText: 'Montant',
                              ),
                              validator: (val) {
                                if (context.read(boolToggleProvider).amount ==
                                        'Une partie' &&
                                    (val == null || val.isEmpty) &&
                                    !isValid(val, amoutOfItem)) {
                                  return 'Veuillez saisir ce champs';
                                }

                                return null;
                              },
                            ),
                          ));
                    }),
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annulé'),
                  ),
                  FlatButton(
                    onPressed: () {
                      if (context.read(boolToggleProvider).amount ==
                              'Une partie' &&
                          _fbKey.currentState.validate()) {
                        final amount =
                            _fbKey.currentState.fields['amount'].value;
                        double chosenAmount;
                        try {
                          chosenAmount = double.parse(amount.toString());
                          response.addAll({'amount': chosenAmount});
                          Navigator.of(context).pop(response);
                        } catch (e) {
                          Navigator.of(context).pop({});
                        }
                      } else if (context.read(boolToggleProvider).amount ==
                          'La totalité') {
                        Navigator.of(context).pop(response);
                      }
                    },
                    child: const Text('Oui'),
                  ),
                ],
              )
            : CupertinoAlertDialog(
                title: const Text('Rembourser'),
                content: Column(
                  children: [
                    Consumer(builder: (context, watch, child) {
                      return DropdownButton<RefundReason>(
                          value: watch(boolToggleProvider).reason,
                          hint: const Text('Selectionner une raison'),
                          items: myList.map((val) {
                            return DropdownMenuItem(
                                value: val, child: Text(toNormalReason(val)));
                          }).toList(),
                          onChanged: (val) {
                            context
                                .read(boolToggleProvider)
                                .setRefundRaison(val);
                            response.addAll({'reason': val});
                          });
                    }),
                    ...context
                        .read(boolToggleProvider)
                        .amountList
                        .map((e) => Consumer(builder: (context, watch, child) {
                              return RadioListTile(
                                value: e,
                                groupValue: watch(boolToggleProvider).amount,
                                onChanged: (value) {
                                  context
                                      .read(boolToggleProvider)
                                      .setAmount(value as String);
                                  if (value == 'La totalité') {
                                    response.addAll({'amount': null});
                                  }
                                },
                                title: Text(
                                  e,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              );
                            }))
                        .toList(),
                    Consumer(builder: (context, watch, child) {
                      return Visibility(
                          visible:
                              watch(boolToggleProvider).amount == 'Une partie',
                          child: FormBuilder(
                            key: _fbKey,
                            child: FormBuilderTextField(
                              name: 'amount',
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              cursorColor:
                                  Theme.of(context).colorScheme.onSurface,
                              decoration: const InputDecoration(
                                labelText: 'Montant',
                              ),
                              validator: (val) {
                                if (context.read(boolToggleProvider).amount ==
                                        'Une partie' &&
                                    (val == null || val.isEmpty) &&
                                    !isValid(val, amoutOfItem)) {
                                  return 'Erreur de saisi';
                                }
                                if (context.read(boolToggleProvider).amount ==
                                        'Une partie' &&
                                    !isValid(val, amoutOfItem)) {
                                  return 'Erreur de saisi';
                                }
                                return null;
                              },
                            ),
                          ));
                    }),
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop({});
                    },
                    child: const Text('Annulé'),
                  ),
                  FlatButton(
                    onPressed: () {
                      if (context.read(boolToggleProvider).amount ==
                              'Une partie' &&
                          _fbKey.currentState.validate()) {
                        final amount =
                            _fbKey.currentState.fields['amount'].value;
                        double chosenAmount;
                        try {
                          chosenAmount = double.parse(amount.toString());
                          response.addAll({'amount': chosenAmount});
                          Navigator.of(context).pop(response);
                        } catch (e) {
                          debugPrint(e.toString());
                          Navigator.of(context).pop({});
                        }
                      } else if (context.read(boolToggleProvider).amount ==
                          'La totalité') {
                        Navigator.of(context).pop(response);
                      }
                    },
                    child: const Text('Ok'),
                  ),
                ],
              ));
  }

  static bool isValid(String chosenAmount, double amountOfItem) {
    double chosenAmountTemp;

    try {
      chosenAmountTemp = double.parse(chosenAmount.toString());
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }

    return chosenAmountTemp != null &&
        chosenAmountTemp < amountOfItem &&
        chosenAmountTemp > 0;
  }

  static Future<bool> showAreYouSurePhotoModel(
      {BuildContext context, String title, File content}) async {
    return showDialog<bool>(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
                title: Text(title),
                content: Image(
                  image: FileImage(content),
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Non'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Oui'),
                  ),
                ],
              )
            : CupertinoAlertDialog(
                title: Text(title),
                content: Image(
                  image: FileImage(content),
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Non'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Oui'),
                  ),
                ],
              ));
  }

  static Future<void> showProgress(BuildContext context) async {
    await showGeneralDialog<String>(
        barrierDismissible: true,
        barrierLabel: "Label",
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 500),
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
                .animate(anim1),
            child: child,
          );
        },
        context: context,
        pageBuilder: (BuildContext context, anim1, anim2) {
          context.read(boolToggleProvider).setProgressContext(context);

          return Center(
            child: Container(
              margin: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              constraints: const BoxConstraints(maxWidth: 300, minHeight: 300),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(5),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: FlareCacheBuilder([
                        AssetFlare(
                            bundle: rootBundle,
                            name: 'assets/animations/paymentProcess.flr')
                      ], builder: (context, isWarm) {
                        return !isWarm
                            ? Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary)),
                              )
                            : const FlareActor(
                                'assets/animations/paymentProcess.flr',
                                animation: 'paymentProcess',
                              );
                      }),
                    ),
                    Text(
                      'Veuillez patienter...',
                      style: Theme.of(context).textTheme.headline6,
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  static Future<bool> showDialogChoicesAvatar(BuildContext context) async {
    return showDialog<bool>(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
                title: const Text('Avatar'),
                content: const Text('Que voulez-vous changer?'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annuler'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Image'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Nom'),
                  ),
                ],
              )
            : CupertinoAlertDialog(
                title: const Text('Avatar'),
                content: const Text('Que voulez-vous changer?'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annuler'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Image'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Nom'),
                  ),
                ],
              ));
  }

  static Future<String> showNewName(BuildContext context) {
    final GlobalKey<FormBuilderState> fbKey = GlobalKey<FormBuilderState>();
    return showDialog<String>(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
                title: const Text('Nouveau nom'),
                content: FormBuilder(
                  key: fbKey,
                  child: FormBuilderTextField(
                    keyboardType: TextInputType.text,
                    autofocus: true,
                    style: Theme.of(context).textTheme.bodyText1,
                    cursorColor: Theme.of(context).colorScheme.onBackground,
                    name: 'nom',
                    decoration: const InputDecoration(
//labelText: 'Ville',
                      hintText: 'Nom',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
//
                    ),
                    validator: (val) {
                      final RegExp regex = RegExp(regExpNom);

                      if (regex.allMatches(val).isEmpty) {
                        return 'Non valide';
                      }
                      return null;
                    },
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annuler'),
                  ),
                  FlatButton(
                    onPressed: () {
                      if (fbKey.currentState.validate()) {
                        Navigator.of(context).pop(
                            fbKey.currentState.fields['nom'].value.toString());
                      }
                    },
                    child: const Text('Ok'),
                  ),
                ],
              )
            : CupertinoAlertDialog(
                title: const Text('Nouveau nom'),
                content: FormBuilder(
                  key: fbKey,
                  child: FormBuilderTextField(
                    keyboardType: TextInputType.text,
                    autofocus: true,
                    style: Theme.of(context).textTheme.bodyText1,
                    cursorColor: Theme.of(context).colorScheme.onBackground,
                    name: 'nom',
                    decoration: const InputDecoration(
//labelText: 'Ville',
                      hintText: 'Nom',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
//
                    ),
                    validator: (val) {
                      final RegExp regex = RegExp(regExpNom);

                      if (regex.allMatches(val).isEmpty) {
                        return 'Non valide';
                      }
                      return null;
                    },
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annuler'),
                  ),
                  FlatButton(
                    onPressed: () {
                      if (fbKey.currentState.validate()) {
                        Navigator.of(context).pop(
                            fbKey.currentState.fields['nom'].value.toString());
                      }
                    },
                    child: const Text('Ok'),
                  ),
                ],
              ));
  }

  static Future<void> showLoading(BuildContext context) async {
    return showGeneralDialog<String>(
        barrierDismissible: false,
        barrierLabel: "Label",
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 500),
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
                .animate(anim1),
            child: child,
          );
        },
        context: context,
        pageBuilder: (BuildContext context, anim1, anim2) => Center(
              child: SizedBox(
                height: 200.0,
                width: 200.0,
                child: CircularProgressIndicator(
                  strokeWidth: 5,

                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary)),
              ),
            ));
  }
}
