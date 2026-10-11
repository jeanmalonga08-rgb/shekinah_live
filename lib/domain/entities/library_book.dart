class LibraryBook {
  const LibraryBook({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.author,
    required this.category,
    required this.date,
    required this.imagePath,
    required this.pdfUrl,
  });

  final int id;
  final String title;
  final String subtitle;
  final String author;
  final String category;
  final String date;
  final String imagePath;
  final String pdfUrl;

  String coverImageUrl(String assetsBaseUrl) {
    if (imagePath.startsWith('http')) return imagePath;
    final base = assetsBaseUrl.endsWith('/')
        ? assetsBaseUrl
        : '$assetsBaseUrl/';
    final path =
        imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '$base$path';
  }
}
