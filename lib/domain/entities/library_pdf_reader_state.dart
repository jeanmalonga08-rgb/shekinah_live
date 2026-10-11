enum LibraryPdfAnnotationType { highlight, underline }

class LibraryPdfAnnotation {
  const LibraryPdfAnnotation({
    required this.id,
    required this.pageNumber,
    required this.type,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    this.text,
    this.colorValue = 0xFFFFEB3B,
  });

  final String id;
  final int pageNumber;
  final LibraryPdfAnnotationType type;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final String? text;
  final int colorValue;

  Map<String, dynamic> toJson() => {
        'id': id,
        'pageNumber': pageNumber,
        'type': type.name,
        'left': left,
        'top': top,
        'right': right,
        'bottom': bottom,
        'text': text,
        'colorValue': colorValue,
      };

  factory LibraryPdfAnnotation.fromJson(Map<String, dynamic> json) {
    return LibraryPdfAnnotation(
      id: json['id'] as String,
      pageNumber: json['pageNumber'] as int,
      type: LibraryPdfAnnotationType.values.byName(json['type'] as String),
      left: (json['left'] as num).toDouble(),
      top: (json['top'] as num).toDouble(),
      right: (json['right'] as num).toDouble(),
      bottom: (json['bottom'] as num).toDouble(),
      text: json['text'] as String?,
      colorValue: json['colorValue'] as int? ?? 0xFFFFEB3B,
    );
  }
}

class LibraryPdfReaderState {
  const LibraryPdfReaderState({
    this.lastPage = 1,
    this.bookmarks = const [],
    this.annotations = const [],
  });

  final int lastPage;
  final List<int> bookmarks;
  final List<LibraryPdfAnnotation> annotations;

  LibraryPdfReaderState copyWith({
    int? lastPage,
    List<int>? bookmarks,
    List<LibraryPdfAnnotation>? annotations,
  }) {
    return LibraryPdfReaderState(
      lastPage: lastPage ?? this.lastPage,
      bookmarks: bookmarks ?? this.bookmarks,
      annotations: annotations ?? this.annotations,
    );
  }

  Map<String, dynamic> toJson() => {
        'lastPage': lastPage,
        'bookmarks': bookmarks,
        'annotations': annotations.map((e) => e.toJson()).toList(),
      };

  factory LibraryPdfReaderState.fromJson(Map<String, dynamic> json) {
    return LibraryPdfReaderState(
      lastPage: json['lastPage'] as int? ?? 1,
      bookmarks: (json['bookmarks'] as List<dynamic>? ?? const [])
          .map((e) => e as int)
          .toList(),
      annotations: (json['annotations'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => LibraryPdfAnnotation.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
