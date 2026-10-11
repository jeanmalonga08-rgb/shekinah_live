import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/locale_format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/network_error_utils.dart';
import '../../domain/entities/library_message.dart';
import '../../domain/entities/offline_media.dart';
import '../providers/library_provider.dart';
import '../widgets/library_list_actions.dart';
import '../widgets/library_offline_download_helper.dart';
import '../widgets/sht_widgets.dart';

class LibraryPublicationTab extends ConsumerStatefulWidget {
  const LibraryPublicationTab({super.key});

  @override
  ConsumerState<LibraryPublicationTab> createState() =>
      _LibraryPublicationTabState();
}

class _LibraryPublicationTabState extends ConsumerState<LibraryPublicationTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openYear(LibraryMessageYearGroup group) {
    final yearKey = group.year?.toString() ?? LibraryPublicationFilter.yearUndated;
    ref.read(libraryPublicationFilterProvider.notifier).state =
        LibraryPublicationFilter(yearKey: yearKey);
  }

  void _backToYears() {
    ref.read(libraryPublicationFilterProvider.notifier).state =
        const LibraryPublicationFilter();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final groupsAsync = ref.watch(groupedLibraryMessagesProvider);
    final publicationFilter = ref.watch(libraryPublicationFilterProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.librarySearchMessagesHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (value) => ref
                .read(libraryPublicationSearchProvider.notifier)
                .state = value,
          ),
        ),
        Expanded(
          child: groupsAsync.when(
            data: (groups) {
              if (groups.isEmpty) {
                return Center(child: Text(l10n.libraryNoResults));
              }

              if (publicationFilter.showsYearCards) {
                return _YearCardsView(
                  groups: groups,
                  onOpenYear: _openYear,
                  onDownloadAll: () => downloadAllLibraryMessages(
                    context,
                    ref,
                    _flattenMessages(groups),
                  ),
                );
              }

              final selectedGroup = _findGroup(groups, publicationFilter);
              if (selectedGroup == null) {
                return Center(child: Text(l10n.libraryNoResults));
              }

              return _YearMessagesView(
                group: selectedGroup,
                onBack: _backToYears,
                onDownloadAll: () => downloadAllLibraryMessages(
                  context,
                  ref,
                  selectedGroup.messages,
                ),
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

List<LibraryMessage> _flattenMessages(List<LibraryMessageYearGroup> groups) {
  return [for (final group in groups) ...group.messages];
}

LibraryMessageYearGroup? _findGroup(
  List<LibraryMessageYearGroup> groups,
  LibraryPublicationFilter filter,
) {
  if (filter.isUndated) {
    for (final group in groups) {
      if (group.year == null) return group;
    }
    return null;
  }
  final year = filter.selectedYear;
  if (year == null) return null;
  for (final group in groups) {
    if (group.year == year) return group;
  }
  return null;
}

class _YearCardsView extends StatelessWidget {
  const _YearCardsView({
    required this.groups,
    required this.onOpenYear,
    required this.onDownloadAll,
  });

  final List<LibraryMessageYearGroup> groups;
  final ValueChanged<LibraryMessageYearGroup> onOpenYear;
  final VoidCallback onDownloadAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.libraryPublicationYearsHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.grey,
                      ),
                ),
              ),
              TextButton.icon(
                onPressed: onDownloadAll,
                icon: const Icon(Icons.download_for_offline_outlined),
                label: Text(l10n.libraryDownloadAll),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 124,
            ),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return _YearCard(
                group: group,
                onTap: () => onOpenYear(group),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _YearCard extends StatelessWidget {
  const _YearCard({
    required this.group,
    required this.onTap,
  });

  final LibraryMessageYearGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = group.year?.toString() ?? l10n.libraryYearUnknown;

    return ShtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.royalBlue.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: AppTheme.royalBlue,
              size: 22,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.libraryMessageCount(group.messages.length),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.grey,
                          ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppTheme.grey, size: 20),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _YearMessagesView extends StatelessWidget {
  const _YearMessagesView({
    required this.group,
    required this.onBack,
    required this.onDownloadAll,
  });

  final LibraryMessageYearGroup group;
  final VoidCallback onBack;
  final VoidCallback onDownloadAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final yearLabel = group.year?.toString() ?? l10n.libraryYearUnknown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
          child: Row(
            children: [
              IconButton(
                tooltip: l10n.libraryBackToYears,
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yearLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      l10n.libraryMessageCount(group.messages.length),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.grey,
                          ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onDownloadAll,
                icon: const Icon(Icons.download_for_offline_outlined),
                label: Text(l10n.libraryDownloadAll),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: group.messages.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _PublicationMessageTile(message: group.messages[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _PublicationMessageTile extends ConsumerWidget {
  const _PublicationMessageTile({
    required this.message,
  });

  final LibraryMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateLabel = message.date == null
        ? null
        : formatCeremonyDate(
            message.date!,
            Localizations.localeOf(context),
          );

    return ShtCard(
      onTap: () => openLibraryPdf(
        context,
        ref,
        title: message.title,
        pdfUrl: message.pdfUrl,
        category: OfflineMediaCategory.libraryPublication,
        sourceId: libraryMessageSourceId(message),
        subtitle: message.date?.year.toString() ?? '',
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dateLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    dateLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.grey,
                        ),
                  ),
                ],
              ],
            ),
          ),
          LibraryListActions.message(message),
        ],
      ),
    );
  }
}
