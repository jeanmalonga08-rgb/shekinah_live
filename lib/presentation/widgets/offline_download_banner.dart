import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/navigation/app_navigator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_sync.dart';
import '../providers/offline_download_progress_provider.dart';

/// Bannière / panneau du gestionnaire de téléchargements hors ligne (en haut).
class OfflineDownloadBanner extends ConsumerWidget {
  const OfflineDownloadBanner({super.key, this.topInset = 8, this.embedded = false});

  final double topInset;

  /// Si true, pas de [Positioned] (utilisé dans une colonne de bannières).
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeSync.watch(context);
    final l10n = context.l10n;
    final manager = ref.watch(offlineDownloadManagerProvider);
    if (!manager.isVisible) return const SizedBox.shrink();

    final notifier = ref.read(offlineDownloadManagerProvider.notifier);
    final downloading = manager.downloadingCount;
    final queued = manager.jobs.where((j) => j.isQueued).length;
    final errors = manager.errorCount;
    final paused = manager.pausedCount;
    final total = manager.jobs.length;
    final primary = manager.primaryFocus;

    String summary;
    if (downloading > 0 || queued > 0) {
      summary = l10n.downloadManagerSummary(downloading, total);
    } else if (paused > 0 && errors == 0) {
      summary = l10n.downloadPaused;
    } else if (errors > 0) {
      summary = l10n.downloadManagerErrors(errors);
    } else {
      summary = l10n.downloadManagerTitle;
    }

    final sizeLabel = primary == null
        ? ''
        : offlineDownloadSizeProgressLabel(
            l10n,
            receivedBytes: primary.receivedBytes,
            totalBytes: primary.knownTotalBytes,
          );
    final speedLabel = primary != null && primary.isDownloading
        ? offlineDownloadSpeedLabel(l10n, primary.bytesPerSecond)
        : '';
    final metaParts = <String>[
      if (primary != null) primary.title,
      if (sizeLabel.isNotEmpty) sizeLabel,
      if (speedLabel.isNotEmpty) speedLabel,
    ];
    final metaLine = metaParts.isEmpty ? summary : metaParts.join(' · ');

