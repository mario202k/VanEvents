import 'dart:async';

import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/domain/models/call.dart';
import 'package:van_events_project/domain/repositories/my_chat_repository.dart';
import 'package:van_events_project/providers/call_change_notifier.dart';

/// MultiChannel Example
class CallScreen extends StatefulWidget {
  final String imageUrl;
  final String chatId;
  final String nom;
  final String callId;
  final bool isCaller;
  final bool isVideoCall;

  const CallScreen(
      {this.imageUrl,
      this.chatId,
      this.nom,
      this.isVideoCall,
      this.isCaller,
      this.callId});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  CallChangeNotifier callRead;
  MyChatRepository chatRead;
  Call _call;
  bool hasStopAndPop, noTapVideo;

  @override
  void initState() {
    super.initState();

    noTapVideo = true;
    hasStopAndPop = false;
    callRead = context.read(callChangeNotifierProvider);
    chatRead = context.read(myChatRepositoryProvider);
    callRead.initial(context, widget.isVideoCall, widget.isCaller,
        widget.callId, widget.chatId);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (!widget.isCaller) {
      Timer(const Duration(seconds: 55), () {
        if (_call != null && _call.callStatus == CallStatus.callReceived) {
          context
              .read(myChatRepositoryProvider)
              .setCallNotRespond(callId: widget.callId, chatId: widget.chatId);
        }
      });
    } else {
      Timer(const Duration(seconds: 15), () {
        // the caller

        if (_call != null && _call.callStatus == CallStatus.callSent) {
          context.read(myChatRepositoryProvider).setCallNotReachable(
              callId: widget.callId, chatId: widget.chatId);
        }
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    callRead.destroy();
    if (_call != null &&
        _call.callStatus == CallStatus.hangUp &&
        (callRead.seconds > 0 || callRead.minutes > 0)) {
      chatRead.setCallDuration(
          callId: widget.callId,
          chatId: widget.chatId,
          h: callRead.hours,
          m: callRead.minutes,
          s: callRead.seconds);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildPhoneVideoCallPortrait(context);
  }

  Consumer buildPhoneVideoCallPortrait(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final isDisplayVideo = watch(callChangeNotifierProvider).isDisableVideo;

      return InkWell(
        onTap: (){
          if(!isDisplayVideo){
            return;
          }
          context.read(callChangeNotifierProvider).setCurrentOpacity();
        },
        child: Stack(
          alignment: Alignment.center,
          overflow: Overflow.visible,
          children: [
            if (isDisplayVideo) _renderVideo(context) else const SizedBox(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                shadowColor: Colors.transparent,
                backgroundColor: isDisplayVideo
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.primary,
              ),
              body: AnimatedOpacity(
                opacity: watch(callChangeNotifierProvider).currentOpacity,
                duration: const Duration(seconds: 1),
                child: Column(
                  children: [
                    if (isDisplayVideo) circularAvatar(),
                    Container(
                      width: double.maxFinite,
                      color: isDisplayVideo
                          ? Colors.transparent
                          : Theme.of(context).colorScheme.primary,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              widget.nom,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(fontSize: 35),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          StreamBuilder<Call>(
                              stream: context
                                  .read(myChatRepositoryProvider)
                                  .callStream(widget.chatId, widget.callId),
                              initialData: Call(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  debugPrint(snapshot.error.toString());
                                  return Center(
                                    child: Text(
                                      'Erreur de connexion',
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  );
                                } else if (!snapshot.hasData) {
                                  return Center(
                                    child: Text(
                                      'Pas de data',
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  );
                                }

                                _call = snapshot.data;

                                return displayCallStatus(context);
                              }),
                        ],
                      ),
                    ),
                    if (!isDisplayVideo)
                      Expanded(
                          child: widget.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: widget.imageUrl,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: double.maxFinite,
                                    decoration: BoxDecoration(
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
                                    child: Container(
                                      width: double.maxFinite,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) {
                                    return Center(
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor:
                                            Theme.of(context).colorScheme.primary,
                                        backgroundImage: const AssetImage(
                                            'assets/img/normal_user_icon.png'),
                                      ),
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/img/normal_user_icon.png',
                                  fit: BoxFit.cover,
                                ))
                    else
                      const SizedBox(),
                  ],
                ),
              ),
              bottomNavigationBar: AnimatedOpacity(
                opacity: watch(callChangeNotifierProvider).currentOpacity,
                duration: const Duration(seconds: 1),
                child: Container(
                  height: 80,
                  color: isDisplayVideo
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.primary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (isDisplayVideo)
                        FlatButton(
                          onPressed: () {
                            if (callRead.currentOpacity == 0) {
                              return;
                            }
                            context
                                .read(callChangeNotifierProvider)
                                .switchCameraM();
                          },
                          child: const FaIcon(FontAwesomeIcons.exchangeAlt,
                              color: Color(0xFFFFFFFF)),
                        )
                      else
                        FlatButton(
                          onPressed: () {
                            if (callRead.currentOpacity == 0) {
                              return;
                            }
                            context
                                .read(callChangeNotifierProvider)
                                .switchSpeakerphone();
                          },
                          child: Consumer(builder: (context, watch, child) {
                            return FaIcon(
                                watch(callChangeNotifierProvider)
                                        .enableSpeakerphone
                                    ? FontAwesomeIcons.volumeUp
                                    : FontAwesomeIcons.volumeDown,
                                color: const Color(0xFFFFFFFF));
                          }),
                        ),
                      FlatButton(
                        onPressed: () {
                          if (callRead.currentOpacity == 0) {
                            return;
                          }
                          context.read(callChangeNotifierProvider).disableVideo();
                        },
                        child: Consumer(builder: (context, watch, child) {
                          return watch(callChangeNotifierProvider).isDisableVideo
                              ? const FaIcon(
                                  FontAwesomeIcons.videoSlash,
                                  color: Color(0xFFFFFFFF),
                                )
                              : const FaIcon(
                                  FontAwesomeIcons.video,
                                  color: Color(0xFFFFFFFF),
                                );
                        }),
                      ),
                      FlatButton(
                        onPressed: () {
                          if (callRead.currentOpacity == 0) {
                            return;
                          }
                          context
                              .read(callChangeNotifierProvider)
                              .switchMicrophone();
                        },
                        child: Consumer(builder: (context, watch, child) {
                          return watch(callChangeNotifierProvider).openMicrophone
                              ? const FaIcon(FontAwesomeIcons.microphoneSlash,
                                  color: Color(0xFFFFFFFF))
                              : const FaIcon(FontAwesomeIcons.microphone,
                                  color: Color(0xFFFFFFFF));
                        }),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 130,
              child: AnimatedOpacity(
                opacity: watch(callChangeNotifierProvider).currentOpacity,
                duration: const Duration(seconds: 1),
                child: widget.isCaller
                    ? RaisedButton(
                        color: Colors.red,
                        shape: const StadiumBorder(),
                        onPressed: () async {
                          if (callRead.currentOpacity == 0) {
                            return;
                          }
                          context.read(callChangeNotifierProvider).stopAllSound();
                          await context
                              .read(myChatRepositoryProvider)
                              .setCallHangUp(
                                  callId: widget.callId, chatId: widget.chatId);
                          ExtendedNavigator.of(context).pop();
                        },
                        child: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        children: <Widget>[
                          RaisedButton(
                            color: Colors.red,
                            shape: const StadiumBorder(),
                            onPressed: () async {
                              if (callRead.currentOpacity == 0) {
                                return;
                              }
                              context
                                  .read(callChangeNotifierProvider)
                                  .stopAllSound();

                              if (_call != null &&
                                  _call.callStatus == CallStatus.pickUp) {
                                await context
                                    .read(myChatRepositoryProvider)
                                    .setCallHangUp(
                                        callId: widget.callId,
                                        chatId: widget.chatId);
                              } else if (_call != null &&
                                  _call.callStatus == CallStatus.callReceived) {
                                await context
                                    .read(myChatRepositoryProvider)
                                    .setCallRefused(
                                        callId: widget.callId,
                                        chatId: widget.chatId);
                              }

                              ExtendedNavigator.of(context).pop();
                            },
                            child: const Icon(
                              Icons.call_end,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 120,
                          ),
                          if (!watch(callChangeNotifierProvider).isJoined)
                            RaisedButton(
                              color: Colors.green,
                              shape: const StadiumBorder(),
                              onPressed: () async {
                                if (callRead.currentOpacity == 0) {
                                  return;
                                }
                                context
                                    .read(callChangeNotifierProvider)
                                    .stopAllSound();

                                await context
                                    .read(callChangeNotifierProvider)
                                    .joinChannel(context);

                                await context
                                    .read(myChatRepositoryProvider)
                                    .setCallPickUp(
                                        callId: widget.callId,
                                        chatId: widget.chatId);
                              },
                              child: const Icon(
                                Icons.call,
                                color: Colors.white,
                              ),
                            )
                          else
                            const SizedBox(),
                        ],
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Padding displayCallStatus(BuildContext context) {
    if (_call != null) {
      switch (_call.callStatus) {
        case CallStatus.callSent:
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Appel en cours',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          );
          break;
        case CallStatus.callReceived:
          if (!context.read(callChangeNotifierProvider).playEffect) {
            if (widget.isCaller) {
              context.read(callChangeNotifierProvider).playEffectTonalite();
            } else {
              context.read(callChangeNotifierProvider).playEffectSonnerie();
            }
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Appel en cours',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          );
          break;
        case CallStatus.notRespond:
          stopAndPop(context);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Pas de réponse',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          );
          break;
        case CallStatus.pickUp:
          context.read(callChangeNotifierProvider).stopAllSound();
          context.read(callChangeNotifierProvider).startTimer();
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer(builder: (context, watch, child) {
              String sec = watch(callChangeNotifierProvider).seconds.toString();
              final min = watch(callChangeNotifierProvider).minutes;
              final hou = watch(callChangeNotifierProvider).hours;
              if (sec.length == 1) {
                sec = '0$sec';
              }

              final countUp = hou != 0 ? "$hou:$min:$sec" : "$min:$sec";
              return Text(
                countUp,
                style: Theme.of(context).textTheme.bodyText2,
              );
            }),
          );
          break;
        case CallStatus.hangUp:
          stopAndPop(context);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Fin de la conversation',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          );
          break;
        case CallStatus.refused:
          stopAndPop(context);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Appel refusé',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          );
          break;
        case CallStatus.unreachable:
          stopAndPop(context);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Injoignable',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          );
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Appel en cours',
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );
  }

  void stopAndPop(BuildContext context) {
    context.read(callChangeNotifierProvider).stopAllSound();
    if (!hasStopAndPop) {
      hasStopAndPop = true;
      Timer(const Duration(seconds: 2), () {
        if (callRead.engine != null) {
          ExtendedNavigator.of(context).pop();
        }
      });
    }
  }

  Widget _renderVideo(BuildContext context) {
    return Stack(
      children: [
        Consumer(builder: (context, watch, child) {
          final remoteUid = watch(callChangeNotifierProvider).remoteUid;

          return remoteUid.isNotEmpty
              ? rtc_remote_view.SurfaceView(
                  uid: remoteUid.first,
                )
              : const SizedBox();
        }),
        Positioned(
            bottom: 120,
            right: 6,
            child: SizedBox(
                width: 120, height: 120, child: rtc_local_view.SurfaceView())),
      ],
    );
  }

  Widget circularAvatar() {
    if (widget.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: widget.imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(100)),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: Theme.of(context).colorScheme.primary,
          child: Container(
            width: double.maxFinite,
          ),
        ),
        errorWidget: (context, url, error) {
          return Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage:
                  const AssetImage('assets/img/normal_user_icon.png'),
            ),
          );
        },
      );
    } else {
      return Center(
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage: const AssetImage('assets/img/normal_user_icon.png'),
        ),
      );
    }
  }
}
