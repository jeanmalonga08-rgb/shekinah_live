import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/cantique.dart';
import '../../domain/entities/multimedia_video.dart';
import '../../domain/entities/offline_media.dart';
import '../../domain/entities/pending_offline_download.dart';
import '../../domain/entities/predication.dart';
import '../../l10n/app_localizations.dart';
import '../providers/offline_download_progress_provider.dart';
import '../providers/offline_media_provider.dart';
import 'offline_download_helper.dart';
import 'offline_playback_helper.dart';

/// Boutons lecture / téléchargement compacts pour les listes.
class MediaListActions extends ConsumerWidget {
  const MediaListActions._({
    required this.category,
    required this.sourceId,
    required this.title,
    required this.subtitle,
    required this.hasAudio,
    required this.hasVideo,
    this.audioUrl,
    this.videoId,
    this.thumbnailUrl,
    this.cantiqueVideoProvider,
    this.videoEmbedUrl,
    this.cantique,
    this.predication,
    this.multimediaVideo,
  });

  factory MediaListActions.cantique(AppLocalizations l10n, Cantique cantique) {
    return MediaListActions._(
      category: OfflineMediaCategory.cantique,
      sourceId: cantique.id,
      title: cantiqueDisplayTitle(l10n, cantique),
      subtitle: cantique.displaySubtitle,
      hasAudio: cantique.hasAudio,
      hasVideo: cantique.hasVideo,
      audioUrl: cantique.audioUrl,
      videoId: cantique.videoId,
      thumbnailUrl: cantique.coverUrl,
      cantiqueVideoProvider: cantique.videoProvider,
      videoEmbedUrl: cantique.videoEmbedUrl,
      cantique: cantique,
    );
  }

  factory MediaListActions.predication(
    AppLocalizations l10n,
    Predication predication,
  ) {
    return MediaListActions._(
      category: OfflineMediaCategory.predication,
      sourceId: predication.id,
      title: predicationDisplayTitle(l10n, predication),
      subtitle: predication.displayPreacher,
      hasAudio: predication.hasAudio,
      hasVideo: predication.hasVideo,
      audioUrl: predication.primaryAudioUrl,
      videoId: predication.primaryVideoId,
      thumbnailUrl: predication.thumbnailUrl,
      predication: predication,
    );
  }

  factory MediaListActions.multimedia(
    AppLocalizations l10n,
    MultimediaVideo video,
  ) {
    return MediaListActions._(
      category: OfflineMediaCategory.documentaire,
      sourceId: video.id,
      title: video.title,
      subtitle: multimediaVideoCategoryLabel(l10n, video.category),
      hasAudio: false,
      hasVideo: true,
      videoId: video.videoId,
      thumbnailUrl: video.defaultThumbnailUrl,
      multimediaVideo: video,
    );
  }

  final OfflineMediaCategory category;
  final String sourceId;
  final String title;
  final String subtitle;
  final bool hasAudio;
  final bool hasVideo;
  final String? audioUrl;
  final String? videoId;
  final String? thumbnailUrl;
  final CantiqueVideoProvider? cantiqueVideoProvider;
  final String? videoEmbedUrl;
  final Cantique? cantique;
  final Predication? predication;
  final MultimediaVideo? multimediaVideo;

