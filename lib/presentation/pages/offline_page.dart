import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/offline_media.dart';
import '../../l10n/app_localizations.dart';
import '../providers/offline_media_provider.dart';
import '../providers/offline_playback_provider.dart';
import '../widgets/content_share_helper.dart';
import '../widgets/sht_widgets.dart';
import '../utils/offline_predication_grouping.dart';
import 'library_pdf_viewer_page.dart';
import 'offline_media_player_page.dart';

/// Hub Hors ligne : 4 cards (Prédications, Cantiques, Pépites d'or, Shekinah Publication).
class OfflinePage extends ConsumerWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final asyncItems = ref.watch(offlineMediaProvider);
    final items = asyncItems.valueOrNull ?? const <OfflineMediaItem>[];

    int countOf(OfflineMediaCategory category) =>
        items.where((e) => e.category == category).length;

    final cards = [
      _OfflineHubCardData(
        category: OfflineMediaCategory.predication,
        icon: Icons.mic_none_rounded,
        title: l10n.offlineTabPredications,
        count: countOf(OfflineMediaCategory.predication),
      ),
      _OfflineHubCardData(
        category: OfflineMediaCategory.cantique,
        icon: Icons.music_note_outlined,
        title: l10n.offlineTabCantiques,
        count: countOf(OfflineMediaCategory.cantique),
      ),
      _OfflineHubCardData(
        category: OfflineMediaCategory.documentaire,
        icon: Icons.video_library_outlined,
        title: 'Documentaire - Scénette',
        count: countOf(OfflineMediaCategory.documentaire),
      ),
      _OfflineHubCardData(
        category: OfflineMediaCategory.recueilCantique,
        icon: Icons.picture_as_pdf_outlined,
        title: 'Recueils de cantiques',
        count: countOf(OfflineMediaCategory.recueilCantique),
      ),
      _OfflineHubCardData(
        category: OfflineMediaCategory.libraryPepite,
        icon: Icons.menu_book,
        title: l10n.libraryPepites,
        count: countOf(OfflineMediaCategory.libraryPepite),
      ),
      _OfflineHubCardData(
        category: OfflineMediaCategory.libraryPublication,
        assetIcon: AppConstants.shekinahPublicationEagleAsset,
        title: l10n.libraryPublication,
        count: countOf(OfflineMediaCategory.libraryPublication),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.offlineTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(offlineMediaProvider.notifier).refresh(),
          ),
        ],
      ),
      body: asyncItems.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: AppTheme.accentOnSurface),
        ),
        error: (_, _) => _ErrorState(
          onRetry: () => ref.read(offlineMediaProvider.notifier).refresh(),
        ),
        data: (_) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.accentOnSurface.withValues(alpha: 0.14),
                ),
              ),
              child: Text(
                l10n.offlineChooseSection,
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.accentOnSurface.withValues(alpha: 0.14),
                ),
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.05,
                children: [
                  for (final card in cards)
                    _OfflineHubTile(
                      icon: card.icon,
                      assetIcon: card.assetIcon,
                      title: card.title,
                      countLabel: l10n.offlineFileCount(card.count),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OfflineSectionPage(
                            category: card.category,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineHubCardData {
  const _OfflineHubCardData({
    required this.category,
    this.icon,
    this.assetIcon,
    required this.title,
    required this.count,
  }) : assert(icon != null || assetIcon != null);

  final OfflineMediaCategory category;
  final IconData? icon;
  final String? assetIcon;
  final String title;
  final int count;
}

class _OfflineHubTile extends StatelessWidget {
  const _OfflineHubTile({
    this.icon,
    this.assetIcon,
    required this.title,
    required this.countLabel,
    required this.onTap,
  }) : assert(icon != null || assetIcon != null);

  final IconData? icon;
  final String? assetIcon;
  final String title;
  final String countLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.accentOnSurface.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: assetIcon != null
                    ? Padding(
                        padding: const EdgeInsets.all(7),
                        child: Image.asset(
                          assetIcon!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.menu_book_outlined,
                            color: AppTheme.accentOnSurface,
                            size: 24,
                          ),
                        ),
                      )
                    : Icon(icon, color: AppTheme.accentOnSurface, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                countLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.accentOnSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Liste détaillée d'une catégorie hors ligne.
class OfflineSectionPage extends ConsumerStatefulWidget {
  const OfflineSectionPage({super.key, required this.category});

  final OfflineMediaCategory category;

  @override
  ConsumerState<OfflineSectionPage> createState() => _OfflineSectionPageState();
}

class _OfflineSectionPageState extends ConsumerState<OfflineSectionPage> {
  static const _formatAll = 'all';
  static const _formatAudio = 'audio';
  static const _formatVideo = 'video';
  static const _formatPdf = 'pdf';

  final _searchController = TextEditingController();
  String _query = '';
  String _formatFilterKey = _formatAll;

  bool get _isLibrary => isLibraryOfflineCategory(widget.category);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asyncItems = ref.watch(offlineMediaProvider);
    final items = asyncItems.valueOrNull ?? const <OfflineMediaItem>[];
    final filtered = _applyFilters(items);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_sectionTitle(l10n)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(offlineMediaProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: AppTheme.white),
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: l10n.offlineSearchHint,
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
          const SizedBox(height: 10),
          ShtFilterDropdown<String>(
            label: l10n.filterFormat,
            icon: Icons.tune_rounded,
            value: _formatFilterKey,
            items: [
              DropdownMenuItem(
                value: _formatAll,
                child: Text(l10n.offlineFilterAll),
              ),
              if (!_isLibrary) ...[
                DropdownMenuItem(
                  value: _formatAudio,
                  child: Text(l10n.audio),
                ),
                DropdownMenuItem(
                  value: _formatVideo,
                  child: Text(l10n.video),
                ),
              ],
              if (_isLibrary)
                DropdownMenuItem(
                  value: _formatPdf,
                  child: Text(l10n.pdf),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _formatFilterKey = value);
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: asyncItems.when(
              loading: () => Center(
                child:
                    CircularProgressIndicator(color: AppTheme.accentOnSurface),
              ),
              error: (_, _) => _ErrorState(
                onRetry: () =>
                    ref.read(offlineMediaProvider.notifier).refresh(),
              ),
              data: (_) => _MediaList(
                items: filtered,
                groupByPreacher:
                    widget.category == OfflineMediaCategory.predication,
                unknownPreacherLabel: l10n.offlineUnknownPreacher,
                emptyTitle: _emptyTitle(l10n),
                emptyHint: _emptyHint(l10n),
                noMatchTitle: l10n.offlineNoResults,
                noMatchHint: l10n.offlineNoResultsHint,
                hasActiveFilter: _hasActiveFilter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sectionTitle(AppLocalizations l10n) {
    switch (widget.category) {
      case OfflineMediaCategory.predication:
        return l10n.offlineTabPredications;
      case OfflineMediaCategory.cantique:
        return l10n.offlineTabCantiques;
      case OfflineMediaCategory.ceremony:
        return l10n.offlineTabCeremonies;
      case OfflineMediaCategory.documentaire:
        return 'Documentaire - Scénette';
      case OfflineMediaCategory.recueilCantique:
        return 'Recueils de cantiques';
      case OfflineMediaCategory.libraryPepite:
        return l10n.libraryPepites;
      case OfflineMediaCategory.libraryPublication:
        return l10n.libraryPublication;
    }
  }

  String _emptyTitle(AppLocalizations l10n) {
    switch (widget.category) {
      case OfflineMediaCategory.predication:
        return l10n.offlineEmptyPredication;
      case OfflineMediaCategory.cantique:
        return l10n.offlineEmptyCantique;
      case OfflineMediaCategory.ceremony:
        return l10n.offlineEmptyCeremony;
      case OfflineMediaCategory.documentaire:
        return 'Aucune vidéo enregistrée';
      case OfflineMediaCategory.recueilCantique:
        return 'Aucun recueil enregistré';
      case OfflineMediaCategory.libraryPepite:
      case OfflineMediaCategory.libraryPublication:
        return l10n.offlineEmptyLibrary;
    }
  }

  String _emptyHint(AppLocalizations l10n) {
    switch (widget.category) {
      case OfflineMediaCategory.predication:
        return l10n.offlineEmptyPredicationHint;
      case OfflineMediaCategory.cantique:
        return l10n.offlineEmptyCantiqueHint;
      case OfflineMediaCategory.ceremony:
        return l10n.offlineEmptyCeremonyHint;
      case OfflineMediaCategory.documentaire:
        return 'Les documentaires et scénettes téléchargés apparaîtront ici.';
      case OfflineMediaCategory.recueilCantique:
        return 'Les recueils PDF téléchargés apparaîtront ici.';
      case OfflineMediaCategory.libraryPepite:
      case OfflineMediaCategory.libraryPublication:
        return l10n.offlineEmptyLibraryHint;
    }
  }

  bool get _hasActiveFilter =>
      _query.isNotEmpty || _formatFilterKey != _formatAll;

  OfflineMediaFormat? get _formatFilter {
    switch (_formatFilterKey) {
      case _formatAudio:
        return OfflineMediaFormat.audio;
      case _formatVideo:
        return OfflineMediaFormat.video;
      case _formatPdf:
        return OfflineMediaFormat.pdf;
      default:
        return null;
    }
  }

  List<OfflineMediaItem> _applyFilters(List<OfflineMediaItem> items) {
    final q = _query.toLowerCase();
    final l10n = context.l10n;
    return items.where((e) {
      if (e.category != widget.category) return false;
      if (_formatFilter != null && e.format != _formatFilter) return false;
      if (q.isEmpty) return true;
      return e.title.toLowerCase().contains(q) ||
          e.subtitle.toLowerCase().contains(q) ||
          offlineFormatLabel(l10n, e.format).toLowerCase().contains(q) ||
          offlineCategoryLabel(l10n, e.category).toLowerCase().contains(q);
    }).toList();
  }
}

class _MediaList extends ConsumerWidget {
  const _MediaList({
    required this.items,
    required this.groupByPreacher,
    required this.unknownPreacherLabel,
    required this.emptyTitle,
    required this.emptyHint,
    required this.noMatchTitle,
    required this.noMatchHint,
    required this.hasActiveFilter,
  });

  final List<OfflineMediaItem> items;
  final bool groupByPreacher;
  final String unknownPreacherLabel;
  final String emptyTitle;
  final String emptyHint;
  final String noMatchTitle;
  final String noMatchHint;
  final bool hasActiveFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return _EmptyState(
        title: hasActiveFilter ? noMatchTitle : emptyTitle,
        hint: hasActiveFilter ? noMatchHint : emptyHint,
        icon: hasActiveFilter
            ? Icons.search_off_outlined
            : Icons.download_done_outlined,
      );
    }

    final rows = <({String? heading, OfflineMediaItem? item})>[];
    if (groupByPreacher) {
      final groups = groupOfflinePredications(
        items,
        unknownPreacherLabel: unknownPreacherLabel,
      );
      for (final entry in groups.entries) {
        rows.add((heading: entry.key, item: null));
        for (final item in entry.value) {
          rows.add((heading: null, item: item));
        }
      }
    } else {
      for (final item in items) {
        rows.add((heading: null, item: item));
      }
    }

    return RefreshIndicator(
      color: AppTheme.accentOnSurface,
      backgroundColor: AppTheme.background,
      onRefresh: () => ref.read(offlineMediaProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: rows.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final l10n = context.l10n;
            final total = items.fold<int>(0, (s, e) => s + e.fileSizeBytes);
            final totalMo = (total / (1024 * 1024)).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l10n.offlineStorageSummary(items.length, totalMo),
                style: TextStyle(color: AppTheme.grey, fontSize: 13),
              ),
            );
          }
          final row = rows[index - 1];
          if (row.heading != null) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 8),
              child: Text(
                row.heading!,
                style: TextStyle(
                  color: AppTheme.accentOnSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }
          final item = row.item!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OfflineTile(
              item: item,
              onPlay: () {
                if (item.format == OfflineMediaFormat.pdf) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LibraryPdfViewerPage(
                        title: item.title,
                        pdfUrl: '',
                        localPath: item.localPath,
                        category: item.category,
                        sourceId: item.sourceId,
                      ),
                    ),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OfflineMediaPlayerPage(
                      playlist: items
                          .where((e) => e.format != OfflineMediaFormat.pdf)
                          .toList(),
                      initialIndex: items
                          .where((e) => e.format != OfflineMediaFormat.pdf)
                          .toList()
                          .indexOf(item),
                    ),
                  ),
                );
              },
              onShare: () => shareOfflineMediaInfo(context, item),
              onFileActions: () => showOfflineFileActions(context, item),
              onDelete: () => _confirmDeleteOfflineItem(context, ref, item),
            ),
          );
        },
      ),
    );
  }

}

