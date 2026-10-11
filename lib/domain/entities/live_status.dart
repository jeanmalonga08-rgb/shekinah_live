enum LiveStatus {
  live,
  offline,
  loading,
  error,
}

enum LiveLang {
  fr,
  en,
  pr,
}

extension LiveLangX on LiveLang {
  String get code {
    switch (this) {
      case LiveLang.fr:
        return 'fr';
      case LiveLang.en:
        return 'en';
      case LiveLang.pr:
        return 'pr';
    }
  }

  String get label {
    switch (this) {
      case LiveLang.fr:
        return 'Français';
      case LiveLang.en:
        return 'English';
      case LiveLang.pr:
        return 'Português';
    }
  }

  String get shortLabel {
    switch (this) {
      case LiveLang.fr:
        return 'FR';
      case LiveLang.en:
        return 'EN';
      case LiveLang.pr:
        return 'PR';
    }
  }
}

class LiveStreamEntity {
  final LiveStatus status;
  final String? title;
  final String? message;
  final Map<LiveLang, String> videoIds;
  final Map<LiveLang, String> audioLinks;
  final DateTime? lastChecked;
  final DateTime? liveStartedAt;

  const LiveStreamEntity({
    required this.status,
    this.title,
    this.message,
    this.videoIds = const {},
    this.audioLinks = const {},
    this.lastChecked,
    this.liveStartedAt,
  });

  bool get isLive => status == LiveStatus.live;

  bool get hasAnyVideo => videoIds.isNotEmpty;

  bool get hasAnyAudio => audioLinks.isNotEmpty;

  List<LiveLang> get availableVideoLangs => LiveLang.values
      .where((lang) => videoIds.containsKey(lang))
      .toList(growable: false);

  List<LiveLang> get availableAudioLangs => LiveLang.values
      .where((lang) => audioLinks.containsKey(lang))
      .toList(growable: false);

  LiveLang get preferredVideoLang {
    if (videoIds.containsKey(LiveLang.fr)) return LiveLang.fr;
    if (videoIds.containsKey(LiveLang.en)) return LiveLang.en;
    if (videoIds.containsKey(LiveLang.pr)) return LiveLang.pr;
    return LiveLang.fr;
  }

  LiveLang get preferredAudioLang {
    if (audioLinks.containsKey(LiveLang.fr)) return LiveLang.fr;
    if (audioLinks.containsKey(LiveLang.en)) return LiveLang.en;
    if (audioLinks.containsKey(LiveLang.pr)) return LiveLang.pr;
    return LiveLang.fr;
  }

  String? videoIdFor(LiveLang lang) => videoIds[lang];

  String? audioLinkFor(LiveLang lang) => audioLinks[lang];

  /// Lien réel du player Vimeo Event (pas le site shekinahgospel.org).
  String? embedUrlFor(LiveLang lang) {
    final id = videoIdFor(lang);
    if (id == null || id.isEmpty) return null;
    final trimmed = id.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://vimeo.com/event/$trimmed/embed';
  }

  /// Compare la config streaming (IDs / liens / statut) pour détecter un changement.
  bool hasSameStreamingConfig(LiveStreamEntity other) {
    bool sameMap(Map<LiveLang, String> a, Map<LiveLang, String> b) {
      if (a.length != b.length) return false;
      for (final entry in a.entries) {
        if (b[entry.key] != entry.value) return false;
      }
      return true;
    }

    return status == other.status &&
        sameMap(videoIds, other.videoIds) &&
        sameMap(audioLinks, other.audioLinks);
  }

  LiveStreamEntity copyWith({
    LiveStatus? status,
    String? title,
    String? message,
    Map<LiveLang, String>? videoIds,
    Map<LiveLang, String>? audioLinks,
    DateTime? lastChecked,
    DateTime? liveStartedAt,
  }) {
    return LiveStreamEntity(
      status: status ?? this.status,
      title: title ?? this.title,
      message: message ?? this.message,
      videoIds: videoIds ?? this.videoIds,
      audioLinks: audioLinks ?? this.audioLinks,
      lastChecked: lastChecked ?? this.lastChecked,
      liveStartedAt: liveStartedAt ?? this.liveStartedAt,
    );
  }
}
