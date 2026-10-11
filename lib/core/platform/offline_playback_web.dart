import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

void ensureOfflineVideoBackend() {}

Future<bool> offlineFileExists(String path) async => false;

Future<void> setOfflineAudioSource(AudioPlayer player, String path) async {}

Future<VideoPlayerController?> createOfflineVideoController(String path) async =>
    null;
