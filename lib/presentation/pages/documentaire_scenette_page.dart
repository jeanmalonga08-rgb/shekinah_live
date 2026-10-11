import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/network_error_utils.dart';
import '../../domain/entities/multimedia_video.dart';
import '../providers/multimedia_provider.dart';
import '../widgets/content_share_helper.dart';
import '../widgets/media_info_chips.dart';
import '../widgets/media_list_actions.dart';
import '../widgets/sht_widgets.dart';
import '../providers/predication_provider.dart';
import 'multimedia_video_detail_page.dart';

class DocumentaireScenettePage extends ConsumerStatefulWidget {
  const DocumentaireScenettePage({super.key});

  @override
  ConsumerState<DocumentaireScenettePage> createState() =>
      _DocumentaireScenettePageState();
}

class _DocumentaireScenettePageState
    extends ConsumerState<DocumentaireScenettePage> {
  static const _filterAll = 'all';

  final _searchController = TextEditingController();
  String _query = '';
  String _categoryFilter = _filterAll;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asyncVideos = ref.watch(documentaireScenetteProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Documentaire - Scénette'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(documentaireScenetteProvider.notifier).refresh(),
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
                hintText: 'Rechercher une vidéo...',
                hintStyle: TextStyle(color: AppTheme.muted),
                prefixIcon: Icon(Icons.search, color: AppTheme.accentOnSurface),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ShtFilterDropdown<String>(
              label: l10n.filterBy,
              icon: Icons.category_outlined,
              padding: EdgeInsets.zero,
              value: _categoryFilter,
              items: [
                DropdownMenuItem(
                  value: _filterAll,
                  child: Text(l10n.allItems),
                ),
                DropdownMenuItem(
                  value: MultimediaVideoCategory.documentaire.name,
                  child: Text(
                    multimediaVideoCategoryLabel(
                      l10n,
                      MultimediaVideoCategory.documentaire,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: MultimediaVideoCategory.scenette.name,
                  child: Text(
                    multimediaVideoCategoryLabel(
                      l10n,
                      MultimediaVideoCategory.scenette,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: MultimediaVideoCategory.divers.name,
                  child: Text(
                    multimediaVideoCategoryLabel(
                      l10n,
                      MultimediaVideoCategory.divers,
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
          const SizedBox(height: 8),
          Expanded(
            child: asyncVideos.when(
              loading: () => Center(
                child: SpinKitFadingCircle(
                  color: AppTheme.accentOnSurface,
                  size: 48,
                ),
              ),
              error: (error, _) => _ErrorState(
                message: formatNetworkError(l10n, error),
                onRetry: () =>
                    ref.read(documentaireScenetteProvider.notifier).refresh(),
              ),
              data: (videos) {
                final filtered = _applyFilters(videos);
                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Text(
                        l10n.libraryNoResults,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.grey, height: 1.4),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.accentOnSurface,
                  backgroundColor: AppTheme.background,
                  onRefresh: () =>
                      ref.read(documentaireScenetteProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            '${filtered.length} vidéo(s)',
                            style: TextStyle(
                              color: AppTheme.grey,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }
                      final video = filtered[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _VideoTile(
                          video: video,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  MultimediaVideoDetailPage(video: video),
                            ),
                          ),
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

  List<MultimediaVideo> _applyFilters(List<MultimediaVideo> videos) {
    final q = _query.toLowerCase();
    return videos.where((video) {
      if (_categoryFilter != _filterAll &&
          video.category.name != _categoryFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return video.title.toLowerCase().contains(q) ||
          multimediaVideoCategoryLabel(
            context.l10n,
            video.category,
          ).toLowerCase().contains(q);
    }).toList();
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({
    required this.video,
    required this.onTap,
  });

  static const _thumbWidth = 108.0;

  final MultimediaVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categoryLabel = multimediaVideoCategoryLabel(l10n, video.category);

    return ShtCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _thumbWidth,
              child: _Thumbnail(url: video.defaultThumbnailUrl),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      video.title,
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
                      categoryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.goldOnSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!video.isAvailable) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.unavailable,
                        style: TextStyle(
                          color: Colors.orangeAccent.shade200,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (video.dateLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        video.dateLabel!,
                        style: TextStyle(
                          color: AppTheme.grey,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    if (video.isAvailable) ...[
                      _VideoMediaInfo(videoId: video.videoId),
                      const SizedBox(height: 6),
                    ],
                    Row(
                      children: [
                        Flexible(
                          child: _MetaBadge(label: categoryLabel),
                        ),
                        if (video.isAvailable) ...[
                          Icon(Icons.videocam_outlined,
                              size: 16, color: AppTheme.grey),
                          MediaListActions.multimedia(l10n, video),
                          IconButton(
                            tooltip: l10n.share,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: () =>
                                shareMultimediaVideo(context, video),
                            icon: Icon(
                              Icons.share_outlined,
                              size: 18,
                              color: AppTheme.accentOnSurface,
                            ),
                          ),
                        ],
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
  const _Thumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
      child: SizedBox(
        width: 108,
        child: CachedNetworkImage(
          imageUrl: url,
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
            Icons.videocam,
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

class _VideoMediaInfo extends ConsumerWidget {
  const _VideoMediaInfo({required this.videoId});

  final String videoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(videoDownloadsProvider(videoId));
    final options = async.valueOrNull;
    int? durationSeconds;
    int? sizeBytes;
    if (options != null) {
      for (final option in options) {
        final seconds = option.durationSeconds;
        if (seconds != null && seconds > 0) {
          durationSeconds = seconds;
          break;
        }
      }
      final best = options
          .map((e) => e.sizeBytes)
          .where((e) => e > 0)
          .fold<int>(0, (a, b) => a > b ? a : b);
      if (best > 0) sizeBytes = best;
    }

    if (async.isLoading && durationSeconds == null && sizeBytes == null) {
      return SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 1.8,
          color: AppTheme.accentOnSurface,
        ),
      );
    }

    return MediaInfoChips(
      typeLabel: l10n.video,
      durationSeconds: durationSeconds,
      sizeBytes: sizeBytes,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, color: AppTheme.grey, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}
