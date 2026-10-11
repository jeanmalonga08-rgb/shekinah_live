import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/audio/background_audio_hub.dart';
import '../../domain/entities/branham_predication.dart';
import 'live_playback_provider.dart';

class BranhamAudioPlaybackState {
  const BranhamAudioPlaybackState({
    this.sourceId,
    this.title,
    this.subtitle,
    this.audioUrl,
    this.playlist = const [],
    this.index = 0,
    this.isActive = false,
    this.isLoading = false,
    this.isPlaying = false,
  });

  final String? sourceId;
  final String? title;
  final String? subtitle;
  final String? audioUrl;
  final List<BranhamPredication> playlist;
  final int index;
  final bool isActive;
  final bool isLoading;
  final bool isPlaying;

  bool get hasPrevious => index > 0;
  bool get hasNext => index < playlist.length - 1;

  BranhamAudioPlaybackState copyWith({
    String? sourceId,
    String? title,
    String? subtitle,
    String? audioUrl,
    List<BranhamPredication>? playlist,
    int? index,
    bool? isActive,
    bool? isLoading,
    bool? isPlaying,
  }) {
    return BranhamAudioPlaybackState(
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      audioUrl: audioUrl ?? this.audioUrl,
      playlist: playlist ?? this.playlist,
      index: index ?? this.index,
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

final branhamAudioPlaybackProvider =
    NotifierProvider<BranhamAudioPlaybackNotifier, BranhamAudioPlaybackState>(
  BranhamAudioPlaybackNotifier.new,
);

class BranhamAudioPlaybackNotifier extends Notifier<BranhamAudioPlaybackState> {
  StreamSubscription<PlayerState>? _playerStateSubscription;
  bool _startingOwnAudio = false;

  AudioPlayer get _player => BackgroundAudioHub.instance.player;

  @override
  BranhamAudioPlaybackState build() {
    BackgroundAudioHub.instance.addBeforePlayListener(_onOtherAudioStarting);
    _playerStateSubscription = _player.playerStateStream.listen((playerState) {
      if (!state.isActive) return;
      state = state.copyWith(
        isLoading: playerState.processingState == ProcessingState.loading ||
            playerState.processingState == ProcessingState.buffering,
        isPlaying: playerState.playing,
      );
      if (playerState.processingState == ProcessingState.completed) {
        state = const BranhamAudioPlaybackState();
      }
    });
    ref.onDispose(() {
      BackgroundAudioHub.instance
          .removeBeforePlayListener(_onOtherAudioStarting);
      unawaited(_playerStateSubscription?.cancel());
    });
    return const BranhamAudioPlaybackState();
  }

  Future<void> _onOtherAudioStarting() async {
    if (_startingOwnAudio || !state.isActive) return;
    state = const BranhamAudioPlaybackState();
  }

  Future<void> play({
    required String sourceId,
    required String title,
    required String subtitle,
    required String audioUrl,
    required List<BranhamPredication> playlist,
    required int index,
        bool resumeIfActive = false,
  }) async {
    if (state.sourceId == sourceId && state.isActive) {
      if (resumeIfActive && !_player.playing) {
        await BackgroundAudioHub.instance.resume();
      }
      return;
    }

    await ref.read(livePlaybackProvider.notifier).stopPlayback();
    state = BranhamAudioPlaybackState(
      sourceId: sourceId,
      title: title,
      subtitle: subtitle,
      audioUrl: audioUrl,
      playlist: playlist,
      index: index,
      isActive: true,
      isLoading: true,
    );
    _startingOwnAudio = true;
    try {
      await BackgroundAudioHub.instance.playUri(
        id: 'stream:$audioUrl',
        url: audioUrl,
        title: title,
        artist: subtitle,
      );
      if (state.sourceId == sourceId) {
        state = state.copyWith(isLoading: false, isPlaying: _player.playing);
      }
    } catch (_) {
      if (state.sourceId == sourceId) {
        state = const BranhamAudioPlaybackState();
      }
      rethrow;
    } finally {
      _startingOwnAudio = false;
    }
  }

  Future<void> togglePlay() async {
    if (!state.isActive) return;
    if (_player.playing) {
      await BackgroundAudioHub.instance.pause();
    } else {
      await BackgroundAudioHub.instance.resume();
    }
  }

  Future<void> next() async {
    if (!state.hasNext) return;
    await _playAt(state.index + 1);
  }

  Future<void> previous() async {
    if (!state.hasPrevious) return;
    await _playAt(state.index - 1);
  }

  Future<void> _playAt(int index) async {
    final item = state.playlist[index];
    final audioUrl = item.audioUrl;
    if (audioUrl == null) return;
    await play(
      sourceId:
          'branham_${item.code.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_')}',
      title: item.title,
      subtitle: 'William Branham · ${item.code}',
      audioUrl: audioUrl,
      playlist: state.playlist,
      index: index,
    );
  }

  Future<void> stop() async {
    state = const BranhamAudioPlaybackState();
    await BackgroundAudioHub.instance.stop();
  }
}