  bool get _canPlay => hasVideo || hasAudio;
  bool get _canDownload => hasVideo || hasAudio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_canPlay && !_canDownload) return const SizedBox.shrink();

    ref.watch(offlineMediaProvider);
    final manager = ref.watch(offlineDownloadManagerProvider);
    final l10n = context.l10n;

    final audioOffline = hasAudio &&
        hasOfflineMedia(
          ref,
          category: category,
          sourceId: sourceId,
          format: OfflineMediaFormat.audio,
        );
    final videoOffline = hasVideo &&
        hasOfflineMedia(
          ref,
          category: category,
          sourceId: sourceId,
          format: OfflineMediaFormat.video,
        );
    final needsAudioDownload = hasAudio && !audioOffline;
    final needsVideoDownload = hasVideo && !videoOffline;
    final canStillDownload = needsAudioDownload || needsVideoDownload;

    final audioDownloading = manager.matchesActive(
      category: category,
      sourceId: sourceId,
      format: OfflineMediaFormat.audio,
    );
    final videoDownloading = manager.matchesActive(
      category: category,
      sourceId: sourceId,
      format: OfflineMediaFormat.video,
    );
    final audioFailed = manager.matchesError(
      category: category,
      sourceId: sourceId,
      format: OfflineMediaFormat.audio,
    );
    final videoFailed = manager.matchesError(
      category: category,
      sourceId: sourceId,
      format: OfflineMediaFormat.video,
    );
    final anyDownloading = audioDownloading || videoDownloading;
    final anyFailed = audioFailed || videoFailed;
    final showDownload =
        _canDownload && (canStillDownload || anyFailed || anyDownloading);

    final playTooltip =
        hasVideo ? l10n.mediaPlayVideo : l10n.mediaPlayAudio;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_canPlay)
          _ActionIcon(
            tooltip: playTooltip,
            icon: hasVideo ? Icons.play_circle_outline : Icons.headphones_outlined,
            color: AppTheme.brandAccent,
            onPressed: () => _play(context, ref),
          ),
        if (showDownload)
          _ActionIcon(
            tooltip: anyFailed ? l10n.downloadResume : l10n.downloadInApp,
            icon: anyFailed
                ? Icons.play_arrow_rounded
                : Icons.download_for_offline_outlined,
            color: anyFailed ? Colors.orangeAccent : AppTheme.accentOnSurface,
            onPressed: anyFailed
                ? () => _retry(context, ref, manager)
                : () => _download(
                      context,
                      ref,
                      hasAudio: needsAudioDownload,
                      hasVideo: needsVideoDownload,
                    ),
            loading: anyDownloading,
          ),
      ],
    );
  }

  void _retry(
    BuildContext context,
    WidgetRef ref,
    OfflineDownloadManagerState manager,
  ) {
    final audio = manager.jobFor(
      category: category,
      sourceId: sourceId,
      format: OfflineMediaFormat.audio,
    );
    final video = manager.jobFor(
      category: category,
      sourceId: sourceId,
      format: OfflineMediaFormat.video,
    );
    final job = (audio?.canResume == true)
        ? audio
        : (video?.canResume == true)
            ? video
            : null;
    retryFailedOfflineDownload(
      context,
      ref,
      downloadId: job?.id,
      pending: job?.pending,
    );
  }

  void _play(BuildContext context, WidgetRef ref) {
    if (hasVideo) {
      playPredicationVideoSmart(
        context,
        ref,
        sourceId: sourceId,
        title: title,
        videoId: videoId,
        embedUrl: multimediaVideo?.embedUrl ?? videoEmbedUrl,
        cantiqueProvider: cantiqueVideoProvider,
        category: category,
        predicationType: predication?.type,
        cantiqueCategory: cantique?.category,
        multimediaCategory: multimediaVideo?.category,
        date: predication?.date ?? multimediaDateOf(multimediaVideo),
      );
      return;
    }
    playPredicationAudioSmart(
      context,
      ref,
      sourceId: sourceId,
      title: title,
      subtitle: subtitle,
      audioUrl: audioUrl,
      thumbnailUrl: thumbnailUrl,
      category: category,
    );
  }

  void _download(
    BuildContext context,
    WidgetRef ref, {
    required bool hasAudio,
    required bool hasVideo,
  }) {
    showOfflineFormatPicker(
      context,
      hasAudio: hasAudio,
      hasVideo: hasVideo,
      onAudio: () => _downloadAudio(context, ref),
      onVideo: () => _downloadVideo(context, ref),
    );
  }

  void _downloadAudio(BuildContext context, WidgetRef ref) {
    final c = cantique;
    final p = predication;
    if (c != null) {
      saveCantiqueAudioOffline(context, ref, cantique: c);
      return;
    }
    if (p != null) {
      savePredicationAudioOffline(context, ref, predication: p);
    }
  }

  void _downloadVideo(BuildContext context, WidgetRef ref) {
    final c = cantique;
    final p = predication;
    final m = multimediaVideo;
    if (c != null) {
      saveCantiqueVideoOffline(context, ref, cantique: c);
      return;
    }
    if (p != null) {
      savePredicationVideoOffline(context, ref, predication: p);
      return;
    }
    if (m != null) {
      saveVimeoVideoOffline(
        context,
        ref,
        videoId: m.videoId,
        sourceId: m.id,
        title: m.title,
        subtitle: multimediaVideoCategoryLabel(context.l10n, m.category),
        category: OfflineMediaCategory.documentaire,
        thumbnailUrl: m.defaultThumbnailUrl,
      );
    }
  }
}

DateTime? multimediaDateOf(MultimediaVideo? video) {
  final raw = video?.dateLabel?.trim();
  if (raw == null || raw.isEmpty) return null;
  final iso = DateTime.tryParse(raw);
  if (iso != null) return iso;
  final dmy =
      RegExp(r'^(\d{1,2})[./-](\d{1,2})[./-](\d{4})$').firstMatch(raw);
  if (dmy == null) return null;
  final d = int.tryParse(dmy.group(1)!);
  final m = int.tryParse(dmy.group(2)!);
  final y = int.tryParse(dmy.group(3)!);
  if (d == null || m == null || y == null) return null;
  return DateTime(y, m.clamp(1, 12), d.clamp(1, 31));
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.loading = false,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: loading ? null : onPressed,
      icon: loading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          : Icon(icon, size: 18, color: color),
    );
  }
}

/// Indique si un élément de liste a un téléchargement échoué.
bool listItemDownloadFailed(
  OfflineDownloadManagerState manager, {
  required OfflineMediaCategory category,
  required String sourceId,
}) {
  return manager.jobs.any(
    (j) =>
        j.isError &&
        j.pending.category == category &&
        j.pending.sourceId == sourceId,
  );
}

PendingOfflineDownload? listItemFailedPending(
  OfflineDownloadManagerState manager, {
  required OfflineMediaCategory category,
  required String sourceId,
}) {
  for (final job in manager.jobs) {
    if (job.isError &&
        job.pending.category == category &&
        job.pending.sourceId == sourceId) {
      return job.pending;
    }
  }
  return null;
}
