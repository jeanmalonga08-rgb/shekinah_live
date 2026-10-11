import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import '../../core/network/network_guard.dart';
import '../../core/utils/location_normalizer.dart';
import '../../core/utils/preacher_name_normalizer.dart';
import '../../data/datasources/predication_remote_datasource.dart';
import '../../domain/entities/predication.dart';
import 'locale_provider.dart';

final predicationDataSourceProvider = Provider<PredicationRemoteDataSource>(
  (ref) => PredicationRemoteDataSourceImpl(dio: ref.watch(dioProvider)),
);

class PredicationQuery {
  const PredicationQuery({
    this.search = '',
    this.year,
    this.preacher,
    this.type,
    this.timeType,
    this.location,
  });

  final String search;
  final String? year;

  /// Libellé normalisé du prédicateur (pas la variante brute DB).
  final String? preacher;
  final String? type;
  final String? timeType;

  /// Libellé normalisé du lieu (pas la variante brute DB).
  final String? location;

  int get extraFilterCount {
    var count = 0;
    if (type != null && type!.isNotEmpty) count++;
    if (timeType != null && timeType!.isNotEmpty) count++;
    if (location != null && location!.isNotEmpty) count++;
    return count;
  }

  PredicationQuery copyWith({
    String? search,
    String? year,
    String? preacher,
    String? type,
    String? timeType,
    String? location,
    bool clearYear = false,
    bool clearPreacher = false,
    bool clearSearch = false,
    bool clearType = false,
    bool clearTimeType = false,
    bool clearLocation = false,
    bool clearExtraFilters = false,
  }) {
    return PredicationQuery(
      search: clearSearch ? '' : (search ?? this.search),
      year: clearYear ? null : (year ?? this.year),
      preacher: clearPreacher ? null : (preacher ?? this.preacher),
      type: clearExtraFilters || clearType ? null : (type ?? this.type),
      timeType: clearExtraFilters || clearTimeType
          ? null
          : (timeType ?? this.timeType),
      location: clearExtraFilters || clearLocation
          ? null
          : (location ?? this.location),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredicationQuery &&
          search == other.search &&
          year == other.year &&
          preacher == other.preacher &&
          type == other.type &&
          timeType == other.timeType &&
          location == other.location;

  @override
  int get hashCode =>
      Object.hash(search, year, preacher, type, timeType, location);
}

class PredicationListState {
  const PredicationListState({
    required this.items,
    required this.totalCount,
    required this.hasMore,
    required this.isLoadingMore,
    required this.query,
  });

  final List<Predication> items;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;
  final PredicationQuery query;

  PredicationListState copyWith({
    List<Predication>? items,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
    PredicationQuery? query,
  }) {
    return PredicationListState(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      query: query ?? this.query,
    );
  }
}

final predicationListProvider = AsyncNotifierProvider<PredicationListNotifier,
    PredicationListState>(PredicationListNotifier.new);

class PredicationListNotifier extends AsyncNotifier<PredicationListState> {
  /// Toutes les années par défaut : un filtre année seul excluait
  /// les prédicateurs historiques (ex. Bahoya / Tom Rae en 2015).
  PredicationQuery _query = const PredicationQuery();
  int _page = 0;

  @override
  Future<PredicationListState> build() async {
    ref.watch(localeProvider);
    return _load(reset: true);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(reset: true));
  }

  Future<void> applyQuery(PredicationQuery query) async {
    _query = query;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(reset: true));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final next = await _fetchPage(_page + 1);
      _page = next.page;
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          totalCount: next.totalCount,
          hasMore: next.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<PredicationListState> _load({required bool reset}) async {
    await ensureNetworkReady();
    if (reset) _page = 0;
    final page = await _fetchPage(_page);
    return PredicationListState(
      items: page.items,
      totalCount: page.totalCount,
      hasMore: page.hasMore,
      isLoadingMore: false,
      query: _query,
    );
  }

  Locale _contentLocale() {
    return ref.read(localeProvider) ?? const Locale('fr', 'FR');
  }

  Future<PredicationPage> _fetchPage(int page) async {
    final catalog = await ref.read(predicationPreachersProvider.future);
    final locationsCatalog = await ref.read(predicationLocationsProvider.future);
    final preacherLabel = _query.preacher?.trim();
    final preacherVariants =
        (preacherLabel != null && preacherLabel.isNotEmpty)
            ? catalog.variantsFor(preacherLabel)
            : null;
    final locationLabel = _query.location?.trim();
    final locationVariants =
        (locationLabel != null && locationLabel.isNotEmpty)
            ? locationsCatalog.variantsFor(locationLabel)
            : null;
    final searchVariants = _query.search.trim().isEmpty
        ? null
        : catalog.variantsMatchingSearch(_query.search);

    return ref.read(predicationDataSourceProvider).fetchPredications(
          query: _query.search,
          year: _query.year,
          preacherVariants: preacherVariants,
          searchPreacherVariants: searchVariants,
          type: _query.type,
          timeType: _query.timeType,
          locationVariants: locationVariants,
          page: page,
          contentLocale: _contentLocale(),
        );
  }
}

final predicationPreachersProvider =
    FutureProvider<NormalizedPreachers>((ref) {
  return ref.read(predicationDataSourceProvider).fetchPreachers();
});

final predicationLocationsProvider = FutureProvider<NormalizedLocations>((ref) {
  return ref.read(predicationDataSourceProvider).fetchLocations();
});

final videoDownloadsProvider =
    FutureProvider.family<List<VideoDownloadOption>, String>((ref, videoId) {
  return ref.read(predicationDataSourceProvider).fetchVideoDownloads(videoId);
});

final predicationDurationProvider =
    FutureProvider.family<int?, String>((ref, videoId) {
  return ref.read(predicationDataSourceProvider).fetchVideoDuration(videoId);
});

final remoteFileSizeProvider =
    FutureProvider.family<int?, String>((ref, url) {
  return ref.read(predicationDataSourceProvider).fetchRemoteFileSize(url);
});

final recentMonthPredicationsProvider =
    FutureProvider<List<Predication>>((ref) {
  ref.watch(localeProvider);
  final locale = ref.read(localeProvider) ?? const Locale('fr', 'FR');
  return ref.read(predicationDataSourceProvider).fetchRecentOfMonth(
        limit: 2,
        contentLocale: locale,
      );
});
