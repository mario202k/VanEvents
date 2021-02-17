import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/providers/call_change_notifier.dart';
import 'package:flutter/services.dart';

/// MultiChannel Example
class CallScreen extends StatefulWidget {
  final String imageUrl;
  final String nom;
  final String channel;
  final bool isVideoCall;

  const CallScreen({this.imageUrl, this.nom, this.isVideoCall, this.channel});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  CallChangeNotifier callRead;
  @override
  void initState() {
    super.initState();
    callRead = context.read(callChangeNotifierProvider);
    callRead.initial(context, widget.isVideoCall,widget.channel);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callRead = context.read(callChangeNotifierProvider);

    return buildPhoneVideoCallPortrait(callRead, context);
  }

  Consumer buildPhoneVideoCallPortrait(
      CallChangeNotifier callRead, BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final isDisplayVideo = watch(callChangeNotifierProvider).isDisableVideo;
      return Stack(
        alignment: Alignment.center,
        overflow: Overflow.visible,
        children: [
          if (isDisplayVideo) _renderVideo(callRead) else const SizedBox(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              shadowColor: Colors.transparent,
              backgroundColor: isDisplayVideo? Colors.transparent : Theme.of(context).colorScheme.primary,
            ),
            body: Column(
              children: [
                if(isDisplayVideo) circularAvatar(),
                Container(
                  width: double.maxFinite,
                  color: isDisplayVideo? Colors.transparent : Theme.of(context).colorScheme.primary,
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Appel en cours',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isDisplayVideo) Expanded(
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
                          )) else const SizedBox(),
              ],
            ),
            bottomNavigationBar: Container(
              height: 80,
              color: isDisplayVideo? Colors.transparent : Theme.of(context).colorScheme.primary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (isDisplayVideo) FlatButton(
                    onPressed: () => callRead.switchCamera,
                    child: const FaIcon(FontAwesomeIcons.exchangeAlt,
                        color: Color(0xFFFFFFFF)),
                  ) else FlatButton(
                    onPressed: () => callRead.switchCamera,
                    child: const FaIcon(FontAwesomeIcons.volumeUp,
                        color: Color(0xFFFFFFFF)),
                  ),
                  FlatButton(
                    onPressed: () {
                      callRead.disableVideo();
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
                    onPressed: callRead.switchMicrophone,
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
          Positioned(
            bottom: 130,
            child: FloatingActionButton(
              onPressed: () {
                ExtendedNavigator.of(context).pop();
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const FaIcon(FontAwesomeIcons.phoneSlash),
            ),
          ),
        ],
      );
    });
  }

  Widget _renderVideo(CallChangeNotifier callRead) {
    return Expanded(
      child: Stack(
        children: [
          RtcLocalView.SurfaceView(),
          Consumer(builder: (context, watch, child) {
            final remoteUid = watch(callChangeNotifierProvider).remoteUid;
            return remoteUid != null
                ? Align(
                    alignment: Alignment.topRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.of(remoteUid.map(
                          (e) => GestureDetector(
                            onTap: callRead.switchRender,
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: RtcRemoteView.SurfaceView(
                                uid: e,
                              ),
                            ),
                          ),
                        )),
                      ),
                    ),
                  )
                : const SizedBox();
          })
        ],
      ),
    );
  }

  Widget circularAvatar() {
    if (widget.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: widget.imageUrl,
        imageBuilder: (context, imageProvider) =>
            Container(
              width: 100,
              height: 100,
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
      );
    } else {
      return Center(
        child: CircleAvatar(
          radius: 50,
          backgroundColor:
          Theme.of(context).colorScheme.primary,
          backgroundImage: const AssetImage(
              'assets/img/normal_user_icon.png'),
        ),
      );
    }
  }

}
