import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_theme.dart';

/// Lecteur plein écran pour les vidéos Temple Moriah (Ravage & Gloire).
class MoriahTempleVideoPage extends StatefulWidget {
  const MoriahTempleVideoPage({
    super.key,
    required this.videoAsset,
    required this.title,
    this.subtitle,
  });

  final String videoAsset;
  final String title;
  final String? subtitle;

  @override
  State<MoriahTempleVideoPage> createState() => _MoriahTempleVideoPageState();
}

class _MoriahTempleVideoPageState extends State<MoriahTempleVideoPage> {
  VideoPlayerController? _controller;
  Timer? _positionTimer;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final controller = VideoPlayerController.asset(widget.videoAsset);
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setVolume(1);
      await controller.play();
      _startPositionUpdates();
      _scheduleHideControls();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  void _startPositionUpdates() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() {});
    });
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() => _showControls = false);
      }
    });
  }

  void _revealControls() {
    setState(() => _showControls = true);
    _scheduleHideControls();
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      controller.pause();
      setState(() => _showControls = true);
      _hideControlsTimer?.cancel();
    } else {
      controller.play();
      _scheduleHideControls();
    }
    setState(() {});
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _hideControlsTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final initialized =
        controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.white,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: initialized
          ? Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _revealControls,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: _showControls ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: IgnorePointer(
                            ignoring: !_showControls,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                              ),
                              child: Center(
                                child: IconButton(
                                  iconSize: 72,
                                  color: Colors.white,
                                  onPressed: _togglePlay,
                                  icon: Icon(
                                    controller.value.isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_filled,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _showControls ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.subtitle != null) ...[
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              color: AppTheme.softWhite,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppTheme.accentGold,
                            inactiveTrackColor:
                                Colors.white.withValues(alpha: 0.25),
                            thumbColor: AppTheme.accentGold,
                            overlayColor:
                                AppTheme.accentGold.withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: controller.value.duration.inMilliseconds == 0
                                ? 0
                                : (controller.value.position.inMilliseconds /
                                        controller
                                            .value.duration.inMilliseconds)
                                    .clamp(0.0, 1.0),
                            onChanged: (v) {
                              final target = Duration(
                                milliseconds: (v *
                                        controller
                                            .value.duration.inMilliseconds)
                                    .round(),
                              );
                              controller.seekTo(target);
                              _revealControls();
                            },
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _formatDuration(controller.value.position),
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDuration(controller.value.duration),
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(color: AppTheme.accentGold),
            ),
    );
  }
}
