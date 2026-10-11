import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/network/notifications_api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/audio_conversion_job.dart';
import '../../domain/entities/offline_media.dart';
import '../../domain/entities/pending_offline_download.dart';
import '../../domain/entities/predication.dart';
import '../../domain/entities/cantique.dart';
import '../providers/audio_conversion_manager_provider.dart';
import '../providers/audio_conversion_provider.dart';
import '../providers/offline_download_progress_provider.dart';
import '../providers/predication_provider.dart';

Future<void> savePredicationAudioOffline(
  BuildContext context,
  WidgetRef ref, {
  required Predication predication,
  OfflineMediaCategory category = OfflineMediaCategory.predication,
}) async {
  final url = predication.primaryAudioUrl;
  if (url == null) {
    _snack(context, context.l10n.downloadAudioUnavailable);
    return;
  }
  await _enqueueDownload(
    context,
    ref,
    PendingOfflineDownload(
      category: category,
      format: OfflineMediaFormat.audio,
      sourceId: predication.id,
      title: predicationDisplayTitle(context.l10n, predication),
      subtitle: predication.displayPreacher,
      url: url,
      thumbnailUrl: predication.thumbnailUrl,
    ),
  );
}

Future<void> saveAudioUrlOffline(
  BuildContext context,
  WidgetRef ref, {
  required String sourceId,
  required String title,
  required String subtitle,
  required String url,
  required String fileExtension,
  OfflineMediaCategory category = OfflineMediaCategory.predication,
  String? thumbnailUrl,
}) async {
  if (url.trim().isEmpty) {
    _snack(context, context.l10n.downloadAudioUnavailable);
    return;
  }

  await _enqueueDownload(
    context,
    ref,
    PendingOfflineDownload(
      category: category,
      format: OfflineMediaFormat.audio,
      sourceId: sourceId,
      title: title,
      subtitle: subtitle,
      url: url,
      fileExtension: fileExtension,
      thumbnailUrl: thumbnailUrl,
    ),
  );
}

Future<void> savePredicationVideoOffline(
  BuildContext context,
  WidgetRef ref, {
  required Predication predication,
  OfflineMediaCategory category = OfflineMediaCategory.predication,
}) async {
  final videoId = predication.primaryVideoId;
  if (videoId == null) {
    _snack(context, context.l10n.downloadVideoUnavailable);
    return;
  }
  await saveVimeoVideoOffline(
    context,
    ref,
    videoId: videoId,
    sourceId: predication.id,
    title: predicationDisplayTitle(context.l10n, predication),
    subtitle: predication.displayPreacher,
    category: category,
    thumbnailUrl: predication.thumbnailUrl,
  );
}

