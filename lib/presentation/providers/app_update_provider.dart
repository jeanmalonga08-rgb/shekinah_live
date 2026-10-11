import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/notifications_api_config.dart';
import '../../core/utils/version_utils.dart';
import '../../data/datasources/app_update_remote_datasource.dart';
import '../../data/services/app_update_dismiss_service.dart';
import '../../domain/entities/app_update_info.dart';
import '../pages/profile_page.dart';

final appUpdateRemoteDataSourceProvider = Provider<AppUpdateRemoteDataSource>(
  (ref) => AppUpdateRemoteDataSourceImpl(),
);

/// État null = pas de mise à jour à proposer.
final appUpdatePromptProvider = FutureProvider<AppUpdatePrompt?>((ref) async {
  if (!notificationsApiEnabled) return null;

  final packageInfo = await ref.watch(appPackageInfoProvider.future);
  final remote = await ref.watch(appUpdateRemoteDataSourceProvider).fetchUpdateInfo();
  if (remote == null) return null;

  final version = packageInfo.version.trim();
  final buildNumber = packageInfo.buildNumber.trim();
  final current = buildNumber.isEmpty ? version : '$version+$buildNumber';
  if (current.isEmpty) return null;

  final latest = remote.latestVersion;
  final minimum = remote.minimumVersion.isEmpty ? '0.0.0' : remote.minimumVersion;

  final belowLatest = VersionUtils.isLower(current, latest);
  final belowMinimum = VersionUtils.isLower(current, minimum);
  final required = remote.forceUpdate || belowMinimum;

  if (!belowLatest && !required) return null;

  if (!required) {
    final dismissed = await AppUpdateDismissService.loadDismissedVersion();
    if (dismissed == latest) return null;
  }

  final storeUrl = _storeUrlForPlatform(remote);
  if (storeUrl == null || storeUrl.isEmpty) return null;

  return AppUpdatePrompt(
    latestVersion: latest,
    required: required,
    storeUrl: storeUrl,
    releaseNotes: remote.releaseNotes,
  );
});

String? _storeUrlForPlatform(AppUpdateInfo info) {
  if (kIsWeb) {
    return info.androidStoreUrl.isNotEmpty
        ? info.androidStoreUrl
        : AppConstants.playStoreUrl;
  }
  if (!kIsWeb && Platform.isIOS) {
    final ios = info.iosStoreUrl;
    if (ios != null && ios.isNotEmpty) return ios;
    // Pas de lien App Store configuré — ne pas renvoyer vers le Play Store.
    return null;
  }
  if (info.androidStoreUrl.isNotEmpty) return info.androidStoreUrl;
  return AppConstants.playStoreUrl;
}

final appUpdateDismissProvider =
    Provider<Future<void> Function(String)>((ref) {
  return (version) async {
    await AppUpdateDismissService.dismissVersion(version);
    ref.invalidate(appUpdatePromptProvider);
  };
});
