class LibraryMessage {
  const LibraryMessage({
    required this.id,
    required this.title,
    required this.date,
    required this.pdfUrl,
  });

  final String id;
  final String title;
  final DateTime? date;
  final String pdfUrl;
}
