import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_sync.dart';
import '../../l10n/app_localizations.dart';
import '../pages/moriah_donation_page.dart';
import '../pages/moriah_temple_video_page.dart';
import '../providers/background_video_players_provider.dart';

class SinistreMajeurCard extends ConsumerStatefulWidget {
  const SinistreMajeurCard({super.key});

  @override
  ConsumerState<SinistreMajeurCard> createState() => _SinistreMajeurCardState();
}

class _SinistreMajeurCardState extends ConsumerState<SinistreMajeurCard> {
  static const int _beforeSlideCount = 2;
  static const int _videoBeforeIndex = 6;
  static const int _videoAfterIndex = 7;
  static const int _slideCount = 8;
  static const Duration _imageSlideDuration = Duration(seconds: 5);
  static const Duration _videoSlideExtra = Duration(seconds: 4);

  List<_SinistreSlide> _slides(AppLocalizations l10n) => [
        _SinistreSlide(
          imageAsset: AppConstants.moriahMainEntranceBeforeAsset,
          badge: l10n.sinistreBadgeSplendid,
          badgeIcon: Icons.check_circle,
          badgeColor: const Color(0xFF2E7D4F),
          captionTitle: l10n.sinistreFacadeTitle,
          captionTitleColor: const Color(0xFF4CAF6A),
          captionBody: l10n.sinistreFacadeBody,
        ),
        _SinistreSlide(
          imageAsset: AppConstants.moriahSanctuaryBeforeAsset,
          badge: l10n.sinistreBadgeSplendid,
          badgeIcon: Icons.check_circle,
          badgeColor: const Color(0xFF2E7D4F),
          captionTitle: l10n.sinistreBeforeTitle,
          captionTitleColor: const Color(0xFF4CAF6A),
          captionBody: l10n.sinistreBeforeBody,
        ),
        _SinistreSlide(
          imageAsset: AppConstants.moriahMainEntranceAfterAsset,
          badge: l10n.sinistreBadgeAfterFire,
          badgeIcon: Icons.local_fire_department,
          badgeColor: const Color(0xFFC62828),
          captionTitle: l10n.sinistreAfterTitle,
          captionTitleColor: const Color(0xFFE57373),
          captionBody: l10n.sinistreEntranceBody,
        ),
        _SinistreSlide(
          imageAsset: AppConstants.moriahSanctuaryAfterAsset,
          badge: l10n.sinistreBadgeAfterFire,
          badgeIcon: Icons.local_fire_department,
          badgeColor: const Color(0xFFC62828),
          captionTitle: l10n.sinistreAfterTitle,
          captionTitleColor: const Color(0xFFE57373),
          captionBody: l10n.sinistreSanctuaryBody,
        ),
        _SinistreSlide(
          imageAsset: AppConstants.moriahBalconyAfterAsset,
          badge: l10n.sinistreBadgeAfterFire,
          badgeIcon: Icons.local_fire_department,
          badgeColor: const Color(0xFFC62828),
          captionTitle: l10n.sinistreAfterTitle,
          captionTitleColor: const Color(0xFFE57373),
          captionBody: l10n.sinistreBalconyBody,
        ),
        _SinistreSlide(
          imageAsset: AppConstants.moriahRoofAfterAsset,
          badge: l10n.sinistreBadgeAfterFire,
          badgeIcon: Icons.local_fire_department,
          badgeColor: const Color(0xFFC62828),
          captionTitle: l10n.sinistreAfterTitle,
          captionTitleColor: const Color(0xFFE57373),
          captionBody: l10n.sinistreRoofBody,
        ),
        _SinistreSlide(
          videoAsset: AppConstants.moriahTempleBeforeVideoAsset,
          badge: l10n.sinistreBadgeSplendid,
          badgeIcon: Icons.check_circle,
          badgeColor: const Color(0xFF2E7D4F),
          captionTitle: l10n.sinistreBeforeTitle,
          captionTitleColor: const Color(0xFF4CAF6A),
          captionBody: l10n.sinistreVideoBeforeBody,
        ),
        _SinistreSlide(
          videoAsset: AppConstants.moriahTempleAfterVideoAsset,
          badge: l10n.sinistreBadgeAfterFire,
          badgeIcon: Icons.local_fire_department,
          badgeColor: const Color(0xFFC62828),
          captionTitle: l10n.sinistreAfterTitle,
          captionTitleColor: const Color(0xFFE57373),
          captionBody: l10n.sinistreVideoAfterBody,
        ),
      ];