Future<void> _confirmDeleteOfflineItem(
  BuildContext context,
  WidgetRef ref,
  OfflineMediaItem item,
) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(l10n.deleteQuestion),
        content: Text(l10n.deleteOfflineConfirm(item.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.crossRed),
            child: Text(l10n.delete),
          ),
        ],
      );
    },
  );
  if (confirmed != true || !context.mounted) return;

  final playback = ref.read(offlinePlaybackProvider);
  if (playback.currentItem?.id == item.id) {
    await ref.read(offlinePlaybackProvider.notifier).stop();
  }
  await ref.read(offlineMediaProvider.notifier).remove(item.id);
}

class _OfflineTile extends StatelessWidget {
  const _OfflineTile({
    required this.item,
    required this.onPlay,
    required this.onShare,
    required this.onFileActions,
    required this.onDelete,
  });

  static const _thumbWidth = 108.0;

  final OfflineMediaItem item;
  final VoidCallback onPlay;
  final VoidCallback onShare;
  final VoidCallback onFileActions;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtitle = offlineItemSubtitle(l10n, item);
    final details = offlineMediaDetailsLine(l10n, item);
    final isPdf = item.format == OfflineMediaFormat.pdf;

    return ShtCard(
      onTap: onPlay,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _thumbWidth,
              child: _OfflineThumbnail(item: item),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: item.category == OfflineMediaCategory.cantique
                            ? 15
                            : 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.goldOnSurface,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        details,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.grey,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: _OfflineFormatBadge(format: item.format),
                        ),
                        const Spacer(),
                        _OfflineTileMoreMenu(
                          onExplorer: onFileActions,
                          onShare: onShare,
                          onDelete: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 10, 8),
              child: Center(
                child: IconButton(
                  tooltip: isPdf ? l10n.pdf : l10n.offlinePlay,
                  onPressed: onPlay,
                  iconSize: 46,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 52,
                    minHeight: 52,
                  ),
                  icon: Icon(
                    isPdf
                        ? Icons.menu_book_rounded
                        : Icons.play_circle_fill,
                    color: AppTheme.accentOnSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _OfflineTileMenuAction { explorer, share, delete }

class _OfflineTileMoreMenu extends StatelessWidget {
  const _OfflineTileMoreMenu({
    required this.onExplorer,
    required this.onShare,
    required this.onDelete,
  });

  final VoidCallback onExplorer;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopupMenuButton<_OfflineTileMenuAction>(
      tooltip: l10n.plusTitle,
      icon: Icon(
        Icons.more_horiz_rounded,
        color: AppTheme.accentOnSurface,
        size: 26,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      onSelected: (action) {
        switch (action) {
          case _OfflineTileMenuAction.explorer:
            onExplorer();
          case _OfflineTileMenuAction.share:
            onShare();
          case _OfflineTileMenuAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _OfflineTileMenuAction.explorer,
          child: _OfflineMenuRow(
            icon: Icons.folder_open_outlined,
            label: l10n.offlineShowInExplorer,
          ),
        ),
        PopupMenuItem(
          value: _OfflineTileMenuAction.share,
          child: _OfflineMenuRow(
            icon: Icons.share_outlined,
            label: l10n.share,
          ),
        ),
        PopupMenuItem(
          value: _OfflineTileMenuAction.delete,
          child: _OfflineMenuRow(
            icon: Icons.delete_outline,
            label: l10n.delete,
            color: AppTheme.crossRed,
          ),
        ),
      ],
    );
  }
}

class _OfflineMenuRow extends StatelessWidget {
  const _OfflineMenuRow({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppTheme.softWhite;
    return Row(
      children: [
        Icon(icon, size: 22, color: tint),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: tint, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _OfflineThumbnail extends StatelessWidget {
  const _OfflineThumbnail({required this.item});

  final OfflineMediaItem item;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.format) {
      OfflineMediaFormat.audio => Icons.headphones,
      OfflineMediaFormat.video => Icons.videocam,
      OfflineMediaFormat.pdf => Icons.picture_as_pdf_outlined,
    };
    final showPlay = item.format != OfflineMediaFormat.pdf;
    final isBranham = isOfflineWilliamBranhamPredication(item);

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isBranham)
            Image.asset(
              'assets/images/bro-branham.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _fallback(icon),
            )
          else if (item.thumbnailUrl != null)
            CachedNetworkImage(
              imageUrl: item.thumbnailUrl!,
              fit: BoxFit.cover,
              placeholder: (_, _) => _fallback(icon),
              errorWidget: (_, _, _) => _fallback(icon),
            )
          else
            _fallback(icon),
          if (showPlay)
            Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white.withValues(alpha: 0.82),
                size: 36,
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallback(IconData icon) {
    return ColoredBox(
      color: AppTheme.surfaceElevated,
      child: Center(
        child: Icon(icon, color: AppTheme.accentOnSurface, size: 28),
      ),
    );
  }
}

class _OfflineFormatBadge extends StatelessWidget {
  const _OfflineFormatBadge({required this.format});

  final OfflineMediaFormat format;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, bg, fg) = switch (format) {
      OfflineMediaFormat.video => (
          l10n.video,
          AppTheme.crossRed.withValues(alpha: 0.18),
          AppTheme.softWhite,
        ),
      OfflineMediaFormat.audio => (
          l10n.audio,
          AppTheme.royalBlue.withValues(alpha: 0.28),
          AppTheme.softWhite,
        ),
      OfflineMediaFormat.pdf => (
          l10n.pdf,
          AppTheme.accentOnSurface.withValues(alpha: 0.16),
          AppTheme.softWhite,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.hint,
    this.icon = Icons.download_done_outlined,
  });

  final String title;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppTheme.accentOnSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grey, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.offlineLoadError),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
