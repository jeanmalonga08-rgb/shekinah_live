import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_provider.dart';
import '../../data/datasources/library_remote_datasource.dart';
import '../../domain/entities/library_book.dart';
import '../../domain/entities/library_message.dart';

final libraryDataSourceProvider = Provider<LibraryRemoteDataSource>(
  (ref) => LibraryRemoteDataSourceImpl(dio: ref.watch(dioProvider)),
);

final libraryBooksProvider = FutureProvider<List<LibraryBook>>((ref) async {
  return ref.watch(libraryDataSourceProvider).fetchBooks();
});

final libraryMessagesProvider = FutureProvider<List<LibraryMessage>>((ref) async {
  return ref.watch(libraryDataSourceProvider).fetchMessages();
});

class LibraryPepitesFilter {
  const LibraryPepitesFilter({this.category});

  final String? category;

  LibraryPepitesFilter copyWith({
    String? category,
    bool clearCategory = false,
  }) {
    return LibraryPepitesFilter(
      category: clearCategory ? null : (category ?? this.category),
    );
  }
}

final libraryPepitesFilterProvider = StateProvider<LibraryPepitesFilter>(
  (ref) => const LibraryPepitesFilter(),
);

final libraryPepitesSearchProvider = StateProvider<String>((ref) => '');

final libraryPublicationSearchProvider = StateProvider<String>((ref) => '');

class LibraryPublicationFilter {
  const LibraryPublicationFilter({
    this.yearKey = yearAll,
    this.sortKey = sortDateDesc,
  });

  static const yearAll = 'all';
  static const yearUndated = 'undated';
  static const sortDateDesc = 'date_desc';
  static const sortDateAsc = 'date_asc';
  static const sortTitle = 'title';

  final String yearKey;
  final String sortKey;

  bool get showsYearCards => yearKey == yearAll;

  bool get isUndated => yearKey == yearUndated;

  int? get selectedYear {
    if (showsYearCards || isUndated) return null;
    return int.tryParse(yearKey);
  }

  LibraryPublicationFilter copyWith({
    String? yearKey,
    String? sortKey,
  }) {
    return LibraryPublicationFilter(
      yearKey: yearKey ?? this.yearKey,
      sortKey: sortKey ?? this.sortKey,
    );
  }
}

final libraryPublicationFilterProvider = StateProvider<LibraryPublicationFilter>(
  (ref) => const LibraryPublicationFilter(),
);

final libraryPublicationYearsProvider = Provider<AsyncValue<List<int>>>((ref) {
  return ref.watch(libraryMessagesProvider).whenData((messages) {
    final years = messages
        .map((message) => message.date?.year)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return years;
  });
});

final libraryPublicationHasUndatedProvider = Provider<bool>((ref) {
  final messages = ref.watch(libraryMessagesProvider).valueOrNull ?? const [];
  return messages.any((message) => message.date == null);
});

final filteredLibraryBooksProvider = Provider<AsyncValue<List<LibraryBook>>>(
  (ref) {
    final booksAsync = ref.watch(libraryBooksProvider);
    final filter = ref.watch(libraryPepitesFilterProvider);
    final search = ref.watch(libraryPepitesSearchProvider);

    return booksAsync.whenData((books) {
      var result = books;
      final category = filter.category;
      if (category != null && category.isNotEmpty) {
        result = result.where((book) => book.category == category).toList();
      }
      final query = search.trim().toLowerCase();
      if (query.isNotEmpty) {
        result = result
            .where(
              (book) =>
                  book.title.toLowerCase().contains(query) ||
                  book.author.toLowerCase().contains(query) ||
                  book.category.toLowerCase().contains(query),
            )
            .toList();
      }
      return result;
    });
  },
);

final libraryBookCategoriesProvider = Provider<AsyncValue<List<String>>>((ref) {
  return ref.watch(libraryBooksProvider).whenData((books) {
    final categories = books.map((book) => book.category).toSet().toList()
      ..sort();
    return categories;
  });
});

final filteredLibraryMessagesProvider =
    Provider<AsyncValue<List<LibraryMessage>>>((ref) {
  final messagesAsync = ref.watch(libraryMessagesProvider);
  final search = ref.watch(libraryPublicationSearchProvider);

  return messagesAsync.whenData((messages) {
    final query = search.trim().toLowerCase();
    if (query.isEmpty) return messages;
    return messages
        .where((message) => message.title.toLowerCase().contains(query))
        .toList();
  });
});

class LibraryMessageYearGroup {
  const LibraryMessageYearGroup({
    required this.year,
    required this.messages,
  });

  final int? year;
  final List<LibraryMessage> messages;
}

List<LibraryMessageYearGroup> groupLibraryMessagesByYear(
  List<LibraryMessage> messages, {
  String sortKey = LibraryPublicationFilter.sortDateDesc,
}) {
  final sorted = [...messages];
  switch (sortKey) {
    case LibraryPublicationFilter.sortDateAsc:
      sorted.sort((a, b) {
        final ad = a.date;
        final bd = b.date;
        if (ad == null && bd == null) return a.title.compareTo(b.title);
        if (ad == null) return 1;
        if (bd == null) return -1;
        final cmp = ad.compareTo(bd);
        return cmp != 0 ? cmp : a.title.compareTo(b.title);
      });
      break;
    case LibraryPublicationFilter.sortTitle:
      sorted.sort((a, b) => a.title.compareTo(b.title));
      break;
    case LibraryPublicationFilter.sortDateDesc:
    default:
      sorted.sort((a, b) {
        final ad = a.date;
        final bd = b.date;
        if (ad == null && bd == null) return a.title.compareTo(b.title);
        if (ad == null) return 1;
        if (bd == null) return -1;
        final cmp = bd.compareTo(ad);
        return cmp != 0 ? cmp : a.title.compareTo(b.title);
      });
  }

  final byYear = <int?, List<LibraryMessage>>{};
  for (final message in sorted) {
    final year = message.date?.year;
    byYear.putIfAbsent(year, () => []).add(message);
  }

  final years = byYear.keys.toList()
    ..sort((a, b) {
      if (a == null) return 1;
      if (b == null) return -1;
      return b.compareTo(a);
    });

  return [
    for (final year in years)
      LibraryMessageYearGroup(year: year, messages: byYear[year]!),
  ];
}

final groupedLibraryMessagesProvider =
    Provider<AsyncValue<List<LibraryMessageYearGroup>>>((ref) {
  final sortKey = ref.watch(libraryPublicationFilterProvider).sortKey;
  return ref.watch(filteredLibraryMessagesProvider).whenData(
        (messages) => groupLibraryMessagesByYear(messages, sortKey: sortKey),
      );
});

void refreshLibraryCatalog(WidgetRef ref) {
  ref.read(libraryDataSourceProvider).clearCache();
  ref.invalidate(libraryBooksProvider);
  ref.invalidate(libraryMessagesProvider);
}
