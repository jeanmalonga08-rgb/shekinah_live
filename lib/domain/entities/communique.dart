class Communique {
  final String title;
  final String message;
  final String readMoreLabel;
  final String readMoreUrl;
  final String language;

  const Communique({
    required this.title,
    required this.message,
    required this.readMoreLabel,
    required this.readMoreUrl,
    this.language = 'fr',
  });
}
