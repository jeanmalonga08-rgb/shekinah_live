import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import '../../core/audio/background_audio_hub.dart';
import '../../core/platform/offline_playback_platform.dart';
import '../../domain/entities/offline_media.dart';
import 'background_video_players_provider.dart';
import 'live_playback_provider.dart';

enum OfflineRepeatMode { off, all, one }

enum OfflinePlaybackFailure {
  none,
  missingFile,
  playbackError,
}

class OfflinePlaybackState {
  const OfflinePlaybackState({
    this.playlist = const [],
    this.index = 0,
    this.isActive = false,
    this.showMiniPlayer = false,
    this.isFullPlayerOpen = false,
    this.isLoading = false,
    this.failed = false,
    this.failure = OfflinePlaybackFailure.none,
    this.isPlaying = false,
    this.speed = 1.0,
    this.repeatMode = OfflineRepeatMode.off,
    this.shuffle = false,
    this.tick = 0,
  });

  final List<OfflineMediaItem> playlist;
  final int index;
  final bool isActive;
  final bool showMiniPlayer;
  final bool isFullPlayerOpen;
  final bool isLoading;
  final bool failed;
  final OfflinePlaybackFailure failure;
  final bool isPlaying;
  final double speed;
  final OfflineRepeatMode repeatMode;
  final bool shuffle;

  /// Incrémenté pour rafraîchir la position vidéo dans l'UI.
  final int tick;

  OfflineMediaItem? get currentItem {
    if (playlist.isEmpty || index < 0 || index >= playlist.length) return null;
    return playlist[index];
  }

  bool get hasPrevious => index > 0;
  bool get hasNext => index < playlist.length - 1;
  bool get hasPlaylist => playlist.length > 1;

  OfflinePlaybackState copyWith({
    List<OfflineMediaItem>? playlist,
    int? index,
    bool? isActive,
    bool? showMiniPlayer,
    bool? isFullPlayerOpen,
    bool? isLoading,
    bool? failed,
    OfflinePlaybackFailure? failure,
    bool? isPlaying,
    double? speed,
    OfflineRepeatMode? repeatMode,
    bool? shuffle,
    int? tick,
    bool clearPlaylist = false,
  }) {
    return OfflinePlaybackState(
      playlist: clearPlaylist ? const [] : (playlist ?? this.playlist),
      index: index ?? this.index,
      isActive: isActive ?? this.isActive,
      showMiniPlayer: showMiniPlayer ?? this.showMiniPlayer,
      isFullPlayerOpen: isFullPlayerOpen ?? this.isFullPlayerOpen,
      isLoading: isLoading ?? this.isLoading,
      failed: failed ?? this.failed,
      failure: failure ?? this.failure,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffle: shuffle ?? this.shuffle,
      tick: tick ?? this.tick,
    );
  }
}

final offlinePlaybackProvider =
    NotifierProvider<OfflinePlaybackNotifier, OfflinePlaybackState>(
  OfflinePlaybackNotifier.new,
);

class OfflinePlaybackNotifier extends Notifier<OfflinePlaybackState> {
  AudioPlayer? _audioPlayer;
  VideoPlayerController? _videoController;
  StreamSubscription<PlayerState>? _audioStateSub;
  bool _advancing = false;
  int _loadToken = 0;
  final _random = Random();
  bool _ownsSharedAudio = false;
  bool _startingOwnAudio = false;
  Future<void>? _activeLoad;

  AudioPlayer get sharedAudioPlayer => BackgroundAudioHub.instance.player;

  AudioPlayer? get audioPlayer => _audioPlayer ?? (_ownsSharedAudio ? sharedAudioPlayer : null);
  VideoPlayerController? get videoController => _videoController;

  bool get _isSharedAudioActive {
    if (!state.isActive || state.currentItem?.format != OfflineMediaFormat.audio) {
      return false;
    }
    final player = sharedAudioPlayer;
    return player.playing ||
        player.processingState != ProcessingState.idle;
  }

  @override
  OfflinePlaybackState build() {
    ref.onDispose(() {
      BackgroundAudioHub.instance
          .removeBeforePlayListener(_onOtherAudioStarting);
      unawaited(_disposePlayers(stopSharedAudio: _ownsSharedAudio));
      ref.read(backgroundVideoPlayersAllowedProvider.notifier).setAllowed(true);
    });
    BackgroundAudioHub.instance.addBeforePlayListener(_onOtherAudioStarting);
    return const OfflinePlaybackState();
  }

