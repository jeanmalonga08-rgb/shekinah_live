import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/platform/local_file.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/offline_media.dart';
import '../providers/offline_playback_provider.dart';
import '../widgets/content_share_helper.dart';
import 'offline_video_fullscreen_page.dart';

class OfflineMediaPlayerPage extends ConsumerStatefulWidget {
  const OfflineMediaPlayerPage({
    super.key,
    required this.playlist,
    this.initialIndex = 0,
  }) : assert(playlist.length > 0, 'playlist must not be empty'),
       assert(initialIndex >= 0);

  final List<OfflineMediaItem> playlist;
  final int initialIndex;

  factory OfflineMediaPlayerPage.single({
    Key? key,
    required OfflineMediaItem item,
  }) {
    return OfflineMediaPlayerPage(
      key: key,
      playlist: [item],
      initialIndex: 0,
    );
  }

  @override
  ConsumerState<OfflineMediaPlayerPage> createState() =>
      _OfflineMediaPlayerPageState();
}

class _OfflineMediaPlayerPageState extends ConsumerState<OfflineMediaPlayerPage> {
  bool _videoFullscreenOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensurePlayback();
      if (!mounted) return;
      ref.read(offlinePlaybackProvider.notifier).reconcileLoadingState();
    });
  }

  Future<void> _ensurePlayback() async {
    final notifier = ref.read(offlinePlaybackProvider.notifier);
    final current = ref.read(offlinePlaybackProvider);
    final targetIndex = widget.initialIndex.clamp(0, widget.playlist.length - 1);
    final sameQueue = _sameQueue(current.playlist, widget.playlist) &&
        current.isActive;

    if (sameQueue) {
      notifier.openFullPlayer();
      await notifier.waitForActiveLoad();
      final latest = ref.read(offlinePlaybackProvider);
      if (latest.index != targetIndex) {
        await notifier.goToIndex(targetIndex);
      }
      return;
    }

    await notifier.playQueue(
      widget.playlist,
      initialIndex: widget.initialIndex,
      openFullPlayer: true,
    );
  }

  bool _sameQueue(List<OfflineMediaItem> a, List<OfflineMediaItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  Widget _coverFallback() {
    return Container(
      color: AppTheme.surfaceElevated,
      alignment: Alignment.center,
      child: Image.asset(
        AppConstants.logoAsset,
        width: 72,
        height: 72,
        errorBuilder: (_, _, _) => Icon(
          Icons.headphones,
          color: AppTheme.accentGold,
          size: 48,
        ),
      ),
    );
  }

  Future<void> _openVideoFullscreen() async {
    if (_videoFullscreenOpen) return;
    setState(() => _videoFullscreenOpen = true);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const OfflineVideoFullscreenPage(),
      ),
    );
    if (mounted) setState(() => _videoFullscreenOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final playback = ref.watch(offlinePlaybackProvider);
    final notifier = ref.read(offlinePlaybackProvider.notifier);
    ref.listen(offlinePlaybackProvider, (previous, next) {
      if (next.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(offlinePlaybackProvider.notifier).reconcileLoadingState();
        });
      }
    });
    final current = playback.currentItem;
    final positionLabel = playback.hasPlaylist
        ? '${playback.index + 1} / ${playback.playlist.length}'
        : null;
    final isVideo = current?.format == OfflineMediaFormat.video;
    final videoController = notifier.videoController;
    final hubPlayer = notifier.sharedAudioPlayer;
    final isOfflineAudio =
        playback.isActive && current?.format == OfflineMediaFormat.audio;
    final audioPlaying = isOfflineAudio
        ? hubPlayer.playing
        : (notifier.audioPlayer?.playing ?? false);
    final audioActive = isOfflineAudio &&
        (hubPlayer.playing ||
            hubPlayer.processingState != ProcessingState.idle);
    final videoReady = videoController?.value.isInitialized ?? false;
    final videoPlaying = videoController?.value.isPlaying ?? false;
    final showLoading = playback.isLoading &&
        !playback.isPlaying &&
        !audioPlaying &&
        !audioActive &&
        !videoReady &&
        !videoPlaying &&
        current != null;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) notifier.collapseToMiniPlayer();
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(
            positionLabel == null
                ? l10n.offlinePlayerTitle
                : '${l10n.offlinePlayerTitle} · $positionLabel',
          ),
          actions: [
            if (isVideo &&
                videoController != null &&
                !_videoFullscreenOpen)
              IconButton(
                tooltip: l10n.offlineFullscreen,
                icon: const Icon(Icons.fullscreen),
                onPressed: _openVideoFullscreen,
              ),
            if (current != null) ...[
              IconButton(
                tooltip: l10n.offlineShowInExplorer,
                icon: const Icon(Icons.folder_open_outlined),
                onPressed: () => showOfflineFileActions(context, current),
              ),
              IconButton(
                tooltip: l10n.share,
                icon: const Icon(Icons.share_outlined),
                onPressed: () => shareOfflineMediaInfo(context, current),
              ),
            ],
          ],
        ),
        body: playback.failed || current == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        playback.failure ==
                                OfflinePlaybackFailure.playbackError
                            ? l10n.offlinePlaybackFailed
                            : l10n.offlineFileNotFound,
                        style: TextStyle(color: AppTheme.grey),
                        textAlign: TextAlign.center,
                      ),
                      if (current != null &&
                          playback.failure ==
                              OfflinePlaybackFailure.playbackError &&
                          canOpenLocalFileExternally) ...[
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () async {
                            final ok = await openLocalFileExternally(
                              current.localPath,
                            );
                            if (!context.mounted) return;
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.offlineFileLocationUnavailable,
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: Text(l10n.offlineOpenExternally),
                        ),
                      ],
                      if (playback.hasNext) ...[
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: notifier.next,
                          icon: const Icon(Icons.skip_next),
                          label: Text(l10n.offlineNextTrack),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            : showLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppTheme.accentGold),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final bottomInset = MediaQuery.paddingOf(context).bottom;
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          4,
                          16,
                          bottomInset > 0 ? bottomInset : 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, stage) {
                                  if (isVideo &&
                                      videoController != null &&
                                      !_videoFullscreenOpen) {
                                    return _OfflineVideoPreview(
                                      controller: videoController,
                                      maxWidth: stage.maxWidth,
                                      maxHeight: stage.maxHeight,
                                      onOpenFullscreen: _openVideoFullscreen,
                                      fullscreenTooltip:
                                          l10n.offlineFullscreen,
                                    );
                                  }
                                  if (_videoFullscreenOpen) {
                                    return _FullscreenPlaceholder(
                                      label: l10n.offlineFullscreen,
                                      maxWidth: stage.maxWidth,
                                      maxHeight: stage.maxHeight,
                                    );
                                  }
                                  return _OfflineAudioCover(
                                    item: current,
                                    maxWidth: stage.maxWidth,
                                    maxHeight: stage.maxHeight,
                                    coverFallback: _coverFallback(),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              current.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                height: 1.22,
                              ),
                            ),
                            if (current.subtitle.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                current.subtitle,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppTheme.goldLight,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              positionLabel == null
                                  ? offlineMediaMetaLine(l10n, current)
                                  : '${offlineMediaMetaLine(l10n, current)} · $positionLabel',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _ExtraControls(
                              speed: playback.speed,
                              repeatMode: playback.repeatMode,
                              shuffle: playback.shuffle,
                              onSpeed: notifier.cycleSpeed,
                              onRepeat: notifier.cycleRepeatMode,
                              onShuffle: notifier.toggleShuffle,
                            ),
                            if (current.format == OfflineMediaFormat.audio &&
                                notifier.audioPlayer != null)
                              _AudioControls(
                                player: notifier.audioPlayer!,
                                formatDuration: _formatDuration,
                                hasPrevious: playback.hasPrevious ||
                                    playback.repeatMode ==
                                        OfflineRepeatMode.all,
                                hasNext: playback.hasNext ||
                                    playback.repeatMode ==
                                        OfflineRepeatMode.all,
                                onPrevious: notifier.previous,
                                onNext: notifier.next,
                                onSkipBack: notifier.skipBackward,
                                onSkipForward: notifier.skipForward,
                              ),
                            if (isVideo &&
                                videoController != null &&
                                !_videoFullscreenOpen)
                              _VideoControls(
                                controller: videoController,
                                tick: playback.tick,
                                formatDuration: _formatDuration,
                                hasPrevious: playback.hasPrevious ||
                                    playback.repeatMode ==
                                        OfflineRepeatMode.all,
                                hasNext: playback.hasNext ||
                                    playback.repeatMode ==
                                        OfflineRepeatMode.all,
                                onPrevious: notifier.previous,
                                onNext: notifier.next,
                                onSkipBack: notifier.skipBackward,
                                onSkipForward: notifier.skipForward,
                                onTogglePlay: notifier.togglePlay,
                                onFullscreen: _openVideoFullscreen,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

Size _fitMediaBox(double maxWidth, double maxHeight, double aspectRatio) {
  var width = maxWidth;
  var height = width / aspectRatio;
  if (height > maxHeight) {
    height = maxHeight;
    width = height * aspectRatio;
  }
  return Size(width, height);
}

class _OfflineAudioCover extends StatelessWidget {
  const _OfflineAudioCover({
    required this.item,
    required this.maxWidth,
    required this.maxHeight,
    required this.coverFallback,
  });

  final OfflineMediaItem item;
  final double maxWidth;
  final double maxHeight;
  final Widget coverFallback;

  @override
  Widget build(BuildContext context) {
    const aspectRatio = 1.0;
    final size = _fitMediaBox(maxWidth, maxHeight, aspectRatio);
    final isBranhamAudio =
      item.category == OfflineMediaCategory.predication &&
      item.format == OfflineMediaFormat.audio &&
      item.sourceId.startsWith('branham_');

    return Center(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: item.thumbnailUrl == null
              ? isBranhamAudio
                  ? Image.asset(
                      'assets/images/wmb.jpg',
                      fit: BoxFit.cover,
                      width: size.width,
                      height: size.height,
                      errorBuilder: (_, _, _) => coverFallback,
                    )
                  : coverFallback
              : CachedNetworkImage(
                  imageUrl: item.thumbnailUrl!,
                  fit: BoxFit.cover,
                  width: size.width,
                  height: size.height,
                  errorWidget: (_, _, _) => coverFallback,
                ),
        ),
      ),
    );
  }
}

