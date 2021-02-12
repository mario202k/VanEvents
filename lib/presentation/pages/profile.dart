import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/domain/models/billet.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_billet_repository.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';
import 'package:van_events_project/providers/toggle_bool.dart';

class Profil extends HookWidget {
  final MyUser other;

  const Profil({this.other});

  void showDialogGenresEtTypes(BuildContext context, List userGenres,
      List userTypes, int indexStart, TabController tabController) {
    final List<Widget> containersAlertDialog = [
      genreAlertDialog(context),
      typeAlertDialog(context)
    ];
    final List<Widget> containersCupertino = [
      genreCupertino(context),
      typeCupertino(context)
    ];
    context.read(boolToggleProvider).initGenre(genres: userGenres);
    // for (int i = 0; i < userGenres.length; i++) {
    //   if (context.read(boolToggleProvider).genre.containsKey(userGenres[i])) {
    //     context.read(boolToggleProvider).modificationGenre(userGenres[i]);
    //   }
    // }

    context.read(boolToggleProvider).initType(types: userTypes);
    // for (int i = 0; i < userTypes.length; i++) {
    //   if (context.read(boolToggleProvider).type.containsKey(userTypes[i])) {
    //     context.read(boolToggleProvider).modificationType(userTypes[i]);
    //   }
    // }

    tabController.animateTo(indexStart);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Platform.isAndroid
          ? AlertDialog(
              title: Container(
                color: Theme.of(context).colorScheme.primary,
                child: TabBar(
                  tabs: const <Widget>[
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                FlatButton(
                  onPressed: () {
                    context.read(myUserRepository).updateMyUserGenre(
                        context.read(boolToggleProvider).genre);
                    context.read(myUserRepository).updateMyUserType(
                        context.read(boolToggleProvider).type);
                    Navigator.of(context).pop();

                    // context.read<MyUserRepository>().updateUserLieu(context.read(boolToggleProvider).)
                  },
                  child: const Text('Ok'),
                ),
              ],
            )
          : CupertinoAlertDialog(
              title: Container(
                color: Theme.of(context).colorScheme.primary,
                child: TabBar(
                  tabs: const <Widget>[
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                FlatButton(
                  onPressed: () {
                    context.read(myUserRepository).updateMyUserGenre(
                        context.read(boolToggleProvider).genre);
                    context.read(myUserRepository).updateMyUserType(
                        context.read(boolToggleProvider).type);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ok'),
                ),
              ],
            ),
    );
  }

  SizedBox genreAlertDialog(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
          itemCount: context.read(boolToggleProvider).genre.keys.length,
          itemBuilder: (context, index) {
            final List<String> str =
                context.read(boolToggleProvider).genre.keys.toList();

            return Consumer(builder: (context, watch, child) {
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

  Widget genreCupertino(BuildContext context) {
    return SingleChildScrollView(
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

  Widget typeCupertino(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
      ),
    );
  }

  SizedBox typeAlertDialog(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
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
                activeColor: Theme.of(context).colorScheme.primary,
                title: Text(str[index]),
              );
            });
          }),
    );
  }

  void showDialogSource(BuildContext context, MyUserRepository db) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Platform.isAndroid
          ? AlertDialog(
              title: Text(
                'Source?',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              content: const Text('Veuillez choisir une source'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    getImageCamera(db);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Caméra'),
                ),
                FlatButton(
                  onPressed: () {
                    getImageGallery(db);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Galerie'),
                ),
              ],
            )
          : CupertinoAlertDialog(
              title: Text(
                'Source?',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              content: const Text('Veuillez choisir une source'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    getImageCamera(db);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Caméra'),
                ),
                FlatButton(
                  onPressed: () {
                    getImageGallery(db);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Galerie'),
                ),
              ],
            ),
    );
  }

  Future getImageGallery(MyUserRepository db) async {
    final _picker = ImagePicker();
    final File imageProfil =
        File((await _picker.getImage(source: ImageSource.gallery)).path);
    //création du path pour le flyer
    await db.uploadImageProfil(imageProfil);
  }

  Future getImageCamera(MyUserRepository db) async {
    final _picker = ImagePicker();
    final File imageProfil =
        File((await _picker.getImage(source: ImageSource.camera)).path);
    await db.uploadImageProfil(imageProfil);
  }

  @override
  Widget build(BuildContext context) {
    final MyUser user = other ?? useProvider(myUserProvider);
    final streamMyUser = useProvider(streamMyUserProvider);
    final db = useProvider(myUserRepository);
    final tabController = useTabController(initialLength: 2);

    return ModelBody(
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 200,
            height: 100,
            child: Stack(
              overflow: Overflow.visible,
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Align(
                    child: other == null
                        ? streamMyUser.when(
                            data: (data) {
                              return data.imageUrl.isNotEmpty
                                  ? InkWell(
                                      onTap: () {
                                        ExtendedNavigator.of(context).push(
                                            Routes.fullPhoto,
                                            arguments: FullPhotoArguments(
                                                url: data.imageUrl));
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl: data.imageUrl,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(100)),
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Shimmer.fromColors(
                                          baseColor: Colors.white,
                                          highlightColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          child: const CircleAvatar(
                                            radius: 50,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    )
                                  : Center(
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        backgroundImage: const AssetImage(
                                            'assets/img/normal_user_icon.png'),
                                      ),
                                    );
                            },
                            loading: () => Center(
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context)
                                              .colorScheme
                                              .primary)),
                                ),
                            error: (err, stack) => const Icon(Icons.error))
                        : CachedNetworkImage(
                            imageUrl: other?.imageUrl,
                            imageBuilder: (context, imageProvider) =>
                                GestureDetector(
                              onTap: () {
                                ExtendedNavigator.of(context).push(
                                    Routes.fullPhoto,
                                    arguments: FullPhotoArguments(
                                        url: other?.imageUrl));
                              },
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(100)),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.white,
                              highlightColor:
                                  Theme.of(context).colorScheme.primary,
                              child: const CircleAvatar(
                                radius: 50,
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                backgroundImage: const AssetImage(
                                    'assets/img/normal_user_icon.png'),
                              ),
                            ),
                          ),
                  ),
                ),
                if (other == null) Positioned(
                        bottom: -15,
                        right: 10,
                        child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.pencilAlt,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              showDialogSource(context, db);
                            })) else const SizedBox(),
              ],
            ),
          ),
          Center(
            child: Text(
              user.nom ?? 'Anonymous',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Participations:',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ),
          FutureBuilder<List<Billet>>(
            future: context
                .read(myBilletRepositoryProvider)
                .futureBilletParticipation(otherUid: other?.id),
            builder: (context, async) {
              if (async.hasError) {
                debugPrint(async.error.toString());
                return const Center(
                  child: Text(
                    'Erreur de connexion',
                  ),
                );
              } else if (async.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.secondary)),
                );
              }

              final List<Billet> tickets = <Billet>[];

              tickets.addAll(async.data);

              return tickets.isNotEmpty
                  ? SizedBox(
                      height: 100,
                      child: ListView.separated(
                        separatorBuilder: (context, index) => const SizedBox(
                          width: 12,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                ExtendedNavigator.of(context).push(
                                    Routes.fullPhoto,
                                    arguments: FullPhotoArguments(
                                        url: tickets[index].imageUrl));
                              },
                              child: CachedNetworkImage(
                                imageUrl: tickets[index].imageUrl,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: 84,
                                  width: 84,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        const BorderRadius.all(Radius.circular(84)),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.white,
                                  highlightColor:
                                      Theme.of(context).colorScheme.primary,
                                  child: const CircleAvatar(
                                    radius: 42,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox();
            },
          ),
          const Divider(),
          ListTile(
            leading: Text(
              'Genres:',
              style: Theme.of(context).textTheme.headline5,
            ),
            trailing: other == null
                ? streamMyUser.when(
                    data: (user) => IconButton(
                        icon: Icon(FontAwesomeIcons.pencilAlt,
                            color: Theme.of(context).colorScheme.primary),
                        onPressed: () => showDialogGenresEtTypes(
                            context,
                            user.genres != null ? user.genres.toList() : [],
                            user.types != null ? user.types.toList() : [],
                            0,
                            tabController)),
                    loading: () => Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary)),
                        ),
                    error: (err, stack) => const Icon(Icons.error))
                : const SizedBox(),
          ),
          if (other == null) streamMyUser.when(
                  data: (user) {
                    return Column(
                      children: user.genres
                          .map((e) => ListTile(
                                title: Text(
                                  e?.toString() ?? '',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                trailing: IconButton(
                                  onPressed: null,
                                  icon: Icon(FontAwesomeIcons.solidHeart,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ))
                          .toList(),
                    );
                  },
                  loading: () => Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary)),
                      ),
                  error: (err, stack) => const Icon(Icons.error)) else Column(
                  children: other.genres
                      .map((e) => ListTile(
                            title: Text(
                              e?.toString() ?? '',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            trailing: IconButton(
                              onPressed: null,
                              icon: Icon(FontAwesomeIcons.solidHeart,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ))
                      .toList(),
                ),
          const Divider(),
          ListTile(
            leading: Text(
              'Types:',
              style: Theme.of(context).textTheme.headline5,
            ),
            trailing: other == null
                ? streamMyUser.when(
                    data: (user) => IconButton(
                        icon: Icon(FontAwesomeIcons.pencilAlt,
                            color: Theme.of(context).colorScheme.primary),
                        onPressed: () => showDialogGenresEtTypes(
                            context,
                            user.genres != null ? user.genres.toList() : [],
                            user.types != null ? user.types.toList() : [],
                            1,
                            tabController)),
                    loading: () => Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary)),
                        ),
                    error: (err, stack) => const Icon(Icons.error))
                : const SizedBox(),
          ),
          if (other == null) streamMyUser.when(
                  data: (user) => Column(
                        children: user.types
                            .map((e) => ListTile(
                                  title: Text(
                                    e?.toString() ?? '',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  trailing: IconButton(
                                    onPressed: null,
                                    icon: Icon(FontAwesomeIcons.solidHeart,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                ))
                            .toList(),
                      ),
                  loading: () => Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary)),
                      ),
                  error: (err, stack) => const Icon(Icons.error)) else Column(
                  children: other.types
                      .map((e) => ListTile(
                            title: Text(
                              e?.toString() ?? '',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            trailing: IconButton(
                              onPressed: null,
                              icon: Icon(FontAwesomeIcons.solidHeart,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ))
                      .toList(),
                ),
          const Divider(),
          ListTile(
            leading: Icon(FontAwesomeIcons.envelope,
                color: Theme.of(context).colorScheme.onBackground),
            title: Text(
              user.email ?? 'Anonymous@van-Event.fr',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomShapeBorder extends ContinuousRectangleBorder {
  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    const double innerCircleRadius = 150.0;

    final Path path = Path();
    path.lineTo(0, rect.height);
    path.quadraticBezierTo(rect.width / 2 - (innerCircleRadius / 2) - 30,
        rect.height + 15, rect.width / 2 - 75, rect.height + 50);
    path.cubicTo(
        rect.width / 2 - 40,
        rect.height + innerCircleRadius - 40,
        rect.width / 2 + 40,
        rect.height + innerCircleRadius - 40,
        rect.width / 2 + 75,
        rect.height + 50);
    path.quadraticBezierTo(rect.width / 2 + (innerCircleRadius / 2) + 30,
        rect.height + 15, rect.width, rect.height);
    path.lineTo(rect.width, 0.0);
    path.close();

    return path;
  }
}