  Future<void> _onOtherAudioStarting() async {
    if (_startingOwnAudio || !_ownsSharedAudio) return;
    _ownsSharedAudio = false;
    _audioStateSub?.cancel();
    _audioStateSub = null;
    _audioPlayer = null;
    if (state.isActive) {
      state = const OfflinePlaybackState();
    }
  }

  Future<void> _disposePlayers({bool stopSharedAudio = false}) async {
    _audioStateSub?.cancel();
    _audioStateSub = null;
    _audioPlayer = null;
    if (stopSharedAudio) {
      _ownsSharedAudio = false;
      await BackgroundAudioHub.instance.stop();
    }
    final video = _videoController;
    _videoController = null;
    if (video != null) {
      video.removeListener(_onVideoTick);
      await video.dispose();
    }
  }

  void _onVideoTick() {
    final controller = _videoController;
    if (controller == null) return;
    state = state.copyWith(tick: state.tick + 1);
    final value = controller.value;
    if (!_advancing &&
        value.isInitialized &&
        !value.isPlaying &&
        value.duration > Duration.zero &&
        value.position >= value.duration - const Duration(milliseconds: 400)) {
      unawaited(_maybeAdvance());
    }
  }

  Future<void> playQueue(
    List<OfflineMediaItem> playlist, {
    required int initialIndex,
    bool openFullPlayer = true,
  }) async {
    if (playlist.isEmpty) return;

    await ref.read(livePlaybackProvider.notifier).stopPlayback();
    // Free MediaCodec slots held by home carousel (IndexedStack keeps it alive).
    ref.read(backgroundVideoPlayersAllowedProvider.notifier).setAllowed(false);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final index = initialIndex.clamp(0, playlist.length - 1);
    state = state.copyWith(
      playlist: List<OfflineMediaItem>.from(playlist),
      index: index,
      isActive: true,
      showMiniPlayer: !openFullPlayer,
      isFullPlayerOpen: openFullPlayer,
      failed: false,
      failure: OfflinePlaybackFailure.none,
      isLoading: true,
    );
    await _loadCurrent();
  }

  Future<void> waitForActiveLoad() async {
    final load = _activeLoad;
    if (load != null) await load;
    reconcileLoadingState();
  }

  /// Corrige un `isLoading` bloqué alors que la lecture a déjà démarré.
  void reconcileLoadingState() {
    if (!state.isActive || state.failed) return;
    if (!state.isLoading) return;

    final item = state.currentItem;
    if (item?.format == OfflineMediaFormat.audio && _isSharedAudioActive) {
      _audioPlayer = sharedAudioPlayer;
      _ownsSharedAudio = true;
      state = state.copyWith(
        isLoading: false,
        isPlaying: sharedAudioPlayer.playing,
      );
      return;
    }

    final videoReady = _videoController?.value.isInitialized ?? false;
    final videoPlaying = _videoController?.value.isPlaying ?? false;
    if (videoReady || videoPlaying) {
      state = state.copyWith(
        isLoading: false,
        isPlaying: videoPlaying,
      );
    }
  }

  void _bindSharedAudioListener(AudioPlayer player) {
    _audioStateSub?.cancel();
    _audioStateSub = player.playerStateStream.listen((playerState) {
      if (state.isLoading &&
          playerState.processingState != ProcessingState.idle) {
        state = state.copyWith(
          isLoading: false,
          isPlaying: playerState.playing,
        );
      } else if (state.isPlaying != playerState.playing) {
        state = state.copyWith(isPlaying: playerState.playing);
      }
      if (playerState.processingState == ProcessingState.completed) {
        unawaited(_maybeAdvance());
      }
    });
  }

  Future<void> _loadCurrent() async {
    final load = _loadCurrentImpl();
    _activeLoad = load;
    try {
      await load;
    } finally {
      if (identical(_activeLoad, load)) {
        _activeLoad = null;
      }
      reconcileLoadingState();
    }
  }

