import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/library_pdf_reader_storage_service.dart';
import '../../domain/entities/library_pdf_reader_state.dart';

final libraryPdfReaderStorageProvider = Provider<LibraryPdfReaderStorageService>(
  (ref) => LibraryPdfReaderStorageService(),
);

final libraryPdfReaderStateProvider =
    StateNotifierProvider.family<LibraryPdfReaderNotifier, LibraryPdfReaderState, String>(
  LibraryPdfReaderNotifier.new,
);

class LibraryPdfReaderNotifier extends StateNotifier<LibraryPdfReaderState> {
  LibraryPdfReaderNotifier(this._ref, this._documentKey)
      : super(const LibraryPdfReaderState()) {
    _load();
  }

  final Ref _ref;
  final String _documentKey;

  Future<void> _load() async {
    final loaded =
        await _ref.read(libraryPdfReaderStorageProvider).load(_documentKey);
    state = loaded;
  }

  Future<void> _persist() async {
    await _ref.read(libraryPdfReaderStorageProvider).save(_documentKey, state);
  }

  Future<void> setLastPage(int page) async {
    if (state.lastPage == page) return;
    state = state.copyWith(lastPage: page);
    await _persist();
  }

  Future<void> toggleBookmark(int page) async {
    final bookmarks = [...state.bookmarks];
    if (bookmarks.contains(page)) {
      bookmarks.remove(page);
    } else {
      bookmarks.add(page);
      bookmarks.sort();
    }
    state = state.copyWith(bookmarks: bookmarks);
    await _persist();
  }

  Future<void> addAnnotation(LibraryPdfAnnotation annotation) async {
    state = state.copyWith(
      annotations: [...state.annotations, annotation],
    );
    await _persist();
  }

  Future<void> removeAnnotation(String id) async {
    state = state.copyWith(
      annotations:
          state.annotations.where((annotation) => annotation.id != id).toList(),
    );
    await _persist();
  }

  Future<void> clearAnnotations() async {
    state = state.copyWith(annotations: []);
    await _persist();
  }
}
