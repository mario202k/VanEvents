import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:van_events_project/presentation/widgets/my_drawer.dart';

class CustomDrawer extends StatefulWidget {
  final Widget child;
  final String uid;

  const CustomDrawer(this.uid, {Key key, @required this.child})
      : super(key: key);

  static CustomDrawerState of(BuildContext context) =>
      context.findAncestorStateOfType<CustomDrawerState>();

  @override
  CustomDrawerState createState() => CustomDrawerState();
}

class CustomDrawerState extends State<CustomDrawer>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final double maxSlide = 300.0;
  AnimationController _animationController;
  bool _canBeDragged = false;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleDrawer() => _animationController.isCompleted ? close() : open();

  // void _onDragEnd(DragEndDetails details) {
  //   if (_animationController.isDismissed || _animationController.isCompleted) {
  //     return;
  //   }
  //   if (details.velocity.pixelsPerSecond.dx.abs() >= 365.0) {
  //     double visualVelocity = details.velocity.pixelsPerSecond.dx /
  //         MediaQuery.of(context).size.width;
  //     _animationController.fling(velocity: visualVelocity);
  //   } else if (_animationController.value < 0.5) {
  //     close();
  //   } else {
  //     open();
  //   }
  // }

  void close() => _animationController.reverse();

  void open() => _animationController.forward();

  // void _onDragUpdate(DragUpdateDetails details) {
  //   if (_canBeDragged) {
  //     double delta = details.primaryDelta / maxSlide;
  //     _animationController.value += delta;
  //   }
  // }
  //
  // void _onDragStart(DragStartDetails details) {
  //   bool isDragOpenFromLeft = _animationController.isDismissed;
  //   bool isDragCloseFromRight = _animationController.isCompleted;
  //   _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  // }

  @override
  Widget build(BuildContext context) {
    print('buildCustomDrawer');

    return WillPopScope(
      onWillPop: () async {
        if (_animationController.isCompleted) {
          close();
          return false;
        }
        return true;
      },
      child: GestureDetector(
//        onHorizontalDragStart: _onDragStart,
//        onHorizontalDragUpdate: _onDragUpdate,
//        onHorizontalDragEnd: _onDragEnd,
//        behavior: HitTestBehavior.translucent,
        //onTap: toggleDrawer,
        child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              return Stack(
                children: <Widget>[
                  Transform.translate(
                    offset:
                        Offset(maxSlide * (_animationController.value - 1), 0),
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(
                            math.pi / 2 * (1 - _animationController.value)),
                      alignment: Alignment.centerRight,
                      child: MyDrawer(),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(maxSlide * _animationController.value, 0),
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(
                            -math.pi * 0.9 * (_animationController.value) / 2),
                      alignment: Alignment.centerLeft,
                      child: widget.child,
                    ),
                  ),

                  // Positioned(
                  //   top: 16.0 + MediaQuery.of(context).padding.top,
                  //   left: Platform.isAndroid
                  //       ? 50
                  //       : 0 +
                  //           _animationController.value *
                  //               MediaQuery.of(context).size.width,
                  //   width: MediaQuery.of(context).size.width,
                  //   child: BlocBuilder<NavigationBloc, NavigationStates>(
                  //       builder:
                  //           (BuildContext context, NavigationStates state) {
                  //         //print(state.toString());
                  //     return Text(
                  //       state.toString(),
                  //       style: Theme.of(context).textTheme.headline1,
                  //       textAlign: Platform.isAndroid
                  //           ? TextAlign.start
                  //           : TextAlign.center,
                  //     );
                  //   }),
                  // ),
                  Positioned(
                    top: 8.0 + MediaQuery.of(context).padding.top,
                    left: 4.0 + _animationController.value * maxSlide,
                    child: IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: toggleDrawer,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}


