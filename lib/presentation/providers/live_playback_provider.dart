import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../core/audio/background_audio_hub.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/network_guard.dart';
import '../../core/network/network_ready.dart';
import '../../domain/entities/live_status.dart';
import 'live_stream_provider.dart';
import 'live_vimeo_embed_resolver_provider.dart';

enum LivePlaybackMode { video, audio }

enum LiveWebPlaybackFailure { network, streamUnavailable }

class LivePlaybackState {
  const LivePlaybackState({
    this.mode = LivePlaybackMode.video,
    this.lang = LiveLang.fr,
    this.userWatchStartedAt,
    this.liveStartedAt,
    this.isFloating = false,
    this.isPlaying = false,
    this.currentTitle,
    this.webLoading = false,
    this.webFailure,
  });

  final LivePlaybackMode mode;
  final LiveLang lang;
  final DateTime? userWatchStartedAt;
  final DateTime? liveStartedAt;
  final bool isFloating;
  final bool isPlaying;
  final String? currentTitle;
  final bool webLoading;
  final LiveWebPlaybackFailure? webFailure;

  LivePlaybackState copyWith({
    LivePlaybackMode? mode,
    LiveLang? lang,
    DateTime? userWatchStartedAt,
    DateTime? liveStartedAt,
    bool? isFloating,
    bool? isPlaying,
    String? currentTitle,
    bool? webLoading,
    LiveWebPlaybackFailure? webFailure,
    bool clearUserWatch = false,
    bool clearLiveStarted = false,
    bool clearWebFailure = false,
  }) {
    return LivePlaybackState(
      mode: mode ?? this.mode,
      lang: lang ?? this.lang,
      userWatchStartedAt:
          clearUserWatch ? null : (userWatchStartedAt ?? this.userWatchStartedAt),
      liveStartedAt:
          clearLiveStarted ? null : (liveStartedAt ?? this.liveStartedAt),
      isFloating: isFloating ?? this.isFloating,
      isPlaying: isPlaying ?? this.isPlaying,
      currentTitle: currentTitle ?? this.currentTitle,
      webLoading: webLoading ?? this.webLoading,
      webFailure: clearWebFailure ? null : (webFailure ?? this.webFailure),
    );
  }
}

final livePlaybackProvider =
    NotifierProvider<LivePlaybackNotifier, LivePlaybackState>(
  LivePlaybackNotifier.new,
);

class LivePlaybackNotifier extends Notifier<LivePlaybackState> {
  static const _vimeoReferer = '${AppConstants.websiteUrl}/';
  static const _videoRetryDelay = Duration(seconds: 20);

  final AudioPlayer audioPlayer = BackgroundAudioHub.instance.player;
  Timer? _liveTicker;
  Timer? _videoRetryTimer;
  WebViewController? webController;
  String? _loadedEmbedUrl;
  String? _pendingRetryUrl;
  bool _pendingRetryIsLive = false;
  String? _pendingRetryTitle;
  int _videoSession = 0;

  @override
  LivePlaybackState build() {
    ref.onDispose(() {
      _liveTicker?.cancel();
      _videoRetryTimer?.cancel();
      BackgroundAudioHub.instance.removeBeforePlayListener(_onOtherAudioStarting);
      // Ne pas disposer le lecteur partagé (hub arrière-plan).
    });

    BackgroundAudioHub.instance.addBeforePlayListener(_onOtherAudioStarting);

    ref.listen<LiveStreamState>(liveStreamProvider, (prev, next) {
      _syncLiveStream(prev?.liveStream, next.liveStream);
    });

    return const LivePlaybackState();
  }

  Future<void> _onOtherAudioStarting() async {
    // Ignoré si on est soi-même en train de (re)démarrer via playAudioUrl.
    if (_startingOwnAudio) return;
    if (!state.isPlaying && !state.isFloating) return;
    state = state.copyWith(
      isPlaying: false,
      isFloating: false,
      clearUserWatch: true,
    );
  }

  bool _startingOwnAudio = false;

  void _syncLiveStream(LiveStreamEntity? prev, LiveStreamEntity? next) {
    if (next == null) return;

    if (prev != null &&
        next.isLive &&
        !prev.hasSameStreamingConfig(next)) {
      resetVideoCache();
    }

    if (next.isLive &&
        state.webFailure != null &&
        _pendingRetryUrl != null) {
      _scheduleVideoRetry(immediate: true);
    }

    _syncLiveTiming(prev, next);
  }

  void _syncLiveTiming(LiveStreamEntity? prev, LiveStreamEntity? next) {
    if (next == null) return;

    if (next.isLive) {
      final started = next.liveStartedAt ?? state.liveStartedAt ?? DateTime.now();
      if (state.liveStartedAt != started) {
        state = state.copyWith(liveStartedAt: started);
      }
      _ensureLiveTicker();
      return;
    }

    if (prev?.isLive == true && !next.isLive) {
      _videoRetryTimer?.cancel();
      _liveTicker?.cancel();
      state = state.copyWith(clearLiveStarted: true);
      unawaited(stopPlayback());
    }
  }

