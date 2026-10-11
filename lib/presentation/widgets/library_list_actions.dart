import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/library_book.dart';
import '../../domain/entities/library_message.dart';
import '../../domain/entities/offline_media.dart';
import '../providers/offline_download_progress_provider.dart';
import '../providers/offline_media_provider.dart';
import 'library_offline_download_helper.dart';
import 'media_list_actions.dart';
import 'offline_download_helper.dart';

class LibraryListActions extends ConsumerWidget {
  const LibraryListActions._({
    required this.category,
    required this.sourceId,
    required this.title,
    required this.pdfUrl,
    this.book,
    this.message,
  });

  factory LibraryListActions.book(LibraryBook book) {
    return LibraryListActions._(
      category: OfflineMediaCategory.libraryPepite,
      sourceId: libraryBookSourceId(book),
      title: book.title,
      pdfUrl: book.pdfUrl,
      book: book,
    );
  }

  factory LibraryListActions.message(LibraryMessage message) {
    return LibraryListActions._(
      category: OfflineMediaCategory.libraryPublication,
      sourceId: libraryMessageSourceId(message),
      title: message.title,
      pdfUrl: message.pdfUrl,
      message: message,
    );
  }

  final OfflineMediaCategory category;
  final String sourceId;
  final String title;
  final String pdfUrl;
  final LibraryBook? book;
  final LibraryMessage? message;

  bool get _isPublication =>
      category == OfflineMediaCategory.libraryPublication;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(offlineMediaProvider);
    final manager = ref.watch(offlineDownloadManagerProvider);
    final l10n = context.l10n;

    final isOffline = libraryPdfLocalPath(
          ref,
          category: category,
          sourceId: sourceId,
        ) !=
        null;
    final downloading = manager.matchesActive(
      category: category,
      sourceId: sourceId,
      format: OfflineMediaFormat.pdf,
    );
    final failed = listItemDownloadFailed(
      manager,
      category: category,
      sourceId: sourceId,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isOffline)
          _isPublication
              ? _EagleAction(
                  tooltip: l10n.libraryOpenPdf,
                  onPressed: () => _open(context, ref),
                )
              : _ActionIcon(
                  tooltip: l10n.libraryOpenPdf,
                  icon: Icons.menu_book_outlined,
                  color: AppTheme.brandAccent,
                  onPressed: () => _open(context, ref),
                ),
        if (isOffline && !failed)
          _isPublication
              ? _EagleAction(
                  tooltip: l10n.libraryReadOffline,
                  onPressed: () => _open(context, ref),
                )
              : _ActionIcon(
                  tooltip: l10n.libraryReadOffline,
                  icon: Icons.chrome_reader_mode_outlined,
                  color: AppTheme.accentOnSurface,
                  onPressed: () => _open(context, ref),
                )
        else
          _ActionIcon(
            tooltip: failed ? l10n.downloadResume : l10n.downloadInApp,
            icon: failed
                ? Icons.play_arrow_rounded
                : Icons.download_for_offline_outlined,
            color: failed ? Colors.orangeAccent : AppTheme.accentOnSurface,
            onPressed: failed
                ? () => _retry(context, ref)
                : () => _download(context, ref),
            loading: downloading,
          ),
      ],
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    openLibraryPdf(
      context,
      ref,
      title: title,
      pdfUrl: pdfUrl,
      category: category,
      sourceId: sourceId,
    );
  }

  void _download(BuildContext context, WidgetRef ref) {
    final b = book;
    final m = message;
    if (b != null) {
      saveLibraryBookOffline(context, ref, book: b);
      return;
    }
    if (m != null) {
      saveLibraryMessageOffline(context, ref, message: m);
    }
  }

  void _retry(BuildContext context, WidgetRef ref) {
    final manager = ref.read(offlineDownloadManagerProvider);
    final job = manager.jobFor(
      category: category,
      sourceId: sourceId,
      format: OfflineMediaFormat.pdf,
    );
    retryFailedOfflineDownload(
      context,
      ref,
      downloadId: job?.id,
      pending: job?.pending ??
          listItemFailedPending(
            manager,
            category: category,
            sourceId: sourceId,
          ),
    );
  }
}

class _EagleAction extends StatelessWidget {
  const _EagleAction({
    required this.tooltip,
    required this.onPressed,
  });

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      onPressed: onPressed,
      icon: Image.asset(
        AppConstants.shekinahPublicationEagleAsset,
        width: 26,
        height: 26,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          Icons.menu_book_outlined,
          size: 20,
          color: AppTheme.brandAccent,
        ),
      ),
    );
  }
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