    final card = Material(
      elevation: 8,
      color: AppTheme.surfaceElevated,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openManagerSheet(ref),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              Icon(
                errors > 0 && downloading == 0 && paused == 0
                    ? Icons.error_outline
                    : paused > 0 && downloading == 0
                        ? Icons.pause_circle_outline
                        : Icons.download_for_offline_outlined,
                color: errors > 0 && downloading == 0 && paused == 0
                    ? Colors.redAccent
                    : AppTheme.accentGold,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.downloadManagerTitle,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      metaLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppTheme.muted, fontSize: 11.5),
                    ),
                    if (downloading > 0 ||
                        (primary != null && primary.progress != null)) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _aggregateProgress(manager),
                          minHeight: 4,
                          backgroundColor: AppTheme.borderSubtle,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (primary != null && primary.canPause)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => notifier.pause(primary.id),
                  icon: Icon(Icons.pause_rounded, color: AppTheme.accentGold),
                )
              else if (primary != null && primary.canResume)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => notifier.resume(primary.id),
                  icon: Icon(
                    Icons.play_arrow_rounded,
                    color: AppTheme.accentGold,
                  ),
                )
              else if (errors > 0)
                TextButton(
                  onPressed: notifier.resumeAllFailed,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppTheme.accentGold,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    l10n.downloadResume,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              // Pas de tooltip : ce widget est hors Overlay (MaterialApp.builder).
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _openManagerSheet(ref),
                icon: Icon(Icons.unfold_more, color: AppTheme.grey, size: 20),
              ),
            ],
          ),
        ),
      ),
    );

    if (embedded) return card;

    final top = MediaQuery.paddingOf(context).top + topInset;
    return Positioned(
      left: 12,
      right: 12,
      top: top,
      child: card,
    );
  }

  double? _aggregateProgress(OfflineDownloadManagerState manager) {
    final active = manager.jobs
        .where((j) => j.isDownloading || (j.isPaused && j.progress != null))
        .toList();
    if (active.isEmpty) return null;
    final withProgress = active.where((j) => j.progress != null).toList();
    if (withProgress.isEmpty) return null;
    final sum =
        withProgress.fold<double>(0, (s, j) => s + (j.progress ?? 0));
    return (sum / withProgress.length).clamp(0.0, 1.0);
  }

  Future<void> _openManagerSheet(WidgetRef ref) async {
    // Contexte du Navigator (sous Overlay), pas celui de la bannière.
    final navContext = appNavigatorKey.currentContext;
    if (navContext == null) return;

    await showModalBottomSheet<void>(
      context: navContext,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, sheetRef, _) {
            final l10n = context.l10n;
            final manager = sheetRef.watch(offlineDownloadManagerProvider);
            final notifier =
                sheetRef.read(offlineDownloadManagerProvider.notifier);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.downloadManagerTitle,
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (manager.downloadingCount > 0)
                            TextButton(
                              onPressed: notifier.pauseAll,
                              child: Text(l10n.downloadPause),
                            ),
                          if (manager.errorCount > 0 ||
                              manager.pausedCount > 0)
                            TextButton(
                              onPressed: notifier.resumeAllFailed,
                              child: Text(l10n.downloadResumeAll),
                            ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: Icon(Icons.close, color: AppTheme.grey),
                          ),
                        ],
                      ),
                    ),
                    if (manager.jobs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.downloadManagerEmpty,
                          style: TextStyle(color: AppTheme.grey),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: manager.jobs.length,
                          separatorBuilder: (_, _) =>
                              Divider(color: AppTheme.borderSubtle, height: 1),
                          itemBuilder: (context, index) {
                            final job = manager.jobs[index];
                            return _JobTile(
                              job: job,
                              onPause: () => notifier.pause(job.id),
                              onResume: () => notifier.resume(job.id),
                              onCancel: () => notifier.cancel(job.id),
                              onDismiss: () => notifier.dismiss(job.id),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _JobTile extends StatelessWidget {
  const _JobTile({
    required this.job,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.onDismiss,
  });

  final OfflineDownloadJob job;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatLabel = offlineFormatLabel(l10n, job.format);
    final isError = job.isError;
    final isActive = job.isActive;
    final sizeLabel = offlineDownloadSizeProgressLabel(
      l10n,
      receivedBytes: job.receivedBytes,
      totalBytes: job.knownTotalBytes,
    );
    final speedLabel = job.isDownloading
        ? offlineDownloadSpeedLabel(l10n, job.bytesPerSecond)
        : '';
    final detailParts = <String>[
      formatLabel,
      job.statusLabel(l10n),
      if (sizeLabel.isNotEmpty) sizeLabel,
      if (speedLabel.isNotEmpty) speedLabel,
    ];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      title: Text(
        job.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppTheme.white,
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            detailParts.join(' · '),
            style: TextStyle(
              color: isError ? Colors.redAccent.shade100 : AppTheme.grey,
              fontSize: 12,
            ),
          ),
          if (job.isDownloading ||
              job.isPaused ||
              (job.progress != null && job.isQueued)) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: job.progress != null && job.progress! > 0
                    ? job.progress
                    : null,
                minHeight: 4,
                backgroundColor: AppTheme.borderSubtle,
                color: AppTheme.accentGold,
              ),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (job.canPause)
            IconButton(
              onPressed: onPause,
              icon: const Icon(Icons.pause_rounded),
              color: AppTheme.accentGold,
            ),
          if (job.canResume)
            IconButton(
              onPressed: onResume,
              icon: const Icon(Icons.play_arrow_rounded),
              color: AppTheme.accentGold,
            ),
          if (isActive)
            IconButton(
              onPressed: onCancel,
              icon: const Icon(Icons.close),
              color: AppTheme.grey,
            ),
          if (job.isSuccess || (isError && !job.canResume))
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.check),
              color: AppTheme.grey,
            ),
          if (isError && job.canResume)
            IconButton(
              onPressed: onCancel,
              icon: Icon(Icons.delete_outline, color: AppTheme.grey),
            ),
        ],
      ),
    );
  }
}
