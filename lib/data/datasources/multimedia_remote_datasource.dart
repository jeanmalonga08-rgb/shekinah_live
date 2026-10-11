import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/multimedia_video.dart';

abstract class MultimediaRemoteDataSource {
  Future<List<MultimediaVideo>> fetchDocumentaireScenetteVideos();
}

class MultimediaRemoteDataSourceImpl implements MultimediaRemoteDataSource {
  MultimediaRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  /// Remplacements connus quand l'ID Vimeo du site a disparu / est en cold storage.
  static const _replacements = <String, _Replacement>{
    '97033564': _Replacement(
      videoId: '921868457',
      title: 'Visite du Rabbin Jean-Marc Rosenfeld',
      dateLabel: '09-02-2023',
    ),
  };

  /// Fallback = même `_playList` que shekinahgospel.org/multimedia
  /// (catégories site : 2=Documentaire, 3=Scenette, 4=Divers).
  static const _fallbackEntries = <_CatalogEntry>[
    _CatalogEntry(
      id: '1',
      title: 'Interview Rabin Jean-marc Rosenfeld',
      category: MultimediaVideoCategory.divers,
      videoId: '97033564',
      dateLabel: '25-05-2014',
    ),
    _CatalogEntry(
      id: '2',
      title: 'Réunion de jeune : Saynète sur la Délinquance Juvénile',
      category: MultimediaVideoCategory.scenette,
      videoId: '126593056',
      dateLabel: '25-05-2014',
    ),
    _CatalogEntry(
      id: '3',
      title: 'Fin de la Traduction Shekinah Publications',
      category: MultimediaVideoCategory.documentaire,
      videoId: '155636764',
      dateLabel: '25-05-2014',
    ),
    _CatalogEntry(
      id: '4',
      title: 'Presentation Chantier Moriha',
      category: MultimediaVideoCategory.divers,
      videoId: '223154064',
      dateLabel: '25-06-2017',
    ),
    _CatalogEntry(
      id: '5',
      title: "La Conservation De L'espece",
      category: MultimediaVideoCategory.scenette,
      videoId: '34056576',
      dateLabel: '12-09-2009',
    ),
    _CatalogEntry(
      id: '6',
      title: 'La Delinquence Juvenile',
      category: MultimediaVideoCategory.scenette,
      videoId: '126593056',
      dateLabel: '25-05-2014',
    ),
    // Complément encore lisible sur Vimeo (pas dans le _playList site).
    _CatalogEntry(
      id: '921868453',
      title: 'Visite du Rabbin Jean-Marc Rosenfeld (08-02-2023)',
      category: MultimediaVideoCategory.divers,
      videoId: '921868453',
      dateLabel: '08-02-2023',
    ),
  ];

