import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/network/network_ready.dart';
import '../../core/utils/live_duration_utils.dart';
import '../../core/theme/app_theme.dart';
import '../pages/home_page.dart';
import '../pages/archives_page.dart';
import '../pages/cantiques_page.dart';
import '../pages/cultes_page.dart';
import '../pages/library_page.dart';
import '../pages/live_page.dart';
import '../pages/offline_page.dart';
import '../pages/plus_page.dart';
import '../providers/cantique_provider.dart';
import '../providers/communique_provider.dart';
import '../providers/live_playback_provider.dart';
import '../providers/live_stream_provider.dart';
import '../providers/moriah_campaign_provider.dart';
import '../providers/predication_provider.dart';
import '../providers/theme_mode_provider.dart';
import '../navigation/notification_navigation.dart';
import '../widgets/live_player_overlays.dart';
import '../widgets/offline_mini_player.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  void _goTo(int index) => setState(() => _currentIndex = index);

  @override
  void initState() {
    super.initState();
    markAppMainShellReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(flushPendingNotificationRoute());
    });
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((results) async {
      if (!results.any((r) => r != ConnectivityResult.none)) return;
      if (!await isNetworkReady()) return;
      ref.invalidate(predicationListProvider);
      ref.invalidate(cantiqueListProvider);
      ref.invalidate(recentMonthPredicationsProvider);
      ref.invalidate(communiqueProvider);
      ref.invalidate(moriahCampaignActiveProvider);
      ref.read(liveStreamProvider.notifier).refreshLiveStatus();
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final l10n = context.l10n;
    final playback = ref.watch(livePlaybackProvider);
    final userElapsed = formatLiveDuration(
      playback.userWatchStartedAt != null
          ? DateTime.now().difference(playback.userWatchStartedAt!)
          : Duration.zero,
    );

    final pages = [
      HomePage(
        onOpenCultes: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CultesPage()),
          );
        },
        onOpenPredications: () => _goTo(1),
      ),
      const ArchivesPage(),
      const CantiquesPage(),
      const OfflinePage(),
      const LibraryPage(),
      const PlusPage(),
    ];

    return Stack(
      children: [
        Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
        index: _currentIndex,
        children: pages,
            ),
          ),
          const OfflineMiniPlayer(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarTheme.of(context).copyWith(
          height: 64,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 9.5,
              height: 1.05,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppTheme.accentOnSurface : AppTheme.grey,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 22,
              color: selected ? AppTheme.accentOnSurface : AppTheme.grey,
            );
          }),
        ),
        child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _goTo,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: AppTheme.accentOnSurface.withValues(alpha: 0.16),
        backgroundColor: AppTheme.surface,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.accentOnSurface),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppTheme.accentOnSurface),
            label: l10n.navPredications,
          ),
          NavigationDestination(
            icon: const Icon(Icons.music_note_outlined),
            selectedIcon: Icon(Icons.music_note, color: AppTheme.accentOnSurface),
            label: l10n.navCantiques,
          ),
          NavigationDestination(
            icon: const Icon(Icons.download_done_outlined),
            selectedIcon:
                Icon(Icons.download_done, color: AppTheme.accentOnSurface),
            label: l10n.navOffline,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_library_outlined),
            selectedIcon:
                Icon(Icons.local_library, color: AppTheme.accentOnSurface),
            label: l10n.navLibrary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps, color: AppTheme.accentOnSurface),
            label: l10n.navPlus,
          ),
        ],
      ),
      ),
        ),
        if (playback.isFloating)
          LiveFloatingPlayer(
            userElapsedLabel: userElapsed,
            isPlaying: playback.isPlaying,
            isAudio: playback.mode == LivePlaybackMode.audio,
            webController: playback.mode == LivePlaybackMode.video
                ? ref.read(livePlaybackProvider.notifier).webController
                : null,
            onTogglePlay: () =>
                ref.read(livePlaybackProvider.notifier).toggleAudio(),
            onExpand: () {
              ref.read(livePlaybackProvider.notifier).hideFloating();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LivePage()),
              );
            },
            onClose: () =>
                ref.read(livePlaybackProvider.notifier).stopPlayback(),
          ),
      ],
    );
  }
}
