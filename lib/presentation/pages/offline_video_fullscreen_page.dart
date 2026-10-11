import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../providers/offline_playback_provider.dart';

/// Fullscreen offline video — reuses the shared [VideoPlayerController]
/// (do not create a second decoder on MediaTek devices).
class OfflineVideoFullscreenPage extends ConsumerStatefulWidget {
  const OfflineVideoFullscreenPage({super.key});

  @override
  ConsumerState<OfflineVideoFullscreenPage> createState() =>
      _OfflineVideoFullscreenPageState();
}

class _OfflineVideoFullscreenPageState
    extends ConsumerState<OfflineVideoFullscreenPage> {
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _scheduleHideControls();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      final playing =
          ref.read(offlinePlaybackProvider.notifier).videoController?.value.isPlaying ??
              false;
      if (mounted && playing) {
        setState(() => _showControls = false);
      }
    });
  }

  void _revealControls() {
    setState(() => _showControls = true);
    _scheduleHideControls();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final playback = ref.watch(offlinePlaybackProvider);
    final notifier = ref.read(offlinePlaybackProvider.notifier);
    final controller = notifier.videoController;
    final current = playback.currentItem;
    final initialized =
        controller != null && controller.value.isInitialized;

    // tick keeps slider/position fresh
    final _ = playback.tick;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _revealControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (initialized)
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio == 0
                      ? 16 / 9
                      : controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            AnimatedOpacity(
              opacity: _showControls ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: l10n.offlineFullscreenExit,
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.fullscreen_exit,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              current?.title ?? l10n.offlinePlayerTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (initialized) ...[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            iconSize: 72,
                            color: Colors.white,
                            onPressed: () {
                              notifier.togglePlay();
                              _revealControls();
                            },
                            icon: Icon(
                              controller.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          child: Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppTheme.accentGold,
                                  inactiveTrackColor:
                                      Colors.white.withValues(alpha: 0.25),
                                  thumbColor: AppTheme.accentGold,
                                  overlayColor: AppTheme.accentGold
                                      .withValues(alpha: 0.2),
                                ),
                                child: Slider(
                                  value: controller.value.duration.inMilliseconds ==
                                          0
                                      ? 0
                                      : (controller.value.position.inMilliseconds /
                                              controller
                                                  .value.duration.inMilliseconds)
                                          .clamp(0.0, 1.0),
                                  onChanged: (v) {
                                    final ms = (v *
                                            controller
                                                .value.duration.inMilliseconds)
                                        .round();
                                    notifier.seek(Duration(milliseconds: ms));
                                    _revealControls();
                                  },
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      _formatDuration(
                                        controller.value.position,
                                      ),
                                      style: TextStyle(
                                        color: AppTheme.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _formatDuration(
                                        controller.value.duration,
                                      ),
                                      style: TextStyle(
                                        color: AppTheme.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    tooltip: l10n.offlineSkipBack,
                                    onPressed: () {
                                      notifier.skipBackward();
                                      _revealControls();
                                    },
                                    icon: const Icon(
                                      Icons.replay_10,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    iconSize: 36,
                                    onPressed: playback.hasPrevious ||
                                            playback.repeatMode ==
                                                OfflineRepeatMode.all
                                        ? () {
                                            notifier.previous();
                                            _revealControls();
                                          }
                                        : null,
                                    icon: Icon(
                                      Icons.skip_previous_rounded,
                                      color: playback.hasPrevious ||
                                              playback.repeatMode ==
                                                  OfflineRepeatMode.all
                                          ? Colors.white
                                          : Colors.white38,
                                    ),
                                  ),
                                  IconButton(
                                    iconSize: 36,
                                    onPressed: playback.hasNext ||
                                            playback.repeatMode ==
                                                OfflineRepeatMode.all
                                        ? () {
                                            notifier.next();
                                            _revealControls();
                                          }
                                        : null,
                                    icon: Icon(
                                      Icons.skip_next_rounded,
                                      color: playback.hasNext ||
                                              playback.repeatMode ==
                                                  OfflineRepeatMode.all
                                          ? Colors.white
                                          : Colors.white38,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: l10n.offlineSkipForward,
                                    onPressed: () {
                                      notifier.skipForward();
                                      _revealControls();
                                    },
                                    icon: const Icon(
                                      Icons.forward_10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
