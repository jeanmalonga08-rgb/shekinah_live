import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../../domain/entities/branham_predication.dart';

const _branhamOrigin = 'https://branham.org';
const _messageAudioPath = '/fr/MessageAudio';
const _messageApiPath = '/branham/messageaudio.aspx';

class BranhamPredicationsRemoteDataSource {
  BranhamPredicationsRemoteDataSource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _branhamOrigin,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 40),
                headers: const {'Accept': 'text/html, application/json'},
              ),
            ) {
    _dio.interceptors.add(CookieManager(CookieJar()));
  }

  final Dio _dio;
  String? _activeLanguage;
  String? _defaultLanguage;

  Future<BranhamPredicationCatalog> fetchCatalog() async {
    final response = await _dio.get<String>(
      _messageAudioPath,
      options: Options(responseType: ResponseType.plain),
    );
    final document = html_parser.parse(response.data ?? '');
    final languages = _readOptions(document, 'ctl00\$main\$ddllanguages');
    final years = _readOptions(document, 'ctl00\$main\$ddlyears');
    final durations = _readOptions(document, 'ctl00\$main\$ddlnarrowlength');
    final series = _readOptions(document, 'ctl00\$main\$ddlseries');
    final defaultLanguage =
        _clean(document.querySelector('#currentlang')?.text) ??
            languages
                .where((option) => option.value == 'FRN')
                .firstOrNull
                ?.value ??
            (languages.isEmpty ? 'FRN' : languages.first.value);

    _defaultLanguage = defaultLanguage;
    return BranhamPredicationCatalog(
      languages: languages,
      years: years,
      durations: durations,
      series: series,
      defaultLanguage: defaultLanguage,
    );
  }

  Future<List<BranhamPredication>> fetchPredications({
    required String language,
    String search = '',
    String? year,
    String? duration,
    String? series,
  }) async {
    await _setLanguage(language);

    final filters = <({String method, String field, String value})>[];
    final searchValue = search.trim();
    if (searchValue.isNotEmpty) {
      filters.add((
        method: 'wmSearch',
        field: 'searchcriteria',
        value: searchValue,
      ));
    }
    if (year != null && year.isNotEmpty) {
      filters.add((method: 'wmSearchByYear', field: 'year', value: '$year-'));
    }
    if (duration != null && duration.isNotEmpty) {
      filters.add((method: 'wmSearchByMinutes', field: 'minutes', value: duration));
    }
    if (series != null && series.isNotEmpty) {
      filters.add((method: 'wmSearchBySeries', field: 'series', value: series));
    }

    if (filters.isEmpty) {
      return _fetchResults('wmSearch', const [
        {'name': 'searchcriteria', 'value': ''},
      ]);
    }

    var matches = await _fetchResults(filters.first.method, [
      {'name': filters.first.field, 'value': filters.first.value},
    ]);
    for (final filter in filters.skip(1)) {
      final filtered = await _fetchResults(filter.method, [
        {'name': filter.field, 'value': filter.value},
      ]);
      final codes = filtered.map((item) => item.code).toSet();
      matches = matches.where((item) => codes.contains(item.code)).toList();
    }
    return matches;
  }

  Future<void> _setLanguage(String language) async {
    final targetLanguage = language.isEmpty ? _defaultLanguage ?? 'FRN' : language;
    if (_activeLanguage == targetLanguage) return;

    final response = await _post('wmSetLanguage', [
      {'name': 'language', 'value': targetLanguage},
    ]);
    if (response is! String || !response.startsWith('$targetLanguage|')) {
      throw const FormatException('La langue Branham.org n’a pas pu être sélectionnée.');
    }
    _activeLanguage = targetLanguage;
  }

  Future<List<BranhamPredication>> _fetchResults(
    String method,
    List<Map<String, String>> formVars,
  ) async {
    final response = await _post(method, formVars);
    if (response is! List || response.isEmpty) {
      throw const FormatException('Réponse invalide de Branham.org.');
    }
    return parseBranhamPredicationResults(response.first?.toString() ?? '');
  }

  Future<Object?> _post(
    String method,
    List<Map<String, String>> formVars,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_messageApiPath/$method',
      data: {'formVars': formVars},
      options: Options(contentType: Headers.jsonContentType),
    );
    final data = response.data;
    if (data == null || !data.containsKey('d')) {
      throw const FormatException('Réponse invalide de Branham.org.');
    }
    return data['d'];
  }

  List<BranhamFilterOption> _readOptions(Document document, String name) {
    final select = document.querySelectorAll('#frmcms select').where(
          (element) => element.attributes['name'] == name,
        ).firstOrNull;
    if (select == null) return const [];

    return select.querySelectorAll('option').skip(1).map((option) {
      return BranhamFilterOption(
        label: _clean(option.text) ?? '',
        value: option.attributes['value'] ?? '',
      );
    }).where((option) => option.value.isNotEmpty).toList();
  }
}

List<BranhamPredication> parseBranhamPredicationResults(String fragment) {
  final document = html_parser.parseFragment(fragment);
  return document.querySelectorAll('.messagebox').map((box) {
    final productTexts = box.querySelectorAll('.prodtext');
    final code = _clean(productTexts.isEmpty ? null : productTexts.first.text) ?? '';
    final title = _clean(box.querySelector('.prodtexttitle')?.text) ?? '';
    final details = box.querySelectorAll('.prodtext2').map((node) {
      return _clean(node.text) ?? '';
    }).where((text) => text.isNotEmpty).toList();
    final durationText = details.where((text) => text.toLowerCase().contains('min')).firstOrNull;
    final duration = durationText == null
        ? null
        : int.tryParse(RegExp(r'\d+').firstMatch(durationText)?.group(0) ?? '');
    final links = box.querySelectorAll('a[href]').map((anchor) {
      return Uri.parse(_branhamOrigin).resolve(anchor.attributes['href']!);
    }).toList();
    Uri? findLink(bool Function(Uri uri) predicate) {
      for (final uri in links) {
        if (predicate(uri)) return uri;
      }
      return null;
    }

    return BranhamPredication(
      code: code,
      title: title,
      location: details.isEmpty ? '' : details.first,
      durationMinutes: duration,
      dateLabel: details.length < 3 ? '' : details[2],
      audioUrl: findLink((uri) => uri.path.toLowerCase().endsWith('.m4a'))?.toString(),
      pdfUrl: findLink((uri) => uri.path.toLowerCase().endsWith('.pdf'))?.toString(),
      streamUrl: findLink((uri) => uri.path.toLowerCase().contains('/messagestream/'))?.toString(),
    );
  }).where((item) => item.code.isNotEmpty && item.title.isNotEmpty).toList();
}

String? _clean(String? value) {
  final cleaned = value?.replaceAll(RegExp(r'\s+'), ' ').trim();
  return cleaned == null || cleaned.isEmpty ? null : cleaned;
}