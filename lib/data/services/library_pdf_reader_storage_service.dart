import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/library_pdf_reader_state.dart';

class LibraryPdfReaderStorageService {
  static const _prefix = 'library_pdf_reader_v1_';

  Future<LibraryPdfReaderState> load(String documentKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$documentKey');
    if (raw == null || raw.isEmpty) {
      return const LibraryPdfReaderState();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return LibraryPdfReaderState.fromJson(json);
    } catch (_) {
      return const LibraryPdfReaderState();
    }
  }

  Future<void> save(String documentKey, LibraryPdfReaderState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix$documentKey',
      jsonEncode(state.toJson()),
    );
  }
}

String libraryPdfDocumentKey({
  String? sourceId,
  String? categoryName,
  required String fallback,
}) {
  if (sourceId != null &&
      sourceId.isNotEmpty &&
      categoryName != null &&
      categoryName.isNotEmpty) {
    return '${categoryName}_$sourceId';
  }
  return fallback.hashCode.toRadixString(16);
}