class _OfflineVideoPreview extends StatelessWidget {
  const _OfflineVideoPreview({
    required this.controller,
    required this.onOpenFullscreen,
    required this.fullscreenTooltip,
    required this.maxWidth,
    required this.maxHeight,
  });

  final VideoPlayerController controller;
  final VoidCallback onOpenFullscreen;
  final String fullscreenTooltip;
  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final ratio = controller.value.aspectRatio == 0
        ? 16 / 9
        : controller.value.aspectRatio;
    final size = _fitMediaBox(maxWidth, maxHeight, ratio);

    return Center(
      child: GestureDetector(
        onTap: onOpenFullscreen,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                VideoPlayer(controller),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: fullscreenTooltip,
                      onPressed: onOpenFullscreen,
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullscreenPlaceholder extends StatelessWidget {
  const _FullscreenPlaceholder({
    required this.label,
    required this.maxWidth,
    required this.maxHeight,
  });

  final String label;
  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final size = _fitMediaBox(maxWidth, maxHeight, 16 / 9);

    return Center(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fullscreen, color: AppTheme.accentGold, size: 36),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(color: AppTheme.softWhite, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExtraControls extends StatelessWidget {
  const _ExtraControls({
    required this.speed,
    required this.repeatMode,
    required this.shuffle,
    required this.onSpeed,
    required this.onRepeat,
    required this.onShuffle,
  });

  final double speed;
  final OfflineRepeatMode repeatMode;
  final bool shuffle;
  final VoidCallback onSpeed;
  final VoidCallback onRepeat;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repeatIcon = switch (repeatMode) {
      OfflineRepeatMode.off => Icons.repeat,
      OfflineRepeatMode.all => Icons.repeat,
      OfflineRepeatMode.one => Icons.repeat_one,
    };
    final repeatColor = repeatMode == OfflineRepeatMode.off
        ? AppTheme.grey
        : AppTheme.accentGold;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: onSpeed,
          icon: Icon(Icons.speed, size: 18, color: AppTheme.accentOnSurface),
          label: Text(
            '${speed}x',
            style: TextStyle(color: AppTheme.softWhite, fontSize: 12),
          ),
        ),
        IconButton(
          tooltip: l10n.offlineShuffle,
          onPressed: onShuffle,
          icon: Icon(
            Icons.shuffle,
            color: shuffle ? AppTheme.accentGold : AppTheme.grey,
          ),
        ),
        IconButton(
          tooltip: l10n.offlineRepeat,
          onPressed: onRepeat,
          icon: Icon(repeatIcon, color: repeatColor),
        ),
      ],
    );
  }
}

class _AudioControls extends StatelessWidget {
  const _AudioControls({
    required this.player,
    required this.formatDuration,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
    required this.onSkipBack,
    required this.onSkipForward,
  });

