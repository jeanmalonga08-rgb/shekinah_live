/// Normalise les lieux pour l'UI tout en conservant les variantes brutes
/// pour les filtres Supabase.
class NormalizedLocation {
  const NormalizedLocation({
    required this.label,
    required this.variants,
  });

  /// Libellé unique affiché dans le filtre.
  final String label;

  /// Toutes les valeurs `location` en base regroupées sous ce libellé.
  final List<String> variants;
}

class NormalizedLocations {
  const NormalizedLocations({required this.options});

  final List<NormalizedLocation> options;

  List<String> get labels => options.map((o) => o.label).toList(growable: false);

  bool containsLabel(String label) => options.any((o) => o.label == label);

  /// Variantes DB pour un libellé canonique (ou la valeur elle-même en secours).
  List<String> variantsFor(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return const [];

    for (final option in options) {
      if (option.label == trimmed) return option.variants;
    }

    final fp = LocationNormalizer.fingerprint(trimmed);
    for (final option in options) {
      if (LocationNormalizer.fingerprint(option.label) == fp) {
        return option.variants;
      }
      for (final variant in option.variants) {
        if (variant == trimmed ||
            LocationNormalizer.fingerprint(variant) == fp) {
          return option.variants;
        }
      }
    }

    return [trimmed];
  }
}

class LocationNormalizer {
  LocationNormalizer._();

  /// Regroupe les lieux bruts en entrées normalisées.
  static NormalizedLocations normalize(Iterable<String> rawLocations) {
    final byFingerprint = <String, Set<String>>{};

    for (final raw in rawLocations) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      final fp = fingerprint(trimmed);
      if (fp.isEmpty) continue;
      byFingerprint.putIfAbsent(fp, () => <String>{}).add(trimmed);
    }

    final options = byFingerprint.values.map((variants) {
      final list = variants.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return NormalizedLocation(
        label: _pickLabel(list),
        variants: List.unmodifiable(list),
      );
    }).toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));

    return NormalizedLocations(options: List.unmodifiable(options));
  }

  /// Empreinte stable pour regrouper les variantes (casse, séparateurs, pays).
  static String fingerprint(String raw) {
    var s = _stripDiacritics(raw).toLowerCase().trim();
    s = s.replaceAll(RegExp(r'[,/\\-]+'), ' ');
    s = s.replaceAll(RegExp(r'[^\w\s]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    s = s.replaceAll(RegExp(r'\bjohanesburg\b'), 'johannesburg');
    s = s.replaceAll(RegExp(r'\bkinshsa\b'), 'kinshasa');

    s = s.replaceAll(RegExp(r'\bpart\s*\d+\b'), '');

    s = s.replaceAll(
      RegExp(
        r'\b(r\.?\s?d\.?\s?c\.?|rd\s?congo|rdcongo|rdc|r\.?\s?d\.?\s?congo|congo)\b',
      ),
      ' ',
    );
    s = s.replaceAll(RegExp(r'\b(rsa|sa|south africa)\b'), ' ');
    s = s.replaceAll(RegExp(r'\b(canada|can)\b'), ' ');
    s = s.replaceAll(RegExp(r'\b(belgique|belgium)\b'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    for (final city in _knownCities) {
      if (RegExp('\\b$city\\b').hasMatch(s)) return city;
    }

    return s;
  }

  static const _knownCities = [
    'bruxelles',
    'durban',
    'johannesburg',
    'kinshasa',
    'kolofuma',
    'kwilu ngongo',
    'lubumbashi',
    'montreal',
    'mvuazi',
    'tshikapa',
    'vancouver',
  ];

  static String _pickLabel(List<String> variants) {
    if (variants.isEmpty) return '';
    if (variants.length == 1) return _cleanupDisplay(variants.first);

    NormalizedLocationCandidate? best;
    for (final variant in variants) {
      final candidate = NormalizedLocationCandidate(
        variant,
        _score(variant),
      );
      if (best == null || candidate.score > best.score) {
        best = candidate;
      }
    }
    return _cleanupDisplay(best!.value);
  }

  static int _score(String value) {
    final lower = value.toLowerCase();
    var score = 0;

    if (RegExp(r'\bpart\s*\d+\b', caseSensitive: false).hasMatch(lower)) {
      score -= 40;
    }
    if (lower.contains('/')) score -= 8;
    if (lower.contains('-') && !lower.contains(', ')) score -= 6;
    if (lower.contains(', ')) score += 12;
    if (RegExp(r'\brdc\b', caseSensitive: false).hasMatch(lower)) score += 8;
    if (RegExp(r'\brsa\b', caseSensitive: false).hasMatch(lower)) score += 6;
    if (RegExp(r'\bcanada\b', caseSensitive: false).hasMatch(lower)) score += 6;
    if (RegExp(r'\bbelgique\b', caseSensitive: false).hasMatch(lower)) {
      score += 6;
    }

    final letters = value.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), '');
    if (letters.length > 4 && letters == letters.toUpperCase()) {
      score -= 15;
    }

    if (RegExp(r'\bjohanesburg\b', caseSensitive: false).hasMatch(lower)) {
      score -= 25;
    }
    if (RegExp(r'\bkinshsa\b', caseSensitive: false).hasMatch(lower)) {
      score -= 25;
    }

    if (value != _stripDiacritics(value)) score += 4;
    score += value.length.clamp(0, 40);
    return score;
  }

  static String _cleanupDisplay(String value) {
    var s = value.trim().replaceAll(RegExp(r'\s+'), ' ');

    s = s.replaceAllMapped(
      RegExp(r'\bJohanesburg\b', caseSensitive: false),
      (_) => 'Johannesburg',
    );
    s = s.replaceAllMapped(
      RegExp(r'\bKinshsa\b', caseSensitive: false),
      (_) => 'Kinshasa',
    );
    s = s.replaceAll(RegExp(r'\s+Part\s*\d+\b', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'\s*-\s*'), ', ');
    s = s.replaceAll('/', ', ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    final fp = fingerprint(s);
    switch (fp) {
      case 'kinshasa':
        return 'Kinshasa, RDC';
      case 'johannesburg':
        return 'Johannesburg, RSA';
      case 'durban':
        return 'Durban, RSA';
      case 'lubumbashi':
        return 'Lubumbashi, RDC';
      case 'tshikapa':
        return 'Tshikapa, RDC';
      case 'kolofuma':
        return 'Kolofuma, RD Congo';
      case 'kwilu ngongo':
        return 'Kwilu-Ngongo, RD Congo';
      case 'mvuazi':
        return 'Mvuazi, RD Congo';
      case 'montreal':
        return 'Montréal, Canada';
      case 'vancouver':
        return 'Vancouver, Canada';
      case 'bruxelles':
        return 'Bruxelles, Belgique';
    }

    return s;
  }

  static String _stripDiacritics(String input) {
    const map = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ä': 'a',
      'ã': 'a',
      'å': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'ö': 'o',
      'õ': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ý': 'y',
      'ÿ': 'y',
      'ñ': 'n',
      'ç': 'c',
      'À': 'A',
      'Á': 'A',
      'Â': 'A',
      'Ä': 'A',
      'È': 'E',
      'É': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Ì': 'I',
      'Í': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Ò': 'O',
      'Ó': 'O',
      'Ô': 'O',
      'Ö': 'O',
      'Ù': 'U',
      'Ú': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ç': 'C',
      'Ñ': 'N',
    };
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(map[ch] ?? ch);
    }
    return buffer.toString();
  }
}

class NormalizedLocationCandidate {
  const NormalizedLocationCandidate(this.value, this.score);
  final String value;
  final int score;
}
