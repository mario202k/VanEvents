import 'dart:async';

import 'package:after_init/after_init.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:van_events_project/constants/credentials.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/toggle_bool.dart';

enum Lieu { address, aroundMe }
enum Quand { date, ceSoir, demain, avenir }

class LieuQuandAlertDialog extends StatefulWidget {
  @override
  _LieuQuandAlertDialogState createState() => _LieuQuandAlertDialogState();
}

class _LieuQuandAlertDialogState extends State<LieuQuandAlertDialog>
    with AfterInitMixin {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchEditingController =
      TextEditingController();
  Timer _throttle;

  @override
  void initState() {
    super.initState();
    _searchEditingController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchEditingController.removeListener(_onSearchChanged);
    _searchEditingController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_throttle?.isActive ?? false) {
      _throttle.cancel();
    }
    _throttle = Timer(const Duration(milliseconds: 500), () {
      getLocationResults(_searchEditingController.text, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      isAlwaysShown: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        child: Column(
          children: [
            Text(
              'Lieu',
              style: Theme.of(context).textTheme.headline5,
            ),
            Consumer(builder: (context, watch, child) {
              return RadioListTile(
                value: Lieu.address,
                groupValue: watch(boolToggleProvider).lieu,
                onChanged: (Lieu value) {
                  context.read(boolToggleProvider).setLieux(value);
                },
                title: InkWell(
                    onTap: () async {
                      showGeneralDialog(
                          barrierDismissible: true,
                          barrierLabel: "Label",
                          barrierColor: Colors.black.withOpacity(0.5),
                          transitionDuration: const Duration(milliseconds: 500),
                          transitionBuilder: (context, anim1, anim2, child) {
                            return SlideTransition(
                              position: Tween(
                                      begin: const Offset(0, 1),
                                      end: const Offset(0, 0))
                                  .animate(anim1),
                              child: child,
                            );
                          },
                          context: context,
                          pageBuilder: (BuildContext context, anim1, anim2) =>
                              Align(
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
                                          controller: _searchEditingController,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                          cursorColor: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          name: 'city',
                                          decoration: InputDecoration(
                                              //labelText: 'Ville',
                                              hintText: 'Recherche',
                                              border: const OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                              disabledBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                              errorBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedErrorBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                              icon: IconButton(
                                                icon: const Icon(
                                                    Icons.arrow_back_ios),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
//
                                              ),
                                        ),
                                        const Divider(),
                                        Consumer(
                                            builder: (context, watch, child) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: watch(boolToggleProvider)
                                                .suggestions
                                                .map((e) => ListTile(
                                                    onTap: () {
                                                      context
                                                          .read(
                                                              boolToggleProvider)
                                                          .setSelectedAdress(
                                                              e.terms[0].value);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    leading: const Icon(
                                                        Icons.location_on),
                                                    title: Text(
                                                      e.description,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                    )))
                                                .toList(),
                                          );
                                        })
                                      ],
                                    ),
                                  ),
                                ),
                              ));
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            borderRadius: BorderRadius.circular(25)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 16),
                          child: Consumer(builder: (context, watch, child) {
                            return Text(
                              watch(boolToggleProvider).selectedAdress ??
                                  'Recherche',
                              style: Theme.of(context).textTheme.bodyText1,
                              overflow: TextOverflow.ellipsis,
                            );
                          }),
                        ))),
              );
            }),
            Consumer(builder: (context, watch, child) {
              return RadioListTile(
                value: Lieu.aroundMe,
                groupValue: watch(boolToggleProvider).lieu,
                onChanged: (Lieu value) async {
                  context.read(boolToggleProvider).setLieux(value);
                  if (value == Lieu.aroundMe) {
                    final LocationPermission permission =
                        await Geolocator.requestPermission();

                    if (permission == LocationPermission.always ||
                        permission == LocationPermission.whileInUse) {
                      final Position position =
                          await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high);

                      context.read(myUserRepository).setUserPosition(position);
                    } else {
                      context.read(boolToggleProvider).setLieux(Lieu.address);
                    }
                  }
                },
                title: Text(
                  'Autour de moi',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
            }),
            Consumer(builder: (context, watch, child) {
              final toggle = watch(boolToggleProvider);
              return toggle.lieu == Lieu.aroundMe
                  ? Slider.adaptive(
                      value: toggle.zone,
                      onChanged: (newZone) =>
                          context.read(boolToggleProvider).newZone(newZone),
                      divisions: 3,
                      label: toggle.zone == 0
                          ? '25 km'
                          : toggle.zone == 1 / 3
                              ? '50 km'
                              : toggle.zone == 2 / 3
                                  ? '100 km'
                                  : 'Partout',
                    )
                  : const SizedBox();
            }),
            Text(
              'Quand',
              style: Theme.of(context).textTheme.headline5,
            ),
            Consumer(builder: (context, watch, child) {
              final toggle = watch(boolToggleProvider);
              // final myUser = context.read(myUserProvider);
              return RadioListTile(
                value: Quand.date,
                groupValue: toggle.quand,
                onChanged: (Quand value) {
                  context.read(boolToggleProvider).setQuand(value);
                },
                title: FormBuilderDateTimePicker(
                  initialValue: toggle.dateQuand,
                  firstDate: DateTime.now(),
                  name: "Date",
                  //focusNode: _nodes[1],
                  onChanged: (dt) {
                    context.read(boolToggleProvider).setSelectedDate(dt);

//                    SystemChannels.textInput
//                        .invokeMethod('TextInput.hide');
//                    context.read<BoolToggle>().modificationDateDebut(dt);
//
//                    setState(() {
//                      _dateDebut = dt;
//                    });
                  },
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  cursorColor: Theme.of(context).colorScheme.onSurface,
                  inputType: InputType.date,
                  format: DateFormat("dd/MM/yyyy"),
                  decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: Theme.of(context).textTheme.bodyText1),
                ),
              );
            }),
            Consumer(builder: (context, watch, child) {
              final toggle = watch(boolToggleProvider);
              return RadioListTile(
                value: Quand.ceSoir,
                groupValue: toggle.quand,
                title: Text(
                  'Ce soir',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onChanged: (Quand value) {
                  context.read(boolToggleProvider).setQuand(value);
                },
              );
            }),
            Consumer(builder: (context, watch, child) {
              final toggle = watch(boolToggleProvider);
              return RadioListTile(
                value: Quand.demain,
                groupValue: toggle.quand,
                title: Text(
                  'Demain',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onChanged: (Quand value) {
                  context.read(boolToggleProvider).setQuand(value);
                },
              );
            }),
            Consumer(builder: (context, watch, child) {
              final toggle = watch(boolToggleProvider);
              return RadioListTile(
                value: Quand.avenir,
                groupValue: toggle.quand,
                title: Text(
                  'À venir',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onChanged: (Quand value) {
                  context.read(boolToggleProvider).setQuand(value);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> getLocationResults(String text, BuildContext context) async {
    if (text.isEmpty) {
      context.read(boolToggleProvider).setSuggestions(<Prediction>[]);
      return;
    }

    const String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    const String components = 'country:fr';

    const String language = 'fr';

    const String types = '(regions)';

    final String request =
        '$baseURL?input=$text&key=$placesApiKey&components=$components&language=$language&types=$types';

    final Response response = await Dio().get(request);

    final predictions = response.data['predictions'] as List;

    final List<Prediction> suggestions = <Prediction>[];

    for (final prediction in predictions) {
      // String name = prediction['description'];

      suggestions.add(Prediction.fromJson(prediction as Map));
    }

    context.read(boolToggleProvider).setSuggestions(suggestions);
  }

  @override
  void didInitState() {
    if (context.read(myUserProvider).lieu.isNotEmpty &&
        context.read(myUserProvider).lieu[0] == 'address') {
      context
          .read(boolToggleProvider)
          .initSelectedAdress(context.read(myUserProvider).lieu[1] as String);
    }
  }
}
