import 'package:auto_route/auto_route.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_cache.dart';
import 'package:flare_flutter/flare_cache_builder.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';

class Walkthrough extends StatefulWidget {
  @override
  _WalkthroughState createState() => _WalkthroughState();
}

class _WalkthroughState extends State<Walkthrough> {
  final int _numPages = 4;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final Map<String, Map<String,String>> nameAnimation = {
    'assets/animations/easypurchase.flr': {
      'start': 'Achetez vos billets simplement.'
    },
    'assets/animations/easyscan.flr': {'start': 'Ne faîtes plus la queue!'},
    'assets/animations/VTC.flr': {
      'door open': 'Réserver votre chauffeur privé.'
    },
    'assets/animations/easychat.flr': {
      'start': 'Restez en contact avec\nles participants'
    }
  };

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  @override
  void initState() {
    cachedActor(
      AssetFlare(
          bundle: rootBundle, name: 'assets/animations/easypurchase.flr'),
    );

    cachedActor(
      AssetFlare(bundle: rootBundle, name: 'assets/animations/easyscan.flr'),
    );
    cachedActor(
      AssetFlare(bundle: rootBundle, name: 'assets/animations/VTC.flr'),
    );
    cachedActor(
      AssetFlare(bundle: rootBundle, name: 'assets/animations/easychat.flr'),
    );

    super.initState();
  }

  @override
  void dispose() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('seen', true);
    });
    super.dispose();
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Widget myFlareAnim({String name, String animation, String comment}) {
    return Padding(
      padding: EdgeInsets.all(40.0),
      child: Wrap(
        children: [
          Center(
            child: LimitedBox(
              maxHeight: MediaQuery.of(context).size.height*0.8,
              child: AspectRatio(
                aspectRatio: 1,
                child: FlareCacheBuilder([AssetFlare(bundle: rootBundle, name: name)],
                    builder: (context, isWarm) {
                  return !isWarm
                      ? Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary)),
                        )
                      : FlareActor(
                          name,
                          alignment: Alignment.center,
                          animation: animation,
                        );
                }),
              ),
            ),
          ),
          Text(
            comment,
            style:
            Theme.of(context).textTheme.bodyText1,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: viewportConstraints.maxWidth,
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerRight,
                        child: FlatButton(
                          onPressed: () async {
                            final rep = await SharedPreferences.getInstance();

                            final seen = rep.getBool('seen');
                            if (seen == null) {
                              ExtendedNavigator.of(context)
                                  .replace(Routes.mySplashScreen);
                            } else {
                              ExtendedNavigator.of(context)
                                  .pop(); //vers paramètre
                            }
                          },
                          child: Text(
                            'Passer',
                            style: Theme.of(context).textTheme.button.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: (MediaQuery.of(context).size.width * 7) / 4.25,
                        child: PageView(
                          physics: ClampingScrollPhysics(),
                          controller: _pageController,
                          onPageChanged: (int page) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                          children: [
                            ...nameAnimation.keys.map((key) {
                            return myFlareAnim(
                              animation: nameAnimation[key].keys.first,
                              name: key,
                              comment: nameAnimation[key].values.first,
                            );
                          }).toList()],
                          // children: <Widget>[
                          //   Padding(
                          //     padding: EdgeInsets.all(40.0),
                          //     child: Wrap(
                          //       children: <Widget>[
                          //         Center(
                          //             child: AspectRatio(
                          //                 aspectRatio: 1,
                          //                 child: FlareActor(
                          //                   'assets/animations/easypurchase.flr',
                          //                   alignment: Alignment.center,
                          //                   animation: 'start',
                          //                 ))),
                          //         SizedBox(height: 30.0),
                          //         Text(
                          //           'Achetez vos billets simplement.',
                          //           style:
                          //               Theme.of(context).textTheme.bodyText1,
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          //   Padding(
                          //     padding: EdgeInsets.all(40.0),
                          //     child: Wrap(
                          //       children: <Widget>[
                          //         Center(
                          //             child: AspectRatio(
                          //                 aspectRatio: 1,
                          //                 child: FlareActor(
                          //                   'assets/animations/easyscan.flr',
                          //                   alignment: Alignment.center,
                          //                   animation: 'start',
                          //                 ))),
                          //         SizedBox(height: 30.0),
                          //         Text(
                          //           'Ne faîtes plus la queue!',
                          //           style:
                          //               Theme.of(context).textTheme.bodyText1,
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          //   Padding(
                          //     padding: EdgeInsets.all(40.0),
                          //     child: Wrap(
                          //       children: <Widget>[
                          //         Center(
                          //             child: AspectRatio(
                          //                 aspectRatio: 1,
                          //                 child: FlareActor(
                          //                   'assets/animations/VTC.flr',
                          //                   alignment: Alignment.center,
                          //                   animation: 'door open',
                          //                 ))),
                          //         SizedBox(height: 30.0),
                          //         Text(
                          //           'Réserver votre chauffeur privé.',
                          //           style:
                          //               Theme.of(context).textTheme.bodyText1,
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          //   Padding(
                          //     padding: EdgeInsets.all(40.0),
                          //     child: Wrap(
                          //       children: <Widget>[
                          //         Center(
                          //             child: AspectRatio(
                          //                 aspectRatio: 1,
                          //                 child: FlareActor(
                          //                   'assets/animations/easychat.flr',
                          //                   alignment: Alignment.center,
                          //                   animation: 'start',
                          //                 ))),
                          //         SizedBox(height: 30.0),
                          //         Text(
                          //           'Restez en contact avec\nles participants',
                          //           style:
                          //               Theme.of(context).textTheme.bodyText1,
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        bottomSheet: _currentPage == _numPages - 1
            ? Container(
                height: 100.0,
                width: double.infinity,
                color: Colors.white,
                child: GestureDetector(
                  onTap: () async {
                    final rep = await SharedPreferences.getInstance();

                    final seen = rep.getBool('seen');
                    if (seen == null) {
                      ExtendedNavigator.of(context)
                          .replace(Routes.mySplashScreen);
                    } else {
                      ExtendedNavigator.of(context).pop(); //vers paramètre
                    }
                  },
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 30.0),
                      child: Text(
                        'Démarrer',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Container(
                clipBehavior: Clip.hardEdge,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicator(),
                    ),
                    _currentPage != _numPages - 1
                        ? Align(
                            alignment: FractionalOffset.bottomRight,
                            child: FlatButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Suivant',
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                  SizedBox(width: 10.0),
                                  Icon(
                                    Icons.arrow_forward,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    size: 30.0,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
      ),
    );
  }
}