  Future<void> _loadCurrentImpl() async {
    final token = ++_loadToken;
    final current = state.currentItem;
    if (current == null) {
      state = state.copyWith(
        isLoading: false,
        failed: true,
        failure: OfflinePlaybackFailure.missingFile,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      failed: false,
      failure: OfflinePlaybackFailure.none,
    );
    final wasOwningAudio = _ownsSharedAudio;
    // Await dispose so MediaCodec instances are released before the next
    // init (MediaTek devices often fail with "start failed" otherwise).
    await _disposePlayers(stopSharedAudio: false);

    if (!await offlineFileExists(current.localPath)) {
      if (token == _loadToken) {
        state = state.copyWith(
          isLoading: false,
          failed: true,
          failure: OfflinePlaybackFailure.missingFile,
        );
      }
      return;
    }

    try {
      if (current.format == OfflineMediaFormat.audio) {
        final hub = BackgroundAudioHub.instance;
        final player = hub.player;
        if (token != _loadToken) return;
        _audioPlayer = player;
        _ownsSharedAudio = true;
        _bindSharedAudioListener(player);
        _startingOwnAudio = true;
        try {
          await hub.playFile(
            id: current.id,
            path: current.localPath,
            title: current.title,
            artist: current.subtitle,
            artUrl: current.thumbnailUrl,
            speed: state.speed,
            notifyOthers: !wasOwningAudio,
          );
        } finally {
          _startingOwnAudio = false;
        }
        if (token != _loadToken) return;
        state = state.copyWith(
          isLoading: false,
          isPlaying: player.playing,
        );
        reconcileLoadingState();
      } else {
        _ownsSharedAudio = false;
        final controller =
            await createOfflineVideoController(current.localPath);
        if (controller == null) {
          if (token == _loadToken) {
            state = state.copyWith(
              isLoading: false,
              failed: true,
              failure: OfflinePlaybackFailure.playbackError,
            );
          }
          return;
        }
        if (token != _loadToken) {
          await controller.dispose();
          return;
        }
        _videoController = controller;
        controller.addListener(_onVideoTick);
        state = state.copyWith(isLoading: false, isPlaying: true);
        await controller.play();
      }
    } catch (e, st) {
      debugPrint('Offline playback error: $e\n$st');
      if (token == _loadToken) {
        state = state.copyWith(
          isLoading: false,
          failed: true,
          failure: OfflinePlaybackFailure.playbackError,
        );
      }
    }
  }

  Future<void> _maybeAdvance() async {
    if (_advancing) return;
    _advancing = true;
    try {
      if (state.repeatMode == OfflineRepeatMode.one) {
        await seek(Duration.zero);
        await play();
        return;
      }
      if (state.hasNext || state.repeatMode == OfflineRepeatMode.all) {
        await next();
        return;
      }
      state = state.copyWith(isPlaying: false);
    } finally {
      _advancing = false;
    }
  }

  int _resolveNextIndex() {
    if (state.shuffle && state.playlist.length > 1) {
      var next = state.index;
      while (next == state.index) {
        next = _random.nextInt(state.playlist.length);
      }
      return next;
    }
    if (state.hasNext) return state.index + 1;
    if (state.repeatMode == OfflineRepeatMode.all) return 0;
    return state.index;
  }

  int _resolvePreviousIndex() {
    if (state.shuffle && state.playlist.length > 1) {
      var prev = state.index;
      while (prev == state.index) {
        prev = _random.nextInt(state.playlist.length);
      }
      return prev;
    }
    if (state.hasPrevious) return state.index - 1;
    if (state.repeatMode == OfflineRepeatMode.all) {
      return state.playlist.length - 1;
    }
    return state.index;
  }

  Future<void> goToIndex(int index) async {
    if (state.playlist.isEmpty) return;
    final target = index.clamp(0, state.playlist.length - 1);
    if (target == state.index && state.isActive && !state.failed) {
      if (state.isLoading) {
        await waitForActiveLoad();
      }
      return;
    }
    state = state.copyWith(index: target);
    await _loadCurrent();
  }

  Future<void> next() async {
    if (state.playlist.isEmpty) return;
    if (!state.hasNext && state.repeatMode != OfflineRepeatMode.all) return;
    state = state.copyWith(index: _resolveNextIndex());
    await _loadCurrent();
  }

  Future<void> previous() async {
    if (state.playlist.isEmpty) return;

    final position = await _currentPosition();
    if (position > const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }

    if (!state.hasPrevious && state.repeatMode != OfflineRepeatMode.all) {
      await seek(Duration.zero);
      return;
    }
    state = state.copyWith(index: _resolvePreviousIndex());
    await _loadCurrent();
  }

  Future<Duration> _currentPosition() async {
    if (_audioPlayer != null) {
      return _audioPlayer!.position;
    }
    final video = _videoController;
    if (video != null && video.value.isInitialized) {
      return video.value.position;
    }
    return Duration.zero;
  }

  Future<void> togglePlay() async {
    if (_audioPlayer != null) {
      if (_audioPlayer!.playing) {
        await BackgroundAudioHub.instance.pause();
        state = state.copyWith(isPlaying: false);
      } else {
        await BackgroundAudioHub.instance.resume();
        state = state.copyWith(isPlaying: true);
      }
      return;
    }
    final video = _videoController;
    if (video != null) {
      if (video.value.isPlaying) {
        await video.pause();
        state = state.copyWith(isPlaying: false);
      } else {
        await video.play();
        state = state.copyWith(isPlaying: true);
      }
    }
  }

  Future<void> play() async {
    if (_audioPlayer != null) {
      await BackgroundAudioHub.instance.resume();
    } else {
      await _videoController?.play();
    }
    state = state.copyWith(isPlaying: true);
  }

  Future<void> pause() async {
    if (_audioPlayer != null) {
      await BackgroundAudioHub.instance.pause();
    } else {
      await _videoController?.pause();
    }
    state = state.copyWith(isPlaying: false);
  }

  Future<void> seek(Duration position) async {
    if (_audioPlayer != null) {
      await BackgroundAudioHub.instance.seek(position);
      return;
    }
    await _videoController?.seekTo(position);
    state = state.copyWith(tick: state.tick + 1);
  }

  Future<void> skipForward([
    Duration offset = const Duration(seconds: 15),
  ]) async {
    final position = await _currentPosition();
    final duration = await _currentDuration();
    var target = position + offset;
    if (duration > Duration.zero && target > duration) {
      target = duration;
    }
    await seek(target);
  }

  Future<void> skipBackward([
    Duration offset = const Duration(seconds: 15),
  ]) async {
    final position = await _currentPosition();
    var target = position - offset;
    if (target.isNegative) target = Duration.zero;
    await seek(target);
  }

  Future<Duration> _currentDuration() async {
    if (_audioPlayer != null) {
      return _audioPlayer!.duration ?? Duration.zero;
    }
    final video = _videoController;
    if (video != null && video.value.isInitialized) {
      return video.value.duration;
    }
    return Duration.zero;
  }

  Future<void> cycleSpeed() async {
    const speeds = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    final currentIndex = speeds.indexOf(state.speed);
    final nextSpeed = speeds[(currentIndex + 1) % speeds.length];
    state = state.copyWith(speed: nextSpeed);
    if (_audioPlayer != null) {
      await BackgroundAudioHub.instance.setSpeed(nextSpeed);
    } else {
      await _videoController?.setPlaybackSpeed(nextSpeed);
    }
  }

  void cycleRepeatMode() {
    final next = switch (state.repeatMode) {
      OfflineRepeatMode.off => OfflineRepeatMode.all,
      OfflineRepeatMode.all => OfflineRepeatMode.one,
      OfflineRepeatMode.one => OfflineRepeatMode.off,
    };
    state = state.copyWith(repeatMode: next);
  }

  void toggleShuffle() {
    state = state.copyWith(shuffle: !state.shuffle);
  }

  void openFullPlayer() {
    reconcileLoadingState();
    state = state.copyWith(isFullPlayerOpen: true, showMiniPlayer: false);
  }

  void collapseToMiniPlayer() {
    if (!state.isActive) return;
    state = state.copyWith(isFullPlayerOpen: false, showMiniPlayer: true);
  }

  Future<void> stop() async {
    _loadToken++;
    await _disposePlayers(stopSharedAudio: true);
    ref.read(backgroundVideoPlayersAllowedProvider.notifier).setAllowed(true);
    state = const OfflinePlaybackState();
  }
}
