import 'package:flutter/material.dart';

import '../../domain/entities/cantique.dart';
import '../../domain/entities/live_status.dart';
import '../../domain/entities/multimedia_video.dart';
import '../../domain/entities/offline_media.dart';
import '../../domain/entities/predication.dart';
import '../../l10n/app_localizations.dart';

String predicationTypeLabel(AppLocalizations l10n, String type) {
  switch (type) {
    case 'PARENTMEETING':
      return l10n.predicationTypeParentMeeting;
    case 'SUNDAYSCHOOL':
      return l10n.predicationTypeSundaySchool;
    case 'PRAYERMEETING':
      return l10n.predicationTypePrayerMeeting;
    case 'SPECIALMEETING':
      return l10n.predicationTypeSpecialMeeting;
    case 'YOUNTHMEETING':
      return l10n.predicationTypeYouthMeeting;
    default:
      return l10n.predicationTypeRegular;
  }
}

String predicationTimeLabel(AppLocalizations l10n, String timeType) {
  switch (timeType) {
    case 'PM':
      return l10n.predicationTimeEvening;
    case 'PMAM':
      return l10n.predicationTimeVigil;
    default:
      return l10n.predicationTimeMorning;
  }
}

String offlineCategoryLabel(
  AppLocalizations l10n,
  OfflineMediaCategory category,
) {
  switch (category) {
    case OfflineMediaCategory.predication:
      return l10n.offlineCategoryPredication;
    case OfflineMediaCategory.cantique:
      return l10n.offlineCategoryCantique;
    case OfflineMediaCategory.ceremony:
      return l10n.offlineCategoryCeremony;
    case OfflineMediaCategory.documentaire:
      return 'Documentaire / Scénette';
    case OfflineMediaCategory.recueilCantique:
      return 'Recueil de chants';
    case OfflineMediaCategory.libraryPepite:
      return l10n.offlineCategoryLibraryPepite;
    case OfflineMediaCategory.libraryPublication:
      return l10n.offlineCategoryLibraryPublication;
  }
}

String offlineFormatLabel(AppLocalizations l10n, OfflineMediaFormat format) {
  switch (format) {
    case OfflineMediaFormat.audio:
      return l10n.audio;
    case OfflineMediaFormat.video:
      return l10n.video;
    case OfflineMediaFormat.pdf:
      return l10n.pdf;
  }
}

bool isLibraryOfflineCategory(OfflineMediaCategory category) {
  return category == OfflineMediaCategory.recueilCantique ||
      category == OfflineMediaCategory.libraryPepite ||
      category == OfflineMediaCategory.libraryPublication;
}

String offlineSizeLabel(AppLocalizations l10n, int fileSizeBytes) {
  if (fileSizeBytes <= 0) return '';
  if (fileSizeBytes < 1024 * 1024) {
    return l10n.sizeKilobytes((fileSizeBytes / 1024).round());
  }
  return l10n.sizeMegabytes((fileSizeBytes / (1024 * 1024)).toStringAsFixed(1));
}

/// Progression de taille : `12,3 Mo / 45,0 Mo` ou taille seule.
String offlineDownloadSizeProgressLabel(
  AppLocalizations l10n, {
  required int receivedBytes,
  required int totalBytes,
}) {
  final received = offlineSizeLabel(l10n, receivedBytes);
  final total = offlineSizeLabel(l10n, totalBytes);
  if (received.isEmpty && total.isEmpty) return '';
  if (total.isEmpty) return received;
  if (received.isEmpty) return total;
  return '$received / $total';
}

/// Vitesse formatée : `1,2 Mo/s`.
String offlineDownloadSpeedLabel(AppLocalizations l10n, int bytesPerSecond) {
  if (bytesPerSecond <= 0) return '';
  final size = offlineSizeLabel(l10n, bytesPerSecond);
  if (size.isEmpty) return '';
  return l10n.downloadSpeedPerSec(size);
}

