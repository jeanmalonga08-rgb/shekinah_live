import 'dart:ui';

import '../../domain/entities/communique.dart';

/// API content language keys to try, in order, for the active app locale.
List<String> contentLocaleKeys(Locale locale) {
  switch (locale.languageCode) {
    case 'fr':
      return const ['fr', 'en', 'pr'];
    case 'en':
      return const ['en', 'fr', 'pr'];
    case 'pt':
      return const ['pr', 'fr', 'en'];
    case 'es':
    case 'zh':
      return const ['en', 'fr', 'pr'];
    default:
      return const ['fr', 'en', 'pr'];
  }
}

String pickLocalizedMap(Map<String, String> map, Locale locale) {
  for (final key in contentLocaleKeys(locale)) {
    final value = map[key]?.trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return '';
}

/// Communiqués are published in French and English only.
List<String> _communiqueLanguageKeys(Locale locale) {
  switch (locale.languageCode) {
    case 'fr':
      return const ['fr', 'en'];
    case 'en':
      return const ['en', 'fr'];
    default:
      return const ['en', 'fr'];
  }
}

Communique pickCommunique(List<Communique> all, Locale locale) {
  if (all.isEmpty) {
    throw StateError('Cannot pick a communique from an empty list.');
  }
  for (final language in _communiqueLanguageKeys(locale)) {
    final match = all.where((item) => item.language == language);
    if (match.isNotEmpty) return match.first;
  }
  return all.first;
}
