import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

bool _videoBackendReady = false;

/// Registers a video_player backend where the official plugin is missing
/// (Windows/Linux) or unreliable for offline files (some Android MediaTek
/// devices fail ExoPlayer MediaCodec init with format_supported=YES).
/// Safe to call multiple times.
void ensureOfflineVideoBackend() {
  if (_videoBackendReady) return;
  final os = Platform.operatingSystem;
  if (os == 'windows' || os == 'linux' || os == 'android') {
    // Must be Map<String, dynamic>: fvp checks `options is Map<String, dynamic>`.
    fvp.registerWith(
      options: <String, dynamic>{
        'platforms': <String>['windows', 'linux', 'android'],
        // Prefer software decode on Android so offline playback still works
        // when hardware decoder slots are exhausted (home carousel, etc.).
        if (os == 'android')
          'video.decoders': <String>['FFmpeg', 'AMediaCodec'],
      },
    );
    debugPrint('Offline video backend: fvp registered for $os');
  }
  _videoBackendReady = true;
}

Future<bool> offlineFileExists(String path) => File(path).exists();

Future<void> setOfflineAudioSource(AudioPlayer player, String path) =>
    player.setFilePath(path);

Future<VideoPlayerController?> createOfflineVideoController(String path) async {
  ensureOfflineVideoBackend();
  final controller = VideoPlayerController.file(File(path));
  try {
    await controller.initialize();
    return controller;
  } catch (_) {
    await controller.dispose();
    rethrow;
  }
}
