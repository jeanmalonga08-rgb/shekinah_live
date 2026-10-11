import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/video_suggestion.dart';
import '../pages/predication_video_page.dart';
import '../providers/video_related_provider.dart';

class VideoRelatedList extends ConsumerWidget {
  const VideoRelatedList({
    super.key,
    required this.query,
  });

  final VideoRelatedQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(videoRelatedSuggestionsProvider(query));

    return async.when(
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AppTheme.brandAccent),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        final title = switch (query.kind) {
          VideoRelatedKind.predication => l10n.videoRelatedPredications,
          VideoRelatedKind.cantique => l10n.videoRelatedCantiques,
          VideoRelatedKind.multimedia => 'Vidéos similaires ou récentes',
        };

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _VideoSuggestionTile(
                  item: item,
                  onTap: () => _openSuggestion(context, item),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openSuggestion(BuildContext context, VideoSuggestion item) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PredicationVideoPage(
          title: item.title,
          videoId: item.videoId,
          provider: item.provider,
          embedUrl: item.videoEmbedUrl,
          sourceId: item.id,
          relatedKind: item.kind,
          relatedTitle: item.title,
          relatedDate: item.date,
          predicationType: item.predicationType,
          cantiqueCategory: item.cantiqueCategory,
          multimediaCategory: item.multimediaCategory,
        ),
      ),
    );
  }
}

class _VideoSuggestionTile extends StatelessWidget {
  const _VideoSuggestionTile({
    required this.item,
    required this.onTap,
  });

  final VideoSuggestion item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 112,
                  height: 64,
                  child: item.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: item.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => _thumbFallback(),
                        )
                      : _thumbFallback(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_circle_outline, color: AppTheme.brandAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbFallback() {
    return ColoredBox(
      color: AppTheme.surfaceElevated,
      child: Center(
        child: Image.asset(
          AppConstants.logoAsset,
          width: 28,
          height: 28,
          errorBuilder: (_, _, _) =>
              Icon(Icons.videocam_outlined, color: AppTheme.grey),
        ),
      ),
    );
  }
}
