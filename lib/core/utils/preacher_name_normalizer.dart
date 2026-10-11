/// Normalise les noms de prédicateurs pour l'UI tout en conservant
/// les variantes brutes pour les filtres / recherches Supabase.
class NormalizedPreacher {
  const NormalizedPreacher({
    required this.label,
    required this.variants,
  });

  /// Libellé unique affiché dans le filtre.
  final String label;

  /// Toutes les valeurs `minister` en base regroupées sous ce libellé.
  final List<String> variants;
}

class NormalizedPreachers {
  const NormalizedPreachers({required this.options});

  final List<NormalizedPreacher> options;

  List<String> get labels => options.map((o) => o.label).toList(growable: false);

  bool containsLabel(String label) => options.any((o) => o.label == label);

  /// Variantes DB pour un libellé canonique (ou la valeur elle-même en secours).
  List<String> variantsFor(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return const [];

    for (final option in options) {
      if (option.label == trimmed) return option.variants;
    }

    final fp = PreacherNameNormalizer.fingerprint(trimmed);
    for (final option in options) {
      if (PreacherNameNormalizer.fingerprint(option.label) == fp) {
        return option.variants;
      }
      for (final variant in option.variants) {
        if (variant == trimmed ||
            PreacherNameNormalizer.fingerprint(variant) == fp) {
          return option.variants;
        }
      }
    }

    return [trimmed];
  }

  /// Si [query] correspond à un prédicateur (libellé, variante, ou empreinte),
  /// retourne toutes ses variantes ; sinon liste vide.
  List<String> variantsMatchingSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final qLower = q.toLowerCase();
    final qFp = PreacherNameNormalizer.fingerprint(q);
    if (qFp.isEmpty) return const [];

    for (final option in options) {
      if (option.label.toLowerCase() == qLower) {
        return option.variants;
      }
      if (PreacherNameNormalizer.fingerprint(option.label) == qFp) {
        return option.variants;
      }
      for (final variant in option.variants) {
        if (variant.toLowerCase() == qLower) {
          return option.variants;
        }
        if (PreacherNameNormalizer.fingerprint(variant) == qFp) {
          return option.variants;
        }
      }
    }

    // Recherche partielle (ex. "DIYOKA") : union des variantes concernées.
    if (qFp.length < 5) return const [];
    final partial = <String>{};
    for (final option in options) {
      final labelFp = PreacherNameNormalizer.fingerprint(option.label);
      if (labelFp.contains(qFp)) {
        partial.addAll(option.variants);
      }
    }
    return partial.toList(growable: false);
  }
}

class PreacherNameNormalizer {
  PreacherNameNormalizer._();

  /// Regroupe les noms bruts en entrées normalisées.
  static NormalizedPreachers normalize(Iterable<String> rawNames) {
    final byFingerprint = <String, Set<String>>{};

    for (final raw in rawNames) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      final fp = fingerprint(trimmed);
      if (fp.isEmpty) continue;
      byFingerprint.putIfAbsent(fp, () => <String>{}).add(trimmed);
    }

