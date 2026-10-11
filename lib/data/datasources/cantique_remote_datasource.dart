import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/cantique.dart';

abstract class CantiqueRemoteDataSource {
  Future<List<Cantique>> fetchCantiques();
}

class CantiqueRemoteDataSourceImpl implements CantiqueRemoteDataSource {
  CantiqueRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  static const _coverByCategory = {
    'Chants Bouclier De David': '/images/docs/harp-0.png',
    'Crois Seulement': '/images/docs/songbook-1.jpg',
    'Hosana': '/images/docs/songbook-1.jpg',
    'Pene Na Yo': '/images/docs/songbook-1.jpg',
    'Instrumentale': '/images/music/eagle_0.png',
    "Chants d'ensemble": '/images/music/eagle_0.png',
    'Chants individuels': '/images/docs/songbook-1.jpg',
  };

  static const _youtubeSearchQueries = [
    'shekinah',
    'elalanga',
    'ensemble',
    'cantique',
    'louange',
  ];

  static final _excludeTitle = RegExp(
    r'(option|binaire|trading|boom|crash|trader|diffusion en direct|habillement|souhait du pasteur)',
    caseSensitive: false,
  );

  static final _includeTitle = RegExp(
    r"(shekinah|elalanga|elelanga|ensemble|cantique|chant|louange|adoration|hosana|"
    r"paternelle|ami fid[eè]le|croix|p[eè]lerin|mis[eé]ricorde|fontaine|"
    r"sauveur|christ|dieu|amour|culte|ador)",
    caseSensitive: false,
  );

  @override
  Future<List<Cantique>> fetchCantiques() async {
    final results = await Future.wait([
      _fetchAudioTracks(),
      _fetchVimeoEnsemble(),
      _fetchYoutubeCantiques(),
    ]);
    final all = <Cantique>[
      ...results[0],
      ...results[1],
      ...results[2],
    ];
    if (all.isEmpty) {
      throw Exception('Aucun cantique trouvé.');
    }

    all.sort((a, b) {
      final cat = a.category.compareTo(b.category);
      if (cat != 0) return cat;
      final videoFirst = (b.hasVideo ? 1 : 0) - (a.hasVideo ? 1 : 0);
      if (videoFirst != 0) return videoFirst;
      if (a.number != b.number) return a.number.compareTo(b.number);
      return a.title.compareTo(b.title);
    });
    return all;
  }

  Future<List<Cantique>> _fetchAudioTracks() async {
    try {
      final script = await _resolvePlaylistScript();
      return _parseTracks(script);
    } catch (_) {
      return const [];
    }
  }

