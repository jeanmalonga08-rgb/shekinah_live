import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../providers/library_provider.dart';
import '../widgets/sht_widgets.dart';
import 'library_home_tab.dart';
import 'library_pepites_tab.dart';
import 'library_publication_tab.dart';
import 'library_section.dart';
import 'offline_page.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key, this.initialUrl});

  final String? initialUrl;

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  late LibrarySection _section;

  @override
  void initState() {
    super.initState();
    _section = LibrarySectionX.fromUrl(widget.initialUrl) ?? LibrarySection.home;
  }

  @override
  void didUpdateWidget(covariant LibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialUrl != widget.initialUrl) {
      final nextSection =
          LibrarySectionX.fromUrl(widget.initialUrl) ?? LibrarySection.home;
      if (nextSection != _section) {
        setState(() => _section = nextSection);
      }
    }
  }

  bool get _isHome => _section == LibrarySection.home;

  void _selectSection(LibrarySection section) {
    if (section != LibrarySection.publication) {
      ref.read(libraryPublicationFilterProvider.notifier).state =
          const LibraryPublicationFilter();
    }
    setState(() => _section = section);
  }

  void _openOfflineLibrary() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const OfflinePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: _isHome
            ? null
            : IconButton(
                tooltip: l10n.libraryBackToHome,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _selectSection(LibrarySection.home),
              ),
        title: Text(
          _isHome ? l10n.libraryTitle : _section.label(l10n),
        ),
        actions: [
          if (_isHome)
            IconButton(
              tooltip: l10n.libraryOfflineLink,
              icon: const Icon(Icons.cloud_download_outlined),
              onPressed: _openOfflineLibrary,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => refreshLibraryCatalog(ref),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_section == LibrarySection.publication) ...[
            _PublicationYearFilter(),
            const SizedBox(height: 8),
            _PublicationSortFilter(),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: IndexedStack(
              index: _section.index,
              children: [
                LibraryHomeTab(
                  onOpenSection: _selectSection,
                  onOpenOfflineLibrary: _openOfflineLibrary,
                ),
                const LibraryPepitesTab(),
                const LibraryPublicationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicationYearFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final yearsAsync = ref.watch(libraryPublicationYearsProvider);
    final hasUndated = ref.watch(libraryPublicationHasUndatedProvider);
    final publicationFilter = ref.watch(libraryPublicationFilterProvider);

    return yearsAsync.when(
      data: (years) {
        return ShtFilterDropdown<String>(
          label: l10n.filterYear,
          icon: Icons.calendar_today_outlined,
          value: publicationFilter.yearKey,
          items: [
            DropdownMenuItem(
              value: LibraryPublicationFilter.yearAll,
              child: Text(l10n.allItems),
            ),
            ...years.map(
              (year) => DropdownMenuItem(
                value: year.toString(),
                child: Text(year.toString()),
              ),
            ),
            if (hasUndated)
              DropdownMenuItem(
                value: LibraryPublicationFilter.yearUndated,
                child: Text(l10n.libraryYearUnknown),
              ),
          ],
          onChanged: (value) {
            if (value == null) return;
            ref.read(libraryPublicationFilterProvider.notifier).state =
                publicationFilter.copyWith(yearKey: value);
          },
        );
      },
      loading: () => const SizedBox(height: 56),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _PublicationSortFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final publicationFilter = ref.watch(libraryPublicationFilterProvider);

    return ShtFilterDropdown<String>(
      label: l10n.librarySortBy,
      icon: Icons.sort_rounded,
      value: publicationFilter.sortKey,
      items: [
        DropdownMenuItem(
          value: LibraryPublicationFilter.sortDateDesc,
          child: Text(l10n.librarySortByDateDesc),
        ),
        DropdownMenuItem(
          value: LibraryPublicationFilter.sortDateAsc,
          child: Text(l10n.librarySortByDateAsc),
        ),
        DropdownMenuItem(
          value: LibraryPublicationFilter.sortTitle,
          child: Text(l10n.librarySortByTitle),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        ref.read(libraryPublicationFilterProvider.notifier).state =
            publicationFilter.copyWith(sortKey: value);
      },
    );
  }
}
