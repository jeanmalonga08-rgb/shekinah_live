import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/utils/network_error_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/cantique.dart';
import '../providers/cantique_provider.dart';
import '../widgets/content_share_helper.dart';
import '../widgets/media_list_actions.dart';
import '../widgets/sht_widgets.dart';
import 'cantique_detail_page.dart';

class CantiquesPage extends ConsumerStatefulWidget {
  const CantiquesPage({super.key});

  @override
  ConsumerState<CantiquesPage> createState() => _CantiquesPageState();
}

class _CantiquesPageState extends ConsumerState<CantiquesPage> {
  static const _formatAll = 'all';
  static const _formatVideo = 'video';
  static const _formatAudio = 'audio';
  static const _categoryAll = 'all';

  final _searchController = TextEditingController();
  String _query = '';
  String _formatFilter = _formatAll;
  String _categoryFilter = _categoryAll;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asyncState = ref.watch(cantiqueListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.cantiquesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(cantiqueListProvider.notifier).refresh(),
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
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: l10n.cantiquesSearchHint,
                hintStyle: TextStyle(color: AppTheme.muted),
                prefixIcon:
                    Icon(Icons.search, color: AppTheme.accentOnSurface),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.clear, color: AppTheme.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
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
            ),
          ),
          const SizedBox(height: 12),
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
                    ref.read(cantiqueListProvider.notifier).refresh(),
              ),
              data: (cantiques) {
                final categories = cantiques
                    .map((c) => c.category)
                    .toSet()
                    .toList()
                  ..sort();
                final activeCategory =
                    _categoryFilter != _categoryAll &&
                            !categories.contains(_categoryFilter)
                        ? _categoryAll
                        : _categoryFilter;
                if (activeCategory != _categoryFilter) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _categoryFilter = activeCategory);
                    }
                  });
                }

                final filtered = cantiques.where((c) {
                  if (!_matchesFormat(c, _formatFilter)) return false;
                  if (!_matchesCategory(c, activeCategory)) return false;
                  if (_query.isEmpty) return true;
                  final q = _query.toLowerCase();
                  return c.title.toLowerCase().contains(q) ||
                      c.category.toLowerCase().contains(q) ||
                      (c.performer?.toLowerCase().contains(q) ?? false) ||
                      c.number.toString().contains(q);
                }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: ShtFilterDropdown<String>(
                              label: l10n.filterFormat,
                              icon: Icons.play_circle_outline,
                              padding: EdgeInsets.zero,
                              value: _formatFilter,
                              items: [
                                DropdownMenuItem(
                                  value: _formatAll,
                                  child: Text(l10n.allItems),
                                ),
                                DropdownMenuItem(
                                  value: _formatVideo,
                                  child: Text(l10n.video),
                                ),
                                DropdownMenuItem(
                                  value: _formatAudio,
                                  child: Text(l10n.audio),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _formatFilter = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: ShtFilterDropdown<String>(
                              label: l10n.filterBy,
                              icon: Icons.library_music_outlined,
                              padding: EdgeInsets.zero,
                              value: activeCategory,
                              items: [
                                DropdownMenuItem(
                                  value: _categoryAll,
                                  child: Text(l10n.allItems),
                                ),
                                ...categories.map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      cantiqueCategoryLabel(l10n, category),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _categoryFilter = value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? const _EmptyState()
                          : RefreshIndicator(
                              color: AppTheme.accentOnSurface,
                              backgroundColor: AppTheme.background,
                              onRefresh: () => ref
                                  .read(cantiqueListProvider.notifier)
                                  .refresh(),
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                itemCount: filtered.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 14),
                                      child: Text(
                                        l10n.cantiqueCount(filtered.length),
                                        style: TextStyle(color: AppTheme.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }
                                  final cantique = filtered[index - 1];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _CantiqueTile(
                                      cantique: cantique,
                                      onTap: () => _openDetail(cantique),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(Cantique cantique) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CantiqueDetailPage(cantique: cantique),
      ),
    );
  }

  bool _matchesFormat(Cantique cantique, String format) {
    switch (format) {
      case _formatVideo:
        return cantique.hasVideo;
      case _formatAudio:
        return cantique.hasAudio;
      case _formatAll:
      default:
        return true;
    }
  }

  bool _matchesCategory(Cantique cantique, String category) {
    if (category == _categoryAll) return true;
    return cantique.category == category;
  }
}

class _CantiqueTile extends StatelessWidget {
  const _CantiqueTile({
    required this.cantique,
    required this.onTap,
  });

  final Cantique cantique;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ShtCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Thumbnail(
              url: cantique.coverUrl,
              number: cantique.number,
              showPlay: cantique.hasVideo,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cantiqueDisplayTitle(l10n, cantique),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppTheme.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cantique.displaySubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.goldOnSurface,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cantiqueMediaLabel(l10n, cantique),
                      style: TextStyle(color: AppTheme.grey,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (cantique.hasVideo)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.crossRed.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.video,
                              style: TextStyle(
                                color: AppTheme.softWhite,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (cantique.hasVideo && cantique.hasAudio)
                          const SizedBox(width: 6),
                        if (cantique.hasAudio)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.royalBlue.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.audio,
                              style: TextStyle(
                                color: AppTheme.softWhite,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (cantique.hasVideo)
                          Icon(Icons.videocam_outlined,
                              size: 16, color: AppTheme.grey),
                        if (cantique.hasVideo && cantique.hasAudio)
                          const SizedBox(width: 6),
                        if (cantique.hasAudio)
                          Icon(Icons.headphones_outlined,
                              size: 16, color: AppTheme.grey),
                        MediaListActions.cantique(l10n, cantique),
                        IconButton(
                          tooltip: l10n.share,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          onPressed: () => shareCantique(context, cantique),
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
    required this.number,
    this.showPlay = false,
  });

  final String? url;
  final int number;
  final bool showPlay;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
      child: SizedBox(
        width: 108,
        child: Stack(
          fit: StackFit.expand,
          children: [
            url == null
                ? _fallback()
                : CachedNetworkImage(
                    imageUrl: url!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _fallback(),
                    errorWidget: (_, _, _) => _fallback(),
                  ),
            if (number > 0)
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: AppTheme.goldOnSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            if (showPlay)
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white70,
                  size: 36,
                ),
              ),
          ],
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
            Icons.music_note,
            color: AppTheme.accentOnSurface,
          ),
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
            Icon(Icons.music_note_outlined, size: 56, color: AppTheme.muted),
            SizedBox(height: 14),
            Text(
              l10n.cantiquesEmpty,
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              l10n.cantiquesEmptyHint,
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
              l10n.cantiquesLoadError,
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
