import 'dart:async';
import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:van_events_project/constants/credentials.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/repositories/my_chat_repository.dart';

final callChangeNotifierProvider =
    ChangeNotifierProvider.autoDispose<CallChangeNotifier>((ref) {
  return CallChangeNotifier();
});

class CallChangeNotifier extends ChangeNotifier {
  bool isJoined,
      openMicrophone,
      enableSpeakerphone,
      playEffect,
      isCaller,
      switchCamera,
      speaker,
  hasStarTimer,

      isDisableVideo;
  List<int> remoteUid;
  RtcEngine engine;
  String channel;
  AudioCache audioCache;
  AudioPlayer advancedPlayer;
  int seconds;
  int minutes;
  int hours;
  double currentOpacity;

  void initial(BuildContext context, bool isVideoCall, bool myIsCaller,
      String callId, String chatId) {
    if(Platform.isAndroid){
      context.read(myChatRepositoryProvider).setCallReceived(chatId: chatId,callId: callId);
    }
    audioCache = AudioCache();
    advancedPlayer = AudioPlayer();
    hasStarTimer = false;
    isJoined = false;
    openMicrophone = true;
    currentOpacity = 1;
    if (isVideoCall) {
      enableSpeakerphone = true;
    } else {
      enableSpeakerphone = false;
    }
    isDisableVideo = isVideoCall ?? false;
    playEffect = false;
    switchCamera = true;
    isCaller = myIsCaller;
    remoteUid = [];
    channel = callId;
    seconds = 0;
    minutes = 0;
    hours = 0;
    initEngine(context);
  }

  Future<void> initEngine(BuildContext context) async {
    engine = await RtcEngine.create(agoraKey);
    _addListeners();

    if (isDisableVideo) {
      await engine.enableVideo();
      await engine.startPreview();
    }
    await engine.enableAudio();
    await engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await engine.setClientRole(ClientRole.Broadcaster);

    if (isCaller) {
      await joinChannel(context);
    }
  }

  Future<void> disableVideo() async {
    if (isDisableVideo) {
      await engine.disableVideo();
      isDisableVideo = false;

      notifyListeners();
    } else {
      await engine.enableVideo();
      await engine.startPreview();
      isDisableVideo = true;
      notifyListeners();
    }
  }

  void startTimer() {
    if(!hasStarTimer){
      hasStarTimer = true;
      Timer.periodic(
        const Duration(seconds: 1),
            (timer){
          if(engine == null){
            timer.cancel();
          }
          seconds = seconds + 1;
          if (seconds > 59) {
            minutes += 1;
            seconds = 0;
            if (minutes > 59) {
              hours += 1;
              minutes = 0;
            }
          }
          notifyListeners();
        },
      );
    }

  }

  void _addListeners() {
    engine?.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (channel, uid, elapsed) {
        isJoined = true;


        notifyListeners();
      },
      userJoined: (uid, elapsed) {
        remoteUid.add(uid);

        if(isDisableVideo){
          setCurrentOpacity();
        }else{
          notifyListeners();
        }

      },
      userOffline: (uid, reason) {
        remoteUid.removeWhere((element) => element == uid);
        notifyListeners();
      },
      leaveChannel: (stats) {
        isJoined = false;
        remoteUid.clear();
        notifyListeners();
      },
    ));
  }

  Future<void> joinChannel(BuildContext context) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }

    final response =
        await context.read(myChatRepositoryProvider).getAgoraToken(channel);

    final uid = context.read(myUserProvider).id;

    if (response != null) {
      await engine.joinChannelWithUserAccount(
          response.data as String, channel, uid).catchError((e){
      });
    }
  }

  Future<void> leaveChannel() async {
    await engine?.leaveChannel();
  }

  void switchMicrophone() {
    engine?.enableLocalAudio(!openMicrophone)?.then((value) {
      openMicrophone = !openMicrophone;
      notifyListeners();
    })?.catchError((err) {
      debugPrint('enableLocalAudio $err');
    });
  }

  void switchSpeakerphone() {
    engine?.setEnableSpeakerphone(!enableSpeakerphone)?.then((value) {
      enableSpeakerphone = !enableSpeakerphone;
      notifyListeners();
    })?.catchError((err) {
      debugPrint('setEnableSpeakerphone $err');
    });
  }

  Future<void> playEffectTonalite() async {
    if (playEffect) {
      engine?.stopEffect(1)?.then((value) {
        playEffect = false;
        notifyListeners();
      })?.catchError((err) {
        debugPrint('stopEffect $err');
      });
    } else {
      engine
          ?.playEffect(
              1,
              await RtcEngineExtension.getAssetAbsolutePath(
                  "assets/sound/tonaliteRetourAppel.aac"),
              -1,
              1,
              1,
              100,
              true)
          ?.then((value) {
        playEffect = true;
        notifyListeners();
      })?.catchError((err) {
        debugPrint('playEffect $err');
      });
    }
  }

  Future<void> playEffectSonnerie() async {
    if (playEffect) {
      advancedPlayer.stop();
      playEffect = false;
    } else {
      if (Platform.isIOS) {
        if (audioCache.fixedPlayer != null) {
          audioCache.fixedPlayer.startHeadlessService();
        }
        advancedPlayer.startHeadlessService();
      }

      advancedPlayer =
          await audioCache.loop('sound/sonnerie.aac').catchError((e) {
        debugPrint(e.toString());
      });

      playEffect = true;
    }
  }

  void switchCameraM() {
    engine?.switchCamera()?.then((value) {
      switchCamera = !switchCamera;
      notifyListeners();
    })?.catchError((err) {
      debugPrint('switchCamera $err');
    });
  }

  void switchRender() {
    remoteUid = List.of(remoteUid.reversed);
    notifyListeners();
  }

  void destroy() {
    engine?.destroy();
    engine = null;
  }

  void setEngine(RtcEngine value) {
    engine = value;
    notifyListeners();
  }

  void setRemoteUid(List<int> value) {
    remoteUid = value;
    notifyListeners();
  }

  void setSwitchCamera(bool value) {
    switchCamera = value;
    notifyListeners();
  }

  void setPlayEffect(bool value) {
    playEffect = value;
    notifyListeners();
  }

  void setEnableSpeakerphone(bool value) {
    enableSpeakerphone = value;
    notifyListeners();
  }

  void setOpenMicrophone(bool value) {
    openMicrophone = value;
    notifyListeners();
  }

  void setIsJoined(bool value) {
    isJoined = value;
    notifyListeners();
  }

  void setChannel(String channel) {
    this.channel = channel;
    notifyListeners();
  }

  void setSpeaker() {
    speaker = !speaker;
    notifyListeners();
  }

  void setCurrentOpacity(){
    if (currentOpacity == 0) {
      currentOpacity = 1;
    } else {
      currentOpacity = 0;
    }
    notifyListeners();
  }

  void stopAllSound() {
    if(playEffect){
      if(isCaller){
        playEffectTonalite();
      }else{
        playEffectSonnerie();
      }
    }
  }

}
