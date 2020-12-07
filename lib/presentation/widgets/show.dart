import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:van_events_project/constants/credentials.dart';
import 'package:van_events_project/domain/models/event.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_event_repository.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/presentation/widgets/lieuQuandAlertDialog.dart';
import 'package:van_events_project/providers/toggle_bool_chat_room.dart';
import 'package:van_events_project/providers/upload_event.dart';


class Show {
  static Future<PlacesDetailsResponse> showAddress(BuildContext context, String from) async {
    Timer _throttle;

    String str = await showGeneralDialog<String>(
        barrierDismissible: true,
        barrierLabel: "Label",
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 500),
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position:
                Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
            child: child,
          );
        },
        context: context,
        pageBuilder: (BuildContext context, anim1, anim2) => Align(
              alignment: Alignment.topCenter,
              child: Container(
//color: Colors.white,
//height: 300,
                margin:
                    EdgeInsets.only(bottom: 50, left: 12, right: 12, top: 30),
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
                              from == 'UploadEvent'? context
                                  .read(uploadEventProvider)
                                  .setSuggestions(List<Prediction>())
                                  :context.read(boolToggleProvider)
                                  .setSuggestions(List<Prediction>());

                              return;
                            }

                            GoogleMapsPlaces _places =
                                GoogleMapsPlaces(apiKey: PLACES_API_KEY);

                            PlacesAutocompleteResponse
                                placesAutocompleteResponse =
                                await _places.autocomplete(
                              value.toString(),
                              components: [Component(Component.country, "fr")],
                              language: 'fr',
                              types: ['address'],
                            );

                            if (placesAutocompleteResponse.isOkay) {
                              from == 'UploadEvent'? context
                                  .read(uploadEventProvider)
                                  .setSuggestions(placesAutocompleteResponse.predictions)
                                  :context.read(boolToggleProvider)
                                  .setSuggestions(placesAutocompleteResponse.predictions);

                            } else {
                              from == 'UploadEvent'? context
                                  .read(uploadEventProvider)
                                  .setSuggestions(null)
                                  :context.read(boolToggleProvider)
                                  .setSuggestions(null);

                            }
                          });
                        },
                        style: Theme.of(context).textTheme.headline5,
                        cursorColor: Theme.of(context).colorScheme.onBackground,
                        name: 'city',
                        maxLines: 1,
                        decoration: InputDecoration(
//labelText: 'Ville',
                            hintText: 'Recherche',
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
                            icon: InkWell(
                              onTap: (){
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: BackButtonIcon(

                                ),
                              ),
                            )
//
                            ),

                        validator: (val) {
                          RegExp regex = RegExp(
                              r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ\-. ]{2,60}$');

                          if (regex.allMatches(val).length == 0) {
                            return 'Non valide';
                          }
                          return null;
                        },
                      ),
                      Divider(),
                      Consumer(
                        builder: (context, watch, child) {
                          final myWatch = from ==  'UploadEvent'?
                          watch(uploadEventProvider).suggestions:watch(boolToggleProvider).suggestions;
                          print(myWatch);
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
                                        leading: Icon(Icons.location_on),
                                        title: Text(
                                          "${e.description}",
                                          style:
                                              Theme.of(context).textTheme.headline5,
                                        )))
                                    ?.toList() ??
                                List<Widget>(),
                          );
                        }
                      )
                    ],
                  ),
                ),
              ),
            ));

    GoogleMapsPlaces _places =
        GoogleMapsPlaces(apiKey: PLACES_API_KEY); //Same API_KEY as above

    if(str==null){
      return null;
    }

    return await _places.getDetailsByPlaceId(str);
  }

  static void showSnackBarError(BuildContext context,GlobalKey<ScaffoldState> _scaffoldKey, String content){
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(content,style: Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).colorScheme.onError ),),
            ],
          ),
        ),
      );
  }

  static showSnackBar(String val, GlobalKey<ScaffoldState> myScaffold) {
    myScaffold.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        )));
  }

  static Future<File> showDialogSource(BuildContext context) async{

    return await showDialog(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
          title: Text('Source?'),
          content: Text('Veuillez choisir une source'),
          actions: <Widget>[
            FlatButton(
              child: Text('Caméra'),
              onPressed: () async{
                await getImageFileCamera(context);
              },
            ),
            FlatButton(
              child: Text('Galerie'),
              onPressed: () async{
                await getImageFileGallery(context);
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
              onPressed: () async {
                await getImageFileCamera(context);
              },
            ),
            FlatButton(
              child: Text('Galerie'),
              onPressed: () async{
                await getImageFileGallery(context);
              },
            ),
          ],
        ));

  }

  static Future getImageFileGallery(BuildContext context) async {
    String str = (await ImagePicker()
        .getImage(source: ImageSource.gallery))?.path;
    if (str == null) {
      Navigator.of(context).pop();
    }
    Navigator.of(context).pop(File(str));
  }

  static Future getImageFileCamera(BuildContext context) async {
    String str = (await ImagePicker()
        .getImage(source: ImageSource.camera))?.path;
    if (str == null) {
      Navigator.of(context).pop();
    }
    Navigator.of(context).pop(File(str));
  }

  static Future showDialogToDismiss(BuildContext context,String title,String content, String button) async{
    return await showDialog(context: context,
        builder: (_){
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
                new FlatButton(
                  child: Text(
                    button,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(Future);
                  },
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
                    child: Text(
                      button[0].toUpperCase() +
                          button.substring(1).toLowerCase(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(Future);
                    },
                  )
                ]);
          }
        });
  }

  static Future showDialogGenresEtTypes(BuildContext context, int indexStart,TabController tabController){
    Widget lieuQuandAlertDialog(BuildContext context) {
      return LieuQuandAlertDialog();
    }

    SizedBox genreAlertDialog(BuildContext context) {
      return SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
            itemCount: context.read(boolToggleProvider).genre.keys.length,
            itemBuilder: (context, index) {
              List<String> str =
              context.read(boolToggleProvider).genre.keys.toList();

              return Consumer(builder: (context, watch, build) {
                return CheckboxListTile(
                  onChanged: (bool val) => context
                      .read(boolToggleProvider)
                      .modificationGenre(str[index]),
                  value: watch(boolToggleProvider).genre[str[index]],
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: Text(str[index]),
                );
              });
            }),
      );
    }

    SizedBox typeAlertDialog(BuildContext context) {
      return SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
            itemCount: context.read(boolToggleProvider).type.keys.length,
            itemBuilder: (context, index) {
              List<String> str =
              context.read(boolToggleProvider).type.keys.toList();

              return Consumer(builder: (context, watch, child) {
                return CheckboxListTile(
                  onChanged: (bool val) => context
                      .read(boolToggleProvider)
                      .modificationType(str[index]),
                  value: watch(boolToggleProvider).type[str[index]],
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: Text(str[index]),
                );
              });
            }),
      );
    }

    Widget genreCupertino(BuildContext context) {
      return SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          children: context
              .read(boolToggleProvider)
              .genre
              .keys
              .map((e) => Consumer(builder: (context, watch, child) {
            return CheckboxListTile(
              onChanged: (bool val) =>
                  context.read(boolToggleProvider).modificationGenre(e),
              value: watch(boolToggleProvider).genre[e],
              activeColor: Theme.of(context).colorScheme.primary,
              title: Text(e),
            );
          }))
              .toList(),
        ),
      );
    }

    Column typeCupertino(BuildContext context) {
      return Column(
        children: context
            .read(boolToggleProvider)
            .type
            .keys
            .map((e) => Consumer(builder: (context, watch, child) {
          return CheckboxListTile(
            onChanged: (bool val) =>
                context.read(boolToggleProvider).modificationType(e),
            value: watch(boolToggleProvider).type[e],
            activeColor: Theme.of(context).colorScheme.primary,
            title: Text(e),
          );
        }))
            .toList(),
      );
    }

    void modificationLieuEtDate(BuildContext context, List lieu, List quand) {
      if (lieu == null || lieu.isEmpty) {
        return;
      }

      switch (lieu[0]) {
        case 'address':
          context.read(boolToggleProvider).setLieux(Lieu.address);

          context.read(boolToggleProvider).setSelectedAdress(lieu[1]);
          break;
        case 'aroundMe':
          context.read(boolToggleProvider).setLieux(Lieu.aroundMe);
          break;
      }
      switch (quand[0]) {
        case 'date':
          context.read(boolToggleProvider).setQuand(Quand.date);

          if (quand[1].toString() != 'null') {
            Timestamp time = quand[1] as Timestamp;

            context.read(boolToggleProvider).setSelectedDate(time.toDate());
          }

          break;
        case 'ceSoir':
          context.read(boolToggleProvider).setQuand(Quand.ceSoir);
          break;
        case 'demain':
          context.read(boolToggleProvider).setQuand(Quand.demain);
          break;
        case 'avenir':
          context.read(boolToggleProvider).setQuand(Quand.avenir);
          break;
      }
    }
    List<Widget> containersAlertDialog = [
      lieuQuandAlertDialog(context),
      genreAlertDialog(context),
      typeAlertDialog(context)
    ];
    List<Widget> containersCupertino = [
      lieuQuandAlertDialog(context),
      genreCupertino(context),
      typeCupertino(context)
    ];

    context.read(boolToggleProvider).initLieuEtLieu();

    final myUserRead = context.read(myUserProvider);

    modificationLieuEtDate(context, myUserRead?.lieu, myUserRead?.quand);

    context.read(boolToggleProvider).initGenre();
    for (int i = 0; i < (myUserRead.genres != null
        ? myUserRead.genres.toList()
        : []).length; i++) {
      if (context.read(boolToggleProvider).genre.containsKey(myUserRead.genres[i])) {
        context.read(boolToggleProvider).modificationGenre(myUserRead.genres[i]);
      }
    }

    context.read(boolToggleProvider).initType();
    for (int i = 0; i < (myUserRead.types != null ? myUserRead.types.toList() : []).length; i++) {
      if (context.read(boolToggleProvider).type.containsKey(myUserRead.types[i])) {
        context.read(boolToggleProvider).modificationType(myUserRead.types[i]);
      }
    }

    tabController.animateTo(indexStart);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => Platform.isAndroid
          ? AlertDialog(
        title: Container(
          color: Theme.of(context).colorScheme.primary,
          child: TabBar(
            tabs: <Widget>[
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
        content: SizedBox(
          height: 450,
          width: double.maxFinite,
          child: TabBarView(
              controller: tabController, children: containersAlertDialog),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Annuler'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              context.read(myUserRepository).updateMyUserGenre(
                  context.read(boolToggleProvider).genre);
              context.read(myUserRepository).updateMyUserType(
                  context.read(boolToggleProvider).type);

              context
                  .read(myUserRepository)
                  .updateMyUserLieuQuand(
                  context.read(boolToggleProvider).lieu,
                  context.read(boolToggleProvider).selectedAdress,
                  context.read(boolToggleProvider).zone == 0
                      ? 25
                      : context.read(boolToggleProvider).zone == 1 / 3
                      ? 50
                      : context.read(boolToggleProvider).zone ==
                      2 / 3
                      ? 100
                      : null,
                  context.read(boolToggleProvider).quand,
                  context.read(boolToggleProvider).date);
              Navigator.of(context).pop();
            },
          ),
        ],
      )
          : CupertinoAlertDialog(
        title: Container(
          color: Theme.of(context).colorScheme.primary,
          child: TabBar(
            tabs: <Widget>[
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
        content: SizedBox(
          height: 450,
          child: TabBarView(
              controller: tabController, children: containersCupertino),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Annuler'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              context.read(myUserRepository).updateMyUserGenre(
                  context.read(boolToggleProvider).genre);
              context.read(myUserRepository).updateMyUserType(
                  context.read(boolToggleProvider).type);

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );

  }

  static void showAreYouSure(BuildContext context, MyEventRepository eventRepo, int index, List<MyEvent> events) {

    showDialog(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
          title: Text('Annuler?'),
          content: Text(
              'Etes vous sur de vouloir annuler l\'events'),
          actions: <Widget>[
            FlatButton(
              child: Text('Non'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Oui'),
              onPressed: () {
                eventRepo.cancelEvent(events
                    .elementAt(index)
                    .id);
              },
            ),
          ],
        )
            : CupertinoAlertDialog(
          title: Text('Annuler?'),
          content: Text(
              'Etes vous sur de vouloir annuler l\'events'),
          actions: <Widget>[
            FlatButton(
              child: Text('Non'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Oui'),
              onPressed: () {
                eventRepo.cancelEvent(events
                    .elementAt(index)
                    .id);
              },
            ),
          ],
        ));

  }

  static Future<void> showRembouser(BuildContext context) async{
    return await showDialog(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
          title: Text('Annuler?'),
          content: Text(
              'Etes vous sur de vouloir demander le remboursement?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Non'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Oui'),
              onPressed: () {
                //TODO
              },
            ),
          ],
        )
            : CupertinoAlertDialog(
          title: Text('Annuler?'),
          content: Text(
              'Etes vous sur de vouloir demander le remboursement?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Non'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Oui'),
              onPressed: () {
                //TODO
              },
            ),
          ],
        ));
  }




}