  void _setWebLoading(bool loading) {
    if (state.webLoading == loading) return;
    state = state.copyWith(webLoading: loading);
  }

  void _setWebFailure(LiveWebPlaybackFailure? failure) {
    if (state.webFailure == failure) return;
    state = state.copyWith(
      webFailure: failure,
      clearWebFailure: failure == null,
    );
  }

  void _rememberRetryContext({
    required String url,
    required bool isLive,
    String? title,
  }) {
    _pendingRetryUrl = url;
    _pendingRetryIsLive = isLive;
    _pendingRetryTitle = title;
  }

  void _scheduleVideoRetry({bool immediate = false}) {
    _videoRetryTimer?.cancel();
    final url = _pendingRetryUrl;
    if (url == null || state.webFailure == null) return;

    _videoRetryTimer = Timer(immediate ? Duration.zero : _videoRetryDelay, () {
      if (state.mode != LivePlaybackMode.video) return;
      if (state.webFailure == null || _pendingRetryUrl == null) return;
      ref.read(liveVimeoEmbedResolverProvider).invalidateCache();
      resetVideoCache();
      unawaited(
        ensureVideoEmbed(
          _pendingRetryUrl!,
          isLive: _pendingRetryIsLive,
          title: _pendingRetryTitle,
        ),
      );
    });
  }

  void _registerWebFailure(
    LiveWebPlaybackFailure failure, {
    required String url,
    required bool isLive,
    String? title,
  }) {
    webController = null;
    _loadedEmbedUrl = null;
    _setWebLoading(false);
    _setWebFailure(failure);
    _rememberRetryContext(url: url, isLive: isLive, title: title);
    _scheduleVideoRetry();
  }

  Future<bool> ensureVideoEmbed(
    String url, {
    required bool isLive,
    String? title,
  }) async {
    setMode(LivePlaybackMode.video);
    final session = _videoSession;
    _rememberRetryContext(url: url, isLive: isLive, title: title);

    String resolvedUrl;
    try {
      resolvedUrl = await ref.read(liveVimeoEmbedResolverProvider).resolve(url);
    } catch (_) {
      resolvedUrl = url;
    }

    if (session != _videoSession) return false;

    if (_loadedEmbedUrl == resolvedUrl &&
        webController != null &&
        state.webFailure == null) {
      if (isLive) markUserWatching(title: title);
      return true;
    }

    try {
      await ensureNetworkReady();
    } on NetworkUnavailableException {
      _registerWebFailure(
        LiveWebPlaybackFailure.network,
        url: url,
        isLive: isLive,
        title: title,
      );
      return false;
    }

    if (session != _videoSession) return false;

    _videoRetryTimer?.cancel();
    _setWebFailure(null);
    _setWebLoading(true);

    await configureAudioSession();

    if (session != _videoSession) return false;

    final controller = _createLiveVideoController();
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            _setWebLoading(true);
            _setWebFailure(null);
          },
          onPageFinished: (pageUrl) {
            _setWebLoading(false);
            _boostWebViewVolume(controller);
          },
          onWebResourceError: (error) async {
            // Ignorer les erreurs de sous-ressources (pub, analytics Vimeo…).
            if (error.isForMainFrame == false) return;

            final offline = error.errorType == WebResourceErrorType.hostLookup ||
                error.errorType == WebResourceErrorType.connect ||
                error.errorType == WebResourceErrorType.timeout;
            if (!offline) return;

            final networkUp = await isNetworkReady();
            if (!networkUp) {
              _registerWebFailure(
                LiveWebPlaybackFailure.network,
                url: url,
                isLive: isLive,
                title: title,
              );
            }
          },
          onNavigationRequest: (request) {
            if (_isAllowedVimeoNavigation(request.url)) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );

    await _loadLiveVideoEmbed(controller, resolvedUrl, isLive: isLive);

    if (session != _videoSession || state.mode != LivePlaybackMode.video) {
      return false;
    }

