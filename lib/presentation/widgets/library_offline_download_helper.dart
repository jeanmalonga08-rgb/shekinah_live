import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/library_book.dart';
import '../../domain/entities/library_message.dart';
import '../../domain/entities/offline_media.dart';
import '../../domain/entities/pending_offline_download.dart';
import '../providers/offline_download_progress_provider.dart';
import '../providers/offline_media_provider.dart';
import '../pages/library_pdf_viewer_page.dart';

String libraryBookSourceId(LibraryBook book) => book.id.toString();

String libraryMessageSourceId(LibraryMessage message) => message.id;

String? libraryPdfLocalPath(
  WidgetRef ref, {
  required OfflineMediaCategory category,
  required String sourceId,
}) {
  final items = ref.read(offlineMediaProvider).valueOrNull ?? const [];
  final id = OfflineMediaItem.buildId(
    category: category,
    sourceId: sourceId,
    format: OfflineMediaFormat.pdf,
  );
  for (final item in items) {
    if (item.id == id) return item.localPath;
  }
  return null;
}

Future<bool> libraryPdfExists(
  WidgetRef ref, {
  required OfflineMediaCategory category,
  required String sourceId,
}) {
  return ref.read(offlineStorageServiceProvider).exists(
        category: category,
        sourceId: sourceId,
        format: OfflineMediaFormat.pdf,
      );
}

/// Ensures the PDF is on device; shows a progress dialog when a download is needed.
/// Returns the local path, or null if cancelled / failed.
Future<String?> ensureLibraryPdfDownloaded(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String pdfUrl,
  required OfflineMediaCategory category,
  required String sourceId,
  String subtitle = '',
  String? thumbnailUrl,
}) async {
  var localPath = libraryPdfLocalPath(
    ref,
    category: category,
    sourceId: sourceId,
  );

  if (localPath == null) {
    final exists = await libraryPdfExists(
      ref,
      category: category,
      sourceId: sourceId,
    );
    if (exists) {
      await ref.read(offlineMediaProvider.notifier).refresh();
      localPath = libraryPdfLocalPath(
        ref,
        category: category,
        sourceId: sourceId,
      );
    }
  }

  if (localPath != null) return localPath;
  if (!context.mounted) return null;

  if (pdfUrl.isEmpty) {
    _snack(context, context.l10n.unavailable);
    return null;
  }

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _LibraryPdfDownloadGateDialog(
      title: title,
      subtitle: subtitle,
      pdfUrl: pdfUrl,
      thumbnailUrl: thumbnailUrl,
      category: category,
      sourceId: sourceId,
    ),
  );
}

/// Opens a library PDF only after it is available offline.
/// Notes / highlights require a local file.
Future<void> openLibraryPdf(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String pdfUrl,
  required OfflineMediaCategory category,
  required String sourceId,
  String subtitle = '',
  String? thumbnailUrl,
}) async {
  final localPath = await ensureLibraryPdfDownloaded(
    context,
    ref,
    title: title,
    pdfUrl: pdfUrl,
    category: category,
    sourceId: sourceId,
    subtitle: subtitle,
    thumbnailUrl: thumbnailUrl,
  );
  if (!context.mounted || localPath == null || localPath.isEmpty) return;

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => LibraryPdfViewerPage(
        title: title,
        pdfUrl: pdfUrl,
        localPath: localPath,
        category: category,
        sourceId: sourceId,
      ),
    ),
  );
}

Future<void> saveLibraryBookOffline(
  BuildContext context,
  WidgetRef ref, {
  required LibraryBook book,
}) {
  return saveLibraryPdfOffline(
    context,
    ref,
    category: OfflineMediaCategory.libraryPepite,
    sourceId: libraryBookSourceId(book),
    title: book.title,
    subtitle: book.category.isNotEmpty ? book.category : book.author,
    pdfUrl: book.pdfUrl,
    thumbnailUrl: book.coverImageUrl(AppConstants.libraryAssetsBaseUrl),
  );
}

Future<void> saveLibraryMessageOffline(
  BuildContext context,
  WidgetRef ref, {
  required LibraryMessage message,
}) {
  final subtitle = message.date?.year.toString() ?? '';
  return saveLibraryPdfOffline(
    context,
    ref,
    category: OfflineMediaCategory.libraryPublication,
    sourceId: libraryMessageSourceId(message),
    title: message.title,
    subtitle: subtitle,
    pdfUrl: message.pdfUrl,
  );
}

