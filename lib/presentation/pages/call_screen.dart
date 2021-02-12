import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/providers/call_change_notifier.dart';

/// MultiChannel Example
class CallScreen extends StatefulWidget {
  final String imageUrl;
  final String nom;

  const CallScreen({this.imageUrl, this.nom});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {

  @override
  void initState() {
    final callRead = context.read(callChangeNotifierProvider);
    callRead.initial(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final callRead = context.read(callChangeNotifierProvider);
    return Stack(
      children: [
        _renderVideo(callRead),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            children: [
              if (widget.imageUrl != null) CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      imageBuilder: (context, imageProvider) => Container(
                        height: 100,
                        width: 100,
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
                        child: const CircleAvatar(
                          radius: 50,
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            backgroundImage:
                                const AssetImage('assets/img/normal_user_icon.png'),
                          ),
                        );
                      },
                    ) else Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        backgroundImage:
                            const AssetImage('assets/img/normal_user_icon.png'),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.nom,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontSize: 35),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Appel en cours',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: FloatingActionButton(
                  onPressed: () {
                    callRead.playEffectTonalite();
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const FaIcon(FontAwesomeIcons.phoneSlash),
                ),
              ),
              const SizedBox(
                height: 80,
              )
            ],
          ),
          bottomSheet: Container(
            clipBehavior: Clip.hardEdge,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(
                  onPressed: () => callRead.switchCamera,
                  child: const FaIcon(FontAwesomeIcons.camera),
                ),
                RaisedButton(
                  onPressed: () {
                    callRead.disableVideo();
                  },
                  child: Consumer(builder: (context, watch, child) {
                    return watch(callChangeNotifierProvider).isDisableVideo
                        ? const FaIcon(FontAwesomeIcons.videoSlash)
                        : const FaIcon(FontAwesomeIcons.video);
                  }),
                ),
                RaisedButton(
                  onPressed: callRead.switchMicrophone,
                  child: Consumer(builder: (context, watch, child) {
                    return watch(callChangeNotifierProvider).openMicrophone
                        ? const FaIcon(FontAwesomeIcons.videoSlash)
                        : const FaIcon(FontAwesomeIcons.video);
                  }),
                )
              ],
            ),
          ),
        ),
      ],
    );
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
                    alignment: Alignment.bottomRight,
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
}
