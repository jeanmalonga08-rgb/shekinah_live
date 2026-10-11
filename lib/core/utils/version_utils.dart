/// Compare les versions `major.minor.patch` et leur numéro de build `+N`.
class VersionUtils {
  VersionUtils._();

  /// `true` si [current] est strictement inférieure à [reference].
  static bool isLower(String current, String reference) {
    return compare(current, reference) < 0;
  }

  /// Retourne un entier négatif / zéro / positif comme [Comparable.compareTo].
  static int compare(String a, String b) {
    final pa = _parse(a);
    final pb = _parse(b);
    for (var i = 0; i < 4; i++) {
      if (pa[i] != pb[i]) return pa[i].compareTo(pb[i]);
    }
    return 0;
  }

  static List<int> _parse(String raw) {
    final trimmed = raw.trim();
    final versionParts = trimmed.split('+');
    final name = versionParts.first.trim();
    final parts = name.split('.');
    final numbers = <int>[];
    for (var i = 0; i < 3; i++) {
      if (i >= parts.length) {
        numbers.add(0);
        continue;
      }
      numbers.add(int.tryParse(parts[i].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0);
    }
    final build = versionParts.length > 1
        ? int.tryParse(versionParts.last.trim()) ?? 0
        : 0;
    numbers.add(build);
    return numbers;
  }
}