  Future<List<Cantique>> _fetchVimeoEnsemble() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '${AppConstants.notificationsApiBaseUrl}/api/v1/vimeo/worships',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          connectTimeout:
              Duration(milliseconds: AppConstants.connectionTimeout),
          receiveTimeout:
              Duration(milliseconds: AppConstants.receiveTimeout),
        ),
      );

      final rows = response.data?['data'];
      if (rows is! List) return const [];

      final items = <Cantique>[];
      for (final row in rows) {
        if (row is! Map) continue;
        final map = Map<String, dynamic>.from(row);
        final uri = map['uri']?.toString() ?? '';
        final videoId = uri.split('/').lastWhere(
              (part) => part.isNotEmpty,
              orElse: () => '',
            );
        final title = (map['name']?.toString() ?? '').trim();
        if (videoId.isEmpty || title.isEmpty) continue;

        items.add(
          Cantique(
            id: 'vimeo_$videoId',
            number: 0,
            title: title,
            category: "Chants d'ensemble",
            videoId: videoId,
            videoEmbedUrl: map['player_embed_url']?.toString().trim(),
            videoProvider: CantiqueVideoProvider.vimeo,
            coverUrl: _bestVimeoThumb(map['pictures']),
            performer: _extractPerformer(title),
            isVideoOnly: true,
          ),
        );
      }
      return items;
    } catch (_) {
      return const [];
    }
  }

  Future<List<Cantique>> _fetchYoutubeCantiques() async {
    try {
      final idSets = await Future.wait(
        _youtubeSearchQueries.map(_youtubeChannelSearchIds),
      );
      final ids = <String>{};
      for (final set in idSets) {
        ids.addAll(set);
      }
      if (ids.isEmpty) return const [];

      final metas = await _fetchYoutubeMetasInBatches(ids);
      final items = <Cantique>[];
      for (final meta in metas) {
        if (meta == null) continue;
        final title = meta.title.trim();
        if (title.isEmpty) continue;
        if (_excludeTitle.hasMatch(title)) continue;
        if (!_includeTitle.hasMatch(title)) continue;

        final ensemble =
            RegExp(r'ensemble', caseSensitive: false).hasMatch(title);
        items.add(
          Cantique(
            id: 'youtube_${meta.videoId}',
            number: 0,
            title: title,
            category: ensemble ? "Chants d'ensemble" : 'Chants individuels',
            videoId: meta.videoId,
            videoProvider: CantiqueVideoProvider.youtube,
            coverUrl: 'https://i.ytimg.com/vi/${meta.videoId}/hqdefault.jpg',
            performer: meta.author.isEmpty
                ? _extractPerformer(title)
                : meta.author,
            isVideoOnly: true,
          ),
        );
      }
      return items;
    } catch (_) {
      return const [];
    }
  }

  Future<List<({String videoId, String title, String author})?>>
      _fetchYoutubeMetasInBatches(Set<String> ids) async {
    const batchSize = 8;
    final idList = ids.toList();
    final metas = <({String videoId, String title, String author})?>[];
    for (var i = 0; i < idList.length; i += batchSize) {
      final batch = idList.skip(i).take(batchSize);
      metas.addAll(await Future.wait(batch.map(_youtubeOEmbedLabeled)));
    }
    return metas;
  }

  Future<({String videoId, String title, String author})?> _youtubeOEmbedLabeled(
    String videoId,
  ) async {
    final meta = await _youtubeOEmbed(videoId);
    if (meta == null) return null;
    return (videoId: videoId, title: meta.title, author: meta.author);
  }

  Future<Set<String>> _youtubeChannelSearchIds(String query) async {
    final response = await dio.get<String>(
      'https://www.youtube.com/channel/${AppConstants.youtubeCantiquesChannelId}/search',
      queryParameters: {'query': query},
      options: Options(
        responseType: ResponseType.plain,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          'Accept-Language': 'fr-FR,fr;q=0.9',
        },
        connectTimeout:
            Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout:
            Duration(milliseconds: AppConstants.receiveTimeout),
      ),
    );

    final html = response.data ?? '';
    final ids = <String>{};
    for (final match in RegExp(r'"videoId":"([A-Za-z0-9_-]{11})"')
        .allMatches(html)) {
      ids.add(match.group(1)!);
    }
    return ids;
  }

  Future<({String title, String author})?> _youtubeOEmbed(String videoId) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        'https://www.youtube.com/oembed',
        queryParameters: {
          'url': 'https://www.youtube.com/watch?v=$videoId',
          'format': 'json',
        },
        options: Options(
          headers: {'User-Agent': AppConstants.userAgent},
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
        ),
      );
      final title = response.data?['title']?.toString() ?? '';
      final author = response.data?['author_name']?.toString() ?? '';
      if (title.isEmpty) return null;
      return (title: title, author: author);
    } catch (_) {
      return null;
    }
  }

  String? _bestVimeoThumb(dynamic pictures) {
    if (pictures is! Map) return null;
    final sizes = pictures['sizes'];
    if (sizes is! List || sizes.isEmpty) return null;
    Map? best;
    var bestWidth = -1;
    for (final size in sizes) {
      if (size is! Map) continue;
      final width = size['width'];
      final w = width is int ? width : int.tryParse('$width') ?? 0;
      if (w >= bestWidth) {
        bestWidth = w;
        best = size;
      }
    }
    final link = best?['link']?.toString();
    if (link == null || link.isEmpty) return null;
    return link;
  }

  String? _extractPerformer(String title) {
    final patterns = [
      RegExp(r'Fr\.?\s*Dauphin\s+Elalanga', caseSensitive: false),
      RegExp(r'Fr\.?\s*Dauphin\s+ELALANGA', caseSensitive: false),
      RegExp(r'brother\s+dauphin[^\|/,-]*', caseSensitive: false),
      RegExp(r'Fr\.?\s*Emmanuel\s+TSHILUMBA', caseSensitive: false),
      RegExp(r'Fr\.?\s*Chrispin\s+TSHILUMBA', caseSensitive: false),
      RegExp(r'frere\s+Etienne\s+TOMATALA', caseSensitive: false),
      RegExp(r'brother\s+tomatala', caseSensitive: false),
      RegExp(r'Pastor\s+diyoka', caseSensitive: false),
      RegExp(r'Pastor\s+Dick', caseSensitive: false),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(title);
      if (match != null) {
        return match.group(0)!.replaceAll(RegExp(r'\s+'), ' ').trim();
      }
    }
    return null;
  }

  Future<String> _resolvePlaylistScript() async {
    final home = await _getPlain('${AppConstants.websiteUrl}/multimedia');
    final mainName = RegExp(r'main-[A-Z0-9]+\.js').firstMatch(home)?.group(0);
    if (mainName == null) {
      throw Exception('Script principal introuvable');
    }

    final mainJs = await _getPlain('${AppConstants.websiteUrl}/$mainName');

    try {
      final script = await _resolvePlaylistFromMultimediaRoute(mainJs);
      if (_parseTracks(script).isNotEmpty) return script;
    } catch (_) {}

    return _resolvePlaylistFromMainBundle(mainJs);
  }

  Future<String> _resolvePlaylistFromMultimediaRoute(String mainJs) async {
    final routesChunk = RegExp(
      r'path:"multimedia",loadChildren:\(\)=>import\("\./(chunk-[A-Z0-9]+\.js)"\)',
    ).firstMatch(mainJs)?.group(1);
    if (routesChunk == null) {
      throw Exception('Module multimedia introuvable');
    }

    final routesJs =
        await _getPlain('${AppConstants.websiteUrl}/$routesChunk');
    final componentChunk = RegExp(
      r'import\("\./(chunk-[A-Z0-9]+\.js)"\)\.then\(\w+=>\w+\.MultimediaComponent\)',
    ).firstMatch(routesJs)?.group(1);
    if (componentChunk == null) {
      throw Exception('Composant multimedia introuvable');
    }

    final componentJs =
        await _getPlain('${AppConstants.websiteUrl}/$componentChunk');
    final imports = RegExp(r'from"\./(chunk-[A-Z0-9]+\.js)"')
        .allMatches(componentJs)
        .map((m) => m.group(1)!)
        .toSet();

    return _firstAudioPlaylistChunk(imports);
  }

  Future<String> _resolvePlaylistFromMainBundle(String mainJs) async {
    final chunks = RegExp(r'"(chunk-[A-Z0-9]+\.js)"')
        .allMatches(mainJs)
        .map((m) => m.group(1)!)
        .toSet();
    return _firstAudioPlaylistChunk(chunks);
  }

  Future<String> _firstAudioPlaylistChunk(Iterable<String> chunks) async {
    for (final chunk in chunks) {
      final body = await _getPlain('${AppConstants.websiteUrl}/$chunk');
      if (body.contains('shekinah-audio.azureedge.net') &&
          _parseTracks(body).isNotEmpty) {
        return body;
      }
    }
    throw Exception('Liste des cantiques introuvable');
  }

  List<Cantique> _parseTracks(String script) {
    final matches = RegExp(
      r'\{id:(\d+),title:"((?:\\.|[^"\\])*)",category:"((?:\\.|[^"\\])*)",source:"((?:\\.|[^"\\])*)"\}',
    ).allMatches(script);

    final items = <Cantique>[];
    for (final match in matches) {
      final rawTitle = _decodeJsString(match.group(2)!);
      final category = _decodeJsString(match.group(3)!);
      final source = _decodeJsString(match.group(4)!);
      if (!source.startsWith('http')) continue;
      // Photos / images parfois listées dans la playlist (ex. Pene Na Yo).
      if (!_isAudioSource(source)) continue;

      items.add(
        Cantique(
          id: '${category}_${match.group(1)}',
          number: _numberFromTitle(rawTitle),
          title: rawTitle,
          category: category,
          audioUrl: source,
          coverUrl: _coverUrl(category),
        ),
      );
    }
    return items;
  }

  /// Accepte uniquement les médias audio (ignore .jpg, .png, etc.).
  bool _isAudioSource(String source) {
    final path =
        (Uri.tryParse(source)?.path ?? source).toLowerCase();
    const audioExts = [
      '.mp3',
      '.m4a',
      '.aac',
      '.wav',
      '.ogg',
      '.flac',
      '.opus',
      '.wma',
    ];
    return audioExts.any(path.endsWith);
  }

  String _coverUrl(String category) {
    final path = _coverByCategory[category] ?? '/images/docs/songbook-1.jpg';
    return '${AppConstants.websiteUrl}$path';
  }

  int _numberFromTitle(String title) {
    final match = RegExp(r'^(\d+)').firstMatch(title.trim());
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  String _decodeJsString(String value) {
    return value
        .replaceAllMapped(
          RegExp(r'\\x([0-9A-Fa-f]{2})'),
          (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
        )
        .replaceAllMapped(
          RegExp(r'\\u([0-9A-Fa-f]{4})'),
          (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
        )
        .replaceAll(r"\'", "'")
        .replaceAll(r'\"', '"')
        .replaceAll(r'\\', r'\');
  }

  Future<String> _getPlain(String url) async {
    final response = await dio.get<String>(
      url,
      options: Options(
        responseType: ResponseType.plain,
        headers: {'User-Agent': AppConstants.userAgent},
      ),
    );
    return response.data ?? '';
  }
}