Future<void> saveLibraryPdfOffline(
  BuildContext context,
  WidgetRef ref, {
  required OfflineMediaCategory category,
  required String sourceId,
  required String title,
  required String subtitle,
  required String pdfUrl,
  String? thumbnailUrl,
  bool queueIfBusy = false,
}) async {
  if (pdfUrl.isEmpty) {
    if (context.mounted) {
      _snack(context, context.l10n.unavailable);
    }
    return;
  }

  final l10n = context.l10n;
  final result =
      await ref.read(offlineDownloadManagerProvider.notifier).enqueue(
            PendingOfflineDownload(
              category: category,
              format: OfflineMediaFormat.pdf,
              sourceId: sourceId,
              title: title,
              subtitle: subtitle,
              url: pdfUrl,
              thumbnailUrl: thumbnailUrl,
            ),
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

Future<void> downloadAllLibraryBooks(
  BuildContext context,
  WidgetRef ref,
  List<LibraryBook> books,
) async {
  final l10n = context.l10n;
  if (books.isEmpty) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.libraryDownloadAll),
      content: Text(l10n.libraryDownloadAllConfirm(books.length)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.libraryDownloadAll),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  var queued = 0;
  var skipped = 0;
  final manager = ref.read(offlineDownloadManagerProvider.notifier);

  for (final book in books) {
    if (book.pdfUrl.isEmpty) continue;

    final exists = await libraryPdfExists(
      ref,
      category: OfflineMediaCategory.libraryPepite,
      sourceId: libraryBookSourceId(book),
    );
    if (exists) {
      skipped++;
      continue;
    }

    final result = await manager.enqueue(
      PendingOfflineDownload(
        category: OfflineMediaCategory.libraryPepite,
        format: OfflineMediaFormat.pdf,
        sourceId: libraryBookSourceId(book),
        title: book.title,
        subtitle: book.category,
        url: book.pdfUrl,
        thumbnailUrl: book.coverImageUrl(AppConstants.libraryAssetsBaseUrl),
      ),
    );
    if (result == EnqueueResult.queued || result == EnqueueResult.resumed) {
      queued++;
    } else if (result == EnqueueResult.alreadySaved) {
      skipped++;
    }
  }

  if (!context.mounted) return;
  _snack(context, l10n.libraryDownloadAllQueued(queued, skipped));
}

Future<void> downloadAllLibraryMessages(
  BuildContext context,
  WidgetRef ref,
  List<LibraryMessage> messages,
) async {
  final l10n = context.l10n;
  if (messages.isEmpty) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.libraryDownloadAll),
      content: Text(l10n.libraryDownloadAllConfirm(messages.length)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.libraryDownloadAll),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  var queued = 0;
  var skipped = 0;
  final manager = ref.read(offlineDownloadManagerProvider.notifier);

  for (final message in messages) {
    if (message.pdfUrl.isEmpty) continue;

    final exists = await libraryPdfExists(
      ref,
      category: OfflineMediaCategory.libraryPublication,
      sourceId: libraryMessageSourceId(message),
    );
    if (exists) {
      skipped++;
      continue;
    }

    final result = await manager.enqueue(
      PendingOfflineDownload(
        category: OfflineMediaCategory.libraryPublication,
        format: OfflineMediaFormat.pdf,
        sourceId: libraryMessageSourceId(message),
        title: message.title,
        subtitle: message.date?.year.toString() ?? '',
        url: message.pdfUrl,
      ),
    );
    if (result == EnqueueResult.queued || result == EnqueueResult.resumed) {
      queued++;
    } else if (result == EnqueueResult.alreadySaved) {
      skipped++;
    }
  }

  if (!context.mounted) return;
  _snack(context, l10n.libraryDownloadAllQueued(queued, skipped));
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

/// Modal that downloads a PDF then returns its local path.
class _LibraryPdfDownloadGateDialog extends ConsumerStatefulWidget {
  const _LibraryPdfDownloadGateDialog({
    required this.title,
    required this.subtitle,
    required this.pdfUrl,
    required this.category,
    required this.sourceId,
    this.thumbnailUrl,
  });

  final String title;
  final String subtitle;
  final String pdfUrl;
  final String? thumbnailUrl;
  final OfflineMediaCategory category;
  final String sourceId;

  @override
  ConsumerState<_LibraryPdfDownloadGateDialog> createState() =>
      _LibraryPdfDownloadGateDialogState();
}

class _LibraryPdfDownloadGateDialogState
    extends ConsumerState<_LibraryPdfDownloadGateDialog> {
  CancelToken? _cancelToken;
  double? _progress;
  String? _error;
  bool _started = false;
  bool _waitingQueue = false;
  bool _userCancelled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _begin());
  }

  @override
  void dispose() {
    if (_userCancelled) {
      _cancelToken?.cancel('cancelled');
    }
    super.dispose();
  }

  Future<void> _begin() async {
    if (_started) return;
    _started = true;

    final active = ref.read(offlineDownloadManagerProvider).jobFor(
          category: widget.category,
          sourceId: widget.sourceId,
          format: OfflineMediaFormat.pdf,
        );
    if (active != null && active.isActive) {
      setState(() {
        _waitingQueue = true;
        _progress = active.progress;
      });
      unawaited(_onQueueJobUpdate(active));
      return;
    }

    await _downloadDirect();
  }

  Future<void> _downloadDirect() async {
    final token = CancelToken();
    _cancelToken = token;
    setState(() {
      _waitingQueue = false;
      _error = null;
      _progress = null;
    });

    try {
      final item = await ref.read(offlineMediaProvider.notifier).download(
            category: widget.category,
            format: OfflineMediaFormat.pdf,
            sourceId: widget.sourceId,
            title: widget.title,
            subtitle: widget.subtitle,
            url: widget.pdfUrl,
            thumbnailUrl: widget.thumbnailUrl,
            cancelToken: token,
            onProgress: (received, total) {
              if (!mounted || total <= 0) return;
              setState(() => _progress = (received / total).clamp(0.0, 1.0));
            },
          );
      if (!mounted || _userCancelled) return;
      Navigator.of(context).pop(item.localPath);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || token.isCancelled) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      if (!mounted) return;
      setState(() => _error = context.l10n.downloadFailed);
    } catch (_) {
      if (token.isCancelled) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      if (!mounted) return;
      setState(() => _error = context.l10n.downloadFailed);
    }
  }

  Future<void> _onQueueJobUpdate(OfflineDownloadJob? job) async {
    if (!_waitingQueue || !mounted) return;

    if (job == null || job.isSuccess) {
      final exists = await libraryPdfExists(
        ref,
        category: widget.category,
        sourceId: widget.sourceId,
      );
      if (!mounted) return;
      if (exists) {
        await ref.read(offlineMediaProvider.notifier).refresh();
        final path = libraryPdfLocalPath(
          ref,
          category: widget.category,
          sourceId: widget.sourceId,
        );
        if (!mounted) return;
        if (path != null) {
          Navigator.of(context).pop(path);
          return;
        }
      }
      if (job == null && mounted) {
        // Job vanished without a file — fall back to direct download.
        await _downloadDirect();
      }
      return;
    }

    if (job.isError) {
      setState(() {
        _error = context.l10n.downloadFailed;
        _waitingQueue = false;
      });
      return;
    }

    setState(() => _progress = job.progress);
  }

  void _cancel() {
    _userCancelled = true;
    if (_waitingQueue) {
      final job = ref.read(offlineDownloadManagerProvider).jobFor(
            category: widget.category,
            sourceId: widget.sourceId,
            format: OfflineMediaFormat.pdf,
          );
      // Don't cancel a shared queue job the user may still want; just close.
      if (job == null) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
      }
      return;
    }
    _cancelToken?.cancel('cancelled');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(offlineDownloadManagerProvider, (previous, next) {
      if (!_waitingQueue) return;
      unawaited(
        _onQueueJobUpdate(
          next.jobFor(
            category: widget.category,
            sourceId: widget.sourceId,
            format: OfflineMediaFormat.pdf,
          ),
        ),
      );
    });

    final progress = _progress;
    final hasError = _error != null;

    return AlertDialog(
      title: Text(widget.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.libraryMustDownloadToRead),
          const SizedBox(height: 20),
          if (hasError)
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))
          else ...[
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.surfaceElevated,
            ),
            const SizedBox(height: 10),
            Text(
              progress != null && progress > 0
                  ? l10n.downloadProgress((progress * 100).round())
                  : l10n.downloadProgressActive,
              style: TextStyle(color: AppTheme.grey, fontSize: 13),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: Text(l10n.cancel),
        ),
        if (hasError)
          FilledButton(
            onPressed: () {
              setState(() {
                _error = null;
                _started = false;
              });
              _begin();
            },
            child: Text(l10n.libraryDownloadAndOpen),
          ),
      ],
    );
  }
}
