import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/live_duration_utils.dart';
import '../../core/utils/next_worship_service.dart';
import '../../domain/entities/live_status.dart';
import '../providers/live_playback_provider.dart';
import '../providers/live_stream_provider.dart';
import '../widgets/live_player_overlays.dart';
import '../widgets/sht_widgets.dart';

enum _LiveMode { video, audio }

class LivePage extends ConsumerStatefulWidget {
  const LivePage({super.key, this.startInAudioMode = false});

  /// Ouvre Direct en mode audio (ex. depuis la bannière Accueil).
  final bool startInAudioMode;

  @override
  ConsumerState<LivePage> createState() => _LivePageState();
}

class _LivePageState extends ConsumerState<LivePage>
    with SingleTickerProviderStateMixin {
  _LiveMode _mode = _LiveMode.video;
  LiveLang _lang = LiveLang.fr;
  bool _playerReady = false;
  bool _audioFailed = false;
  bool _fullscreenActive = false;
  String? _loadedAudioUrl;

  late final AnimationController _pulse;
  late NextWorshipService _next;
  Timer? _chrono;

  bool _audioLaunchHandled = false;
  int _playbackOp = 0;

  bool _isPlaybackOpCurrent(int op) => mounted && op == _playbackOp;

  @override
  void initState() {
    super.initState();
    if (widget.startInAudioMode) {
      _mode = _LiveMode.audio;
      _playerReady = true;
    }
    _next = NextWorshipService.compute();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _chrono = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _next = NextWorshipService.compute());
    });
  }

  @override
  void dispose() {
    _chrono?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  LivePlaybackNotifier get _playback => ref.read(livePlaybackProvider.notifier);
  AudioPlayer get _audioPlayer => _playback.audioPlayer;

  void _syncFromEntity(LiveStreamEntity? entity, {bool force = false}) {
    if (entity == null) return;

    final videoLangs = entity.availableVideoLangs;
    final audioLangs = entity.availableAudioLangs;

    if (_mode == _LiveMode.video && videoLangs.isEmpty && audioLangs.isNotEmpty) {
      _mode = _LiveMode.audio;
    } else if (_mode == _LiveMode.audio &&
        audioLangs.isEmpty &&
        videoLangs.isNotEmpty) {
      _mode = _LiveMode.video;
    }

    final langs = _mode == _LiveMode.video ? videoLangs : audioLangs;
    if (langs.isNotEmpty && !langs.contains(_lang)) {
      _lang = langs.first;
    } else if (langs.isEmpty) {
      _lang = entity.preferredVideoLang;
    }

    if (entity.isLive || force || _playerReady) {
      unawaited(_ensurePlayer(entity));
    }
  }

  Future<void> _onLiveModeChanged(_LiveMode mode, LiveStreamEntity? entity) async {
    if (mode == _mode) return;
    final op = ++_playbackOp;
    setState(() => _mode = mode);
    _playback.setMode(
      mode == _LiveMode.video
          ? LivePlaybackMode.video
          : LivePlaybackMode.audio,
    );

    await WidgetsBinding.instance.endOfFrame;
    if (!_isPlaybackOpCurrent(op)) return;

    await _playback.releaseVideoPlayback();
    if (mode == _LiveMode.video) {
      await _audioPlayer.stop();
    }
    _loadedAudioUrl = null;

    if (entity != null && _isPlaybackOpCurrent(op)) {
      await _ensurePlayer(entity, op: op);
    }
  }

  Future<void> _ensurePlayer(LiveStreamEntity entity, {int? op}) async {
    final playbackOp = op ?? ++_playbackOp;

    if (_mode == _LiveMode.video) {
      final liveTitle = context.l10n.liveTitle;
      await _audioPlayer.stop();
      if (!_isPlaybackOpCurrent(playbackOp)) return;

      if (!entity.isLive) {
        setState(() => _playerReady = false);
        return;
      }
      final url = entity.embedUrlFor(_lang);
      if (url == null) {
        setState(() => _playerReady = false);
        return;
      }
      if (_playback.webController != null &&
          _playerReady &&
          entity.embedUrlFor(_lang) == url &&
          ref.read(livePlaybackProvider).webFailure == null) {
        return;
      }
      if (ref.read(livePlaybackProvider).webFailure != null) {
        _playback.resetVideoCache();
      }
      if (!_isPlaybackOpCurrent(playbackOp)) return;

      setState(() => _playerReady = true);
      final ok = await _playback.ensureVideoEmbed(
        url,
        isLive: entity.isLive,
        title: liveTitle,
      );
      if (!_isPlaybackOpCurrent(playbackOp)) return;
      if (!ok) setState(() => _playerReady = true);
      return;
    }

    _playback.setMode(LivePlaybackMode.audio);

    final audioUrl = entity.audioLinkFor(_lang);
    if (audioUrl == null) {
      if (!_isPlaybackOpCurrent(playbackOp)) return;
      setState(() {
        _playerReady = false;
        _audioFailed = true;
      });
      return;
    }
    if (_loadedAudioUrl == audioUrl && !_audioFailed) {
      if (!_isPlaybackOpCurrent(playbackOp)) return;
      setState(() => _playerReady = true);
      return;
    }

    if (_playback.webController != null) {
      await _playback.releaseVideoPlayback();
      if (!_isPlaybackOpCurrent(playbackOp)) return;
    }

    setState(() {
      _playerReady = true;
      _audioFailed = false;
      _loadedAudioUrl = audioUrl;
    });
    try {
      await _playback.playAudioUrl(audioUrl);
    } catch (_) {
      if (_isPlaybackOpCurrent(playbackOp)) {
        setState(() => _audioFailed = true);
      }
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(liveStreamProvider.notifier).refreshLiveStatus();
    final entity = ref.read(liveStreamProvider).liveStream;
    if (entity != null) {
      _playback.resetVideoCache();
      _loadedAudioUrl = null;
      _syncFromEntity(entity, force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(liveStreamProvider);
    final entity = liveState.liveStream;

    ref.listen<LiveStreamState>(liveStreamProvider, (prev, next) {
      final nextEntity = next.liveStream;
      if (nextEntity == null) return;

      final prevEntity = prev?.liveStream;
      final becameLive = nextEntity.isLive && !(prevEntity?.isLive ?? false);
      final streamingChanged = prevEntity == null ||
          !prevEntity.hasSameStreamingConfig(nextEntity);
      final videoFailed = _mode == _LiveMode.video &&
          nextEntity.isLive &&
          ref.read(livePlaybackProvider).webFailure != null;

      if (!becameLive && !streamingChanged && !videoFailed) return;

      if (streamingChanged || videoFailed) {
        _playback.resetVideoCache();
        _loadedAudioUrl = null;
      }
      _syncFromEntity(nextEntity, force: true);
    });

    if (entity != null && !_playerReady && entity.isLive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncFromEntity(entity, force: true);
      });
    }

    if (widget.startInAudioMode &&
        entity != null &&
        entity.hasAnyAudio &&
        !_audioLaunchHandled) {
      _audioLaunchHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _mode = _LiveMode.audio;
          _playerReady = true;
        });
        _syncFromEntity(entity, force: true);
      });
    }

    final isLive = liveState.isLive;
    final videoLangs = entity?.availableVideoLangs ?? const <LiveLang>[];
    final audioLangs = entity?.availableAudioLangs ?? const <LiveLang>[];
    final activeLangs =
        _mode == _LiveMode.video ? videoLangs : audioLangs;
    final playback = ref.watch(livePlaybackProvider);
    final webController = _playback.webController;
    final webLoading = playback.webLoading;
    final webFailure = playback.webFailure;
    final liveElapsed = formatLiveDuration(
      playback.liveStartedAt != null
          ? DateTime.now().difference(playback.liveStartedAt!)
          : liveElapsedSince(entity?.liveStartedAt),
    );
    final screenSize = MediaQuery.sizeOf(context);
    final compactLayout = screenSize.width < 360 || screenSize.height < 640;

    if (entity?.liveStartedAt != null) {
      _playback.syncLiveStartedAt(entity!.liveStartedAt);
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        if (_playerReady && (isLive || playback.isPlaying)) {
          _playback.showFloating();
        }
      },
      child: Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _LiveTopBar(
              isLive: isLive,
              isLoading: liveState.isLoading,
              onBack: () {
                if (_playerReady && (isLive || playback.isPlaying)) {
                  _playback.showFloating();
                }
                Navigator.of(context).maybePop();
              },
              onRefresh: _onRefresh,
            ),
            Expanded(
              child: liveState.isLoading && entity == null
                  ? Center(
                      child: SpinKitFadingCircle(
                        color: AppTheme.accentOnSurface,
                        size: 48,
                      ),
                    )
                  : liveState.hasError && entity == null
                      ? _ErrorState(
                          message: liveState.errorMessage?.isNotEmpty == true
                              ? liveState.errorMessage!
                              : context.l10n.networkError,
                          onRetry: _onRefresh,
                        )
                      : RefreshIndicator(
                          color: AppTheme.accentOnSurface,
                          backgroundColor: AppTheme.surface,
                          onRefresh: _onRefresh,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              compactLayout ? 12 : 16,
                              compactLayout ? 4 : 8,
                              compactLayout ? 12 : 16,
                              compactLayout ? 16 : 28,
                            ),
                            children: [
                              _PlayerStage(
                                isLive: isLive,
                                playerReady: _playerReady,
                                mode: _mode,
                                pulse: _pulse,
                                next: _next,
                                message: entity?.message,
                                webController: webController,
                                webViewDetached: _fullscreenActive,
                                webLoading: webLoading,
                                webFailure: webFailure,
                                audioPlayer: _audioPlayer,
                                audioFailed: _audioFailed,
                                hasVideo: videoLangs.isNotEmpty,
                                hasAudio: audioLangs.isNotEmpty,
                                onRetryVideo: entity == null
                                    ? null
                                    : () {
                                        _playback.resetVideoCache();
                                        setState(() => _playerReady = true);
                                        _ensurePlayer(entity);
                                      },
                                onFullscreen: webController == null
                                    ? null
                                    : () async {
                                        setState(() => _fullscreenActive = true);
                                        await WidgetsBinding.instance.endOfFrame;
                                        if (!context.mounted) return;
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => LiveFullscreenPage(
                                              controller: webController,
                                              isLive: isLive,
                                            ),
                                          ),
                                        );
                                        if (mounted) {
                                          setState(() => _fullscreenActive = false);
                                        }
                                      },
                                onFloating: () {
                                  _playback.showFloating();
                                  Navigator.of(context).maybePop();
                                },
                                onTogglePlay: () => _playback.toggleAudio(),
                                onStart: () {
                                  if (entity == null) return;
                                  if (_mode == _LiveMode.video && !entity.isLive) {
                                    return;
                                  }
                                  setState(() => _playerReady = true);
                                  _ensurePlayer(entity);
                                },
                              ),
                              SizedBox(height: compactLayout ? 12 : 20),
                              if (videoLangs.isNotEmpty ||
                                  audioLangs.isNotEmpty) ...[
                                _ModeSwitcher(
                                  mode: _mode,
                                  hasVideo: videoLangs.isNotEmpty,
                                  hasAudio: audioLangs.isNotEmpty,
                                  onChanged: (mode) {
                                    unawaited(
                                      _onLiveModeChanged(mode, entity),
                                    );
                                  },
                                ),
                                SizedBox(height: compactLayout ? 10 : 14),
                              ],
                              if (activeLangs.length > 1) ...[
                                _LangChips(
                                  langs: activeLangs,
                                  selected: _lang,
                                  onSelected: (lang) async {
                                    if (lang == _lang) return;
                                    final op = ++_playbackOp;
                                    setState(() => _lang = lang);
                                    if (entity == null || !_playerReady) return;
                                    await WidgetsBinding.instance.endOfFrame;
                                    if (!_isPlaybackOpCurrent(op)) return;
                                    if (_mode == _LiveMode.video) {
                                      await _playback.releaseVideoPlayback();
                                    } else {
                                      _loadedAudioUrl = null;
                                    }
                                    if (_isPlaybackOpCurrent(op)) {
                                      await _ensurePlayer(entity, op: op);
                                    }
                                  },
                                ),
                                SizedBox(height: compactLayout ? 12 : 18),
                              ],
                              _InfoPanel(
                                isLive: isLive,
                                next: _next,
                                message: entity?.message,
                                liveElapsedLabel: liveElapsed,
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _LiveTopBar extends StatelessWidget {
  const _LiveTopBar({
    required this.isLive,
    required this.isLoading,
    required this.onBack,
    required this.onRefresh,
  });

  final bool isLive;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final compactLayout = MediaQuery.sizeOf(context).width < 360;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        compactLayout ? 4 : 8,
        4,
        compactLayout ? 4 : 8,
        4,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppTheme.white,
          ),
          Expanded(
            child: Text(
              l10n.liveDirect,
              style: TextStyle(
                color: AppTheme.white,
                fontSize: compactLayout ? 18 : 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (isLive) const LiveBadge(),
          const SizedBox(width: 4),
          IconButton(
            onPressed: isLoading ? null : onRefresh,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            color: AppTheme.softWhite,
          ),
        ],
      ),
    );
  }
}