  final AudioPlayer player;
  final String Function(Duration) formatDuration;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Future<void> Function() onSkipBack;
  final Future<void> Function() onSkipForward;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: player.durationStream,
      builder: (context, durationSnap) {
        final duration = durationSnap.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, positionSnap) {
            final position = positionSnap.data ?? Duration.zero;
            final value = duration.inMilliseconds == 0
                ? 0.0
                : (position.inMilliseconds / duration.inMilliseconds)
                    .clamp(0.0, 1.0);
            return StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, stateSnap) {
                final playing = stateSnap.data?.playing ?? false;
                return _ControlsColumn(
                  value: value,
                  position: position,
                  duration: duration,
                  playing: playing,
                  formatDuration: formatDuration,
                  hasPrevious: hasPrevious,
                  hasNext: hasNext,
                  onSeek: (v) => player.seek(
                    Duration(
                      milliseconds: (v * duration.inMilliseconds).round(),
                    ),
                  ),
                  onPrevious: onPrevious,
                  onNext: onNext,
                  onSkipBack: onSkipBack,
                  onSkipForward: onSkipForward,
                  onTogglePlay: () {
                    if (playing) {
                      player.pause();
                    } else {
                      player.play();
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _VideoControls extends StatelessWidget {
  const _VideoControls({
    required this.controller,
    required this.tick,
    required this.formatDuration,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
    required this.onSkipBack,
    required this.onSkipForward,
    required this.onTogglePlay,
    this.onFullscreen,
  });

  final VideoPlayerController controller;
  final int tick;
  final String Function(Duration) formatDuration;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Future<void> Function() onSkipBack;
  final Future<void> Function() onSkipForward;
  final VoidCallback onTogglePlay;
  final VoidCallback? onFullscreen;

  @override
  Widget build(BuildContext context) {
    final _ = tick;
    final duration = controller.value.duration;
    final position = controller.value.position;
    final value = duration.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return _ControlsColumn(
      value: value,
      position: position,
      duration: duration,
      playing: controller.value.isPlaying,
      formatDuration: formatDuration,
      hasPrevious: hasPrevious,
      hasNext: hasNext,
      onSeek: (v) {
        controller.seekTo(
          Duration(milliseconds: (v * duration.inMilliseconds).round()),
        );
      },
      onPrevious: onPrevious,
      onNext: onNext,
      onSkipBack: onSkipBack,
      onSkipForward: onSkipForward,
      onTogglePlay: onTogglePlay,
      onFullscreen: onFullscreen,
    );
  }
}

class _ControlsColumn extends StatelessWidget {
  const _ControlsColumn({
    required this.value,
    required this.position,
    required this.duration,
    required this.playing,
    required this.formatDuration,
    required this.hasPrevious,
    required this.hasNext,
    required this.onSeek,
    required this.onPrevious,
    required this.onNext,
    required this.onSkipBack,
    required this.onSkipForward,
    required this.onTogglePlay,
    this.onFullscreen,
  });

  final double value;
  final Duration position;
  final Duration duration;
  final bool playing;
  final String Function(Duration) formatDuration;
  final bool hasPrevious;
  final bool hasNext;
  final ValueChanged<double> onSeek;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Future<void> Function() onSkipBack;
  final Future<void> Function() onSkipForward;
  final VoidCallback onTogglePlay;
  final VoidCallback? onFullscreen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Slider(
          value: value,
          activeColor: AppTheme.accentGold,
          onChanged: duration.inMilliseconds == 0 ? null : onSeek,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(position),
                style: TextStyle(color: AppTheme.grey, fontSize: 12),
              ),
              Text(
                formatDuration(duration),
                style: TextStyle(color: AppTheme.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: l10n.offlineSkipBack,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: onSkipBack,
                icon: Icon(Icons.replay_10, color: AppTheme.softWhite),
              ),
              IconButton(
                iconSize: 32,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: hasPrevious ? onPrevious : null,
                icon: Icon(
                  Icons.skip_previous_rounded,
                  color: hasPrevious ? AppTheme.white : AppTheme.muted,
                ),
              ),
              IconButton(
                iconSize: 56,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
                onPressed: onTogglePlay,
                icon: Icon(
                  playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: AppTheme.accentGold,
                ),
              ),
              IconButton(
                iconSize: 32,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: hasNext ? onNext : null,
                icon: Icon(
                  Icons.skip_next_rounded,
                  color: hasNext ? AppTheme.white : AppTheme.muted,
                ),
              ),
              IconButton(
                tooltip: l10n.offlineSkipForward,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: onSkipForward,
                icon: Icon(Icons.forward_10, color: AppTheme.softWhite),
              ),
              if (onFullscreen != null)
                IconButton(
                  tooltip: l10n.offlineFullscreen,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  onPressed: onFullscreen,
                  icon: Icon(Icons.fullscreen, color: AppTheme.softWhite),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
