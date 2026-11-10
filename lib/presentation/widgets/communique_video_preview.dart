import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_theme.dart';
import 'communique_video_controller_stub.dart'
    if (dart.library.io) 'communique_video_controller_io.dart'
    if (dart.library.html) 'communique_video_controller_web.dart' as platform;

class CommuniqueVideoPreview extends StatefulWidget {
  const CommuniqueVideoPreview({
    required this.source,
    this.isLocal = false,
    super.key,
  });

  final String source;
  final bool isLocal;

  @override
  State<CommuniqueVideoPreview> createState() => _CommuniqueVideoPreviewState();
}

class _CommuniqueVideoPreviewState extends State<CommuniqueVideoPreview> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialized;

  @override
  void initState() {
    super.initState();
    _controller = platform.createCommuniqueVideoController(
      widget.source,
      widget.isLocal,
    );
    _initialized = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          color: Colors.black,
          constraints: const BoxConstraints(maxHeight: 300),
          child: FutureBuilder<void>(
            future: _initialized,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SizedBox(
                  height: 180,
                  child: Center(
                    child: Icon(Icons.video_file_outlined,
                        color: Colors.white70, size: 40),
                  ),
                );
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    IconButton.filledTonal(
                      tooltip: _controller.value.isPlaying
                          ? 'Mettre en pause'
                          : 'Lire la vidéo',
                      onPressed: () => setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      }),
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.65),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: AppTheme.accentGold,
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
}
