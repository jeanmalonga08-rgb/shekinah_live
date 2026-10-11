import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/offline_media.dart';
import '../providers/library_provider.dart';
import '../providers/offline_media_provider.dart';
import 'library_section.dart';

class LibraryHomeTab extends ConsumerWidget {
  const LibraryHomeTab({
    super.key,
    required this.onOpenSection,
    required this.onOpenOfflineLibrary,
  });

  final ValueChanged<LibrarySection> onOpenSection;
  final VoidCallback onOpenOfflineLibrary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final booksAsync = ref.watch(libraryBooksProvider);
    final messagesAsync = ref.watch(libraryMessagesProvider);
    final offlineItems =
        ref.watch(offlineMediaProvider).valueOrNull ?? const <OfflineMediaItem>[];
    final offlineLibraryCount =
        offlineItems.where((e) => isLibraryOfflineCategory(e.category)).length;

    final pepitesCountLabel = booksAsync.when(
      data: (books) => l10n.libraryBooksAvailable(books.length),
      loading: () => '…',
      error: (_, _) => l10n.libraryCatalogLoadError,
    );
    final publicationCountLabel = messagesAsync.when(
      data: (messages) => l10n.libraryMessagesAvailable(messages.length),
      loading: () => '…',
      error: (_, _) => l10n.libraryCatalogLoadError,
    );

    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(isLandscape ? 12 : 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.accentOnSurface.withValues(alpha: 0.14),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _LibraryHubTile(
                icon: Icons.menu_book_rounded,
                title: l10n.libraryPepites,
                countLabel: pepitesCountLabel,
                detail: l10n.libraryPepitesDescription,
                onTap: () => onOpenSection(LibrarySection.pepites),
                landscape: isLandscape,
              ),
            ),
            SizedBox(height: isLandscape ? 10 : 12),
            Expanded(
              child: _LibraryHubTile(
                assetIcon: AppConstants.shekinahPublicationEagleAsset,
                title: l10n.libraryPublication,
                countLabel: publicationCountLabel,
                detail: l10n.libraryPublicationDescription,
                onTap: () => onOpenSection(LibrarySection.publication),
                landscape: isLandscape,
              ),
            ),
            SizedBox(height: isLandscape ? 10 : 12),
            Expanded(
              child: _LibraryHubTile(
                icon: Icons.cloud_download_outlined,
                title: l10n.libraryOfflineLink,
                countLabel: offlineLibraryCount > 0
                    ? l10n.offlineFileCount(offlineLibraryCount)
                    : l10n.libraryOfflineLinkSubtitle,
                detail: l10n.libraryOfflineLinkSubtitle,
                onTap: onOpenOfflineLibrary,
                landscape: isLandscape,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryHubTile extends StatelessWidget {
  const _LibraryHubTile({
    this.icon,
    this.assetIcon,
    required this.title,
    required this.countLabel,
    required this.detail,
    required this.onTap,
    this.landscape = false,
  }) : assert(icon != null || assetIcon != null);

  final IconData? icon;
  final String? assetIcon;
  final String title;
  final String countLabel;
  final String detail;
  final VoidCallback onTap;
  final bool landscape;

  @override
  Widget build(BuildContext context) {
    final iconBadge = _IconBadge(
      icon: icon,
      assetIcon: assetIcon,
      size: landscape ? 72 : 56,
      iconSize: landscape ? 36 : 28,
    );

    return Material(
      color: AppTheme.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: landscape ? 18 : 16,
            vertical: landscape ? 14 : 16,
          ),
          child: Row(
            children: [
              iconBadge,
              SizedBox(width: landscape ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w800,
                        fontSize: landscape ? 18 : 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      countLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.accentOnSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: landscape ? 14 : 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      detail,
                      maxLines: landscape ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: landscape ? 13 : 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.muted,
                size: landscape ? 30 : 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    this.icon,
    this.assetIcon,
    required this.size,
    required this.iconSize,
  });

  final IconData? icon;
  final String? assetIcon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.accentOnSurface.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size >= 70 ? 18 : 14),
      ),
      alignment: Alignment.center,
      child: assetIcon != null
          ? Padding(
              padding: EdgeInsets.all(size >= 70 ? 12 : 10),
              child: Image.asset(
                assetIcon!,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.menu_book_outlined,
                  color: AppTheme.accentOnSurface,
                  size: iconSize,
                ),
              ),
            )
          : Icon(icon, color: AppTheme.accentOnSurface, size: iconSize),
    );
  }
}
