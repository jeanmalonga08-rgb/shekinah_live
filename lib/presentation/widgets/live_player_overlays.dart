import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/sht_widgets.dart';

class LiveFullscreenPage extends StatefulWidget {
  const LiveFullscreenPage({
    super.key,
    required this.controller,
    required this.isLive,
  });

  final WebViewController controller;
  final bool isLive;

  @override
  State<LiveFullscreenPage> createState() => _LiveFullscreenPageState();
}

class _LiveFullscreenPageState extends State<LiveFullscreenPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: WebViewWidget(controller: widget.controller),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
              ),
            ),
          ),
          if (widget.isLive)
            const SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: LiveBadge(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LiveFloatingPlayer extends StatefulWidget {
  const LiveFloatingPlayer({
    super.key,
    required this.onExpand,
    required this.onClose,
    required this.userElapsedLabel,
    required this.isPlaying,
    required this.isAudio,
    required this.onTogglePlay,
    this.webController,
  });

  final VoidCallback onExpand;
  final VoidCallback onClose;
  final String userElapsedLabel;
  final bool isPlaying;
  final bool isAudio;
  final VoidCallback onTogglePlay;
  final WebViewController? webController;

  @override
  State<LiveFloatingPlayer> createState() => _LiveFloatingPlayerState();
}

class _LiveFloatingPlayerState extends State<LiveFloatingPlayer> {
  Offset _position = const Offset(16, 120);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final hasVideo = !widget.isAudio && widget.webController != null;
    final panelWidth = hasVideo ? 240.0 : 168.0;

    return Positioned(
      left: _position.dx.clamp(8, size.width - panelWidth - 8),
      top: _position.dy.clamp(80, size.height - (hasVideo ? 220 : 120)),
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        child: Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.surface,
          child: Container(
            width: panelWidth,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.live.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasVideo) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: WebViewWidget(controller: widget.webController!),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: const LiveBadge(),
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      onPressed: widget.onClose,
                      icon: Icon(Icons.close, size: 18, color: AppTheme.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.isAudio
                        ? context.l10n.liveFloatingAudio
                        : context.l10n.liveFloatingVideo,
                    maxLines: 1,
                    style: TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.userElapsedLabel,
                    maxLines: 1,
                    style: TextStyle(
                      color: AppTheme.goldLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isAudio)
                      IconButton(
                        onPressed: widget.onTogglePlay,
                        icon: Icon(
                          widget.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    IconButton(
                      onPressed: widget.onExpand,
                      icon: Icon(
                        Icons.open_in_full,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
