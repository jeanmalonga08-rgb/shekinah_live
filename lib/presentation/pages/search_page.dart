import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/locale_format.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/cantique.dart';
import '../../domain/entities/predication.dart';
import '../providers/cantique_provider.dart';
import '../providers/predication_provider.dart';
import '../widgets/media_list_actions.dart';
import '../widgets/sht_widgets.dart';
import 'cantique_detail_page.dart';
import 'predication_detail_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  String _query = '';
  bool _loadingPredications = false;
  String? _predicationError;
  List<Predication> _predications = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String raw) {
    final value = raw.trim();
    setState(() => _query = value);
    _debounce?.cancel();

    if (value.isEmpty) {
      setState(() {
        _predications = const [];
        _predicationError = null;
        _loadingPredications = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _searchPredications(value);
    });
  }

  Future<void> _searchPredications(String query) async {
    setState(() {
      _loadingPredications = true;
      _predicationError = null;
    });

    try {
      final page = await ref.read(predicationDataSourceProvider).fetchPredications(
            query: query,
            year: null,
            page: 0,
          );
      if (!mounted || _query != query) return;
      setState(() {
        _predications = page.items;
        _loadingPredications = false;
      });
    } catch (e) {
      if (!mounted || _query != query) return;
      setState(() {
        _predicationError = e.toString();
        _predications = const [];
        _loadingPredications = false;
      });
    }
  }

  List<Cantique> _filterCantiques(List<Cantique> all) {
    if (_query.isEmpty) return const [];
    final q = _query.toLowerCase();
    return all.where((c) {
      return c.title.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q) ||
          c.number.toString().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cantiquesAsync = ref.watch(cantiqueListProvider);
    final cantiques = _filterCantiques(cantiquesAsync.valueOrNull ?? const []);
    final hasQuery = _query.isNotEmpty;
    final isLoading =
        _loadingPredications || (hasQuery && cantiquesAsync.isLoading);
    final hasResults = _predications.isNotEmpty || cantiques.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          style: TextStyle(color: AppTheme.white, fontSize: 16),
          textInputAction: TextInputAction.search,
          onChanged: _onQueryChanged,
          onSubmitted: (value) {
            _debounce?.cancel();
            final q = value.trim();
            setState(() => _query = q);
            if (q.isNotEmpty) _searchPredications(q);
          },
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            hintStyle: TextStyle(color: AppTheme.muted),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _debounce?.cancel();
                _controller.clear();
                setState(() {
                  _query = '';
                  _predications = const [];
                  _predicationError = null;
                  _loadingPredications = false;
                });
                _focusNode.requestFocus();
              },
            ),
        ],
      ),
      body: !hasQuery
          ? const _HintState()
          : isLoading && !hasResults
              ? Center(
                  child: SpinKitFadingCircle(
                    color: AppTheme.accentOnSurface,
                    size: 48,
                  ),
                )
              : _predicationError != null && !hasResults
                  ? _ErrorState(
                      message: _predicationError!,
                      onRetry: () => _searchPredications(_query),
                    )
                  : !hasResults && !isLoading
                      ? const _EmptyState()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                          children: [
                            if (_loadingPredications)
                              Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: Center(
                                  child: SpinKitThreeBounce(
                                    color: AppTheme.accentOnSurface,
                                    size: 22,
                                  ),
                                ),
                              ),
                            if (_predications.isNotEmpty) ...[
                              _SectionHeader(
                                title: l10n.searchSectionPredications,
                                count: _predications.length,
                              ),
                              const SizedBox(height: 10),
                              ..._predications.map(
                                (p) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _PredicationResultTile(
                                    predication: p,
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PredicationDetailPage(
                                          predication: p,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (cantiques.isNotEmpty) ...[
                              _SectionHeader(
                                title: l10n.searchSectionCantiques,
                                count: cantiques.length,
                              ),
                              const SizedBox(height: 10),
                              ...cantiques.map(
                                (c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _CantiqueResultTile(
                                    cantique: c,
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CantiqueDetailPage(cantique: c),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(color: AppTheme.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: TextStyle(color: AppTheme.grey, fontSize: 13),
        ),
      ],
    );
  }
}

class _HintState extends StatelessWidget {
  const _HintState();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, color: AppTheme.accentOnSurface, size: 42),
            SizedBox(height: 14),
            Text(
              l10n.searchTypeHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grey, height: 1.4),
            ),
          ],
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
        padding: EdgeInsets.all(28),
        child: Text(
          l10n.searchNoResults,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.grey),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, color: AppTheme.grey, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _PredicationResultTile extends StatelessWidget {
  const _PredicationResultTile({
    required this.predication,
    required this.onTap,
  });

  final Predication predication;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final l10n = context.l10n;

    return ShtCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 86,
              child: predication.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: predication.thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => _thumbFallback(),
                      errorWidget: (_, _, _) => _thumbFallback(),
                    )
                  : _thumbFallback(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      predicationDisplayTitle(l10n, predication),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppTheme.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      predication.displayPreacher,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.goldOnSurface,
                        fontSize: 12.5,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '${formatShortDate(predication.date, locale)} · ${predicationTimeLabel(l10n, predication.timeType)}',
                          style:
                              TextStyle(color: AppTheme.muted, fontSize: 11.5),
                        ),
                        const Spacer(),
                        MediaListActions.predication(l10n, predication),
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

  Widget _thumbFallback() {
    return Container(
      color: AppTheme.surfaceElevated,
      alignment: Alignment.center,
      child: Image.asset(
        AppConstants.logoAsset,
        width: 36,
        height: 36,
        errorBuilder: (_, _, _) =>
            Icon(Icons.menu_book, color: AppTheme.accentOnSurface),
      ),
    );
  }
}

class _CantiqueResultTile extends StatelessWidget {
  const _CantiqueResultTile({
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
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.accentOnSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${cantique.number}',
              style: TextStyle(
                color: AppTheme.accentOnSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cantiqueDisplayTitle(l10n, cantique),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppTheme.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cantique.category,
                  style: TextStyle(color: AppTheme.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          MediaListActions.cantique(l10n, cantique),
          Icon(Icons.chevron_right, color: AppTheme.muted),
        ],
      ),
    );
  }
}
