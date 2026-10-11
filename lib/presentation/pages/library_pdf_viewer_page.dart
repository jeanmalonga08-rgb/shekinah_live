import 'dart:math' show max;
import 'dart:typed_data';

import '../../core/platform/local_file.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/network/dio_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/library_pdf_reader_storage_service.dart';
import '../../domain/entities/library_pdf_reader_state.dart';
import '../../domain/entities/offline_media.dart';
import '../../l10n/app_localizations.dart';
import '../providers/library_pdf_reader_provider.dart';
import '../providers/offline_media_provider.dart';
import '../widgets/library_offline_download_helper.dart';

class LibraryPdfViewerPage extends ConsumerStatefulWidget {
  const LibraryPdfViewerPage({
    super.key,
    required this.title,
    required this.pdfUrl,
    this.localPath,
    this.category,
    this.sourceId,
  });

  final String title;
  final String pdfUrl;
  final String? localPath;
  final OfflineMediaCategory? category;
  final String? sourceId;

  @override
  ConsumerState<LibraryPdfViewerPage> createState() =>
      _LibraryPdfViewerPageState();
}

class _LibraryPdfViewerPageState extends ConsumerState<LibraryPdfViewerPage> {
  final _viewerController = PdfViewerController();
  PdfTextSearcher? _textSearcher;
  final _searchFieldController = TextEditingController();

  String? _error;
  bool _loading = true;
  String? _activeLocalPath;
  bool _useLocalFile = false;
  Uint8List? _pdfBytes;
  bool _restoredLastPage = false;
  bool _showSearch = false;
  bool _caseSensitive = false;
  bool _wholeWord = false;
  bool _nightMode = false;
  /// One page at a time (horizontal). When false, continuous vertical scroll.
  bool _singlePageMode = true;
  bool _pendingModePageRestore = false;
  int _currentPage = 1;
  int _pageCount = 0;
  double _currentZoom = 1;
  double? _fitZoom;

  late final String _documentKey;

  @override
  void initState() {
    super.initState();
    _activeLocalPath = widget.localPath;
    _documentKey = libraryPdfDocumentKey(
      sourceId: widget.sourceId,
      categoryName: widget.category?.name,
      fallback: widget.pdfUrl.isNotEmpty ? widget.pdfUrl : widget.title,
    );
    _viewerController.addListener(_onViewerUpdated);
    _loadPdf();
  }

  @override
  void dispose() {
    _disposeTextSearcher();
    _viewerController.removeListener(_onViewerUpdated);
    _searchFieldController.dispose();
    super.dispose();
  }

  void _disposeTextSearcher() {
    final searcher = _textSearcher;
    if (searcher == null) return;
    searcher
      ..removeListener(_onSearchUpdated)
      ..dispose();
    _textSearcher = null;
  }

  void _ensureTextSearcher(PdfViewerController controller) {
    if (_textSearcher != null) return;
    _textSearcher = PdfTextSearcher(controller)..addListener(_onSearchUpdated);
  }

  LibraryPdfReaderState get _readerState =>
      ref.read(libraryPdfReaderStateProvider(_documentKey));

  void _onSearchUpdated() {
    if (mounted) setState(() {});
  }

  void _onViewerUpdated() {
    if (!_viewerController.isReady) return;
    final page = _viewerController.pageNumber;
    final zoom = _viewerController.currentZoom;
    var changed = false;

    if (page != null && page != _currentPage) {
      _currentPage = page;
      ref
          .read(libraryPdfReaderStateProvider(_documentKey).notifier)
          .setLastPage(page);
      changed = true;
    }
    if ((zoom - _currentZoom).abs() > 0.01) {
      _currentZoom = zoom;
      changed = true;
    }
    if (changed && mounted) setState(() {});
  }

