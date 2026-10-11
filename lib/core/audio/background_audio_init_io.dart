import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// Initialise le service de lecture audio en arrière-plan (Android / iOS).
Future<void> initBackgroundAudio() async {
  if (!Platform.isAndroid && !Platform.isIOS) return;

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.shekinah.tabernacle.audio',
    androidNotificationChannelName: 'Lecture audio',
    androidNotificationIcon: 'mipmap/launcher_icon',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
    androidStopForegroundOnPause: true,
    fastForwardInterval: const Duration(seconds: 15),
    rewindInterval: const Duration(seconds: 15),
    preloadArtwork: true,
    notificationColor: const Color(0xFFC9A227),
  );
}
