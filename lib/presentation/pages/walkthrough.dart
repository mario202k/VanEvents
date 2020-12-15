import 'package:auto_route/auto_route.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';


class Walkthrough extends StatefulWidget {
  @override
  _WalkthroughState createState() => _WalkthroughState();
}

class _WalkthroughState extends State<Walkthrough> {
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('seen', true);
    });
    super.initState();
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onBackground,
        borderRadius: BorderRadius.all(Radius.circular(12)),
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
                          onPressed: () {
                            ExtendedNavigator.of(context)
                                .replace(Routes.mySplashScreen);
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
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Wrap(
                                children: <Widget>[
                                  Center(
                                      child: AspectRatio(
                                          aspectRatio: 1,
                                          child: FlareActor(
                                            'assets/animations/easypurchase.flr',
                                            alignment: Alignment.center,
                                            animation: 'start',
                                          ))),
                                  SizedBox(height: 30.0),
                                  Text(
                                    'Achetez vos billets simplement.',
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),

                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Wrap(
                                children: <Widget>[
                                  Center(
                                      child: AspectRatio(
                                          aspectRatio: 1,
                                          child: FlareActor(
                                            'assets/animations/easyscan.flr',
                                            alignment: Alignment.center,
                                            animation: 'start',
                                          ))),
                                  SizedBox(height: 30.0),
                                  Text(
                                    'Ne faîtes plus la queue!',
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),

                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Wrap(
                                children: <Widget>[
                                  Center(
                                      child: AspectRatio(
                                          aspectRatio: 1,
                                          child: FlareActor(
                                            'assets/animations/easychat.flr',
                                            alignment: Alignment.center,
                                            animation: 'start',
                                          ))),
                                  SizedBox(height: 30.0),
                                  Text(
                                    'Restez en contact avec\nvos rencontres',
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .button
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground),
                                    ),
                                    SizedBox(width: 10.0),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      size: 30.0,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Text(''),
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
                  onTap: () {
                    ExtendedNavigator.of(context)
                        .replace(Routes.mySplashScreen);
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
            : Text(''),
      ),
    );
  }
}
