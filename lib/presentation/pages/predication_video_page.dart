import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/network/network_guard.dart';
import '../../core/network/network_ready.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/cantique.dart';
import '../../domain/entities/multimedia_video.dart';
import '../../domain/entities/video_suggestion.dart';
import '../providers/predication_provider.dart';
import '../widgets/video_related_list.dart';

class PredicationVideoPage extends ConsumerStatefulWidget {
  const PredicationVideoPage({
    super.key,
    required this.title,
    required this.videoId,
    this.provider = CantiqueVideoProvider.vimeo,
    this.embedUrl,
    this.sourceId,
    this.relatedKind,
    this.relatedTitle,
    this.relatedDate,
    this.predicationType,
    this.cantiqueCategory,
    this.multimediaCategory,
  });

  final String title;
  final String videoId;
  final CantiqueVideoProvider provider;
  final String? embedUrl;
  final String? sourceId;
  final VideoRelatedKind? relatedKind;
  final String? relatedTitle;
  final DateTime? relatedDate;
  final String? predicationType;
  final String? cantiqueCategory;
  final MultimediaVideoCategory? multimediaCategory;

  @override
  ConsumerState<PredicationVideoPage> createState() =>
      _PredicationVideoPageState();
}

class _PredicationVideoPageState extends ConsumerState<PredicationVideoPage> {
  WebViewController? _controller;
  bool _loading = true;
  bool _isFullscreen = false;
  String? _playbackError;

  static const _vimeoReferer = '${AppConstants.websiteUrl}/';

  VideoRelatedQuery? get _relatedQuery {
    final id = widget.sourceId;
    final kind = widget.relatedKind;
    if (id == null || kind == null) return null;
    return VideoRelatedQuery(
      kind: kind,
      excludeId: id,
      title: widget.relatedTitle ?? widget.title,
      date: widget.relatedDate,
      predicationType: widget.predicationType,
      cantiqueCategory: widget.cantiqueCategory,
      multimediaCategory: widget.multimediaCategory,
    );
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await ensureNetworkReady();
      final uri = await _resolvePlaybackUri();
      final isYoutube = widget.provider == CantiqueVideoProvider.youtube;
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppTheme.primaryDark)
        ..addJavaScriptChannel(
          'FullscreenChannel',
          onMessageReceived: (message) {
            final next = message.message == 'true';
            if (next != _isFullscreen && mounted) {
              setState(() => _isFullscreen = next);
            }
          },
        );
      controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _playbackError = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
            _injectFullscreenListener(controller);
          },
          onWebResourceError: (error) async {
            // Erreur réseau / DNS : ne pas laisser la page d'erreur du site.
            final offline = error.errorType == WebResourceErrorType.hostLookup ||
                error.errorType == WebResourceErrorType.connect ||
                error.errorType == WebResourceErrorType.timeout ||
                !(await isNetworkReady());
            if (!mounted || !offline) return;
            setState(() {
              _controller = null;
              _loading = false;
              _playbackError = context.l10n.networkError;
            });
          },
          onNavigationRequest: (request) {
            final host = Uri.tryParse(request.url)?.host ?? '';
            if (isYoutube) {
              if (host.contains('youtube.com') ||
                  host.contains('youtube-nocookie.com') ||
                  host.contains('youtu.be') ||
                  host.contains('googlevideo.com') ||
                  host.contains('google.com') ||
                  host.contains('gstatic.com') ||
                  host.contains('ytimg.com')) {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            }
            if (host.contains('vimeo.com') || host.contains('vimeocdn.com')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );

      await controller.loadRequest(
        uri,
        headers: isYoutube ? const {} : {'Referer': _vimeoReferer},
      );

      if (!mounted) return;
      setState(() {
        _controller = controller;
        _loading = true;
        _playbackError = null;
      });
    } on NetworkUnavailableException {
      if (!mounted) return;
      setState(() {
        _controller = null;
        _playbackError = context.l10n.networkError;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _controller = null;
        _playbackError = context.l10n.mediaUnavailable;
        _loading = false;
      });
    }
  }

  Future<Uri> _resolvePlaybackUri() async {
    final isYoutube = widget.provider == CantiqueVideoProvider.youtube;
    if (isYoutube) {
      return Uri.https('www.youtube-nocookie.com', '/embed/${widget.videoId}', {
        'rel': '0',
        'modestbranding': '1',
        'playsinline': '1',
      });
    }

    var embedUrl = widget.embedUrl?.trim() ?? '';
    if (embedUrl.isEmpty) {
      embedUrl = await ref
              .read(predicationDataSourceProvider)
              .fetchVimeoPlayerEmbedUrl(widget.videoId) ??
          '';
    }

    if (embedUrl.isNotEmpty) {
      final uri = Uri.parse(embedUrl);
      return uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          'title': '0',
          'byline': '0',
          'portrait': '0',
          'color': 'd4a017',
          'autoplay': '1',
        },
      );
    }

    return Uri.https('player.vimeo.com', '/video/${widget.videoId}', {
      'title': '0',
      'byline': '0',
      'portrait': '0',
      'color': 'd4a017',
      'autoplay': '1',
    });
  }

  void _injectFullscreenListener(WebViewController controller) {
    controller.runJavaScript('''
      (function() {
        if (window.__shtFullscreenHook) return;
        window.__shtFullscreenHook = true;
        function notify() {
          var fs = !!(document.fullscreenElement || document.webkitFullscreenElement);
          FullscreenChannel.postMessage(fs ? 'true' : 'false');
        }
        document.addEventListener('fullscreenchange', notify);
        document.addEventListener('webkitfullscreenchange', notify);
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    final relatedQuery = _relatedQuery;
    final showRelated = relatedQuery != null && !_isFullscreen;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white, size: 24),
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              leading: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
              title: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                if (_controller != null)
                  WebViewWidget(controller: _controller!)
                else if (_playbackError != null)
                  ColoredBox(
                    color: Colors.black,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _playbackError!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.grey,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _loading = true;
                                  _playbackError = null;
                                });
                                _initPlayer();
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text(context.l10n.retry),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_loading)
                  ColoredBox(
                    color: Colors.black,
                    child: Center(
                      child: SpinKitFadingCircle(
                        color: AppTheme.accentGold,
                        size: 42,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (showRelated)
            Expanded(
              child: ColoredBox(
                color: AppTheme.background,
                child: VideoRelatedList(query: relatedQuery),
              ),
            )
          else if (!_isFullscreen && relatedQuery == null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    context.l10n.videoPlaybackHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.grey, height: 1.5),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