String mediaDurationLabel(int durationSeconds) {
  if (durationSeconds <= 0) return '';
  final hours = durationSeconds ~/ 3600;
  final minutes = (durationSeconds % 3600) ~/ 60;
  final seconds = durationSeconds % 60;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String offlineMediaMetaLine(
  AppLocalizations l10n,
  OfflineMediaItem item,
) {
  final parts = <String>[
    if (item.subtitle.trim().isNotEmpty)
      item.subtitle.trim()
    else
      offlineCategoryLabel(l10n, item.category),
    offlineFormatLabel(l10n, item.format),
    if (item.durationSeconds != null && item.durationSeconds! > 0)
      mediaDurationLabel(item.durationSeconds!),
    if (item.fileSizeBytes > 0) offlineSizeLabel(l10n, item.fileSizeBytes),
  ];
  return parts.where((e) => e.isNotEmpty).join(' · ');
}

/// Sous-titre affiché sous le titre (prédicateur, catégorie de cantique, etc.).
String offlineItemSubtitle(AppLocalizations l10n, OfflineMediaItem item) {
  final raw = item.subtitle.trim();
  if (raw.isEmpty) {
    return offlineCategoryLabel(l10n, item.category);
  }
  if (item.category == OfflineMediaCategory.cantique) {
    return cantiqueCategoryLabel(l10n, raw);
  }
  return raw;
}

/// Ligne grise : format, durée, taille (sans répéter le sous-titre).
String offlineMediaDetailsLine(
  AppLocalizations l10n,
  OfflineMediaItem item,
) {
  final parts = <String>[
    offlineFormatLabel(l10n, item.format),
    if (item.durationSeconds != null && item.durationSeconds! > 0)
      mediaDurationLabel(item.durationSeconds!),
    if (item.fileSizeBytes > 0) offlineSizeLabel(l10n, item.fileSizeBytes),
  ];
  return parts.where((e) => e.isNotEmpty).join(' · ');
}

List<({String day, String time})> worshipScheduleEntries(
  AppLocalizations l10n,
) {
  return [
    (day: l10n.worshipSunday, time: l10n.worshipTimeSunday),
    (day: l10n.worshipWednesday, time: l10n.worshipTimeEvening),
    (day: l10n.worshipThursday, time: l10n.worshipTimeEvening),
  ];
}

List<String> assemblyAddressLines(AppLocalizations l10n) {
  return [
    l10n.assemblyAddressLine1,
    l10n.assemblyAddressLine2,
    l10n.assemblyAddressLine3,
  ];
}

String playSubtitle({
  required AppLocalizations l10n,
  required bool hasMedia,
  required bool hasOffline,
  required String onlineLabel,
}) {
  if (!hasMedia) return l10n.unavailable;
  if (hasOffline) return l10n.playOfflineReady;
  return onlineLabel;
}

String downloadSubtitle({
  required AppLocalizations l10n,
  required bool hasMedia,
  required bool hasOffline,
}) {
  if (!hasMedia) return l10n.unavailable;
  if (hasOffline) return l10n.downloadAvailableOffline;
  return l10n.downloadInApp;
}

String predicationDisplayTitle(AppLocalizations l10n, Predication predication) {
  final trimmed = predication.title.trim();
  if (trimmed.isEmpty) return l10n.predicationUntitled;
  return trimmed;
}

String cantiqueDisplayTitle(AppLocalizations l10n, Cantique cantique) {
  final trimmed = cantique.title.trim();
  if (trimmed.isEmpty) return l10n.cantiqueUntitled;
  return trimmed;
}

String cantiqueMediaLabel(AppLocalizations l10n, Cantique cantique) {
  if (cantique.hasVideo && cantique.hasAudio) {
    return l10n.cantiqueMediaAudioVideo;
  }
  if (cantique.hasVideo) return l10n.cantiqueMediaVideo;
  if (cantique.hasAudio) return l10n.cantiqueMediaAudio;
  return l10n.cantiqueMediaGeneric;
}

String cantiqueCategoryLabel(AppLocalizations l10n, String category) {
  switch (category) {
    case 'Chants Bouclier De David':
      return l10n.cantiqueCategoryShieldOfDavid;
    case "Chants d'ensemble":
      return l10n.cantiqueCategoryEnsemble;
    case 'Chants individuels':
      return l10n.cantiqueCategoryIndividual;
    case 'Instrumentale':
      return l10n.cantiqueCategoryInstrumental;
    default:
      return category;
  }
}

String multimediaVideoCategoryLabel(
  AppLocalizations l10n,
  MultimediaVideoCategory category,
) {
  switch (category) {
    case MultimediaVideoCategory.documentaire:
      return 'Documentaire';
    case MultimediaVideoCategory.scenette:
      return 'Scénette';
    case MultimediaVideoCategory.divers:
      return 'Divers';
  }
}

String libraryCategoryLabel(AppLocalizations l10n, String category) {
  switch (category) {
    case 'Divers':
      return l10n.libraryCategoryDivers;
    case 'Foi et Doctrine':
      return l10n.libraryCategoryFaithDoctrine;
    case 'La Famille':
      return l10n.libraryCategoryFamily;
    case 'La Femme':
      return l10n.libraryCategoryWoman;
    case 'Le Mariage':
      return l10n.libraryCategoryMarriage;
    case 'Spécial':
      return l10n.libraryCategorySpecial;
    default:
      return category;
  }
}

String liveLangLabel(AppLocalizations l10n, LiveLang lang) {
  switch (lang) {
    case LiveLang.fr:
      return l10n.langFrench;
    case LiveLang.en:
      return l10n.langEnglish;
    case LiveLang.pr:
      return l10n.langPortuguese;
  }
}

String localeOptionLabel(AppLocalizations l10n, Locale locale) {
  switch (locale.languageCode) {
    case 'fr':
      return l10n.langFrench;
    case 'en':
      return l10n.langEnglish;
    case 'pt':
      return l10n.langPortuguese;
    case 'es':
      return l10n.langSpanish;
    case 'zh':
      return l10n.langChinese;
    default:
      return l10n.langFrench;
  }
}
