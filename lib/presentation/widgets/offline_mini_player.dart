import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/offline_media.dart';
import '../pages/offline_media_player_page.dart';
import '../providers/offline_playback_provider.dart';

class OfflineMiniPlayer extends ConsumerWidget {
  const OfflineMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(offlinePlaybackProvider);
    if (!playback.isActive || !playback.showMiniPlayer) {
      return const SizedBox.shrink();
    }

    final item = playback.currentItem;
    if (item == null) return const SizedBox.shrink();

    final notifier = ref.read(offlinePlaybackProvider.notifier);

    return Material(
      color: AppTheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: () {
            notifier.openFullPlayer();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OfflineMediaPlayerPage(
                  playlist: playback.playlist,
                  initialIndex: playback.index,
                ),
              ),
            );
          },
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.accentOnSurface.withValues(alpha: 0.35)),
              ),
            ),
            child: Row(
              children: [
                _Thumb(item: item),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppTheme.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.offlinePreviousTrack,
                  onPressed: playback.hasPrevious
                      ? () => notifier.previous()
                      : null,
                  icon: Icon(
                    Icons.skip_previous_rounded,
                    color: AppTheme.white,
                  ),
                ),
                IconButton(
                  tooltip: playback.isPlaying
                      ? context.l10n.offlinePause
                      : context.l10n.offlinePlay,
                  onPressed: () => notifier.togglePlay(),
                  icon: Icon(
                    playback.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppTheme.accentGold,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.offlineNextTrack,
                  onPressed: playback.hasNext ? () => notifier.next() : null,
                  icon: Icon(
                    Icons.skip_next_rounded,
                    color: AppTheme.white,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.offlineStop,
                  onPressed: () => notifier.stop(),
                  icon: Icon(Icons.close, color: AppTheme.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.item});

  final OfflineMediaItem item;

  @override
  Widget build(BuildContext context) {
    final icon = item.format == OfflineMediaFormat.audio
        ? Icons.headphones
        : Icons.videocam;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 44,
        height: 44,
        child: item.thumbnailUrl == null
            ? _fallback(icon)
            : CachedNetworkImage(
                imageUrl: item.thumbnailUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => _fallback(icon),
              ),
      ),
    );
  }

  Widget _fallback(IconData icon) {
    return Container(
      color: AppTheme.accentOnSurface.withValues(alpha: 0.14),
      alignment: Alignment.center,
      child: item.format == OfflineMediaFormat.audio
          ? Image.asset(
              AppConstants.logoAsset,
              width: 24,
              height: 24,
              errorBuilder: (_, _, _) =>
                  Icon(icon, color: AppTheme.accentGold, size: 20),
            )
          : Icon(icon, color: AppTheme.accentGold, size: 20),
    );
  }
}
