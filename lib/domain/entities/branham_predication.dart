class BranhamFilterOption {
  const BranhamFilterOption({required this.label, required this.value});

  final String label;
  final String value;
}

class BranhamPredicationCatalog {
  const BranhamPredicationCatalog({
    required this.languages,
    required this.years,
    required this.durations,
    required this.series,
    required this.defaultLanguage,
  });

  final List<BranhamFilterOption> languages;
  final List<BranhamFilterOption> years;
  final List<BranhamFilterOption> durations;
  final List<BranhamFilterOption> series;
  final String defaultLanguage;
}

class BranhamPredication {
  const BranhamPredication({
    required this.code,
    required this.title,
    required this.location,
    required this.durationMinutes,
    required this.dateLabel,
    required this.audioUrl,
    required this.pdfUrl,
    required this.streamUrl,
  });

  final String code;
  final String title;
  final String location;
  final int? durationMinutes;
  final String dateLabel;
  final String? audioUrl;
  final String? pdfUrl;
  final String? streamUrl;
}