import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/network_error_utils.dart';
import '../../domain/entities/library_book.dart';
import '../../domain/entities/offline_media.dart';
import '../providers/library_provider.dart';
import '../widgets/library_list_actions.dart';
import '../widgets/library_offline_download_helper.dart';
import '../widgets/sht_widgets.dart';

class LibraryPepitesTab extends ConsumerStatefulWidget {
  const LibraryPepitesTab({super.key});

  @override
  ConsumerState<LibraryPepitesTab> createState() => _LibraryPepitesTabState();
}

class _LibraryPepitesTabState extends ConsumerState<LibraryPepitesTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final booksAsync = ref.watch(filteredLibraryBooksProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.librarySearchBooksHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (value) =>
                ref.read(libraryPepitesSearchProvider.notifier).state = value,
          ),
        ),
        Expanded(
          child: booksAsync.when(
            data: (books) {
              if (books.isEmpty) {
                return Center(child: Text(l10n.libraryNoResults));
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            downloadAllLibraryBooks(context, ref, books),
                        icon: const Icon(Icons.download_for_offline_outlined),
                        label: Text(l10n.libraryDownloadAll),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: books.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return _BookTile(book: book);
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => Center(
              child: SpinKitFadingCircle(
                color: AppTheme.accentOnSurface,
                size: 48,
              ),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(formatNetworkError(l10n, error)),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => refreshLibraryCatalog(ref),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookTile extends ConsumerWidget {
  const _BookTile({
    required this.book,
  });

  final LibraryBook book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverUrl =
        book.coverImageUrl(AppConstants.libraryAssetsBaseUrl);

    return ShtCard(
      onTap: () => openLibraryPdf(
        context,
        ref,
        title: book.title,
        pdfUrl: book.pdfUrl,
        category: OfflineMediaCategory.libraryPepite,
        sourceId: libraryBookSourceId(book),
        subtitle: book.category.isNotEmpty ? book.category : book.author,
        thumbnailUrl: coverUrl,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: coverUrl,
              width: 64,
              height: 88,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                width: 64,
                height: 88,
                color: AppTheme.surfaceElevated,
                child: Icon(Icons.menu_book, color: AppTheme.grey),
              ),
              errorWidget: (_, _, _) => Container(
                width: 64,
                height: 88,
                color: AppTheme.surfaceElevated,
                child: Icon(Icons.menu_book, color: AppTheme.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (book.category.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    libraryCategoryLabel(context.l10n, book.category),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.accentOnSurface,
                        ),
                  ),
                ],
                if (book.author.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.grey,
                        ),
                  ),
                ],
              ],
            ),
          ),
          LibraryListActions.book(book),
        ],
      ),
    );
  }
}