Future<void> saveVimeoVideoOffline(
  BuildContext context,
  WidgetRef ref, {
  required String videoId,
  required String sourceId,
  required String title,
  required String subtitle,
  required OfflineMediaCategory category,
  String? thumbnailUrl,
}) async {
  final pageContext = context;
  final pageRef = ref;

  showModalBottomSheet<void>(
    context: pageContext,
    backgroundColor: AppTheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.65;
      return Consumer(
        builder: (sheetCtx, sheetRef, _) {
          final l10n = sheetCtx.l10n;
          final asyncDownloads = sheetRef.watch(videoDownloadsProvider(videoId));
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: asyncDownloads.when(
                  loading: () => const SizedBox(
                    height: 140,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => Text(
                    l10n.downloadQualitiesUnavailable,
                    style: TextStyle(color: AppTheme.grey),
                  ),
                  data: (options) {
                    final downloadable =
                        options.where((o) => o.url.trim().isNotEmpty).toList();
                    if (downloadable.isEmpty) {
                      return Text(
                        l10n.downloadQualitiesUnavailable,
                        style: TextStyle(color: AppTheme.grey),
                      );
                    }
                    final dataSaver = pickDataSaverVideoOption(downloadable);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.downloadInApp,
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.downloadChooseQuality,
                          style: TextStyle(color: AppTheme.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.data_saver_on_outlined,
                            color: AppTheme.accentGold,
                          ),
                          title: Text(
                            l10n.downloadDataSaver,
                            style: TextStyle(
                              color: AppTheme.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            dataSaver.sizeBytes > 0
                                ? '${l10n.downloadDataSaverHint} · ${offlineSizeLabel(l10n, dataSaver.sizeBytes)}'
                                : l10n.downloadDataSaverHint,
                            style: TextStyle(
                              color: AppTheme.grey,
                              fontSize: 12.5,
                            ),
                          ),
                          onTap: () async {
                            Navigator.pop(sheetContext);
                            await _enqueueDownload(
                              pageContext,
                              pageRef,
                              PendingOfflineDownload(
                                category: category,
                                format: OfflineMediaFormat.video,
                                sourceId: sourceId,
                                title: title,
                                subtitle: subtitle,
                                url: dataSaver.url,
                                thumbnailUrl: thumbnailUrl,
                                durationSeconds: dataSaver.durationSeconds,
                                expectedSizeBytes: dataSaver.sizeBytes > 0
                                    ? dataSaver.sizeBytes
                                    : null,
                              ),
                            );
                          },
                        ),
                        const Divider(height: 16),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: downloadable.length,
                            itemBuilder: (_, i) {
                              final option = downloadable[i];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.download_for_offline_outlined,
                                  color: AppTheme.accentGold,
                                ),
                                title: Text(
                                  option.label,
                                  style: TextStyle(color: AppTheme.white),
                                ),
                                subtitle: option.sizeBytes > 0
                                    ? Text(
                                        offlineSizeLabel(
                                          l10n,
                                          option.sizeBytes,
                                        ),
                                        style: TextStyle(
                                          color: AppTheme.grey,
                                          fontSize: 12.5,
                                        ),
                                      )
                                    : null,
                                onTap: () async {
                                  Navigator.pop(sheetContext);
                                  await _enqueueDownload(
                                    pageContext,
                                    pageRef,
                                    PendingOfflineDownload(
                                      category: category,
                                      format: OfflineMediaFormat.video,
                                      sourceId: sourceId,
                                      title: title,
                                      subtitle: subtitle,
                                      url: option.url,
                                      thumbnailUrl: thumbnailUrl,
                                      durationSeconds: option.durationSeconds,
                                      expectedSizeBytes: option.sizeBytes > 0
                                          ? option.sizeBytes
                                          : null,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> saveCantiqueAudioOffline(
  BuildContext context,
  WidgetRef ref, {
  required Cantique cantique,
}) async {
  final url = cantique.audioUrl;
  if (url == null || !url.startsWith('http')) {
    _snack(context, context.l10n.downloadAudioUnavailable);
    return;
  }
  await _enqueueDownload(
    context,
    ref,
    PendingOfflineDownload(
      category: OfflineMediaCategory.cantique,
      format: OfflineMediaFormat.audio,
      sourceId: cantique.id,
      title: cantiqueDisplayTitle(context.l10n, cantique),
      subtitle: cantique.category,
      url: url,
      thumbnailUrl: cantique.coverUrl,
    ),
  );
}

Future<void> saveYoutubeVideoOffline(
  BuildContext context,
  WidgetRef ref, {
  required String videoId,
  required String sourceId,
  required String title,
  required String subtitle,
  required OfflineMediaCategory category,
  String? thumbnailUrl,
}) async {
  await _enqueueDownload(
    context,
    ref,
    PendingOfflineDownload(
      category: category,
      format: OfflineMediaFormat.video,
      sourceId: sourceId,
      title: title,
      subtitle: subtitle,
      videoId: videoId,
      thumbnailUrl: thumbnailUrl,
      kind: OfflineDownloadKind.youtube,
    ),
  );
}

/// Convertit une vidéo en audio côté serveur, puis télécharge uniquement l'audio.
/// Non bloquant : progression dans la bannière (comme les téléchargements).
Future<void> saveVideoAsAudioOffline(
  BuildContext context,
  WidgetRef ref, {
  required String videoId,
  required String sourceId,
  required String title,
  required String subtitle,
  required OfflineMediaCategory category,
  String? thumbnailUrl,
  CantiqueVideoProvider provider = CantiqueVideoProvider.vimeo,
}) async {
  final l10n = context.l10n;
  final api = ref.read(audioConversionApiServiceProvider);

  if (!api.isEnabled || !notificationsApiEnabled) {
    _snack(context, l10n.audioConversionUnavailable);
    return;
  }

  final profile = await _showAudioConversionProfileSheet(context);
  if (profile == null || !context.mounted) return;

  final providerApi =
      provider == CantiqueVideoProvider.youtube ? 'youtube' : 'vimeo';

  final result = await ref.read(audioConversionManagerProvider.notifier).enqueue(
        PendingAudioConversion(
          mediaId: sourceId,
          provider: providerApi,
          videoId: videoId,
          profile: profile,
          title: title,
          subtitle: subtitle,
          category: category,
          thumbnailUrl: thumbnailUrl,
          youtubeFallbackOnUnsupported:
              provider == CantiqueVideoProvider.youtube,
        ),
      );

  if (!context.mounted) return;
  switch (result) {
    case AudioConversionEnqueueResult.alreadyActive:
      _snack(context, l10n.audioConversionAlreadyRunning);
    case AudioConversionEnqueueResult.queued:
      _snack(context, l10n.audioConversionAddedToQueue);
  }
}

Future<AudioConversionProfile?> _showAudioConversionProfileSheet(
  BuildContext context,
) async {
  final l10n = context.l10n;
  return showModalBottomSheet<AudioConversionProfile>(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.downloadConvertToAudio,
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.audioConversionChooseQuality,
                style: TextStyle(color: AppTheme.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              _profileTile(
                sheetContext,
                profile: AudioConversionProfile.economy,
                title: l10n.audioConversionProfileEconomy,
                subtitle: l10n.audioConversionProfileEconomyHint,
              ),
              _profileTile(
                sheetContext,
                profile: AudioConversionProfile.standard,
                title: l10n.audioConversionProfileStandard,
                subtitle: l10n.audioConversionProfileStandardHint,
                selected: true,
              ),
              _profileTile(
                sheetContext,
                profile: AudioConversionProfile.compatible,
                title: l10n.audioConversionProfileCompatible,
                subtitle: l10n.audioConversionProfileCompatibleHint,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _profileTile(
  BuildContext context, {
  required AudioConversionProfile profile,
  required String title,
  required String subtitle,
  bool selected = false,
}) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      selected ? Icons.radio_button_checked : Icons.radio_button_off,
      color: AppTheme.accentGold,
    ),
    title: Text(
      title,
      style: TextStyle(
        color: AppTheme.white,
        fontWeight: FontWeight.w600,
      ),
    ),
    subtitle: Text(
      subtitle,
      style: TextStyle(color: AppTheme.grey, fontSize: 12.5),
    ),
    onTap: () => Navigator.pop(context, profile),
  );
}

Future<void> saveCantiqueVideoOffline(
  BuildContext context,
  WidgetRef ref, {
  required Cantique cantique,
}) async {
  if (!cantique.hasVideo) {
    _snack(context, context.l10n.downloadVideoUnavailable);
    return;
  }
  if (cantique.videoProvider == CantiqueVideoProvider.youtube) {
    await saveYoutubeVideoOffline(
      context,
      ref,
      videoId: cantique.videoId!,
      sourceId: cantique.id,
      title: cantiqueDisplayTitle(context.l10n, cantique),
      subtitle: cantique.displaySubtitle,
      category: OfflineMediaCategory.cantique,
      thumbnailUrl: cantique.coverUrl,
    );
    return;
  }
  await saveVimeoVideoOffline(
    context,
    ref,
    videoId: cantique.videoId!,
    sourceId: cantique.id,
    title: cantiqueDisplayTitle(context.l10n, cantique),
    subtitle: cantique.displaySubtitle,
    category: OfflineMediaCategory.cantique,
    thumbnailUrl: cantique.coverUrl,
  );
}

Future<void> _enqueueDownload(
  BuildContext context,
  WidgetRef ref,
  PendingOfflineDownload pending, {
  bool resumeExisting = false,
}) async {
  final l10n = context.l10n;
  final result = await ref.read(offlineDownloadManagerProvider.notifier).enqueue(
        pending,
        resumeExisting: resumeExisting,
      );

  if (!context.mounted) return;
  switch (result) {
    case EnqueueResult.alreadySaved:
      _snack(context, l10n.downloadAlreadySaved);
    case EnqueueResult.alreadyActive:
      _snack(context, l10n.downloadAlreadyInQueue);
    case EnqueueResult.queued:
      _snack(context, l10n.downloadAddedToQueue);
    case EnqueueResult.resumed:
      _snack(context, l10n.downloadResumeStarted);
  }
}

/// Reprend un téléchargement échoué (reprise byte-range si possible).
Future<void> retryFailedOfflineDownload(
  BuildContext context,
  WidgetRef ref, {
  PendingOfflineDownload? pending,
  String? downloadId,
}) async {
  final manager = ref.read(offlineDownloadManagerProvider.notifier);
  final state = ref.read(offlineDownloadManagerProvider);

  if (downloadId != null) {
    final job = state.byId(downloadId);
    if (job != null && job.canResume) {
      manager.resume(downloadId);
      if (context.mounted) {
        _snack(context, context.l10n.downloadResumeStarted);
      }
      return;
    }
  }

  if (pending != null) {
    await _enqueueDownload(context, ref, pending, resumeExisting: true);
    return;
  }

  final failed = state.jobs.where((j) => j.canResume).toList();
  if (failed.isEmpty) return;
  if (failed.length == 1) {
    manager.resume(failed.first.id);
  } else {
    manager.resumeAllFailed();
  }
  if (context.mounted) {
    _snack(context, context.l10n.downloadResumeStarted);
  }
}

/// Meilleure qualité ≤720p (sinon la plus petite disponible).
VideoDownloadOption pickDataSaverVideoOption(
  List<VideoDownloadOption> options,
) {
  assert(options.isNotEmpty);
  final under720 = options
      .where((o) => o.height > 0 ? o.height <= 720 : o.width <= 1280)
      .toList();
  if (under720.isNotEmpty) {
    under720.sort((a, b) {
      final byHeight = b.height.compareTo(a.height);
      if (byHeight != 0) return byHeight;
      return b.width.compareTo(a.width);
    });
    return under720.first;
  }
  final sorted = List<VideoDownloadOption>.of(options)
    ..sort((a, b) {
      final byHeight = a.height.compareTo(b.height);
      if (byHeight != 0) return byHeight;
      return a.width.compareTo(b.width);
    });
  return sorted.first;
}

/// Choix audio / vidéo avant téléchargement depuis une liste.
/// L'audio est proposé en premier (plus léger) quand les deux existent.
Future<void> showOfflineFormatPicker(
  BuildContext context, {
  required bool hasAudio,
  required bool hasVideo,
  required VoidCallback onAudio,
  required VoidCallback onVideo,
}) async {
  if (hasAudio && !hasVideo) {
    onAudio();
    return;
  }
  if (hasVideo && !hasAudio) {
    onVideo();
    return;
  }
  if (!hasAudio && !hasVideo) return;

  final l10n = context.l10n;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.downloadChooseFormat,
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.headphones_outlined,
                  color: AppTheme.accentGold,
                ),
                title: Text(l10n.audio, style: TextStyle(color: AppTheme.white)),
                subtitle: Text(
                  l10n.downloadAudioDataHint,
                  style: TextStyle(color: AppTheme.grey, fontSize: 12.5),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onAudio();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.videocam_outlined,
                  color: AppTheme.accentGold,
                ),
                title: Text(l10n.video, style: TextStyle(color: AppTheme.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  onVideo();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.snackBarForeground),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.snackBarBackground,
      ),
    );
}
