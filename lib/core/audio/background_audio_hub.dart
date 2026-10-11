import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../constants/app_constants.dart';

/// Lecteur audio unique pour lecture en arrière-plan + écran de verrouillage.
///
/// [just_audio_background] n'autorise qu'une seule instance d'[AudioPlayer].
class BackgroundAudioHub {
  BackgroundAudioHub._();

  static final BackgroundAudioHub instance = BackgroundAudioHub._();

  final AudioPlayer player = AudioPlayer();
  bool _sessionReady = false;
  final List<Future<void> Function()> _beforePlayListeners = [];

  /// Permet aux providers UI de libérer leur état avant une nouvelle source.
  void addBeforePlayListener(Future<void> Function() listener) {
    _beforePlayListeners.add(listener);
  }

  void removeBeforePlayListener(Future<void> Function() listener) {
    _beforePlayListeners.remove(listener);
  }

  Future<void> ensureSession() async {
    if (_sessionReady) {
      final session = await AudioSession.instance;
      await session.setActive(true);
      return;
    }
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ),
    );
    await session.setActive(true);
    _sessionReady = true;
  }

  Future<void> _notifyBeforePlay() async {
    for (final listener in List<Future<void> Function()>.of(
      _beforePlayListeners,
    )) {
      try {
        await listener();
      } catch (_) {}
    }
  }

  Future<void> playUri({
    required String id,
    required String url,
    required String title,
    String? artist,
    String? artUrl,
    Duration? initialPosition,
    bool notifyOthers = true,
  }) async {
    if (notifyOthers) await _notifyBeforePlay();
    await ensureSession();
    await player.setAudioSource(
      AudioSource.uri(
        Uri.parse(url),
        tag: _mediaItem(
          id: id,
          title: title,
          artist: artist,
          artUrl: artUrl,
        ),
      ),
      initialPosition: initialPosition,
    );
    await player.play();
  }

  Future<void> playFile({
    required String id,
    required String path,
    required String title,
    String? artist,
    String? artUrl,
    double speed = 1.0,
    bool notifyOthers = true,
  }) async {
    if (notifyOthers) await _notifyBeforePlay();
    await ensureSession();
    await player.setAudioSource(
      AudioSource.file(
        path,
        tag: _mediaItem(
          id: id,
          title: title,
          artist: artist,
          artUrl: artUrl,
        ),
      ),
    );
    await player.setSpeed(speed);
    await player.play();
  }

  Future<void> pause() => player.pause();

  Future<void> resume() => player.play();

  Future<void> stop() => player.stop();

  Future<void> seek(Duration position) => player.seek(position);

  Future<void> setSpeed(double speed) => player.setSpeed(speed);

  MediaItem _mediaItem({
    required String id,
    required String title,
    String? artist,
    String? artUrl,
  }) {
    return MediaItem(
      id: id,
      title: title.isEmpty ? AppConstants.appName : title,
      artist: (artist == null || artist.isEmpty)
          ? AppConstants.appShortName
          : artist,
      album: AppConstants.appName,
      artUri: _artUri(artUrl),
    );
  }

  Uri? _artUri(String? artUrl) {
    final trimmed = artUrl?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return Uri.tryParse(trimmed);
    }
    return _defaultNotificationArtUri();
  }

  Uri? _defaultNotificationArtUri() {
    if (kIsWeb) return null;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return Uri.parse(
          'android.resource://${AppConstants.androidApplicationId}/mipmap/launcher_icon',
        );
      case TargetPlatform.iOS:
        return Uri.tryParse(AppConstants.logoUrl);
      default:
        return null;
    }
  }
}
