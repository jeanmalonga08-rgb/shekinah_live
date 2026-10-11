import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/audio/background_audio_hub.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../providers/branham_audio_playback_provider.dart';

class PredicationAudioPage extends ConsumerStatefulWidget {
  const PredicationAudioPage({
    super.key,
    required this.title,
    required this.preacher,
    required this.audioUrl,
    this.thumbnailUrl,
    this.thumbnailAsset,
    this.useBranhamQueue = false,
    this.startPlayback = true,
  });

  final String title;
  final String preacher;
  final String audioUrl;
  final String? thumbnailUrl;
  final String? thumbnailAsset;
  final bool useBranhamQueue;
  final bool startPlayback;

  @override
  ConsumerState<PredicationAudioPage> createState() =>
      _PredicationAudioPageState();
}

class _PredicationAudioPageState extends ConsumerState<PredicationAudioPage> {
  final _hub = BackgroundAudioHub.instance;
  bool _failed = false;
  bool _loading = true;

  AudioPlayer get _player => _hub.player;

  @override
  void initState() {
    super.initState();
    if (widget.startPlayback) {
      _load();
    } else {
      _loading = false;
    }
  }

  Future<void> _load() async {
    try {
      await _hub.playUri(
        id: 'stream:${widget.audioUrl}',
        url: widget.audioUrl,
        title: widget.title,
        artist: widget.preacher,
        artUrl: widget.thumbnailUrl,
      );
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // La lecture continue en arrière-plan / écran de verrouillage.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final queueState = widget.useBranhamQueue
      ? ref.watch(branhamAudioPlaybackProvider)
      : null;
    final queueNotifier = widget.useBranhamQueue
      ? ref.read(branhamAudioPlaybackProvider.notifier)
      : null;
    final title = queueState?.title ?? widget.title;
    final preacher = queueState?.subtitle ?? widget.preacher;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(l10n.audioPlaybackTitle)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          children: [
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: widget.thumbnailAsset != null
                    ? Image.asset(
                        widget.thumbnailAsset!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _coverFallback(),
                      )
                    : widget.thumbnailUrl == null
                        ? _coverFallback()
                        : CachedNetworkImage(
                        imageUrl: widget.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _coverFallback(),
                        errorWidget: (_, _, _) => _coverFallback(),
                      ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              preacher,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.goldLight,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            if (_failed)
              Text(
                l10n.mediaUnavailable,
                style: TextStyle(color: AppTheme.grey),
              )
            else if (_loading)
              CircularProgressIndicator(color: AppTheme.accentGold)
            else
              StreamBuilder<Duration?>(
                stream: _player.durationStream,
                builder: (context, durationSnap) {
                  final duration = durationSnap.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (context, positionSnap) {
                      final position = positionSnap.data ?? Duration.zero;
                      final value = duration.inMilliseconds == 0
                          ? 0.0
                          : (position.inMilliseconds / duration.inMilliseconds)
                              .clamp(0.0, 1.0);
                      return Column(
                        children: [
                          Slider(
                            value: value,
                            onChanged: duration.inMilliseconds == 0
                                ? null
                                : (v) => _hub.seek(
                                      Duration(
                                        milliseconds:
                                            (v * duration.inMilliseconds)
                                                .round(),
                                      ),
                                    ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _format(position),
                                style: TextStyle(
                                  color: AppTheme.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _format(duration),
                                style: TextStyle(
                                  color: AppTheme.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            const SizedBox(height: 8),
            if (!_failed && !_loading)
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  final processing = snapshot.data?.processingState;
                  final busy = processing == ProcessingState.loading ||
                      processing == ProcessingState.buffering;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (queueState != null) ...[
                        IconButton(
                          tooltip: l10n.offlinePreviousTrack,
                          onPressed: queueState.hasPrevious && !busy
                              ? queueNotifier!.previous
                              : null,
                          icon: const Icon(Icons.skip_previous_rounded),
                          iconSize: 36,
                        ),
                      ],
                      IconButton(
                        iconSize: 76,
                        color: AppTheme.accentGold,
                        onPressed: busy
                            ? null
                            : () => playing ? _hub.pause() : _hub.resume(),
                        icon: busy
                            ? const SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              )
                            : Icon(
                                playing
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                              ),
                      ),
                      if (queueState != null)
                        IconButton(
                          tooltip: l10n.offlineNextTrack,
                          onPressed: queueState.hasNext && !busy
                              ? queueNotifier!.next
                              : null,
                          icon: const Icon(Icons.skip_next_rounded),
                          iconSize: 36,
                        ),
                    ],
                  );
                },
              ),
            const Spacer(),
          ],
        ),
      ),
    );
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

  String _format(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }
}