  late final PageController _controller;
  /// At most one MediaCodec — holding both before/after exhausted MediaTek
  /// slots while this card stayed alive under [IndexedStack].
  VideoPlayerController? _activeVideoController;
  String? _activeVideoAsset;
  int _videoBindToken = 0;
  int _index = 0;
  Timer? _auto;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _scheduleAutoAdvance();
  }

  Duration _durationForIndex(int index) {
    if (index == _videoBeforeIndex || index == _videoAfterIndex) {
      return _imageSlideDuration + _videoSlideExtra;
    }
    return _imageSlideDuration;
  }

  void _scheduleAutoAdvance() {
    _auto?.cancel();
    _auto = Timer(_durationForIndex(_index), () {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % _slideCount;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _disposeActiveVideo() async {
    final controller = _activeVideoController;
    _activeVideoController = null;
    _activeVideoAsset = null;
    if (controller != null) {
      await controller.dispose();
    }
  }

  Future<void> _bindVideoForIndex(int index) async {
    final token = ++_videoBindToken;
    final allowed = ref.read(backgroundVideoPlayersAllowedProvider);
    final isVideoSlide =
        index == _videoBeforeIndex || index == _videoAfterIndex;

    if (!allowed || !isVideoSlide) {
      await _disposeActiveVideo();
      if (mounted && token == _videoBindToken) setState(() {});
      return;
    }

    final asset = index == _videoBeforeIndex
        ? AppConstants.moriahTempleBeforeVideoAsset
        : AppConstants.moriahTempleAfterVideoAsset;

    if (_activeVideoAsset == asset &&
        _activeVideoController?.value.isInitialized == true) {
      await _activeVideoController!.play();
      return;
    }

    await _disposeActiveVideo();
    if (!mounted || token != _videoBindToken) return;

    final controller = VideoPlayerController.asset(asset)
      ..setLooping(true)
      ..setVolume(0);
    _activeVideoController = controller;
    _activeVideoAsset = asset;

    try {
      await controller.initialize();
      if (!mounted ||
          token != _videoBindToken ||
          _activeVideoController != controller) {
        await controller.dispose();
        return;
      }
      setState(() {});
      await controller.play();
    } catch (_) {
      if (_activeVideoController == controller) {
        _activeVideoController = null;
        _activeVideoAsset = null;
      }
      await controller.dispose();
      if (mounted && token == _videoBindToken) setState(() {});
    }
  }

  @override
  void dispose() {
    _auto?.cancel();
    _videoBindToken++;
    final video = _activeVideoController;
    _activeVideoController = null;
    _activeVideoAsset = null;
    video?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openDonationForm() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MoriahDonationPage()),
    );
  }

  Future<void> _openVideoPlayer(_SinistreSlide item) async {
    if (!item.isVideo || item.videoAsset == null) return;
    _auto?.cancel();
    await _disposeActiveVideo();
    if (!mounted) return;
    setState(() {});

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MoriahTempleVideoPage(
          videoAsset: item.videoAsset!,
          title: item.captionTitle,
          subtitle: item.captionBody,
        ),
      ),
    );

    if (!mounted) return;
    await _bindVideoForIndex(_index);
    _scheduleAutoAdvance();
  }

  bool _badgeAlignLeft(int index) =>
      index < _beforeSlideCount || index == _videoBeforeIndex;

  VideoPlayerController? _videoControllerFor(_SinistreSlide item) {
    if (item.videoAsset == null || item.videoAsset != _activeVideoAsset) {
      return null;
    }
    return _activeVideoController;
  }

  Widget _buildMedia(_SinistreSlide item) {
    if (item.isVideo) {
      final controller = _videoControllerFor(item);
      if (controller == null || !controller.value.isInitialized) {
        return ColoredBox(
          color: AppTheme.surface,
          child: Center(
            child: CircularProgressIndicator(
              color: AppTheme.accentOnSurface,
              strokeWidth: 2.5,
            ),
          ),
        );
      }
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
    }

    if (item.imageAsset != null) {
      return Image.asset(
        item.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => ColoredBox(
          color: AppTheme.surface,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: AppTheme.grey,
            ),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: item.imageUrl!,
      fit: BoxFit.cover,
      placeholder: (_, _) => ColoredBox(
        color: AppTheme.surface,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.accentOnSurface,
            strokeWidth: 2.5,
          ),
        ),
      ),
      errorWidget: (_, _, _) => ColoredBox(
        color: AppTheme.surface,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppTheme.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeSync.watch(context);
    final l10n = context.l10n;
    final slides = _slides(l10n);
    final slide = slides[_index];

    ref.listen<bool>(backgroundVideoPlayersAllowedProvider, (prev, next) {
      if (next == false) {
        unawaited(_disposeActiveVideo().then((_) {
          if (mounted) setState(() {});
        }));
      } else if (next == true) {
        unawaited(_bindVideoForIndex(_index));
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.isLight
              ? AppTheme.royalBlue.withValues(alpha: 0.18)
              : AppTheme.accentOnSurface.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isLight
                ? Colors.black.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.crossRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.crossRed.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 14, color: AppTheme.crossRed),
                      SizedBox(width: 6),
                      Text(
                        l10n.sinistreBadge,
                        style: TextStyle(
                          color: AppTheme.isLight
                              ? AppTheme.crossRed
                              : AppTheme.goldOnSurface,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${_index + 1}/${slides.length}',
                  style: TextStyle(
                    color: AppTheme.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 16 / 11,
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (i) {
                setState(() => _index = i);
                unawaited(_bindVideoForIndex(i));
                _scheduleAutoAdvance();
              },
              itemBuilder: (_, i) {
                final item = slides[i];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildMedia(item),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x33000000),
                            Colors.transparent,
                            Color(0x66000000),
                          ],
                        ),
                      ),
                    ),
                    if (item.isVideo)
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _openVideoPlayer(item),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  size: 52,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Align(
                        alignment: _badgeAlignLeft(i)
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: item.badgeColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: item.badgeColor.withValues(alpha: 0.35),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.badgeIcon,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                item.badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 3,
                      height: 52,
                      decoration: BoxDecoration(
                        color: slide.captionTitleColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.captionTitle,
                            style: TextStyle(
                              color: slide.captionTitleColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            slide.captionBody,
                            style: TextStyle(
                              color: AppTheme.softWhite,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(slides.length, (i) {
                    final active = i == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active
                            ? (AppTheme.isLight
                                ? AppTheme.royalBlue
                                : AppTheme.accentOnSurface)
                            : AppTheme.grey.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openDonationForm,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.ctaBackground,
                      foregroundColor: AppTheme.ctaForeground,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.volunteer_activism, size: 18),
                    label: Text(
                      l10n.sinistreSupportReconstruction,
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SinistreSlide {
  const _SinistreSlide({
    this.imageUrl,
    this.imageAsset,
    this.videoAsset,
    required this.badge,
    required this.badgeIcon,
    required this.badgeColor,
    required this.captionTitle,
    required this.captionTitleColor,
    required this.captionBody,
  }) : assert(
          imageUrl != null || imageAsset != null || videoAsset != null,
        );

  final String? imageUrl;
  final String? imageAsset;
  final String? videoAsset;
  final String badge;
  final IconData badgeIcon;
  final Color badgeColor;
  final String captionTitle;
  final Color captionTitleColor;
  final String captionBody;

  bool get isVideo => videoAsset != null;
}
