import 'dart:convert';

import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/library_book.dart';
import '../../domain/entities/library_message.dart';

abstract class LibraryRemoteDataSource {
  Future<List<LibraryBook>> fetchBooks({bool forceRefresh = false});

  Future<List<LibraryMessage>> fetchMessages({bool forceRefresh = false});

  void clearCache();
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  LibraryRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  List<LibraryBook>? _booksCache;
  List<LibraryMessage>? _messagesCache;

  static const _monthNames = <String, int>{
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };

  @override
  Future<List<LibraryBook>> fetchBooks({bool forceRefresh = false}) async {
    if (!forceRefresh && _booksCache != null) {
      return _booksCache!;
    }

    final response = await dio.get<dynamic>(
      AppConstants.libraryBookDataUrl,
      options: Options(
        headers: {'Accept': 'application/json'},
        connectTimeout:
            Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      ),
    );

    final rows = _asJsonList(response.data);
    final books = rows
        .whereType<Map>()
        .map((row) => _mapBook(Map<String, dynamic>.from(row)))
        .toList()
      ..sort((a, b) => a.title.compareTo(b.title));

    _booksCache = books;
    return books;
  }

  @override
  Future<List<LibraryMessage>> fetchMessages({bool forceRefresh = false}) async {
    if (!forceRefresh && _messagesCache != null) {
      return _messagesCache!;
    }

    // Same catalog as library.shekinahgospel.org/shekinah-publication
    // (1947–1965). API often omits Content-Type → Dio returns a raw String.
    final response = await dio.get<dynamic>(
      AppConstants.libraryMessageDataUrl,
      options: Options(
        headers: {'Accept': 'application/json'},
        responseType: ResponseType.plain,
        connectTimeout:
            Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      ),
    );

    final groups = _asJsonList(response.data);
    final messages = <LibraryMessage>[];
    for (final group in groups) {
      if (group is! Map) continue;
      final map = Map<String, dynamic>.from(group);
      final year = _asInt(map['year']);
      final items = map['items'];
      if (items is! List) continue;
      for (final item in items) {
        if (item is! Map) continue;
        final message = _mapMessage(
          Map<String, dynamic>.from(item),
          fallbackYear: year == 0 ? null : year,
        );
        if (message.title.isEmpty || message.pdfUrl.isEmpty) continue;
        messages.add(message);
      }
    }

    messages.sort((a, b) {
      final ad = a.date;
      final bd = b.date;
      if (ad == null && bd == null) return a.title.compareTo(b.title);
      if (ad == null) return 1;
      if (bd == null) return -1;
      final cmp = bd.compareTo(ad);
      return cmp != 0 ? cmp : a.title.compareTo(b.title);
    });

    _messagesCache = messages;
    return messages;
  }

  /// Décode une réponse Dio qui peut être déjà une List ou une String JSON.
  static List<dynamic> _asJsonList(Object? data) {
    if (data == null) return const [];
    if (data is List) return data;
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return const [];
      final decoded = jsonDecode(trimmed);
      if (decoded is List) return decoded;
    }
    throw FormatException(
      'Expected JSON list for library catalog, got ${data.runtimeType}',
    );
  }

  @override
  void clearCache() {
    _booksCache = null;
    _messagesCache = null;
  }

  LibraryBook _mapBook(Map<String, dynamic> row) {
    return LibraryBook(
      id: _asInt(row['id']),
      title: _asString(row['title']),
      subtitle: _normalizeMultiline(_asString(row['subtitle'])),
      author: _asString(row['author']),
      category: _asString(row['category']),
      date: _asString(row['date']),
      imagePath: _asString(row['image']),
      pdfUrl: _asString(row['url']),
    );
  }

  LibraryMessage _mapMessage(
    Map<String, dynamic> row, {
    int? fallbackYear,
  }) {
    final id = _asString(row['_id']).isNotEmpty
        ? _asString(row['_id'])
        : _asString(row['id']);
    final title = _asString(row['title']);
    final pdfUrl = _encodePdfUrl(_asString(row['url']));
    final date = _parseDate(_asString(row['date'])) ??
        (fallbackYear == null ? null : DateTime(fallbackYear));

    return LibraryMessage(
      id: id.isNotEmpty ? id : '${title.hashCode}_$pdfUrl',
      title: title,
      date: date,
      pdfUrl: pdfUrl,
    );
  }

  /// Blob URLs include unescaped spaces in file names; encode path for Flutter.
  static String _encodePdfUrl(String raw) {
    if (raw.isEmpty) return raw;
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme) {
      return raw.replaceAll(' ', '%20');
    }
    return uri.replace(pathSegments: uri.pathSegments).toString();
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _asString(Object? value) => value?.toString().trim() ?? '';

  static String _normalizeMultiline(String value) {
    return value
        .replaceAll('\u21b5', '\n')
        .replaceAll('↵', '\n')
        .replaceAll(r'\n', '\n');
  }

  static DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;

    // Catalog entries sometimes use placeholders like 1948-00-00 or 1953-06-00.
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (iso != null) {
      final year = int.tryParse(iso.group(1)!);
      if (year == null || year < 1000) return null;
      final monthRaw = int.tryParse(iso.group(2)!) ?? 0;
      final dayRaw = int.tryParse(iso.group(3)!) ?? 0;
      final month = monthRaw.clamp(1, 12);
      final day = dayRaw.clamp(1, 31);
      return DateTime(year, month, day);
    }

    // API dates: "Sat, 20 Feb 1965 00:00:00 GMT"
    final httpDate = RegExp(
      r'^[A-Za-z]{3},\s+(\d{1,2})\s+([A-Za-z]{3,9})\s+(\d{4})\b',
    ).firstMatch(value);
    if (httpDate != null) {
      final day = int.tryParse(httpDate.group(1)!) ?? 1;
      final month = _monthNames[httpDate.group(2)!.toLowerCase()];
      final year = int.tryParse(httpDate.group(3)!);
      if (month == null || year == null) return null;
      return DateTime(year, month, day.clamp(1, 31));
    }

    return null;
  }
}