class _PlayerStage extends StatelessWidget {
  const _PlayerStage({
    required this.isLive,
    required this.playerReady,
    required this.mode,
    required this.pulse,
    required this.next,
    required this.message,
    required this.webController,
    this.webViewDetached = false,
    required this.webLoading,
    required this.webFailure,
    required this.audioPlayer,
    required this.audioFailed,
    required this.hasVideo,
    required this.hasAudio,
    this.onRetryVideo,
    this.onFullscreen,
    this.onFloating,
    required this.onTogglePlay,
    required this.onStart,
  });

  final bool isLive;
  final bool playerReady;
  final _LiveMode mode;
  final AnimationController pulse;
  final NextWorshipService next;
  final String? message;
  final WebViewController? webController;
  final bool webViewDetached;
  final bool webLoading;
  final LiveWebPlaybackFailure? webFailure;
  final AudioPlayer audioPlayer;
  final bool audioFailed;
  final bool hasVideo;
  final bool hasAudio;
  final VoidCallback? onRetryVideo;
  final VoidCallback? onFullscreen;
  final VoidCallback? onFloating;
  final VoidCallback onTogglePlay;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showVideoError =
        playerReady && mode == _LiveMode.video && webFailure != null;
    final showVideo = playerReady &&
        mode == _LiveMode.video &&
        webController != null &&
        webFailure == null;
    final showAudio = playerReady && mode == _LiveMode.audio;