    webController = controller;
    _loadedEmbedUrl = resolvedUrl;
    if (isLive) markUserWatching(title: title);
    state = state.copyWith(webLoading: true, clearWebFailure: true);
    return true;
  }

  WebViewController _createLiveVideoController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const {},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);
    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      unawaited(platform.setMediaPlaybackRequiresUserGesture(false));
    }
    return controller;
  }

  Future<void> _loadLiveVideoEmbed(
    WebViewController controller,
    String url, {
    required bool isLive,
  }) async {
    final uri = Uri.parse(url);
    final loadUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'autoplay': isLive ? '1' : '0',
        'muted': '0',
        'playsinline': '1',
        'title': '0',
        'byline': '0',
        'portrait': '0',
        'color': 'd4a017',
      },
    );

    await controller.loadRequest(
      loadUri,
      headers: const {'Referer': _vimeoReferer},
    );
  }

  bool _isAllowedVimeoNavigation(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    if (host.isEmpty) return false;
    const allowedHosts = [
      'vimeo.com',
      'player.vimeo.com',
      'vimeocdn.com',
      'f.vimeocdn.com',
      'i.vimeocdn.com',
      'l.vimeocdn.com',
      'google.com',
      'gstatic.com',
      'fonts.googleapis.com',
      'fonts.gstatic.com',
    ];
    return allowedHosts.any(host.contains);
  }

  void _boostWebViewVolume(WebViewController controller) {
    controller.runJavaScript('''
      (function() {
        function apply() {
          document.querySelectorAll('video').forEach(function(v) {
            v.muted = false;
            v.volume = 1.0;
          });
        }
        apply();
        if (!window.__shtLiveVolumeHook) {
          window.__shtLiveVolumeHook = setInterval(apply, 2000);
        }
      })();
    ''');
  }

  void resetVideoCache() {
    _videoSession++;
    _videoRetryTimer?.cancel();
    webController = null;
    _loadedEmbedUrl = null;
    ref.read(liveVimeoEmbedResolverProvider).invalidateCache();
    state = state.copyWith(webLoading: false, clearWebFailure: true);
  }

  /// Arrête proprement la WebView (ex. bascule audio ↔ vidéo) pour éviter les crashs natifs.
  Future<void> releaseVideoPlayback() async {
    _videoSession++;
    _videoRetryTimer?.cancel();
    final controller = webController;
    webController = null;
    _loadedEmbedUrl = null;
    state = state.copyWith(webLoading: false, clearWebFailure: true);

    if (controller == null) return;

    try {
      await controller.runJavaScript(
        r'''
        try {
          document.querySelectorAll('video').forEach(function(v) {
            v.pause();
            v.removeAttribute('src');
            v.load();
          });
        } catch (e) {}
        ''',
      );
    } catch (_) {}

    try {
      await controller.loadRequest(Uri.parse('about:blank'));
    } catch (_) {}
  }

  void _ensureLiveTicker() {
    _liveTicker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.liveStartedAt != null || state.userWatchStartedAt != null) {
        state = state.copyWith();
      }
    });
  }

  Future<void> configureAudioSession() =>
      BackgroundAudioHub.instance.ensureSession();

  void syncLiveStartedAt(DateTime? startedAt) {
    if (startedAt == null) return;
    if (state.liveStartedAt == startedAt) return;
    state = state.copyWith(liveStartedAt: startedAt);
    _ensureLiveTicker();
  }

  void setMode(LivePlaybackMode mode) => state = state.copyWith(mode: mode);

  void setLang(LiveLang lang) => state = state.copyWith(lang: lang);

  void markUserWatching({String? title}) {
    _ensureLiveTicker();
    state = state.copyWith(
      userWatchStartedAt: state.userWatchStartedAt ?? DateTime.now(),
      isPlaying: true,
      currentTitle: title ?? state.currentTitle,
    );
  }

  void setPlaying(bool playing) {
    state = state.copyWith(isPlaying: playing);
    if (playing && state.userWatchStartedAt == null) {
      markUserWatching();
    }
  }

  void showFloating() => state = state.copyWith(isFloating: true);

  void hideFloating() => state = state.copyWith(isFloating: false);

  Future<void> playAudioUrl(String url, {String? title}) async {
    final resolvedTitle =
        title ?? state.currentTitle ?? AppConstants.appName;
    _startingOwnAudio = true;
    try {
      await BackgroundAudioHub.instance.playUri(
        id: 'live:$url',
        url: url,
        title: resolvedTitle,
        artist: AppConstants.appShortName,
      );
    } finally {
      _startingOwnAudio = false;
    }
    markUserWatching(title: resolvedTitle);
  }

  Future<void> toggleAudio() async {
    if (audioPlayer.playing) {
      await BackgroundAudioHub.instance.pause();
      setPlaying(false);
    } else {
      await BackgroundAudioHub.instance.resume();
      setPlaying(true);
    }
  }

  Future<void> stopPlayback() async {
    _videoRetryTimer?.cancel();
    await BackgroundAudioHub.instance.stop();
    resetVideoCache();
    state = state.copyWith(
      isPlaying: false,
      isFloating: false,
      clearUserWatch: true,
    );
  }

  Duration get liveElapsed {
    if (state.liveStartedAt == null) return Duration.zero;
    return DateTime.now().difference(state.liveStartedAt!);
  }

  Duration get userElapsed {
    if (state.userWatchStartedAt == null) return Duration.zero;
    return DateTime.now().difference(state.userWatchStartedAt!);
  }
}
