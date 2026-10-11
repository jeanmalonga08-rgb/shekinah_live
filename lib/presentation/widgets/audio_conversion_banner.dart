import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/navigation/app_navigator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_sync.dart';
import '../providers/audio_conversion_manager_provider.dart';

/// Bannière du gestionnaire de conversions audio (non bloquante).
class AudioConversionBanner extends ConsumerWidget {
  const AudioConversionBanner({super.key, this.embedded = false});

  /// Si true, pas de [Positioned] (utilisé dans une colonne de bannières).
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeSync.watch(context);
    final l10n = context.l10n;
    final manager = ref.watch(audioConversionManagerProvider);
    if (!manager.isVisible) return const SizedBox.shrink();

    final notifier = ref.read(audioConversionManagerProvider.notifier);
    final primary = manager.primaryFocus;
    final active = manager.activeCount;
    final errors = manager.errorCount;
    final total = manager.jobs.length;

    String summary;
    if (active > 0) {
      summary = l10n.audioConversionManagerSummary(active, total);
    } else if (errors > 0) {
      summary = l10n.audioConversionManagerErrors(errors);
    } else {
      summary = l10n.audioConversionManagerTitle;
    }

    final metaParts = <String>[
      if (primary != null) primary.title,
      if (primary != null && primary.isActive) primary.statusLabel(l10n),
      if (primary != null && primary.isFailed)
        audioConversionErrorMessage(
          l10n,
          errorCode: primary.errorCode,
          message: primary.message,
        ) ??
            l10n.audioConversionFailed,
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
                errors > 0 && active == 0
                    ? Icons.error_outline
                    : Icons.audiotrack_outlined,
                color: errors > 0 && active == 0
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
                      l10n.audioConversionManagerTitle,
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
                    if (active > 0) ...[
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
              if (primary != null && primary.canCancel)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => notifier.cancel(primary.id),
                  icon: Icon(Icons.close, color: AppTheme.grey),
                )
              else if (errors > 0)
                TextButton(
                  onPressed: notifier.dismissAllTerminal,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppTheme.accentGold,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(l10n.ok),
                ),
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

    final top = MediaQuery.paddingOf(context).top + 8;
    return Positioned(
      left: 12,
      right: 12,
      top: top,
      child: card,
    );
  }

  double? _aggregateProgress(AudioConversionManagerState manager) {
    final active = manager.jobs.where((j) => j.isActive).toList();
    if (active.isEmpty) return null;
    final withProgress = active.where((j) => j.progress > 0).toList();
    if (withProgress.isEmpty) return null;
    final sum = withProgress.fold<int>(0, (s, j) => s + j.progress);
    return (sum / (withProgress.length * 100)).clamp(0.0, 1.0);
  }

  Future<void> _openManagerSheet(WidgetRef ref) async {
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
            final manager = sheetRef.watch(audioConversionManagerProvider);
            final notifier =
                sheetRef.read(audioConversionManagerProvider.notifier);
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
                              l10n.audioConversionManagerTitle,
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (manager.errorCount > 0)
                            TextButton(
                              onPressed: notifier.dismissAllTerminal,
                              child: Text(l10n.ok),
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
                          l10n.audioConversionManagerEmpty,
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
                            return _ConversionJobTile(
                              job: job,
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

class _ConversionJobTile extends StatelessWidget {
  const _ConversionJobTile({
    required this.job,
    required this.onCancel,
    required this.onDismiss,
  });

  final AudioConversionUiJob job;
  final VoidCallback onCancel;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isError = job.isFailed;
    final detail = isError
        ? (audioConversionErrorMessage(
              l10n,
              errorCode: job.errorCode,
              message: job.message,
            ) ??
            l10n.audioConversionFailed)
        : job.statusLabel(l10n);

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
            detail,
            style: TextStyle(
              color: isError ? Colors.redAccent.shade100 : AppTheme.grey,
              fontSize: 12,
            ),
          ),
          if (job.isActive) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: job.progress > 0
                    ? (job.progress.clamp(0, 100) / 100)
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
          if (job.canCancel)
            IconButton(
              onPressed: onCancel,
              icon: const Icon(Icons.close),
              color: AppTheme.grey,
            ),
          if (job.canDismiss)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.check),
              color: AppTheme.grey,
            ),
        ],
      ),
    );
  }
}
