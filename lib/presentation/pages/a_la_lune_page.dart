import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/locale_content_resolver.dart';
import '../../core/l10n/locale_format.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../providers/locale_provider.dart';
import '../../core/utils/network_error_utils.dart';
import '../../domain/entities/communique.dart';
import '../../domain/entities/predication.dart';
import '../../l10n/app_localizations.dart';
import '../providers/communique_provider.dart';
import '../providers/predication_provider.dart';
import '../widgets/sht_widgets.dart';
import '../widgets/sinistre_majeur_card.dart';
import 'predication_detail_page.dart';

class ALaLunePage extends ConsumerWidget {
  const ALaLunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communiqueState = ref.watch(communiqueProvider);
    final recentState = ref.watch(recentMonthPredicationsProvider);
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider) ?? const Locale('fr', 'FR');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.aLaLuneTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(communiqueProvider.notifier).refresh();
              ref.invalidate(recentMonthPredicationsProvider);
            },
          ),
        ],
      ),
      body: communiqueState.when(
        loading: () => Center(
          child: SpinKitFadingCircle(
            color: AppTheme.accentGold,
            size: 50,
          ),
        ),
        error: (error, _) => _ErrorState(
          message: formatNetworkError(context.l10n, error),
          onRetry: () => ref.read(communiqueProvider.notifier).refresh(),
        ),
        data: (communiques) {
          final selectedCommunique = communiques.isEmpty
              ? null
              : pickCommunique(communiques, locale);

          return RefreshIndicator(
            color: AppTheme.accentGold,
            backgroundColor: AppTheme.background,
            onRefresh: () async {
              await ref.read(communiqueProvider.notifier).refresh();
              ref.invalidate(recentMonthPredicationsProvider);
              await ref.read(recentMonthPredicationsProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                const SinistreMajeurCard(),
                const SizedBox(height: 22),
                _SectionTitle(
                  title: l10n.aLaLuneOfficialCommunique,
                  subtitle: l10n.aLaLuneSubtitle,
                ),
                if (selectedCommunique == null)
                  ShtCard(
                    child: Text(
                      l10n.aLaLuneNoCommunique,
                      style: TextStyle(color: AppTheme.grey),
                    ),
                  )
                else
                  _CommuniqueCard(communique: selectedCommunique),
                const SizedBox(height: 14),
                const _TemplePhotosSlider(),
                const SizedBox(height: 22),
                _SectionTitle(
                  title: l10n.aLaLuneRecentPredications,
                  subtitle: l10n.homeRecentPredicationsBody,
                ),
                recentState.when(
                  loading: () => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: SpinKitThreeBounce(
                        color: AppTheme.accentGold,
                        size: 22,
                      ),
                    ),
                  ),
                  error: (_, _) => ShtCard(
                    child: Text(
                      l10n.archivesLoadError,
                      style: TextStyle(color: AppTheme.grey),
                    ),
                  ),
                  data: (predications) {
                    if (predications.isEmpty) {
                      return ShtCard(
                        child: Text(
                          l10n.archivesEmpty,
                          style: TextStyle(color: AppTheme.grey),
                        ),
                      );
                    }
                    return _RecentPredicationsSlider(
                      predications: predications.take(2).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.accentGold,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(color: AppTheme.grey,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplePhotoItem {
  const _TemplePhotoItem({
    required this.asset,
    required this.titleKey,
  });

  final String asset;
  final _TemplePhotoTitleKey titleKey;
}

enum _TemplePhotoTitleKey { sanctuary, balcony }

String _templePhotoTitle(AppLocalizations l10n, _TemplePhotoTitleKey key) {
  return switch (key) {
    _TemplePhotoTitleKey.sanctuary => l10n.aLaLuneSanctuaryAfter,
    _TemplePhotoTitleKey.balcony => l10n.aLaLuneBalconyAfter,
  };
}

class _TemplePhotosSlider extends StatefulWidget {
  const _TemplePhotosSlider();

  static const items = [
    _TemplePhotoItem(
      asset: 'assets/images/sanctuary-after.jpeg',
      titleKey: _TemplePhotoTitleKey.sanctuary,
    ),
    _TemplePhotoItem(
      asset: 'assets/images/balcony-after.jpeg',
      titleKey: _TemplePhotoTitleKey.balcony,
    ),
  ];

  @override
  State<_TemplePhotosSlider> createState() => _TemplePhotosSliderState();
}

class _TemplePhotosSliderState extends State<_TemplePhotosSlider> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.96);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const items = _TemplePhotosSlider.items;

    return Column(
      children: [
        SizedBox(
          height: 156,
          child: PageView.builder(
            controller: _controller,
            itemCount: items.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final item = items[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _TemplePhotoCard(
                  item: item,
                  indexLabel: '${i + 1}/${items.length}',
                  l10n: l10n,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.accentGold
                    : AppTheme.grey.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _TemplePhotoCard extends StatelessWidget {
  const _TemplePhotoCard({
    required this.item,
    required this.indexLabel,
    required this.l10n,
  });

  final _TemplePhotoItem item;
  final String indexLabel;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ShtCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: SizedBox(
                width: 108,
                child: Image.asset(
                  item.asset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppTheme.royalBlue.withValues(alpha: 0.25),
                    child: Icon(
                      Icons.photo,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.homeTempleMoriah,
                            style: TextStyle(
                              color: AppTheme.goldLight,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          indexLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _templePhotoTitle(l10n, item.titleKey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppTheme.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.homeTempleMoriah,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.goldLight,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.homeAfterReconstruction,
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontSize: 12,
                      ),
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

class _RecentPredicationsSlider extends StatefulWidget {
  const _RecentPredicationsSlider({required this.predications});

  final List<Predication> predications;

  @override
  State<_RecentPredicationsSlider> createState() =>
      _RecentPredicationsSliderState();
}

class _RecentPredicationsSliderState extends State<_RecentPredicationsSlider> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.96);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.predications;
    return Column(
      children: [
        SizedBox(
          height: 156,
          child: PageView.builder(
            controller: _controller,
            itemCount: items.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final predication = items[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _PredicationSlideCard(
                  predication: predication,
                  indexLabel: '${i + 1}/${items.length}',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            PredicationDetailPage(predication: predication),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (items.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(items.length, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active
                      ? AppTheme.accentGold
                      : AppTheme.grey.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _PredicationSlideCard extends StatelessWidget {
  const _PredicationSlideCard({
    required this.predication,
    required this.indexLabel,
    required this.onTap,
  });

  final Predication predication;
  final String indexLabel;
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
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: SizedBox(
                width: 108,
                child: predication.thumbnailUrl == null
                    ? _fallback()
                    : CachedNetworkImage(
                        imageUrl: predication.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _fallback(),
                        errorWidget: (_, _, _) => _fallback(),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.royalBlue.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.homePredicationBadge,
                            style: TextStyle(
                              color: AppTheme.softWhite,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          indexLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      predicationDisplayTitle(l10n, predication),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppTheme.white,
                        fontSize: 15,
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
                        color: AppTheme.goldLight,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${formatShortDate(predication.date, locale)} · ${predicationTimeLabel(l10n, predication.timeType)}',
                      style: TextStyle(color: AppTheme.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.royalBlue.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            predicationTypeLabel(l10n, predication.type),
                            style: TextStyle(color: AppTheme.softWhite,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (predication.hasVideo)
                          Icon(Icons.videocam_outlined,
                              size: 16, color: AppTheme.grey),
                        if (predication.hasVideo && predication.hasAudio)
                          const SizedBox(width: 6),
                        if (predication.hasAudio)
                          Icon(Icons.headphones_outlined,
                              size: 16, color: AppTheme.grey),
                        Icon(Icons.chevron_right,
                            size: 18, color: AppTheme.muted),
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

  Widget _fallback() {
    return ColoredBox(
      color: AppTheme.surfaceElevated,
      child: Center(
        child: Image.asset(
          AppConstants.logoAsset,
          width: 42,
          height: 42,
          errorBuilder: (_, _, _) => Icon(
            Icons.menu_book,
            color: AppTheme.accentGold,
          ),
        ),
      ),
    );
  }
}

class _CommuniqueCard extends StatelessWidget {
  final Communique communique;

  const _CommuniqueCard({required this.communique});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.crossRed.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.crossRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.campaign_outlined,
                  color: AppTheme.crossRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      communique.title,
                      style: TextStyle(color: AppTheme.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    if (communique.language != 'fr')
                      Text(
                        communique.language.toUpperCase(),
                        style: TextStyle(color: AppTheme.grey,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CommuniqueMessage(message: communique.message),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openDetails(communique.readMoreUrl),
              icon: const Icon(Icons.open_in_new),
              label: Text(communique.readMoreLabel),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDetails(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _CommuniqueMessage extends StatelessWidget {
  final String message;

  const _CommuniqueMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final plainText = message
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .trim();

    final quoteMatch = RegExp(r'"([^"]+)"').firstMatch(plainText);
    final bodyText = plainText.split('"').first.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bodyText.isNotEmpty)
          Text(
            bodyText,
            style: TextStyle(color: AppTheme.softWhite,
              height: 1.55,
              fontSize: 15,
            ),
          ),
        if (quoteMatch != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.2)),
            ),
            child: Text(
              '"${quoteMatch.group(1)}"',
              style: TextStyle(
                color: AppTheme.goldLight,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text(
              l10n.networkError,
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: AppTheme.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
