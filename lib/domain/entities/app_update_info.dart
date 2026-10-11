class AppUpdateInfo {
  const AppUpdateInfo({
    required this.latestVersion,
    required this.minimumVersion,
    required this.forceUpdate,
    required this.androidStoreUrl,
    this.iosStoreUrl,
    this.releaseNotes,
  });

  final String latestVersion;
  final String minimumVersion;
  final bool forceUpdate;
  final String androidStoreUrl;
  final String? iosStoreUrl;
  final String? releaseNotes;

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      latestVersion: (json['latestVersion'] ?? '').toString().trim(),
      minimumVersion: (json['minimumVersion'] ?? '').toString().trim(),
      forceUpdate: json['forceUpdate'] == true,
      androidStoreUrl: (json['androidStoreUrl'] ?? '').toString().trim(),
      iosStoreUrl: (json['iosStoreUrl'] as String?)?.trim(),
      releaseNotes: (json['releaseNotes'] as String?)?.trim(),
    );
  }
}

class AppUpdatePrompt {
  const AppUpdatePrompt({
    required this.latestVersion,
    required this.required,
    required this.storeUrl,
    this.releaseNotes,
  });

  final String latestVersion;
  final bool required;
  final String storeUrl;
  final String? releaseNotes;
}
