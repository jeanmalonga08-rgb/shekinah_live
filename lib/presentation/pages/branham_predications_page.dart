import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/network_error_utils.dart';
import '../../data/datasources/branham_predications_remote_datasource.dart';
import '../../domain/entities/branham_predication.dart';
import '../../domain/entities/offline_media.dart';
import '../../domain/entities/pending_offline_download.dart';
import '../providers/branham_audio_playback_provider.dart';
import '../providers/offline_download_progress_provider.dart';
import '../providers/offline_media_provider.dart';
import '../providers/offline_playback_provider.dart';
import '../widgets/branham_audio_mini_player.dart';
import '../widgets/content_share_helper.dart';
import '../widgets/offline_download_helper.dart';
import '../widgets/offline_mini_player.dart';
import '../widgets/offline_playback_helper.dart';
import '../widgets/sht_widgets.dart';
import 'offline_media_player_page.dart';
import 'predication_audio_page.dart';

class BranhamPredicationsPage extends ConsumerStatefulWidget {
  const BranhamPredicationsPage({super.key});

  @override
  ConsumerState<BranhamPredicationsPage> createState() =>
      _BranhamPredicationsPageState();
}

class _BranhamPredicationsPageState
    extends ConsumerState<BranhamPredicationsPage> {
  final _dataSource = BranhamPredicationsRemoteDataSource();
  final _searchController = TextEditingController();
  BranhamPredicationCatalog? _catalog;
  List<BranhamPredication> _items = const [];
  String? _language;
  String? _year;
  String? _duration;
  String? _series;
  String? _error;
  bool _loadingCatalog = true;
  bool _loadingResults = false;
  int _requestId = 0;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCatalog());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_loadResults());
    });
  }

  Future<void> _submitSearch() {
    _searchDebounce?.cancel();
    return _loadResults();
  }

  Future<void> _loadCatalog() async {
    try {
      final catalog = await _dataSource.fetchCatalog();
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
        _language = catalog.defaultLanguage;
        _loadingCatalog = false;
      });
      await _loadResults();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = formatNetworkError(context.l10n, error);
        _loadingCatalog = false;
      });
    }
  }

  Future<void> _loadResults() async {
    final catalog = _catalog;
    if (catalog == null) return;
    final requestId = ++_requestId;
    setState(() {
      _loadingResults = true;
      _error = null;
    });
    try {
      final items = await _dataSource.fetchPredications(
        language: _language ?? catalog.defaultLanguage,
        search: _searchController.text,
        year: _year,
        duration: _duration,
        series: _series,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _items = items;
        _loadingResults = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = formatNetworkError(context.l10n, error);
        _loadingResults = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final offlinePlayback = ref.watch(offlinePlaybackProvider);
    final branhamPlayback = ref.watch(branhamAudioPlaybackProvider);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Prédications Branham'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _loadingCatalog || _loadingResults
                ? null
                : () => unawaited(_loadResults()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      bottomNavigationBar: offlinePlayback.isActive &&
              offlinePlayback.showMiniPlayer
          ? const OfflineMiniPlayer()
          : branhamPlayback.isActive
              ? const BranhamAudioMiniPlayer()
              : null,
      body: _loadingCatalog
          ? Center(
              child: SpinKitFadingCircle(
                color: AppTheme.accentOnSurface,
                size: 44,
              ),
            )
          : _catalog == null
              ? _ErrorState(message: _error ?? l10n.networkError, onRetry: _loadCatalog)
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: AppTheme.white),
                        textInputAction: TextInputAction.search,
                        onChanged: _onSearchChanged,
                        onSubmitted: (_) => unawaited(_submitSearch()),
                        decoration: InputDecoration(
                          hintText: 'Rechercher par titre, date ou lieu',
                          hintStyle: TextStyle(color: AppTheme.muted),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppTheme.accentOnSurface,
                          ),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Effacer la recherche',
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchDebounce?.cancel();
                                    setState(() {});
                                    unawaited(_loadResults());
                                  },
                                  icon: Icon(Icons.close_rounded, color: AppTheme.grey),
                                ),
                          filled: true,
                          fillColor: AppTheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final fieldWidth = (constraints.maxWidth - 8) / 2;
                          final catalog = _catalog!;
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildFilter(
                                width: fieldWidth,
                                label: 'Langues',
                                resetLabel: 'Choisir une langue',
                                selected: _language,
                                options: catalog.languages,
                                onChanged: (value) {
                                  setState(() => _language = value ?? catalog.defaultLanguage);
                                  unawaited(_loadResults());
                                },
                              ),
                              _buildFilter(
                                width: fieldWidth,
                                label: "Choisir l'année",
                                resetLabel: 'Toutes les années',
                                selected: _year,
                                options: catalog.years,
                                onChanged: (value) {
                                  setState(() => _year = value);
                                  unawaited(_loadResults());
                                },
                              ),
                              _buildFilter(
                                width: fieldWidth,
                                label: 'Durée (min)',
                                resetLabel: 'Toutes les durées',
                                selected: _duration,
                                options: catalog.durations,
                                onChanged: (value) {
                                  setState(() => _duration = value);
                                  unawaited(_loadResults());
                                },
                              ),
                              _buildFilter(
                                width: fieldWidth,
                                label: 'Séries',
                                resetLabel: 'Toutes les séries',
                                selected: _series,
                                options: catalog.series,
                                onChanged: (value) {
                                  setState(() => _series = value);
                                  unawaited(_loadResults());
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    if (_loadingResults) const LinearProgressIndicator(),
                    if (_error != null && _items.isNotEmpty)
                      MaterialBanner(
                        content: Text(_error!, maxLines: 2, overflow: TextOverflow.ellipsis),
                        actions: [
                          TextButton(
                            onPressed: () => unawaited(_loadResults()),
                            child: Text(l10n.retry),
                          ),
                        ],
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadResults,
                        child: _items.isEmpty && _error != null
                            ? _ErrorState(
                                message: l10n.networkError,
                                onRetry: _loadResults,
                              )
                            : ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      '${_items.length} ${_items.length == 1 ? 'résultat' : 'résultats'}',
                                      style: TextStyle(
                                        color: AppTheme.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (_items.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 48),
                                      child: Center(
                                        child: Text(
                                          'Aucune prédication trouvée.',
                                          style: TextStyle(color: AppTheme.grey),
                                        ),
                                      ),
                                    )
                                  else
                                    ..._items.map(_buildPredicationTile),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilter({
    required double width,
    required String label,
    required String resetLabel,
    required String? selected,
    required List<BranhamFilterOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        initialValue: selected ?? '',
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppTheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.divider),
          ),
        ),
        items: [
          DropdownMenuItem(
            value: '',
            child: Text(resetLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          ...options.map(
            (option) => DropdownMenuItem(
              value: option.value,
              child: Text(option.label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPredicationTile(BranhamPredication item) {
    ref.watch(offlineMediaProvider);
    final downloads = ref.watch(offlineDownloadManagerProvider);
    final sourceId = _offlineSourceId(item);
    const category = OfflineMediaCategory.predication;
    final downloaded = hasOfflineMedia(
      ref,
      category: category,
      sourceId: sourceId,
      format: OfflineMediaFormat.audio,
    );
    final job = downloads.jobFor(
      category: category,
      sourceId: sourceId,
      format: OfflineMediaFormat.audio,
    );
    final showDownload = !downloaded || job?.isError == true || job?.isActive == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ShtCard(
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 108,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: InkWell(
                    onTap: item.audioUrl == null
                        ? null
                        : () => _openPredication(item, openFullPlayer: true),
                    child: Image.asset(
                      'assets/images/bro-branham.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: AppTheme.surfaceElevated,
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: AppTheme.accentOnSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: item.audioUrl == null
                            ? null
                            : () => _openPredication(
                                  item,
                                  openFullPlayer: true,
                                ),
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            height: 1.22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'William Branham',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.goldOnSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              [
                                if (item.location.isNotEmpty) item.location,
                                if (item.dateLabel.isNotEmpty) item.dateLabel,
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                          if (item.durationMinutes != null)
                            Text(
                              '${item.durationMinutes} min',
                              style: TextStyle(
                                color: AppTheme.muted,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(child: _BranhamBadge(label: item.code)),
                          Icon(
                            Icons.headphones_outlined,
                            size: 16,
                            color: AppTheme.grey,
                          ),
                          IconButton(
                            tooltip: 'Écouter',
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: item.audioUrl == null
                                ? null
                                : () => _openPredication(item),
                            icon: Icon(
                              Icons.play_circle_outline_rounded,
                              size: 20,
                              color: item.audioUrl == null
                                  ? AppTheme.muted
                                  : AppTheme.accentOnSurface,
                            ),
                          ),
                          if (showDownload)
                            IconButton(
                              tooltip: job?.isError == true
                                  ? context.l10n.downloadResume
                                  : context.l10n.downloadInApp,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              onPressed: item.audioUrl == null || job?.isActive == true
                                  ? null
                                  : () => _downloadAudio(item, sourceId, job),
                              icon: job?.isActive == true
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.accentOnSurface,
                                      ),
                                    )
                                  : Icon(
                                      job?.isError == true
                                          ? Icons.play_arrow_rounded
                                          : Icons.download_for_offline_outlined,
                                      size: 18,
                                      color: job?.isError == true
                                          ? Colors.orangeAccent
                                          : AppTheme.accentOnSurface,
                                    ),
                            ),
                          IconButton(
                            tooltip: context.l10n.share,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: () => _sharePredication(item),
                            icon: Icon(
                              Icons.share_outlined,
                              size: 18,
                              color: AppTheme.accentOnSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPredication(
    BranhamPredication item, {
    bool openFullPlayer = false,
  }) async {
    final audioUrl = item.audioUrl;
    if (audioUrl == null) return;

    final sourceId = _offlineSourceId(item);
    final offlineItem = findOfflineItem(
      ref,
      category: OfflineMediaCategory.predication,
      sourceId: sourceId,
      format: OfflineMediaFormat.audio,
    );
    if (offlineItem != null) {
      final playlist = (ref.read(offlineMediaProvider).valueOrNull ?? const [])
          .where(
            (candidate) =>
                candidate.category == OfflineMediaCategory.predication &&
            candidate.format == OfflineMediaFormat.audio &&
            (!sourceId.startsWith('branham_') ||
              candidate.sourceId.startsWith('branham_')),
          )
          .toList();
      final index = playlist.indexWhere((candidate) => candidate.id == offlineItem.id);
      final playback = ref.read(offlinePlaybackProvider);
      final sameTrack = playback.isActive &&
          playback.currentItem?.id == offlineItem.id;
      if (!sameTrack) {
        await ref.read(offlinePlaybackProvider.notifier).playQueue(
              playlist,
              initialIndex: index < 0 ? 0 : index,
              openFullPlayer: openFullPlayer,
            );
      }
      if (openFullPlayer && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => OfflineMediaPlayerPage(
              playlist: playlist,
              initialIndex: index < 0 ? 0 : index,
            ),
          ),
        );
      }
      return;
    }

    final playlist = _items
        .where((candidate) => candidate.audioUrl != null)
        .toList(growable: false);
    final index = playlist.indexWhere((candidate) => candidate.code == item.code);
    await ref.read(branhamAudioPlaybackProvider.notifier).play(
          sourceId: sourceId,
          title: item.title,
          subtitle: 'William Branham · ${item.code}',
          audioUrl: audioUrl,
          playlist: playlist,
          index: index < 0 ? 0 : index,
          resumeIfActive: !openFullPlayer,
        );
    if (openFullPlayer && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PredicationAudioPage(
            title: item.title,
            preacher: 'William Branham · ${item.code}',
            audioUrl: audioUrl,
            thumbnailAsset: 'assets/images/wmb.jpg',
            useBranhamQueue: true,
            startPlayback: false,
          ),
        ),
      );
    }
  }

  String _offlineSourceId(BranhamPredication item) =>
      'branham_${item.code.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_')}';

  Future<void> _downloadAudio(
    BranhamPredication item,
    String sourceId,
    OfflineDownloadJob? job,
  ) async {
    final pending = PendingOfflineDownload(
      category: OfflineMediaCategory.predication,
      format: OfflineMediaFormat.audio,
      sourceId: sourceId,
      title: item.title,
      subtitle: 'William Branham · ${item.code}',
      url: item.audioUrl,
      fileExtension: 'm4a',
    );
    if (job?.isError == true) {
      await retryFailedOfflineDownload(
        context,
        ref,
        pending: pending,
        downloadId: job!.id,
      );
      return;
    }

    await saveAudioUrlOffline(
      context,
      ref,
      sourceId: sourceId,
      title: item.title,
      subtitle: 'William Branham · ${item.code}',
      url: item.audioUrl!,
      fileExtension: 'm4a',
    );
  }

  Future<void> _sharePredication(BranhamPredication item) async {
    final l10n = context.l10n;
    final appInvitation = l10n.shareAppMessage(
      AppConstants.appName,
      AppConstants.playStoreUrl,
      AppConstants.websiteUrl,
    );
    await shareTextContent(
      context,
      text: buildBranhamPredicationShareText(
        title: item.title,
        code: item.code,
        location: item.location,
        appInvitation: appInvitation,
      ),
      subject: item.title,
    );
  }
}

class _BranhamBadge extends StatelessWidget {
  const _BranhamBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.royalBlue.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppTheme.softWhite,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 42, color: AppTheme.grey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => unawaited(onRetry()),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(MaterialLocalizations.of(context).refreshIndicatorSemanticLabel),
            ),
          ],
        ),
      ),
    );
  }
}