    final options = byFingerprint.values.map((variants) {
      final list = variants.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return NormalizedPreacher(
        label: _pickLabel(list),
        variants: List.unmodifiable(list),
      );
    }).toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));

    return NormalizedPreachers(options: List.unmodifiable(options));
  }

  /// Empreinte stable pour regrouper les variantes (typos, titres, accents).
  static String fingerprint(String raw) {
    var s = _stripDiacritics(raw).toLowerCase().trim();
    s = s.replaceAll(RegExp(r'[^\w\s-]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Titres / préfixes redondants.
    s = s.replaceAllMapped(
      RegExp(
        r'\b(brother|pastor|pasteur|frere|fr|past)\b\.?',
        caseSensitive: false,
      ),
      (_) => ' ',
    );
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Abréviations / typos fréquentes.
    s = s.replaceAll(RegExp(r'\btheo\b'), 'theophile');
    s = s.replaceAll(RegExp(r'\bdioyka\b'), 'diyoka');
    s = s.replaceAll(RegExp(r'\bdoyoka\b'), 'diyoka');
    s = s.replaceAll(RegExp(r'\blukumuena\b'), 'lukumwena');
    s = s.replaceAll(RegExp(r'\bnsomue\b'), 'nsomue');

    // Suffixes bruit (ex. "DIYOKA Ns", "LUKUMUENA-USA").
    s = s.replaceAll(RegExp(r'-(usa|us|fr|en)\b'), '');
    s = s.replaceAll(RegExp(r'\b(ns|usa)\b'), '');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    return s;
  }

  static String _pickLabel(List<String> variants) {
    if (variants.isEmpty) return '';
    if (variants.length == 1) return _cleanupDisplay(variants.first);

    NormalizedCandidate? best;
    for (final variant in variants) {
      final candidate = NormalizedCandidate(variant, _score(variant));
      if (best == null || candidate.score > best.score) {
        best = candidate;
      }
    }
    return _cleanupDisplay(best!.value);
  }

  static int _score(String value) {
    final lower = value.toLowerCase();
    var score = 0;

    if (lower.startsWith('pastor ')) {
      score += 40;
    } else if (lower.startsWith('pasteur ')) {
      score += 35;
    } else if (lower.startsWith('brother ')) {
      score += 25;
    } else if (lower.startsWith('frère ') || lower.startsWith('frere ')) {
      score += 20;
    }

    // Pénaliser les libellés sales / doublons de titre.
    if (RegExp(r'\bpast\.?\b', caseSensitive: false).hasMatch(lower) &&
        lower.startsWith('pastor ')) {
      score -= 50;
    }
    if (lower.contains('pasteur') && lower.startsWith('pastor ')) {
      score -= 40;
    }
    if (RegExp(r'\bfr\.?\b').hasMatch(lower) &&
        (lower.startsWith('brother ') || lower.startsWith('frère '))) {
      score -= 25;
    }
    if (RegExp(r'\s{2,}').hasMatch(value)) score -= 15;
    if (RegExp(r'\bns\b', caseSensitive: false).hasMatch(lower)) score -= 20;
    if (lower.contains('-usa')) score -= 10;

    // Pénaliser les typos connus pour ne pas les afficher comme libellé.
    if (RegExp(r'\bdioyka\b').hasMatch(lower)) score -= 35;
    if (RegExp(r'\bdoyoka\b').hasMatch(lower)) score -= 35;
    if (RegExp(r'\blukumuena\b').hasMatch(lower)) score -= 25;

    // Préférer une capitalisation mixte à un libellé TOUT EN MAJUSCULES.
    final letters = value.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ]'), '');
    if (letters.length > 6 && letters == letters.toUpperCase()) {
      score -= 18;
    }

    // Préférer accents (Grâce > Grace) et formes longues (Théophile > Théo).
    if (value != _stripDiacritics(value)) score += 8;
    if (RegExp(r'\bthéophile\b', caseSensitive: false).hasMatch(value) ||
        RegExp(r'\btheophile\b', caseSensitive: false).hasMatch(lower)) {
      score += 12;
    }
    if (RegExp(r'\bgrâce\b', caseSensitive: false).hasMatch(value)) {
      score += 6;
    }
    if (RegExp(r'\bdiyoka\b').hasMatch(lower)) score += 8;

    score += value.length;
    return score;
  }

  static String _cleanupDisplay(String value) {
    var s = value.trim().replaceAll(RegExp(r'\s+'), ' ');

    // "Pastor Past. X" / "Pastor pasteur X" → "Pastor X"
    s = s.replaceFirst(
      RegExp(r'^(Pastor)\s+(Past\.?|pasteur)\s+', caseSensitive: false),
      r'$1 ',
    );
    // "Brother Fr. X" / "Brother Fr X" → "Brother X"
    s = s.replaceFirst(
      RegExp(r'^(Brother)\s+Fr\.?\s+', caseSensitive: false),
      r'$1 ',
    );
    // Suffixe bruit.
    s = s.replaceFirst(RegExp(r'\s+Ns$', caseSensitive: false), '');
    s = s.replaceFirst(RegExp(r'-USA$', caseSensitive: false), '');

    // Orthographes canoniques.
    s = s.replaceAllMapped(
      RegExp(r'\b(DIOYKA|DOYOKA)\b', caseSensitive: false),
      (_) => 'DIYOKA',
    );
    s = s.replaceAllMapped(
      RegExp(r'\bLUKUMUENA\b', caseSensitive: false),
      (_) => 'LUKUMWENA',
    );
    s = s.replaceFirst(RegExp(r'\bFAUSTIN\b'), 'Faustin');
    s = s.replaceFirst(RegExp(r'\bOBED\b'), 'Obed');

    return s.trim();
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

class NormalizedCandidate {
  const NormalizedCandidate(this.value, this.score);
  final String value;
  final int score;
}
