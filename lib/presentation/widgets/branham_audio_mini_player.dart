import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../pages/predication_audio_page.dart';
import '../providers/branham_audio_playback_provider.dart';

class BranhamAudioMiniPlayer extends ConsumerWidget {
  const BranhamAudioMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(branhamAudioPlaybackProvider);
    if (!playback.isActive || playback.title == null || playback.audioUrl == null) {
      return const SizedBox.shrink();
    }

    final notifier = ref.read(branhamAudioPlaybackProvider.notifier);
    return Material(
      color: AppTheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: () => _openFullPlayer(context, playback),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.accentOnSurface.withValues(alpha: 0.35),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.graphic_eq_rounded, color: AppTheme.accentOnSurface),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playback.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        playback.subtitle ?? 'William Branham',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppTheme.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (playback.hasPrevious)
                  IconButton(
                    tooltip: context.l10n.offlinePreviousTrack,
                    onPressed: notifier.previous,
                    icon: Icon(
                      Icons.skip_previous_rounded,
                      color: AppTheme.white,
                    ),
                  ),
                IconButton(
                  tooltip: context.l10n.offlinePreviousTrack,
                  onPressed: playback.hasPrevious && !playback.isLoading
                      ? notifier.previous
                      : null,
                  icon: Icon(Icons.skip_previous_rounded, color: AppTheme.white),
                ),
                IconButton(
                  tooltip: playback.isPlaying
                      ? context.l10n.offlinePause
                      : context.l10n.offlinePlay,
                  onPressed: playback.isLoading ? null : notifier.togglePlay,
                  icon: Icon(
                    playback.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppTheme.accentGold,
                  ),
                ),
                if (playback.hasNext)
                  IconButton(
                    tooltip: context.l10n.offlineNextTrack,
                    onPressed: notifier.next,
                    icon: Icon(
                      Icons.skip_next_rounded,
                      color: AppTheme.white,
                    ),
                  ),
                IconButton(
                  tooltip: context.l10n.offlineNextTrack,
                  onPressed: playback.hasNext && !playback.isLoading
                      ? notifier.next
                      : null,
                  icon: Icon(Icons.skip_next_rounded, color: AppTheme.white),
                ),
                IconButton(
                  tooltip: context.l10n.offlineStop,
                  onPressed: notifier.stop,
                  icon: Icon(Icons.close, color: AppTheme.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openFullPlayer(
    BuildContext context,
    BranhamAudioPlaybackState playback,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PredicationAudioPage(
          title: playback.title!,
          preacher: playback.subtitle ?? 'William Branham',
          audioUrl: playback.audioUrl!,
          thumbnailAsset: 'assets/images/wmb.jpg',
          useBranhamQueue: true,
          startPlayback: false,
        ),
      ),
    );
  }
}