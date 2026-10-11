import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/locale_content_resolver.dart';
import '../../core/l10n/locale_format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_sync.dart';
import '../../core/utils/live_duration_utils.dart';
import '../../core/utils/next_worship_service.dart';
import '../../domain/entities/communique.dart';
import '../../domain/entities/predication.dart';
import '../providers/communique_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/live_stream_provider.dart';
import '../providers/predication_provider.dart';
import '../providers/theme_mode_provider.dart';
import '../widgets/app_update_banner.dart';
import '../widgets/audio_stream_hint.dart';
import '../widgets/home_header_toolbar.dart';
import '../widgets/sht_widgets.dart';
import '../widgets/sinistre_majeur_card.dart';
import 'a_la_lune_page.dart';
import 'branham_predications_page.dart';
import 'cultes_page.dart';
import 'live_page.dart';
import 'login_page.dart';
import 'notifications_page.dart';
import 'predication_detail_page.dart';
import 'search_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({
    super.key,
    this.onOpenCultes,
    this.onOpenPredications,
  });

  final VoidCallback? onOpenCultes;
  final VoidCallback? onOpenPredications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    ThemeSync.watch(context);
    final l10n = context.l10n;
    final communiques = ref.watch(communiqueProvider).valueOrNull ?? [];
    final recentPredications =
        ref.watch(recentMonthPredicationsProvider).valueOrNull ?? [];
    final liveState = ref.watch(liveStreamProvider);
    final locale = ref.watch(localeProvider) ?? const Locale('fr', 'FR');
    final slides = _buildALaUneSlides(
      context: context,
      locale: locale,
      communiques: communiques,
      recentPredications: recentPredications,
      onOpenPredications: onOpenPredications,
    );
    final openCultes = onOpenCultes ??
        () => _push(context, const CultesPage());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HomeHeader(
              onNotifications: () => _push(context, const NotificationsPage()),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _HomeSearchBar(
                onTap: () => _push(context, const SearchPage()),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: const AppUpdateBanner(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: AudioStreamHintBanner(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _LiveBanner(
                onTap: () => _push(
                  context,
                  const LivePage(startInAudioMode: true),
                ),
                isLive: liveState.isLive,
                isLoading: liveState.isLoading,
                liveStartedAt: liveState.liveStream?.liveStartedAt,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ShtSectionHeader(
              title: l10n.homeFeatured,
              actionLabel: l10n.seeAll,
              onAction: () => _push(context, const ALaLunePage()),
            ),
          ),
          SliverToBoxAdapter(
            child: _ALaUneSlider(slides: slides),
          ),
          SliverToBoxAdapter(
            child: ShtSectionHeader(
              title: l10n.homeBranhamAudioTitle,
              actionLabel: l10n.homeBranhamAudioAction,
              onAction: () => _push(context, const BranhamPredicationsPage()),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ShtCard(
                onTap: () => _push(context, const BranhamPredicationsPage()),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/wmb.jpg',
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 52,
                          height: 52,
                          color: AppTheme.surfaceElevated,
                          child: Icon(
                            Icons.library_music_rounded,
                            color: AppTheme.accentOnSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.homeBranhamAudioBody,
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.language_rounded, color: AppTheme.accentOnSurface),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ShtSectionHeader(
              title: l10n.homeTempleMoriah,
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SinistreMajeurCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: ShtSectionHeader(
              title: l10n.homeWeeklySchedule,
              actionLabel: l10n.seeMore,
              onAction: openCultes,
            ),
          ),
          SliverToBoxAdapter(
            child: _NextWorshipCard(onSeeMore: openCultes),
          ),
          SliverToBoxAdapter(
            child: ShtSectionHeader(
              title: l10n.homeImportantAnnouncements,
              actionLabel: l10n.seeAll,
              onAction: () => _push(context, const ALaLunePage()),
            ),
          ),
          if (communiques.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ShtCard(
                  onTap: () => _push(context, const ALaLunePage()),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.royalBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.campaign,
                          color: AppTheme.accentOnSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.homeCommuniquesInEffect,
                              style: TextStyle(
                                color: AppTheme.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              context.l10n.homeConsultALaLune,
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppTheme.grey),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final a = communiques[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ShtCard(
                      onTap: () => _push(context, const ALaLunePage()),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.royalBlue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.campaign,
                              color: AppTheme.accentOnSurface,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.title,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  a.language.toUpperCase(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: AppTheme.grey),
                        ],
                      ),
                    ),
                  );
                },
                childCount: communiques.length.clamp(0, 3),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  List<_ALaUneSlide> _buildALaUneSlides({
    required BuildContext context,
    required Locale locale,
    required List<Communique> communiques,
    required List<Predication> recentPredications,
    VoidCallback? onOpenPredications,
  }) {
    final l10n = context.l10n;
    final slides = <_ALaUneSlide>[];

    // 1) Prédications récentes
    if (recentPredications.isEmpty) {
      slides.add(
        _ALaUneSlide(
          badge: l10n.homePredicationBadge,
          icon: Icons.menu_book_rounded,
          title: l10n.homeRecentPredications,
          subtitle: l10n.homeThisMonth,
          body: l10n.homeRecentPredicationsBody,
          color: AppTheme.royalBlue,
          onTap: onOpenPredications,
        ),
      );
    } else {
      for (final predication in recentPredications.take(2)) {
        slides.add(
          _ALaUneSlide(
            badge: l10n.homePredicationBadge,
            icon: Icons.menu_book_rounded,
            title: predicationDisplayTitle(l10n, predication),
            subtitle: predication.displayPreacher,
            body: predicationTypeLabel(l10n, predication.type),
            color: AppTheme.royalBlue,
            predication: predication,
            onTap: () => _push(
              context,
              PredicationDetailPage(predication: predication),
            ),
          ),
        );
      }
    }

    // 2) Communiqué — images empilées à gauche, texte à droite
    if (communiques.isEmpty) {
      slides.add(
        _ALaUneSlide(
          badge: l10n.homeCommuniqueBadge,
          icon: Icons.campaign_outlined,
          title: l10n.homeOfficialCommunique,
          subtitle: l10n.homeALaLune,
          body: l10n.homeCommuniqueBody,
          color: AppTheme.crossRed,
          stackedTempleImages: true,
          onTap: () => _push(context, const ALaLunePage()),
        ),
      );
    } else {
      final c = pickCommunique(communiques, locale);
      final plain = c.message
          .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
          .replaceAll(RegExp(r'<[^>]+>'), '')
          .trim();
      slides.add(
        _ALaUneSlide(
          badge: l10n.homeCommuniqueBadge,
          icon: Icons.campaign_outlined,
          title: c.title,
          subtitle: l10n.homeOfficialAnnouncement,
          body: plain,
          color: AppTheme.crossRed,
          stackedTempleImages: true,
          onTap: () => _push(context, const ALaLunePage()),
        ),
      );
    }

    return slides;
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.onNotifications,
  });

  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    ThemeSync.watch(context);
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isLight
                ? Colors.black.withValues(alpha: 0.06)
                : AppTheme.royalBlue.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onDoubleTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LoginPage(adminMode: true),
                  ),
                ),
                child: const AppLogo(size: 48, showShadow: false),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.headerOnSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        height: 1.15,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      l10n.homeTempleMoriah,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.headerOnSurfaceMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                        height: 1.15,
                      ),
                    ),
                    Text(
                      l10n.churchTagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.headerOnSurfaceSubtle,
                        fontWeight: FontWeight.w500,
                        fontSize: 10.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HomeHeaderToolbar(
                onNotifications: onNotifications,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppTheme.accentOnSurface),
            const SizedBox(width: 12),
            Text(
              l10n.homeSearchHint,
              style: TextStyle(color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveBanner extends StatefulWidget {
  const _LiveBanner({
    required this.onTap,
    required this.isLive,
    required this.isLoading,
    this.liveStartedAt,
  });

  final VoidCallback onTap;
  final bool isLive;
  final bool isLoading;
  final DateTime? liveStartedAt;

  @override
  State<_LiveBanner> createState() => _LiveBannerState();
}

class _LiveBannerState extends State<_LiveBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late NextWorshipService _next;
  Timer? _chrono;

  @override
  void initState() {
    super.initState();
    _next = NextWorshipService.compute();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _chrono = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _next = NextWorshipService.compute());
    });
  }

  @override
  void dispose() {
    _chrono?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLive = widget.isLive;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: isLive
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8B0E1A),
                      Color(0xFFC62828),
                      Color(0xFF5C0A14),
                    ],
                  )
                : AppTheme.liveBannerOfflineGradient,
            border: Border.all(
              color: isLive
                  ? AppTheme.accentOnSurface.withValues(alpha: 0.55)
                  : (AppTheme.isLight
                      ? AppTheme.royalBlue.withValues(alpha: 0.22)
                      : AppTheme.accentOnSurface.withValues(alpha: 0.28)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isLive ? AppTheme.crossRed : AppTheme.royalBlue)
                    .withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -14,
                top: -16,
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.liveBannerDecorCircle,
                  ),
                ),
              ),
              Positioned(
                left: -22,
                bottom: -28,
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.isLight
                        ? AppTheme.royalBlue.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, child) {
                        // Zoom avant / zoom arrière continu
                        final scale = 0.88 + (_pulse.value * 0.24);
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.crossRed,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.crossRed.withValues(alpha: 0.45),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          isLive
                              ? Icons.sensors
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isLive) ...[
                            const LiveBadge(),
                            const SizedBox(height: 4),
                          ] else if (widget.isLoading) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.isLight
                                    ? AppTheme.royalBlue.withValues(alpha: 0.1)
                                    : Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                l10n.homeChecking,
                                style: TextStyle(
                                  color: AppTheme.isLight
                                      ? AppTheme.royalBlue
                                      : Colors.white70,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            l10n.homeTheLive,
                            style: TextStyle(
                              color: isLive
                                  ? Colors.white
                                  : AppTheme.liveBannerTitle,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            l10n.homeLiveStreaming,
                            style: TextStyle(
                              color: isLive
                                  ? AppTheme.accentOnSurface.withValues(alpha: 0.95)
                                  : AppTheme.liveBannerSubtitle,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    widget.isLive
                        ? _LiveElapsedChrono(liveStartedAt: widget.liveStartedAt)
                        : _NextServiceChrono(next: _next),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveElapsedChrono extends StatelessWidget {
  const _LiveElapsedChrono({this.liveStartedAt});

  final DateTime? liveStartedAt;

  @override
  Widget build(BuildContext context) {
    final elapsed = liveElapsedSince(liveStartedAt);

    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.liveBannerChronoBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.live.withValues(alpha: 0.55)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            context.l10n.homeLiveSince,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.live,
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatLiveDuration(elapsed),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.liveBannerChronoValue,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextServiceChrono extends StatelessWidget {
  const _NextServiceChrono({required this.next});

  final NextWorshipService next;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.liveBannerChronoBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.liveBannerChronoBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            context.l10n.homeNextService,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.liveBannerChronoLabel,
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${next.dayLabel(context.l10n)} · ${next.timeLabel(context.l10n)}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.liveBannerChronoTime,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            next.chronoLabel(context.l10n),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.crossRed,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _ALaUneSlide {
  const _ALaUneSlide({
    required this.badge,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.color,
    this.predication,
    this.stackedTempleImages = false,
    this.onTap,
  }) : imageAsset = null;

  final String badge;
  final IconData icon;
  final String title;
  final String subtitle;
  final String body;
  final Color color;
  final Predication? predication;
  final String? imageAsset;
  final bool stackedTempleImages;
  final VoidCallback? onTap;
}

class _ALaUneSlider extends StatefulWidget {
  const _ALaUneSlider({required this.slides});

  final List<_ALaUneSlide> slides;

  @override
  State<_ALaUneSlider> createState() => _ALaUneSliderState();
}

class _ALaUneSliderState extends State<_ALaUneSlider> {
  late final PageController _controller;
  int _index = 0;
  bool _alive = true;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.96);
    _autoPlay();
  }

  Future<void> _autoPlay() async {
    while (_alive) {
      await Future.delayed(const Duration(seconds: 5));
      if (!_alive || !mounted || widget.slides.length < 2) continue;
      final next = (_index + 1) % widget.slides.length;
      await _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _alive = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.slides.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final slide = widget.slides[i];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: slide.predication != null
                    ? _ALaUnePredicationCard(
                        predication: slide.predication!,
                        indexLabel: '${i + 1}/${widget.slides.length}',
                        onTap: slide.onTap,
                      )
                    : slide.stackedTempleImages
                    ? _ALaUneCommuniqueCard(
                        badge: slide.badge,
                        title: slide.title,
                        subtitle: slide.subtitle,
                        body: slide.body,
                        indexLabel: '${i + 1}/${widget.slides.length}',
                        onTap: slide.onTap,
                      )
                    : slide.imageAsset != null
                    ? _ALaUnePhotoCard(
                        imageAsset: slide.imageAsset!,
                        badge: slide.badge,
                        title: slide.title,
                        subtitle: slide.subtitle,
                        indexLabel: '${i + 1}/${widget.slides.length}',
                        onTap: slide.onTap ??
                            () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ALaLunePage(),
                                  ),
                                ),
                      )
                    : ShtCard(
                        onTap: slide.onTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: slide.color.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(slide.icon,
                                          size: 14, color: slide.color),
                                      const SizedBox(width: 6),
                                      Text(
                                        slide.badge,
                                        style: TextStyle(
                                          color: slide.color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${i + 1}/${widget.slides.length}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              slide.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              slide.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                slide.body,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                context.l10n.seeMoreArrow,
                                style: TextStyle(
                                  color: slide.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.slides.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.accentOnSurface
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

class _ALaUnePredicationCard extends StatelessWidget {
  const _ALaUnePredicationCard({
    required this.predication,
    required this.indexLabel,
    this.onTap,
  });

  final Predication predication;
  final String indexLabel;
  final VoidCallback? onTap;

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
                    ? _thumbFallback()
                    : CachedNetworkImage(
                        imageUrl: predication.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _thumbFallback(),
                        errorWidget: (_, _, _) => _thumbFallback(),
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
                        color: AppTheme.goldOnSurface,
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
                        const SizedBox(width: 4),
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

  Widget _thumbFallback() {
    return ColoredBox(
      color: AppTheme.surfaceElevated,
      child: Center(
        child: Image.asset(
          AppConstants.logoAsset,
          width: 42,
          height: 42,
          errorBuilder: (_, _, _) => Icon(
            Icons.menu_book,
            color: AppTheme.accentOnSurface,
          ),
        ),
      ),
    );
  }
}

class _ALaUneCommuniqueCard extends StatelessWidget {
  const _ALaUneCommuniqueCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.indexLabel,
    this.onTap,
  });

  final String badge;
  final String title;
  final String subtitle;
  final String body;
  final String indexLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/images/sanctuary-after.jpeg',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: AppTheme.surfaceElevated,
                          child: Icon(
                            Icons.photo,
                            color: AppTheme.accentOnSurface,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Image.asset(
                        'assets/images/balcony-after.jpeg',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: AppTheme.surfaceElevated,
                          child: Icon(
                            Icons.photo,
                            color: AppTheme.accentOnSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                            color: AppTheme.crossRed.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(color: AppTheme.softWhite,
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
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppTheme.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
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
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppTheme.softWhite,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        context.l10n.seeMoreArrow,
                        style: TextStyle(
                          color: AppTheme.crossRed.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
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

class _ALaUnePhotoCard extends StatelessWidget {
  const _ALaUnePhotoCard({
    required this.imageAsset,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.indexLabel,
    this.onTap,
  });

  final String imageAsset;
  final String badge;
  final String title;
  final String subtitle;
  final String indexLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: AppTheme.surfaceElevated,
                    child: Icon(
                      Icons.photo,
                      color: AppTheme.accentOnSurface,
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
                            color: AppTheme.accentOnSurface.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: AppTheme.goldOnSurface,
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
                      title,
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
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.goldOnSurface,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      context.l10n.homeAfterReconstruction,
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

class _NextWorshipCard extends StatefulWidget {
  const _NextWorshipCard({required this.onSeeMore});

  final VoidCallback onSeeMore;

  @override
  State<_NextWorshipCard> createState() => _NextWorshipCardState();
}

class _NextWorshipCardState extends State<_NextWorshipCard> {
  late NextWorshipService _next;

  @override
  void initState() {
    super.initState();
    _next = NextWorshipService.compute();
    _tick();
  }

  Future<void> _tick() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _next = NextWorshipService.compute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ShtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 58,
                    height: 58,
                    child: Image.asset(
                      AppConstants.logoShekinahAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeNextServiceLabel,
                        style: TextStyle(
                          color: AppTheme.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_next.dayLabel(l10n)} · ${_next.timeLabel(l10n)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        l10n.assemblyAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.royalBlue.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.accentOnSurface.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: AppTheme.accentOnSurface,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.homeTimeRemaining,
                    style: TextStyle(
                      color: AppTheme.softWhite,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _next.countdownLabel(l10n),
                    style: TextStyle(
                      color: AppTheme.goldOnSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onSeeMore,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentOnSurface,
                  side: BorderSide(
                    color: AppTheme.accentOnSurface.withValues(alpha: 0.55),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.seeMore,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

