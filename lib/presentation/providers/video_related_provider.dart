import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cantique.dart';
import '../../domain/entities/multimedia_video.dart';
import '../../domain/entities/predication.dart';
import '../../domain/entities/video_suggestion.dart';
import 'cantique_provider.dart';
import 'multimedia_provider.dart';
import 'predication_provider.dart';

const _suggestionLimit = 12;

/// Fenêtre « même période » autour de la date de la vidéo en cours.
const _periodWindow = Duration(days: 45);

final videoRelatedSuggestionsProvider =
    FutureProvider.family<List<VideoSuggestion>, VideoRelatedQuery>(
  (ref, query) async {
    switch (query.kind) {
      case VideoRelatedKind.predication:
        return _predicationSuggestions(ref, query);
      case VideoRelatedKind.cantique:
        return _cantiqueSuggestions(ref, query);
      case VideoRelatedKind.multimedia:
        return _multimediaSuggestions(ref, query);
    }
  },
);

Future<List<VideoSuggestion>> _predicationSuggestions(
  Ref ref,
  VideoRelatedQuery query,
) async {
  final ds = ref.read(predicationDataSourceProvider);
  final pool = <Predication>[];

  for (var page = 0; page < 4; page++) {
    final result = await ds.fetchPredications(page: page);
    pool.addAll(result.items.where((p) => p.hasVideo && p.id != query.excludeId));
    if (!result.hasMore) break;
  }

  bool sameCategory(Predication p) =>
      query.predicationType != null &&
      query.predicationType!.isNotEmpty &&
      p.type == query.predicationType;

  bool sameTitleOrPeriod(Predication p) =>
      _titlesSimilar(query.title, p.title) ||
      _samePeriod(query.date, p.date);

  final tierCategory = pool.where(sameCategory).toList()
    ..sort((a, b) {
      final aBoost = sameTitleOrPeriod(a) ? 0 : 1;
      final bBoost = sameTitleOrPeriod(b) ? 0 : 1;
      if (aBoost != bBoost) return aBoost.compareTo(bBoost);
      return b.date.compareTo(a.date);
    });

  final tierTitlePeriod = pool
      .where((p) => !sameCategory(p) && sameTitleOrPeriod(p))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  final tierRecent = List<Predication>.from(pool)
    ..sort((a, b) => b.date.compareTo(a.date));

  return _mergePredications(tierCategory, tierTitlePeriod, tierRecent);
}

List<VideoSuggestion> _mergePredications(
  List<Predication> category,
  List<Predication> titleOrPeriod,
  List<Predication> recent,
) {
  final seen = <String>{};
  final out = <VideoSuggestion>[];

  void add(Predication p) {
    if (!seen.add(p.id)) return;
    final videoId = p.primaryVideoId;
    if (videoId == null) return;
    out.add(
      VideoSuggestion(
        id: p.id,
        title: p.title,
        subtitle: p.displayPreacher,
        thumbnailUrl: p.thumbnailUrl,
        videoId: videoId,
        kind: VideoRelatedKind.predication,
        predicationType: p.type,
        date: p.date,
      ),
    );
  }

  for (final list in [category, titleOrPeriod, recent]) {
    for (final p in list) {
      add(p);
      if (out.length >= _suggestionLimit) return out;
    }
  }
  return out;
}

Future<List<VideoSuggestion>> _cantiqueSuggestions(
  Ref ref,
  VideoRelatedQuery query,
) async {
  final all = await ref.read(cantiqueListProvider.future);
  final pool = all.where((c) => c.hasVideo && c.id != query.excludeId).toList();

  // « Période » cantique : numéros proches dans le recueil.
  Cantique? current;
  for (final c in all) {
    if (c.id == query.excludeId) {
      current = c;
      break;
    }
  }
  final currentNumber = current?.number;

  bool sameCategory(Cantique c) =>
      query.cantiqueCategory != null &&
      query.cantiqueCategory!.isNotEmpty &&
      c.category == query.cantiqueCategory;

  bool sameTitleOrPeriod(Cantique c) {
    if (_titlesSimilar(query.title, c.title) ||
        _titlesSimilar(query.title, c.displaySubtitle)) {
      return true;
    }
    if (currentNumber != null && currentNumber > 0 && c.number > 0) {
      return (c.number - currentNumber).abs() <= 8;
    }
    return false;
  }

  final tierCategory = pool.where(sameCategory).toList()
    ..sort((a, b) {
      final aBoost = sameTitleOrPeriod(a) ? 0 : 1;
      final bBoost = sameTitleOrPeriod(b) ? 0 : 1;
      if (aBoost != bBoost) return aBoost.compareTo(bBoost);
      return b.number.compareTo(a.number);
    });

  final tierTitlePeriod = pool
      .where((c) => !sameCategory(c) && sameTitleOrPeriod(c))
      .toList()
    ..sort((a, b) => b.number.compareTo(a.number));

  final tierRecent = List<Cantique>.from(pool)
    ..sort((a, b) => b.number.compareTo(a.number));

  return _mergeCantiques(tierCategory, tierTitlePeriod, tierRecent);
}