  @override
  Future<List<MultimediaVideo>> fetchDocumentaireScenetteVideos() async {
    final catalog = await _loadCatalog();
    final resolved = <MultimediaVideo>[];
    final seenKeys = <String>{};

    for (final entry in catalog) {
      final replacement = _replacements[entry.videoId];
      final candidateIds = <String>[
        if (replacement != null) replacement.videoId,
        entry.videoId,
      ];

      _ResolvedVimeo? meta;
      String? usedId;
      for (final id in candidateIds) {
        meta = await _resolveVimeo(id);
        if (meta != null) {
          usedId = id;
          break;
        }
      }

      final useReplacement =
          replacement != null && usedId != null && usedId == replacement.videoId;
      final effectiveId = usedId ?? entry.videoId;
      final dedupeKey = '${entry.category.name}:$effectiveId:${entry.title}';
      if (!seenKeys.add(dedupeKey)) continue;

      // Toujours afficher l'entrée (documentaire / scénette / divers),
      // même si Vimeo renvoie 404 ou cold_storage.
      resolved.add(
        MultimediaVideo(
          id: 'mm_${entry.id}_$effectiveId',
          title: useReplacement
              ? (replacement.title ?? meta?.name ?? entry.title)
              : entry.title,
          category: entry.category,
          videoId: effectiveId,
          dateLabel: useReplacement
              ? (replacement.dateLabel ?? entry.dateLabel)
              : entry.dateLabel,
          thumbnailUrl: meta?.thumbnailUrl,
          embedUrl: meta?.embedUrl,
          isAvailable: meta != null,
        ),
      );
    }

    // Ordre : disponibles d'abord, puis par catégorie puis titre.
    resolved.sort((a, b) {
      final byAvail = (b.isAvailable ? 1 : 0).compareTo(a.isAvailable ? 1 : 0);
      if (byAvail != 0) return byAvail;
      final byCat = a.category.index.compareTo(b.category.index);
      if (byCat != 0) return byCat;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return resolved;
  }

  Future<List<_CatalogEntry>> _loadCatalog() async {
    try {
      final scraped = await _scrapeSitePlaylist();
      if (scraped.isNotEmpty) {
        // Conserve le complément encore jouable hors liste site.
        final ids = scraped.map((e) => e.videoId).toSet();
        final extras = _fallbackEntries
            .where((e) => !ids.contains(e.videoId) && e.videoId == '921868453')
            .toList();
        return [...scraped, ...extras];
      }
    } catch (_) {}
    return List<_CatalogEntry>.of(_fallbackEntries);
  }

  /// Extrait `_playList` du composant Multimedia du site (cat. 2/3/4).
  Future<List<_CatalogEntry>> _scrapeSitePlaylist() async {
    final home = await _getPlain('${AppConstants.websiteUrl}/multimedia');
    final mainName = RegExp(r'main-[A-Z0-9]+\.js').firstMatch(home)?.group(0);
    if (mainName == null) return const [];

    final mainJs = await _getPlain('${AppConstants.websiteUrl}/$mainName');
    final routesChunk = RegExp(
      r'path:"multimedia",loadChildren:\(\)=>import\("\./(chunk-[A-Z0-9]+\.js)"\)',
    ).firstMatch(mainJs)?.group(1);
    if (routesChunk == null) return const [];

    final routesJs =
        await _getPlain('${AppConstants.websiteUrl}/$routesChunk');
    final componentChunk = RegExp(
      r'import\("\./(chunk-[A-Z0-9]+\.js)"\)\.then\(\w+=>\w+\.MultimediaComponent\)',
    ).firstMatch(routesJs)?.group(1);
    if (componentChunk == null) return const [];

    final componentJs =
        await _getPlain('${AppConstants.websiteUrl}/$componentChunk');
    final start = componentJs.indexOf('_playList=[');
    if (start < 0) return const [];
    final end = componentJs.indexOf('];', start);
    if (end < 0) return const [];
    final block = componentJs.substring(start, end);

    final matches = RegExp(
      r'\{id:(\d+),title:"((?:\\.|[^"\\])*)",category:"([234])",source:"(\d+)",date:"([^"]*)"\}',
    ).allMatches(block);

    final entries = <_CatalogEntry>[];
    for (final m in matches) {
      final category = _categoryFromSite(m.group(3)!);
      if (category == null) continue;
      entries.add(
        _CatalogEntry(
          id: m.group(1)!,
          title: _unescapeJsString(m.group(2)!),
          category: category,
          videoId: m.group(4)!,
          dateLabel: m.group(5),
        ),
      );
    }
    return entries;
  }

  MultimediaVideoCategory? _categoryFromSite(String code) {
    switch (code) {
      case '2':
        return MultimediaVideoCategory.documentaire;
      case '3':
        return MultimediaVideoCategory.scenette;
      case '4':
        return MultimediaVideoCategory.divers;
      default:
        return null;
    }
  }

  String _unescapeJsString(String raw) {
    return raw
        .replaceAllMapped(
          RegExp(r'\\x([0-9A-Fa-f]{2})'),
          (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
        )
        .replaceAllMapped(
          RegExp(r'\\u([0-9A-Fa-f]{4})'),
          (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
        )
        .replaceAll(r'\"', '"')
        .replaceAll(r"\'", "'")
        .replaceAll(r'\n', '\n');
  }

  Future<String> _getPlain(String url) async {
    final response = await dio.get<String>(
      url,
      options: Options(
        responseType: ResponseType.plain,
        headers: {
          'User-Agent': AppConstants.userAgent,
          'Accept': '*/*',
          'Accept-Language': 'fr-FR,fr;q=0.9',
        },
        connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      ),
    );
    return response.data ?? '';
  }

  Future<_ResolvedVimeo?> _resolveVimeo(String videoId) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '${AppConstants.notificationsApiBaseUrl}/api/v1/vimeo/videos/$videoId',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          connectTimeout: Duration(
            milliseconds: AppConstants.connectionTimeout,
          ),
          receiveTimeout: Duration(
            milliseconds: AppConstants.receiveTimeout,
          ),
          validateStatus: (status) =>
              status != null && status >= 200 && status < 500,
        ),
      );

      if (response.statusCode == 404 || response.data == null) return null;

      final data = response.data!;
      final status = data['status']?.toString() ?? '';
      final privacy = data['privacy'];
      final privacyView = privacy is Map
          ? privacy['view']?.toString() ?? ''
          : '';
      final play = data['play'];
      final playStatus =
          play is Map ? play['status']?.toString() ?? '' : '';

      if (privacyView == 'cold_storage' ||
          privacyView == 'disable' ||
          status == 'uploading_error' ||
          (playStatus.isNotEmpty && playStatus != 'playable')) {
        return null;
      }
      if (status.isNotEmpty && status != 'available') return null;

      final embedUrl = data['player_embed_url']?.toString().trim();
      final name = data['name']?.toString().trim();
      final thumb = _bestVimeoThumb(data['pictures']);

      return _ResolvedVimeo(
        name: name?.isEmpty == true ? null : name,
        embedUrl: (embedUrl != null && embedUrl.isNotEmpty) ? embedUrl : null,
        thumbnailUrl: thumb,
      );
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _bestVimeoThumb(dynamic pictures) {
    if (pictures is! Map) return null;
    final sizes = pictures['sizes'];
    if (sizes is! List || sizes.isEmpty) return null;

    Map<String, dynamic>? best;
    var bestWidth = -1;
    for (final size in sizes) {
      if (size is! Map) continue;
      final map = Map<String, dynamic>.from(size);
      final width = map['width'] as int? ?? 0;
      if (width >= bestWidth) {
        bestWidth = width;
        best = map;
      }
    }
    final link = best?['link']?.toString();
    return link != null && link.startsWith('http') ? link : null;
  }
}

class _CatalogEntry {
  const _CatalogEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.videoId,
    this.dateLabel,
  });

  final String id;
  final String title;
  final MultimediaVideoCategory category;
  final String videoId;
  final String? dateLabel;
}

class _Replacement {
  const _Replacement({
    required this.videoId,
    this.title,
    this.dateLabel,
  });

  final String videoId;
  final String? title;
  final String? dateLabel;
}

class _ResolvedVimeo {
  const _ResolvedVimeo({
    this.name,
    this.embedUrl,
    this.thumbnailUrl,
  });

  final String? name;
  final String? embedUrl;
  final String? thumbnailUrl;
}
