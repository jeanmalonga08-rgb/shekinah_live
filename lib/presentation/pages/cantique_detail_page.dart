import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/cantique.dart';
import '../../domain/entities/offline_media.dart';
import '../providers/offline_media_provider.dart';
import '../providers/offline_download_progress_provider.dart';
import '../widgets/offline_available_banner.dart';
import '../widgets/offline_download_helper.dart';
import '../widgets/offline_playback_helper.dart';
import '../widgets/content_share_helper.dart';
import '../widgets/media_info_chips.dart';

class CantiqueDetailPage extends ConsumerWidget {
  const CantiqueDetailPage({super.key, required this.cantique});

  final Cantique cantique;

  bool get _canDownloadVideo => cantique.hasVideo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref.watch(offlineMediaProvider);
    final manager = ref.watch(offlineDownloadManagerProvider);
    final hasOfflineAudio = hasOfflineMedia(
      ref,
      category: OfflineMediaCategory.cantique,
      sourceId: cantique.id,
      format: OfflineMediaFormat.audio,
    );
    final hasOfflineVideo = hasOfflineMedia(
      ref,
      category: OfflineMediaCategory.cantique,
      sourceId: cantique.id,
      format: OfflineMediaFormat.video,
    );
    final audioDownloadProgress = manager.jobFor(
      category: OfflineMediaCategory.cantique,
      sourceId: cantique.id,
      format: OfflineMediaFormat.audio,
    );
    final videoDownloadProgress = manager.jobFor(
      category: OfflineMediaCategory.cantique,
      sourceId: cantique.id,
      format: OfflineMediaFormat.video,
    );
    final audioDownloading = audioDownloadProgress?.isActive ?? false;
    final videoDownloading = videoDownloadProgress?.isActive ?? false;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppTheme.background,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            actionsIconTheme: const IconThemeData(color: Colors.white),
            leading: _DetailAppBarIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            actions: [
              _DetailAppBarIconButton(
                icon: Icons.share_outlined,
                tooltip: l10n.share,
                onPressed: () => shareCantique(context, cantique),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  cantique.coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: cantique.coverUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => _heroFallback(),
                          errorWidget: (_, _, _) => _heroFallback(),
                        )
                      : _heroFallback(),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xCC0A1628),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Row(
                      children: [
                        if (cantique.number > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentOnSurface.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.cantiquesNumber(cantique.number),
                              style: TextStyle(color: AppTheme.onAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        if (cantique.number > 0) const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            cantique.category,
                            style: TextStyle(color: AppTheme.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cantiqueDisplayTitle(l10n, cantique),
                    style: TextStyle(color: AppTheme.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    cantique.displaySubtitle,
                    style: TextStyle(
                      color: AppTheme.goldOnSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  OfflineAvailableBanner(
                    hasOfflineAudio: hasOfflineAudio,
                    hasOfflineVideo: hasOfflineVideo,
                  ),
                  OnlineMediaInfoSection(
                    videoId: cantique.videoId,
                    audioUrl: cantique.audioUrl,
                    hasVideo: cantique.hasVideo,
                    hasAudio: cantique.hasAudio,
                  ),
                  Text(
                    l10n.mediaListenWatch,
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.mediaStreamingOrOffline,
                    style: TextStyle(color: AppTheme.grey, fontSize: 12.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MediaAction(
                          icon: Icons.play_circle_fill,
                          label: l10n.mediaPlayVideo,
                          subtitle: playSubtitle(
                            l10n: l10n,
                            hasMedia: cantique.hasVideo,
                            hasOffline: hasOfflineVideo,
                            onlineLabel: l10n.mediaStreamingVideo,
                          ),
                          enabled: cantique.hasVideo,
                          highlighted: hasOfflineVideo,
                          onTap: () => _playVideo(context, ref),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MediaAction(
                          icon: Icons.headphones,
                          label: l10n.mediaPlayAudio,
                          subtitle: playSubtitle(
                            l10n: l10n,
                            hasMedia: cantique.hasAudio,
                            hasOffline: hasOfflineAudio,
                            onlineLabel: l10n.mediaStreamingAudio,
                          ),
                          enabled: cantique.hasAudio,
                          highlighted: hasOfflineAudio,
                          onTap: () => _playAudio(context, ref),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    l10n.downloadInApp,
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (hasOfflineAudio || hasOfflineVideo)
                        ? l10n.downloadOfflineSaved
                        : l10n.downloadOfflineTabHint,
                    style: TextStyle(color: AppTheme.grey, fontSize: 12.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MediaAction(
                          icon: hasOfflineAudio
                              ? Icons.check_circle
                              : Icons.offline_pin_outlined,
                          label: l10n.audio,
                          subtitle: audioDownloading
                              ? (audioDownloadProgress?.statusLabel(l10n) ??
                                  l10n.downloadProgressActive)
                              : !cantique.hasAudio
                                  ? l10n.unavailable
                                  : hasOfflineAudio
                                      ? l10n.downloadAvailableOffline
                                      : l10n.downloadAudioDataHint,
                          enabled: cantique.hasAudio &&
                              !hasOfflineAudio &&
                              !audioDownloading,
                          highlighted: hasOfflineAudio,
                          progress: audioDownloading
                              ? (audioDownloadProgress?.progress ?? 0)
                              : null,
                          onTap: () => saveCantiqueAudioOffline(
                            context,
                            ref,
                            cantique: cantique,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MediaAction(
                          icon: hasOfflineVideo
                              ? Icons.check_circle
                              : Icons.download_for_offline_outlined,
                          label: l10n.video,
                          subtitle: videoDownloading
                              ? (videoDownloadProgress?.statusLabel(l10n) ??
                                  l10n.downloadProgressActive)
                              : downloadSubtitle(
                                  l10n: l10n,
                                  hasMedia: cantique.hasVideo,
                                  hasOffline: hasOfflineVideo,
                                ),
                          enabled: _canDownloadVideo &&
                              !hasOfflineVideo &&
                              !videoDownloading,
                          highlighted: hasOfflineVideo,
                          progress: videoDownloading
                              ? (videoDownloadProgress?.progress ?? 0)
                              : null,
                          onTap: () => saveCantiqueVideoOffline(
                            context,
                            ref,
                            cantique: cantique,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (cantique.hasVideo) ...[
                    const SizedBox(height: 12),
                    _MediaAction(
                      landscape: true,
                      icon: hasOfflineAudio
                          ? Icons.check_circle
                          : Icons.audiotrack_rounded,
                      label: l10n.downloadConvertToAudio,
                      subtitle: audioDownloading
                          ? (audioDownloadProgress?.statusLabel(l10n) ??
                              l10n.downloadProgressActive)
                          : hasOfflineAudio
                              ? l10n.downloadAvailableOffline
                              : l10n.downloadConvertToAudioHint,
                      enabled: !hasOfflineAudio && !audioDownloading,
                      highlighted: hasOfflineAudio,
                      progress: audioDownloading
                          ? (audioDownloadProgress?.progress ?? 0)
                          : null,
                      onTap: () {
                        final videoId = cantique.videoId;
                        if (videoId == null) return;
                        saveVideoAsAudioOffline(
                          context,
                          ref,
                          videoId: videoId,
                          sourceId: cantique.id,
                          title: cantiqueDisplayTitle(l10n, cantique),
                          subtitle: cantique.displaySubtitle,
                          category: OfflineMediaCategory.cantique,
                          thumbnailUrl: cantique.coverUrl,
                          provider: cantique.videoProvider ??
                              CantiqueVideoProvider.vimeo,
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: Text(
                        MaterialLocalizations.of(context).backButtonTooltip,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroFallback() {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.headerGradient),
      alignment: Alignment.center,
      child: Image.asset(
        AppConstants.logoAsset,
        width: 88,
        height: 88,
        errorBuilder: (_, _, _) => Icon(
          Icons.music_note,
          color: AppTheme.accentOnSurface,
          size: 56,
        ),
      ),
    );
  }

  void _showUnavailable(BuildContext context) {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.mediaUnavailable,
            style: const TextStyle(color: AppTheme.snackBarForeground),
          ),
          backgroundColor: AppTheme.snackBarBackground,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _playVideo(BuildContext context, WidgetRef ref) {
    if (!cantique.hasVideo) {
      _showUnavailable(context);
      return;
    }
    playPredicationVideoSmart(
      context,
      ref,
      sourceId: cantique.id,
      title: cantiqueDisplayTitle(context.l10n, cantique),
      videoId: cantique.videoId,
      embedUrl: cantique.videoEmbedUrl,
      cantiqueProvider: cantique.videoProvider,
      category: OfflineMediaCategory.cantique,
      cantiqueCategory: cantique.category,
    );
  }

  void _playAudio(BuildContext context, WidgetRef ref) {
    if (!cantique.hasAudio) {
      _showUnavailable(context);
      return;
    }
    playPredicationAudioSmart(
      context,
      ref,
      sourceId: cantique.id,
      title: cantiqueDisplayTitle(context.l10n, cantique),
      subtitle: cantique.displaySubtitle,
      audioUrl: cantique.audioUrl,
      thumbnailUrl: cantique.coverUrl,
      category: OfflineMediaCategory.cantique,
    );
  }
}

class _MediaAction extends StatelessWidget {
  const _MediaAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
    this.highlighted = false,
    this.progress,
    this.landscape = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;
  final bool highlighted;
  final double? progress;
  final bool landscape;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showProgress = progress != null && progress! >= 0;
    final interactive = enabled;

    final iconWidget = showProgress
        ? SizedBox(
            width: landscape ? 24 : 28,
            height: landscape ? 24 : 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.accentOnSurface,
              value: progress! > 0 ? progress : null,
            ),
          )
        : Icon(
            icon,
            color: interactive || highlighted
                ? AppTheme.accentOnSurface
                : AppTheme.muted,
            size: landscape ? 24 : 28,
          );

    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: interactive || highlighted ? AppTheme.white : AppTheme.grey,
            fontWeight: FontWeight.w700,
            fontSize: landscape ? 15 : 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: highlighted ? AppTheme.goldOnSurface : AppTheme.muted,
            fontSize: landscape ? 12 : 11.5,
            fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );

    return Material(
      color: interactive || highlighted
          ? AppTheme.surface
          : AppTheme.surface.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: interactive
            ? onTap
            : () {
                final message = highlighted
                    ? l10n.downloadAlreadySaved
                    : showProgress
                        ? l10n.downloadProgressActive
                        : l10n.mediaUnavailable;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        message,
                        style: const TextStyle(color: AppTheme.snackBarForeground),
                      ),
                      backgroundColor: AppTheme.snackBarBackground,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: landscape ? double.infinity : null,
          height: landscape ? null : 126,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlighted || showProgress
                  ? AppTheme.accentOnSurface.withValues(alpha: 0.55)
                  : interactive
                      ? AppTheme.accentOnSurface.withValues(alpha: 0.28)
                      : Colors.white10,
            ),
          ),
          child: landscape
              ? Row(
                  children: [
                    iconWidget,
                    const SizedBox(width: 14),
                    Expanded(child: texts),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconWidget,
                    const Spacer(),
                    texts,
                  ],
                ),
        ),
      ),
    );
  }
}

class _DetailAppBarIconButton extends StatelessWidget {
  const _DetailAppBarIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