  Future<void> _loadPdf() async {
    _disposeTextSearcher();
    setState(() {
      _loading = true;
      _error = null;
      _pdfBytes = null;
      _useLocalFile = false;
      _restoredLastPage = false;
      _pageCount = 0;
      _currentPage = 1;
    });

    try {
      final localPath = _activeLocalPath;
      final hasLocal = localPath != null &&
          localPath.isNotEmpty &&
          await localFileExists(localPath);

      if (hasLocal) {
        if (!mounted) return;
        setState(() {
          _useLocalFile = true;
          _loading = false;
        });
        return;
      }

      // Sermons / library PDFs must be downloaded first (notes & highlights).
      if (widget.category != null && widget.sourceId != null) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = context.l10n.libraryMustDownloadToRead;
        });
        return;
      }

      if (widget.pdfUrl.isEmpty) {
        throw StateError('empty pdf');
      }

      final bytes = await _readPdfBytesFromNetwork();
      if (bytes == null || bytes.isEmpty) {
        throw StateError('empty pdf');
      }
      final data = Uint8List.fromList(bytes);
      if (!_looksLikePdf(data)) {
        throw StateError('not a pdf');
      }

      if (!mounted) return;
      setState(() {
        _pdfBytes = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = context.l10n.libraryPdfLoadError;
      });
    }
  }

  Future<List<int>?> _readPdfBytesFromNetwork() async {
    final dio = ref.read(dioProvider);
    final response = await dio.get<List<int>>(
      widget.pdfUrl,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (status) => status != null && status >= 200 && status < 400,
      ),
    );
    return response.data;
  }

  static bool _looksLikePdf(Uint8List data) {
    if (data.length < 5) return false;
    return data[0] == 0x25 &&
        data[1] == 0x50 &&
        data[2] == 0x44 &&
        data[3] == 0x46;
  }

  Future<void> _onDocumentReady(bool succeeded) async {
    if (!succeeded) {
      if (!mounted) return;
      setState(() => _error = context.l10n.libraryPdfLoadError);
      return;
    }
    if (!_viewerController.isReady) return;

    final pageCount = _viewerController.pageCount;
    _pageCount = pageCount;
    _currentZoom = _viewerController.currentZoom;
    _captureFitZoom();
    if (pageCount < 1) return;

    if (!_restoredLastPage) {
      _restoredLastPage = true;
      final saved = _readerState.lastPage;
      final target = saved.clamp(1, pageCount);
      _currentPage = target;
      if (target != (_viewerController.pageNumber ?? 1)) {
        await _goToPage(target);
      }
    } else if (_pendingModePageRestore) {
      _pendingModePageRestore = false;
      await _goToPage(_currentPage.clamp(1, pageCount));
    }

    if (mounted) setState(() {});
  }

  void _captureFitZoom() {
    if (!_viewerController.isReady) return;
    final page = _viewerController.pageNumber ?? _currentPage;
    try {
      final matrix =
          _viewerController.calcMatrixFitWidthForPage(pageNumber: page);
      if (matrix != null) {
        _fitZoom = matrix.zoom;
      }
    } catch (_) {}
  }

  int get _zoomPercent {
    final fit = _fitZoom;
    if (fit != null && fit > 0) {
      return ((_currentZoom / fit) * 100).round().clamp(25, 500);
    }
    return (_currentZoom * 100).round().clamp(25, 500);
  }

  Future<void> _zoomIn() async {
    if (!_viewerController.isReady) return;
    await _viewerController.zoomUp();
    _currentZoom = _viewerController.currentZoom;
    if (mounted) setState(() {});
  }

  Future<void> _zoomOut() async {
    if (!_viewerController.isReady) return;
    await _viewerController.zoomDown();
    _currentZoom = _viewerController.currentZoom;
    if (mounted) setState(() {});
  }

  Future<void> _zoomReset() async {
    if (!_viewerController.isReady) return;
    final page = _viewerController.pageNumber ?? _currentPage;
    final matrix =
        _viewerController.calcMatrixFitWidthForPage(pageNumber: page);
    if (matrix != null) {
      await _viewerController.goTo(matrix);
      _fitZoom = matrix.zoom;
      _currentZoom = _viewerController.currentZoom;
      if (mounted) setState(() {});
    }
  }

  PdfPageAnchor get _pageAnchor =>
      _singlePageMode ? PdfPageAnchor.all : PdfPageAnchor.top;

  Future<void> _goToPage(int page) async {
    if (!_viewerController.isReady) return;
    await _viewerController.goToPage(
      pageNumber: page,
      anchor: _pageAnchor,
    );
  }

  void _toggleViewMode() {
    if (!_viewerController.isReady && _pageCount < 1) {
      setState(() => _singlePageMode = !_singlePageMode);
      return;
    }
    setState(() {
      _singlePageMode = !_singlePageMode;
      _pendingModePageRestore = true;
    });
  }

  /// Horizontal layout with gaps so only one page is typically visible.
  static PdfPageLayout _layoutSinglePage(
    List<PdfPage> pages,
    PdfViewerParams params,
  ) {
    final maxWidth = pages.fold(0.0, (w, p) => max(w, p.width));
    final height = pages.fold(0.0, (h, p) => max(h, p.height)) + params.margin * 2;
    final pageLayouts = <Rect>[];
    var x = params.margin;
    for (final page in pages) {
      pageLayouts.add(
        Rect.fromLTWH(
          x,
          (height - page.height) / 2,
          page.width,
          page.height,
        ),
      );
      // Extra gap ≈ one page width so neighbours stay off-screen when fitted.
      x += page.width + maxWidth + params.margin;
    }
    return PdfPageLayout(
      pageLayouts: pageLayouts,
      documentSize: Size(x, height),
    );
  }

  void _paintAnnotations(Canvas canvas, Rect pageRect, PdfPage page) {
    _textSearcher?.pageTextMatchPaintCallback(canvas, pageRect, page);

    final annotations = _readerState.annotations
        .where((annotation) => annotation.pageNumber == page.pageNumber);
    for (final annotation in annotations) {
      final bounds = PdfRect(
        annotation.left,
        annotation.top,
        annotation.right,
        annotation.bottom,
      );
      final rect = bounds
          .toRect(page: page, scaledPageSize: pageRect.size)
          .translate(pageRect.left, pageRect.top);
      if (annotation.type == LibraryPdfAnnotationType.highlight) {
        canvas.drawRect(
          rect,
          Paint()..color = Color(annotation.colorValue).withValues(alpha: 0.38),
        );
      } else {
        final y = rect.bottom - 1;
        canvas.drawLine(
          Offset(rect.left, y),
          Offset(rect.right, y),
          Paint()
            ..color = Color(annotation.colorValue)
            ..strokeWidth = 2,
        );
      }
    }
  }

  Future<void> _addAnnotationFromSelection(LibraryPdfAnnotationType type) async {
    if (!_viewerController.isReady) return;
    final delegate = _viewerController.textSelectionDelegate;
    final ranges = await delegate.getSelectedTextRanges();
    if (ranges.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pdfReaderSelectTextFirst)),
      );
      return;
    }

    final notifier =
        ref.read(libraryPdfReaderStateProvider(_documentKey).notifier);
    for (final range in ranges) {
      final bounds = range.bounds;
      await notifier.addAnnotation(
        LibraryPdfAnnotation(
          id: '${DateTime.now().microsecondsSinceEpoch}_${range.pageNumber}_${range.start}',
          pageNumber: range.pageNumber,
          type: type,
          left: bounds.left,
          top: bounds.top,
          right: bounds.right,
          bottom: bounds.bottom,
          text: range.text,
          colorValue: type == LibraryPdfAnnotationType.highlight
              ? 0xFFFFEB3B
              : 0xFF42A5F5,
        ),
      );
    }
    await delegate.clearTextSelection();
    _viewerController.invalidate();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.pdfReaderAnnotationsSaved)),
    );
  }

  void _runSearch() {
    final searcher = _textSearcher;
    if (searcher == null) return;
    final query = _searchFieldController.text.trim();
    if (query.isEmpty) {
      searcher.resetTextSearch();
      return;
    }
    final pattern = _wholeWord ? RegExp(r'\b' + RegExp.escape(query) + r'\b') : query;
    searcher.startTextSearch(
      pattern,
      caseInsensitive: !_caseSensitive,
      goToFirstMatch: true,
    );
  }

  Future<void> _openExternally() async {
    final uri = Uri.parse(widget.pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sharePdf() async {
    await SharePlus.instance.share(
      ShareParams(text: widget.pdfUrl, subject: widget.title),
    );
  }

  Future<void> _downloadOffline() async {
    final category = widget.category;
    final sourceId = widget.sourceId;
    if (category == null || sourceId == null) return;

    final localPath = await ensureLibraryPdfDownloaded(
      context,
      ref,
      title: widget.title,
      pdfUrl: widget.pdfUrl,
      category: category,
      sourceId: sourceId,
    );

    if (!mounted || localPath == null) return;
    if (localPath != _activeLocalPath) {
      setState(() => _activeLocalPath = localPath);
      await _loadPdf();
    }
  }

  bool get _canDownloadOffline {
    final category = widget.category;
    final sourceId = widget.sourceId;
    if (category == null || sourceId == null || widget.pdfUrl.isEmpty) {
      return false;
    }
    if (_activeLocalPath != null) {
      return localFileExistsSync(_activeLocalPath!);
    }
    return true;
  }

  bool get _isOfflineReady {
    final path = _activeLocalPath;
    return path != null && path.isNotEmpty && localFileExistsSync(path);
  }

  Future<void> _showGoToPageDialog() async {
    if (!_viewerController.isReady) return;
    final l10n = context.l10n;
    final total = _viewerController.pageCount;
    final controller = TextEditingController(text: '$_currentPage');
    final page = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.pdfReaderGoToPage),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: l10n.pdfReaderPageOf(_currentPage, total),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              Navigator.pop(ctx, value);
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
    if (page != null && page >= 1 && page <= total) {
      await _goToPage(page);
    }
  }

  Future<void> _showBookmarksSheet() async {
    final l10n = context.l10n;
    final bookmarks = _readerState.bookmarks;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        if (bookmarks.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.pdfReaderNoBookmarks),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.pdfReaderBookmarks,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            for (final page in bookmarks)
              ListTile(
                leading: Icon(Icons.bookmark, color: AppTheme.accentGold),
                title: Text(l10n.pdfReaderPageLabel(page)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _goToPage(page);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await ref
                        .read(libraryPdfReaderStateProvider(_documentKey).notifier)
                        .toggleBookmark(page);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) setState(() {});
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showAnnotationsSheet() async {
    final l10n = context.l10n;
    final annotations = _readerState.annotations;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        if (annotations.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.pdfReaderNoAnnotations),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.pdfReaderAnnotations,
                      style: Theme.of(ctx).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await ref
                          .read(libraryPdfReaderStateProvider(_documentKey).notifier)
                          .clearAnnotations();
                      _viewerController.invalidate();
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) setState(() {});
                    },
                    child: Text(l10n.pdfReaderClearAnnotations),
                  ),
                ],
              ),
            ),
            for (final annotation in annotations)
              ListTile(
                leading: Icon(
                  annotation.type == LibraryPdfAnnotationType.highlight
                      ? Icons.highlight_outlined
                      : Icons.format_underlined,
                  color: Color(annotation.colorValue),
                ),
                title: Text(
                  annotation.text?.trim().isNotEmpty == true
                      ? annotation.text!.trim()
                      : l10n.pdfReaderPageLabel(annotation.pageNumber),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(l10n.pdfReaderPageLabel(annotation.pageNumber)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _goToPage(annotation.pageNumber);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await ref
                        .read(libraryPdfReaderStateProvider(_documentKey).notifier)
                        .removeAnnotation(annotation.id);
                    _viewerController.invalidate();
                    if (mounted) setState(() {});
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(offlineMediaProvider);
    final readerState = ref.watch(libraryPdfReaderStateProvider(_documentKey));
    final isBookmarked = readerState.bookmarks.contains(_currentPage);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.search_off : Icons.search),
            tooltip: l10n.pdfReaderSearchInDocument,
            onPressed: () => setState(() => _showSearch = !_showSearch),
          ),
          if (_canDownloadOffline && !_isOfflineReady)
            IconButton(
              icon: const Icon(Icons.download_for_offline_outlined),
              tooltip: l10n.downloadInApp,
              onPressed: _downloadOffline,
            ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _sharePdf,
          ),
          if (!_isOfflineReady)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: l10n.libraryOpenExternally,
              onPressed: _openExternally,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch) _buildSearchBar(l10n),
          Expanded(child: _buildBody(l10n)),
          _buildBottomBar(l10n, isBookmarked, readerState),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    final searcher = _textSearcher;
    final matches = searcher?.matches ?? const [];
    final current = searcher?.currentIndex;

    return Material(
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          children: [
            TextField(
              controller: _searchFieldController,
              decoration: InputDecoration(
                hintText: l10n.pdfReaderSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchFieldController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchFieldController.clear();
                          searcher?.resetTextSearch();
                          setState(() {});
                        },
                      ),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _runSearch(),
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FilterChip(
                  label: Text(l10n.pdfReaderSearchCaseSensitive),
                  selected: _caseSensitive,
                  onSelected: (value) {
                    setState(() => _caseSensitive = value);
                    _runSearch();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(l10n.pdfReaderSearchWholeWord),
                  selected: _wholeWord,
                  onSelected: (value) {
                    setState(() => _wholeWord = value);
                    _runSearch();
                  },
                ),
                const Spacer(),
                if (searcher?.isSearching == true)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (matches.isNotEmpty)
                  Text(
                    l10n.pdfReaderMatchCount(
                      (current ?? 0) + 1,
                      matches.length,
                    ),
                    style: TextStyle(color: AppTheme.grey, fontSize: 12),
                  )
                else if (_searchFieldController.text.trim().isNotEmpty)
                  Text(
                    l10n.pdfReaderNoMatches,
                    style: TextStyle(color: AppTheme.grey, fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: l10n.pdfReaderPreviousMatch,
                  onPressed: matches.isEmpty
                      ? null
                      : () => searcher?.goToPrevMatch(),
                  icon: const Icon(Icons.keyboard_arrow_up),
                ),
                IconButton(
                  tooltip: l10n.pdfReaderNextMatch,
                  onPressed: matches.isEmpty
                      ? null
                      : () => searcher?.goToNextMatch(),
                  icon: const Icon(Icons.keyboard_arrow_down),
                ),
                FilledButton(
                  onPressed: _runSearch,
                  child: Text(l10n.searchTitle),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    AppLocalizations l10n,
    bool isBookmarked,
    LibraryPdfReaderState readerState,
  ) {
    return Material(
      color: AppTheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ToolButton(
                  icon: Icons.highlight_outlined,
                  tooltip: l10n.pdfReaderHighlight,
                  onPressed: () =>
                      _addAnnotationFromSelection(LibraryPdfAnnotationType.highlight),
                ),
                _ToolButton(
                  icon: Icons.format_underlined,
                  tooltip: l10n.pdfReaderUnderline,
                  onPressed: () =>
                      _addAnnotationFromSelection(LibraryPdfAnnotationType.underline),
                ),
                _ToolButton(
                  icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  tooltip: l10n.pdfReaderBookmark,
                  onPressed: () async {
                    await ref
                        .read(libraryPdfReaderStateProvider(_documentKey).notifier)
                        .toggleBookmark(_currentPage);
                    setState(() {});
                  },
                ),
                _ToolButton(
                  icon: Icons.bookmarks_outlined,
                  tooltip: l10n.pdfReaderBookmarks,
                  onPressed: _showBookmarksSheet,
                ),
                _ToolButton(
                  icon: Icons.notes_outlined,
                  tooltip: l10n.pdfReaderAnnotations,
                  badge: readerState.annotations.isEmpty
                      ? null
                      : '${readerState.annotations.length}',
                  onPressed: _showAnnotationsSheet,
                ),
                _ToolButton(
                  icon: Icons.article_outlined,
                  tooltip: l10n.pdfReaderGoToPage,
                  onPressed: _showGoToPageDialog,
                ),
                _ToolButton(
                  icon: Icons.text_decrease_rounded,
                  tooltip: l10n.pdfReaderZoomOut,
                  onPressed: _zoomOut,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: TextButton(
                    onPressed: _zoomReset,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      foregroundColor: AppTheme.accentOnSurface,
                    ),
                    child: Text(
                      l10n.pdfReaderZoomLevel(_zoomPercent),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                _ToolButton(
                  icon: Icons.text_increase_rounded,
                  tooltip: l10n.pdfReaderZoomIn,
                  onPressed: _zoomIn,
                ),
                _ToolButton(
                  icon: Icons.fit_screen_outlined,
                  tooltip: l10n.pdfReaderZoomReset,
                  onPressed: _zoomReset,
                ),
                _ToolButton(
                  icon: _singlePageMode
                      ? Icons.view_stream_outlined
                      : Icons.crop_portrait_outlined,
                  tooltip: _singlePageMode
                      ? l10n.pdfReaderContinuousView
                      : l10n.pdfReaderSinglePageView,
                  onPressed: _toggleViewMode,
                ),
                _ToolButton(
                  icon: _nightMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  tooltip: l10n.pdfReaderNightMode,
                  onPressed: () => setState(() => _nightMode = !_nightMode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitFadingCircle(color: AppTheme.accentOnSurface, size: 48),
            const SizedBox(height: 16),
            Text(l10n.libraryLoadingPdf),
          ],
        ),
      );
    }

    if (_error != null) {
      final mustDownload = widget.category != null &&
          widget.sourceId != null &&
          !_isOfflineReady;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              if (mustDownload && _canDownloadOffline)
                FilledButton.icon(
                  onPressed: _downloadOffline,
                  icon: const Icon(Icons.download_for_offline_outlined),
                  label: Text(l10n.libraryDownloadAndOpen),
                )
              else if (!_isOfflineReady && widget.pdfUrl.isNotEmpty)
                FilledButton.icon(
                  onPressed: _openExternally,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.libraryOpenExternally),
                ),
              const SizedBox(height: 8),
              TextButton(onPressed: _loadPdf, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }

    if (_useLocalFile) {
      final path = _activeLocalPath;
      if (path == null || path.isEmpty) {
        return Center(child: Text(l10n.libraryPdfLoadError));
      }
    } else if (_pdfBytes == null) {
      return Center(child: Text(l10n.libraryPdfLoadError));
    }

    final params = PdfViewerParams(
      backgroundColor: AppTheme.surfaceElevated,
      layoutPages: _singlePageMode ? _layoutSinglePage : null,
      pageAnchor: _pageAnchor,
      pageAnchorEnd: _singlePageMode ? PdfPageAnchor.all : PdfPageAnchor.bottom,
      scrollHorizontallyByMouseWheel: _singlePageMode,
      loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitFadingCircle(color: AppTheme.accentOnSurface, size: 48),
              const SizedBox(height: 16),
              Text(l10n.libraryLoadingPdf),
            ],
          ),
        );
      },
      errorBannerBuilder: (context, error, stackTrace, documentRef) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.libraryPdfLoadError, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _openExternally,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.libraryOpenExternally),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: _loadPdf, child: Text(l10n.retry)),
              ],
            ),
          ),
        );
      },
      onPageChanged: (page) {
        if (page == null) return;
        _currentPage = page;
        if (_viewerController.isReady) {
          _pageCount = _viewerController.pageCount;
        }
        ref
            .read(libraryPdfReaderStateProvider(_documentKey).notifier)
            .setLastPage(page);
        if (mounted) setState(() {});
      },
      onViewerReady: (document, controller) {
        _ensureTextSearcher(controller);
        _pageCount = document.pages.length;
        if (mounted) setState(() {});
      },
      onDocumentLoadFinished: (documentRef, succeeded) {
        _onDocumentReady(succeeded);
      },
      pagePaintCallbacks: [_paintAnnotations],
      textSelectionParams: const PdfTextSelectionParams(enabled: true),
    );

    // Always open on page 1, then restore the saved page after load.
    // A saved page beyond the document length makes pdfrx wait forever
    // for a missing page image and leaves a blank viewer.
    final modeKey = _singlePageMode ? 'single' : 'continuous';
    final viewer = _useLocalFile
        ? PdfViewer.file(
            _activeLocalPath!,
            key: ValueKey(
              'pdf-file-$_documentKey-$_activeLocalPath-$modeKey',
            ),
            controller: _viewerController,
            initialPageNumber: 1,
            params: params,
          )
        : PdfViewer.data(
            _pdfBytes!,
            sourceName: 'library-pdf-$_documentKey',
            key: ValueKey('pdf-data-$_documentKey-$modeKey'),
            controller: _viewerController,
            initialPageNumber: 1,
            params: params,
          );

    return Column(
      children: [
        if (_pageCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            child: Row(
              children: [
                IconButton(
                  tooltip: l10n.pdfReaderPreviousPage,
                  onPressed: _currentPage <= 1
                      ? null
                      : () => _goToPage(_currentPage - 1),
                  icon: const Icon(Icons.chevron_left),
                  color: AppTheme.accentOnSurface,
                ),
                Expanded(
                  child: Slider(
                    value: _currentPage.clamp(1, _pageCount).toDouble(),
                    min: 1,
                    max: _pageCount.toDouble(),
                    divisions: _pageCount > 1 ? _pageCount - 1 : 1,
                    label: '$_currentPage',
                    onChanged: (value) {
                      setState(() => _currentPage = value.round());
                    },
                    onChangeEnd: (value) {
                      _goToPage(value.round());
                    },
                  ),
                ),
                IconButton(
                  tooltip: l10n.pdfReaderNextPage,
                  onPressed: _currentPage >= _pageCount
                      ? null
                      : () => _goToPage(_currentPage + 1),
                  icon: const Icon(Icons.chevron_right),
                  color: AppTheme.accentOnSurface,
                ),
                Text(
                  l10n.pdfReaderPageOf(_currentPage, _pageCount),
                  style: TextStyle(color: AppTheme.grey, fontSize: 12),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        Expanded(
          child: _nightMode
              ? ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    -1, 0, 0, 0, 255,
                    0, -1, 0, 0, 255,
                    0, 0, -1, 0, 255,
                    0, 0, 0, 1, 0,
                  ]),
                  child: viewer,
                )
              : viewer,
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badge,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, size: 22),
          color: AppTheme.accentOnSurface,
        ),
        if (badge != null)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppTheme.brandAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge!,
                style: const TextStyle(fontSize: 9, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