List<VideoSuggestion> _mergeCantiques(
  List<Cantique> category,
  List<Cantique> titleOrPeriod,
  List<Cantique> recent,
) {
  final seen = <String>{};
  final out = <VideoSuggestion>[];

  void add(Cantique c) {
    if (!seen.add(c.id)) return;
    final videoId = c.videoId;
    if (videoId == null || videoId.isEmpty) return;
    out.add(
      VideoSuggestion(
        id: c.id,
        title: c.title.trim().isEmpty ? c.category : c.title.trim(),
        subtitle: c.displaySubtitle,
        thumbnailUrl: c.coverUrl,
        videoId: videoId,
        provider: c.videoProvider ?? CantiqueVideoProvider.vimeo,
        videoEmbedUrl: c.videoEmbedUrl,
        kind: VideoRelatedKind.cantique,
        cantiqueCategory: c.category,
      ),
    );
  }

  for (final list in [category, titleOrPeriod, recent]) {
    for (final c in list) {
      add(c);
      if (out.length >= _suggestionLimit) return out;
    }
  }
  return out;
}

Future<List<VideoSuggestion>> _multimediaSuggestions(
  Ref ref,
  VideoRelatedQuery query,
) async {
  final all = await ref.read(documentaireScenetteProvider.future);
  final pool = all.where((v) => v.id != query.excludeId).toList();

  bool sameCategory(MultimediaVideo v) =>
      query.multimediaCategory != null &&
      v.category == query.multimediaCategory;

  bool sameTitleOrPeriod(MultimediaVideo v) {
    if (_titlesSimilar(query.title, v.title)) return true;
    return _samePeriod(query.date, _parseFlexibleDate(v.dateLabel));
  }

  int recencyKey(MultimediaVideo v) {
    final d = _parseFlexibleDate(v.dateLabel);
    return d?.millisecondsSinceEpoch ?? 0;
  }

  final tierCategory = pool.where(sameCategory).toList()
    ..sort((a, b) {
      final aBoost = sameTitleOrPeriod(a) ? 0 : 1;
      final bBoost = sameTitleOrPeriod(b) ? 0 : 1;
      if (aBoost != bBoost) return aBoost.compareTo(bBoost);
      return recencyKey(b).compareTo(recencyKey(a));
    });

  final tierTitlePeriod = pool
      .where((v) => !sameCategory(v) && sameTitleOrPeriod(v))
      .toList()
    ..sort((a, b) => recencyKey(b).compareTo(recencyKey(a)));

  final tierRecent = List<MultimediaVideo>.from(pool)
    ..sort((a, b) => recencyKey(b).compareTo(recencyKey(a)));

  return _mergeMultimedia(tierCategory, tierTitlePeriod, tierRecent);
}

List<VideoSuggestion> _mergeMultimedia(
  List<MultimediaVideo> category,
  List<MultimediaVideo> titleOrPeriod,
  List<MultimediaVideo> recent,
) {
  final seen = <String>{};
  final out = <VideoSuggestion>[];

  void add(MultimediaVideo v) {
    if (!seen.add(v.id)) return;
    out.add(
      VideoSuggestion(
        id: v.id,
        title: v.title,
        subtitle: v.dateLabel ?? '',
        thumbnailUrl: v.defaultThumbnailUrl,
        videoId: v.videoId,
        videoEmbedUrl: v.embedUrl,
        kind: VideoRelatedKind.multimedia,
        multimediaCategory: v.category,
        date: _parseFlexibleDate(v.dateLabel),
      ),
    );
  }

  for (final list in [category, titleOrPeriod, recent]) {
    for (final v in list) {
      add(v);
      if (out.length >= _suggestionLimit) return out;
    }
  }
  return out;
}

bool _samePeriod(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  if (a.year == b.year && a.month == b.month) return true;
  return a.difference(b).abs() <= _periodWindow;
}

bool _titlesSimilar(String? rawA, String? rawB) {
  final a = _normalizeTitle(rawA);
  final b = _normalizeTitle(rawB);
  if (a.isEmpty || b.isEmpty) return false;
  if (a == b) return true;
  if (a.contains(b) || b.contains(a)) return true;

  final wa = a.split(' ').where((w) => w.length > 3).toSet();
  final wb = b.split(' ').where((w) => w.length > 3).toSet();
  if (wa.isEmpty || wb.isEmpty) return false;
  final inter = wa.intersection(wb).length;
  if (inter >= 2) return true;
  final ratio = inter / (wa.length < wb.length ? wa.length : wb.length);
  return ratio >= 0.5;
}

String _normalizeTitle(String? raw) {
  if (raw == null) return '';
  var s = raw.toLowerCase().trim();
  const pairs = <List<String>>[
    ['é', 'e'],
    ['è', 'e'],
    ['ê', 'e'],
    ['à', 'a'],
    ['â', 'a'],
    ['ù', 'u'],
    ['û', 'u'],
    ['ô', 'o'],
    ['î', 'i'],
    ['ï', 'i'],
    ['ç', 'c'],
    ['’', ''],
    ["'", ''],
    ['-', ' '],
    ['_', ' '],
  ];
  for (final p in pairs) {
    s = s.replaceAll(p[0], p[1]);
  }
  s = s.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

DateTime? _parseFlexibleDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final value = raw.trim();
  final iso = DateTime.tryParse(value);
  if (iso != null) return iso;

  final dmy = RegExp(r'^(\d{1,2})[./-](\d{1,2})[./-](\d{4})$').firstMatch(value);
  if (dmy != null) {
    final d = int.tryParse(dmy.group(1)!);
    final m = int.tryParse(dmy.group(2)!);
    final y = int.tryParse(dmy.group(3)!);
    if (d != null && m != null && y != null) {
      return DateTime(y, m.clamp(1, 12), d.clamp(1, 31));
    }
  }
  return null;
}
