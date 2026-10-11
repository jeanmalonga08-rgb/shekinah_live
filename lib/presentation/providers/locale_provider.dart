import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/l10n/entity_labels.dart';
import '../../l10n/app_localizations.dart';
import 'communique_provider.dart';
import 'predication_provider.dart';

const _localeKey = 'app_locale_v1';

class AppLocaleOption {
  const AppLocaleOption({
    required this.locale,
    required this.flag,
  });

  final Locale locale;
  final String flag;
}

const kAppLocaleOptions = [
  AppLocaleOption(
    locale: Locale('fr', 'FR'),
    flag: '🇫🇷',
  ),
  AppLocaleOption(
    locale: Locale('en', 'US'),
    flag: '🇬🇧',
  ),
  AppLocaleOption(
    locale: Locale('pt'),
    flag: '🇵🇹',
  ),
  AppLocaleOption(
    locale: Locale('es'),
    flag: '🇪🇸',
  ),
  AppLocaleOption(
    locale: Locale('zh'),
    flag: '🇨🇳',
  ),
];

AppLocaleOption localeOptionFor(Locale? locale) {
  final code = locale?.languageCode ?? 'fr';
  return kAppLocaleOptions.firstWhere(
    (o) => o.locale.languageCode == code,
    orElse: () => kAppLocaleOptions.first,
  );
}

String flagForLocale(Locale? locale) => localeOptionFor(locale).flag;

String labelForLocale(AppLocalizations l10n, Locale? locale) {
  return localeOptionLabel(l10n, locale ?? kAppLocaleOptions.first.locale);
}

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref);
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this._ref) : super(null) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localeKey);
    state = _parse(raw) ?? const Locale('fr', 'FR');
  }

  Locale? _parse(String? raw) => switch (raw) {
        'fr' => const Locale('fr', 'FR'),
        'en' => const Locale('en', 'US'),
        'pt' => const Locale('pt'),
        'es' => const Locale('es'),
        'zh' => const Locale('zh'),
        _ => null,
      };

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    final code = switch (locale.languageCode) {
      'fr' => 'fr',
      'en' => 'en',
      'pt' => 'pt',
      'es' => 'es',
      'zh' => 'zh',
      _ => 'fr',
    };
    await prefs.setString(_localeKey, code);

    _ref.invalidate(predicationListProvider);
    _ref.invalidate(recentMonthPredicationsProvider);
    _ref.invalidate(communiqueProvider);
  }
}
