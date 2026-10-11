import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

bool _initialized = false;

Future<void> ensureLocaleFormatInitialized() async {
  if (_initialized) return;
  for (final locale in ['fr_FR', 'en_US', 'pt_BR', 'es_ES', 'zh_CN']) {
    await initializeDateFormatting(locale);
  }
  _initialized = true;
}

String _intlLocale(Locale locale) {
  return switch (locale.languageCode) {
    'fr' => 'fr_FR',
    'en' => 'en_US',
    'pt' => 'pt_BR',
    'es' => 'es_ES',
    'zh' => 'zh_CN',
    _ => 'fr_FR',
  };
}

String formatShortDate(DateTime date, Locale locale) {
  return DateFormat('d MMM yyyy', _intlLocale(locale)).format(date);
}

String formatLongDate(DateTime date, Locale locale) {
  return DateFormat('EEEE d MMMM yyyy', _intlLocale(locale)).format(date);
}

String formatCeremonyDate(DateTime date, Locale locale) {
  return DateFormat('d MMMM yyyy', _intlLocale(locale)).format(date);
}