    Widget stageChild;
    if (showVideoError) {
      final errorMessage = switch (webFailure!) {
        LiveWebPlaybackFailure.network => l10n.networkError,
        LiveWebPlaybackFailure.streamUnavailable => l10n.liveNoStream,
      };
      stageChild = _VideoErrorStage(
        message: errorMessage,
        onRetry: onRetryVideo,
      );
    } else if (showVideo) {
      stageChild = Stack(
        fit: StackFit.expand,
        children: [
          if (webViewDetached)
            const ColoredBox(color: Colors.black)
          else
            WebViewWidget(controller: webController!),
          if (webLoading)
            ColoredBox(
              color: Colors.black54,
              child: Center(
                child: SpinKitFadingCircle(
                  color: AppTheme.accentOnSurface,
                  size: 42,
                ),
              ),
            ),
          if (isLive)
            const Positioned(
              top: 12,
              left: 12,
              child: LiveBadge(),
            ),
          if (playerReady && isLive)
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  if (onFloating != null)
                    _PlayerOverlayButton(
                      icon: Icons.picture_in_picture_alt,
                      onTap: onFloating!,
                    ),
                  if (onFullscreen != null) ...[
                    const SizedBox(width: 6),
                    _PlayerOverlayButton(
                      icon: Icons.fullscreen,
                      onTap: onFullscreen!,
                    ),
                  ],
                ],
              ),
            ),
        ],
      );
    } else if (showAudio) {
      stageChild = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AudioStage(
            player: audioPlayer,
            failed: audioFailed,
            isLive: isLive,
            pulse: pulse,
            onTogglePlay: onTogglePlay,
          ),
          if (isLive && playerReady && onFloating != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onFloating,
                    icon: const Icon(Icons.picture_in_picture_alt, size: 18),
                    label: Text(l10n.liveFloatingWindow),
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      stageChild = _WaitingStage(
        isLive: isLive,
        next: next,
        message: message,
        pulse: pulse,
        canStart: hasVideo || hasAudio,
        onStart: onStart,
      );
    }

    final Widget content;
    if (showVideo || showVideoError) {
      content = AspectRatio(aspectRatio: 16 / 9, child: stageChild);
    } else {
      content = stageChild;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isLive
              ? AppTheme.live.withValues(alpha: 0.55)
              : AppTheme.accentOnSurface.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: (isLive ? AppTheme.crossRed : AppTheme.royalBlue)
                .withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
        gradient: AppTheme.playerGradient,
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}

class _VideoErrorStage extends StatelessWidget {
  const _VideoErrorStage({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, color: AppTheme.grey, size: 40),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.grey, height: 1.5),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WaitingStage extends StatelessWidget {
  const _WaitingStage({
    required this.isLive,
    required this.next,
    required this.message,
    required this.pulse,
    required this.canStart,
    required this.onStart,
  });

  final bool isLive;
  final NextWorshipService next;
  final String? message;
  final AnimationController pulse;
  final bool canStart;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: canStart ? onStart : null,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (_, child) {
                final scale = 0.92 + pulse.value * 0.08;
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.crossRed,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.crossRed.withValues(alpha: 0.45),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  isLive ? Icons.sensors : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isLive ? l10n.liveServiceInProgress : l10n.liveNoStream,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (!isLive) ...[
            const SizedBox(height: 4),
            Text(
              '${l10n.liveNextServiceLabel} · ${next.dayLabel(l10n)} ${next.timeLabel(l10n)}',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grey,
                fontSize: 12.5,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              next.chronoLabel(context.l10n),
              style: TextStyle(
                color: AppTheme.goldOnSurface,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppTheme.softWhite, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _AudioStage extends StatelessWidget {
  const _AudioStage({
    required this.player,
    required this.failed,
    required this.isLive,
    required this.pulse,
    required this.onTogglePlay,
  });

  final AudioPlayer player;
  final bool failed;
  final bool isLive;
  final AnimationController pulse;
  final VoidCallback onTogglePlay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (failed) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            l10n.mediaUnavailable,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.grey),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: pulse,
            builder: (_, child) {
              return Transform.scale(
                scale: 0.96 + pulse.value * 0.04,
                child: child,
              );
            },
            child: const AppLogo(size: 72),
          ),
          const SizedBox(height: 14),
          Text(
            isLive ? l10n.liveAudioInProgress : l10n.liveListenAudio,
            style: TextStyle(color: AppTheme.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.appName,
            style: TextStyle(color: AppTheme.goldOnSurface, fontSize: 12.5),
          ),
          const SizedBox(height: 12),
          StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              final processing = snapshot.data?.processingState;
              final busy = processing == ProcessingState.loading ||
                  processing == ProcessingState.buffering;
              return IconButton(
                iconSize: 64,
                color: AppTheme.accentOnSurface,
                onPressed: busy
                    ? null
                    : onTogglePlay,
                icon: busy
                    ? const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : Icon(
                        playing
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({
    required this.mode,
    required this.hasVideo,
    required this.hasAudio,
    required this.onChanged,
  });

  final _LiveMode mode;
  final bool hasVideo;
  final bool hasAudio;
  final ValueChanged<_LiveMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentOnSurface.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          if (hasVideo)
            Expanded(
              child: _ModeTab(
                selected: mode == _LiveMode.video,
                icon: Icons.videocam_rounded,
                label: l10n.video,
                onTap: () => onChanged(_LiveMode.video),
              ),
            ),
          if (hasAudio)
            Expanded(
              child: _ModeTab(
                selected: mode == _LiveMode.audio,
                icon: Icons.headphones_rounded,
                label: l10n.audio,
                onTap: () => onChanged(_LiveMode.audio),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.surfaceElevated : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppTheme.accentOnSurface : AppTheme.grey,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppTheme.white : AppTheme.grey,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangChips extends StatelessWidget {
  const _LangChips({
    required this.langs,
    required this.selected,
    required this.onSelected,
  });

  final List<LiveLang> langs;
  final LiveLang selected;
  final ValueChanged<LiveLang> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: langs.map((lang) {
        final active = lang == selected;
        return ChoiceChip(
          label: Text(liveLangLabel(context.l10n, lang)),
          selected: active,
          onSelected: (_) => onSelected(lang),
          selectedColor: AppTheme.accentOnSurface.withValues(alpha: 0.22),
          backgroundColor: AppTheme.surface,
          side: BorderSide(
            color: active
                ? AppTheme.accentOnSurface
                : AppTheme.accentOnSurface.withValues(alpha: 0.18),
          ),
          labelStyle: TextStyle(
            color: active ? AppTheme.goldOnSurface : AppTheme.softWhite,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.isLive,
    required this.next,
    required this.message,
    this.liveElapsedLabel,
  });

  final bool isLive;
  final NextWorshipService next;
  final String? message;
  final String? liveElapsedLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentOnSurface.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppLogo(size: 44, showShadow: false),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appName,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.churchTagline,
                      style: TextStyle(
                        color: AppTheme.accentOnSurface.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLive) ...[
            const SizedBox(height: 16),
            Text(
              l10n.liveConnectedMessage,
              style: TextStyle(color: AppTheme.grey,
                height: 1.45,
                fontSize: 13,
              ),
            ),
          ],
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: TextStyle(color: AppTheme.softWhite,
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ],
          if (isLive) ...[
            const SizedBox(height: 16),
            Divider(color: AppTheme.divider, height: 1),
            const SizedBox(height: 14),
            _MetaRow(
              icon: Icons.sensors,
              label: l10n.liveSinceLabel,
              value: liveElapsedLabel ?? '00:00',
            ),
            const SizedBox(height: 10),
            _MetaRow(
              icon: Icons.place_outlined,
              label: l10n.liveAssembly,
              value: l10n.assemblyAddress,
            ),
          ] else ...[
            const SizedBox(height: 16),
            Divider(color: AppTheme.divider, height: 1),
            const SizedBox(height: 14),
            _MetaRow(
              icon: Icons.event_available_rounded,
              label: l10n.liveNextServiceLabel,
              value: '${next.dayLabel(l10n)} · ${next.timeLabel(l10n)}',
            ),
            const SizedBox(height: 10),
            _MetaRow(
              icon: Icons.schedule_rounded,
              label: l10n.liveCountdown,
              value: next.chronoLabel(context.l10n),
            ),
            const SizedBox(height: 10),
            _MetaRow(
              icon: Icons.place_outlined,
              label: l10n.liveAssembly,
              value: l10n.assemblyAddress,
            ),
          ],
        ],
      ),
    );
  }
}

class _PlayerOverlayButton extends StatelessWidget {
  const _PlayerOverlayButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.accentOnSurface),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: AppTheme.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(color: AppTheme.softWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, color: AppTheme.grey, size: 42),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grey, height: 1.4),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.ctaBackground,
                foregroundColor: AppTheme.ctaForeground,
              ),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
