import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/locale_format.dart';
import '../../core/utils/network_error_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/predication.dart';
import '../providers/predication_provider.dart';
import '../widgets/content_share_helper.dart';
import '../widgets/media_list_actions.dart';
import '../widgets/archives_extra_filters.dart';
import '../widgets/sht_widgets.dart';
import 'branham_predications_page.dart';
import 'predication_detail_page.dart';

class ArchivesPage extends ConsumerStatefulWidget {
  const ArchivesPage({super.key});

  @override
  ConsumerState<ArchivesPage> createState() => _ArchivesPageState();
}

class _ArchivesPageState extends ConsumerState<ArchivesPage> {
  static const _yearAll = 'all';
  static const _preacherAll = 'all';

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      ref.read(predicationListProvider.notifier).loadMore();
    }
  }

  PredicationQuery get _currentQuery =>
      ref.read(predicationListProvider).valueOrNull?.query ??
      const PredicationQuery();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asyncState = ref.watch(predicationListProvider);
    final currentYear = DateTime.now().year;
    const firstArchiveYear = 1990;
    final years = List.generate(
      currentYear - firstArchiveYear + 1,
      (i) => (currentYear - i).toString(),
    );
    final selectedYear = asyncState.valueOrNull?.query.year;
    final selectedPreacher = asyncState.valueOrNull?.query.preacher;
    final currentQuery = asyncState.valueOrNull?.query ?? const PredicationQuery();
    final extraFilterCount = currentQuery.extraFilterCount;
    final preachersAsync = ref.watch(predicationPreachersProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.archivesTitle),
        actions: [
          Tooltip(
            message: 'Audios Branham.org',
            child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const BranhamPredicationsPage(),
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.accentOnSurface,
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/wmb.jpg',
                    width: 26,
                    height: 26,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'WMB',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.library_music_rounded, size: 20),
              ],
            ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(predicationPreachersProvider);
              ref.invalidate(predicationLocationsProvider);
              ref.read(predicationListProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: AppTheme.white),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                ref.read(predicationListProvider.notifier).applyQuery(
                      _currentQuery.copyWith(search: value.trim()),
                    );
              },
              decoration: InputDecoration(
                hintText: l10n.archivesSearchHint,
                hintStyle: TextStyle(color: AppTheme.muted),
                prefixIcon:
                    Icon(Icons.search, color: AppTheme.accentOnSurface),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.clear, color: AppTheme.grey),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(predicationListProvider.notifier)
                              .applyQuery(_currentQuery.copyWith(search: ''));
                          setState(() {});
                        },
                      ),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: ShtFilterDropdown<String>(
                    label: l10n.filterYear,
                    icon: Icons.calendar_today_outlined,
                    padding: EdgeInsets.zero,
                    value: selectedYear ?? _yearAll,
                    items: [
                      DropdownMenuItem(
                        value: _yearAll,
                        child: Text(l10n.all),
                      ),
                      ...years.map(
                        (year) => DropdownMenuItem(
                          value: year,
                          child: Text(year),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      if (value == _yearAll) {
                        ref.read(predicationListProvider.notifier).applyQuery(
                              _currentQuery.copyWith(clearYear: true),
                            );
                      } else {
                        ref.read(predicationListProvider.notifier).applyQuery(
                              _currentQuery.copyWith(year: value),
                            );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: preachersAsync.when(
                    data: (catalog) {
                      final preachers = catalog.labels;
                      if (preachers.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final activePreacher = selectedPreacher != null &&
                              catalog.containsLabel(selectedPreacher)
                          ? selectedPreacher
                          : _preacherAll;
                      return ShtFilterDropdown<String>(
                        label: l10n.filterPreacher,
                        icon: Icons.person_outline,
                        padding: EdgeInsets.zero,
                        value: activePreacher,
                        items: [
                          DropdownMenuItem(
                            value: _preacherAll,
                            child: Text(l10n.allItems),
                          ),
                          ...preachers.map(
                            (preacher) => DropdownMenuItem(
                              value: preacher,
                              child: Text(
                                preacher,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          if (value == _preacherAll) {
                            ref
                                .read(predicationListProvider.notifier)
                                .applyQuery(
                                  _currentQuery.copyWith(clearPreacher: true),
                                );
                          } else {
                            // Affiche tous les sermons du prédicateur :
                            // sans année (souvent hors année courante) et
                            // sans texte de recherche résiduel.
                            _searchController.clear();
                            ref
                                .read(predicationListProvider.notifier)
                                .applyQuery(
                                  _currentQuery.copyWith(
                                    preacher: value,
                                    clearYear: true,
                                    clearSearch: true,
                                  ),
                                );
                            setState(() {});
                          }
                        },
                      );
                    },
                    loading: () => const SizedBox(height: 56),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => showArchivesExtraFiltersSheet(
                  context,
                  ref,
                  current: currentQuery,
                  onApply: (query) => ref
                      .read(predicationListProvider.notifier)
                      .applyQuery(query),
                ),
                icon: Badge(
                  isLabelVisible: extraFilterCount > 0,
                  label: Text('$extraFilterCount'),
                  backgroundColor: AppTheme.crossRed,
                  child: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: AppTheme.accentOnSurface,
                  ),
                ),
                label: Text(
                  extraFilterCount > 0
                      ? l10n.filterMoreActive(extraFilterCount)
                      : l10n.filterMore,
                  style: TextStyle(
                    color: extraFilterCount > 0
                        ? AppTheme.goldOnSurface
                        : AppTheme.softWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          if (extraFilterCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                archivesExtraFilterSummary(l10n, currentQuery),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: asyncState.when(
              loading: () => Center(
                child: SpinKitFadingCircle(
                  color: AppTheme.accentOnSurface,
                  size: 48,
                ),
              ),
              error: (error, _) => _ErrorState(
                message: formatNetworkError(context.l10n, error),
                onRetry: () =>
                    ref.read(predicationListProvider.notifier).refresh(),
              ),
              data: (state) {
                if (state.items.isEmpty) {
                  return const _EmptyState();
                }

                return RefreshIndicator(
                  color: AppTheme.accentOnSurface,
                  backgroundColor: AppTheme.background,
                  onRefresh: () =>
                      ref.read(predicationListProvider.notifier).refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount:
                        state.items.length + (state.isLoadingMore ? 2 : 1),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            l10n.predicationCount(state.totalCount),
                            style: TextStyle(color: AppTheme.grey,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }

                      final itemIndex = index - 1;
                      if (itemIndex >= state.items.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SpinKitThreeBounce(
                              color: AppTheme.accentOnSurface,
                              size: 24,
                            ),
                          ),
                        );
                      }

                      final predication = state.items[itemIndex];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PredicationTile(
                          predication: predication,
                          onTap: () => _openDetail(predication),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(Predication predication) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PredicationDetailPage(predication: predication),
      ),
    );
  }
}

class _PredicationTile extends ConsumerWidget {
  const _PredicationTile({
    required this.predication,
    required this.onTap,
  });

  static const _thumbWidth = 108.0;

  final Predication predication;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context);
    final l10n = context.l10n;
    final videoId = predication.primaryVideoId;
    final durationAsync = videoId != null
        ? ref.watch(predicationDurationProvider(videoId))
        : null;

    return ShtCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _thumbWidth,
              child: _Thumbnail(url: predication.thumbnailUrl),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      predicationDisplayTitle(l10n, predication),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      predication.displayPreacher,
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
                            '${formatShortDate(predication.date, locale)} · ${predicationTimeLabel(l10n, predication.timeType)}',
                            style: TextStyle(
                              color: AppTheme.grey,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                        if (durationAsync != null)
                          durationAsync.when(
                            data: (seconds) {
                              if (seconds == null || seconds <= 0) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                mediaDurationLabel(seconds),
                                style: TextStyle(
                                  color: AppTheme.muted,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, _) => const SizedBox.shrink(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: _MetaBadge(
                            label: predicationTypeLabel(l10n, predication.type),
                          ),
                        ),
                        if (predication.hasVideo)
                          Icon(Icons.videocam_outlined,
                              size: 16, color: AppTheme.grey),
                        if (predication.hasVideo && predication.hasAudio)
                          const SizedBox(width: 4),
                        if (predication.hasAudio)
                          Icon(Icons.headphones_outlined,
                              size: 16, color: AppTheme.grey),
                        MediaListActions.predication(l10n, predication),
                        IconButton(
                          tooltip: l10n.share,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          onPressed: () =>
                              sharePredication(context, predication),
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
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    this.url,
  }) : width = 108;

  final String? url;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
      child: SizedBox(
        width: width,
        child: url == null
            ? _fallback()
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, _) => _fallback(),
                errorWidget: (_, _, _) => _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() {
    return ColoredBox(
      color: AppTheme.surfaceElevated,
      child: Center(
        child: Image.asset(
          AppConstants.logoAsset,
          width: 42,
          height: 42,
          errorBuilder: (_, _, _) => Icon(
            Icons.menu_book,
            color: AppTheme.accentOnSurface,
          ),
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.label});

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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 56, color: AppTheme.muted),
            SizedBox(height: 14),
            Text(
              l10n.archivesEmpty,
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              l10n.archivesEmptyHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppTheme.errorRed),
            const SizedBox(height: 14),
            Text(
              l10n.archivesLoadError,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
