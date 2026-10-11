import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/navigation/app_navigator.dart';
import '../../data/services/offline_storage_service.dart';
import '../../domain/entities/offline_media.dart';
import '../../domain/entities/pending_offline_download.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/offline_playback_helper.dart';
import 'live_playback_provider.dart';
import 'offline_media_provider.dart';
import 'offline_playback_provider.dart';

enum OfflineDownloadJobStatus {
  queued,
  downloading,
  paused,
  success,
  error,
}

class OfflineDownloadJob {
  const OfflineDownloadJob({
    required this.pending,
    this.status = OfflineDownloadJobStatus.queued,
    this.progress,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.bytesPerSecond = 0,
    this.message,
  });

  final PendingOfflineDownload pending;
  final OfflineDownloadJobStatus status;
  final double? progress;
  final int receivedBytes;
  final int totalBytes;
  final int bytesPerSecond;
  final String? message;

  String get id => pending.downloadId;
  String get title => pending.title;
  OfflineMediaFormat get format => pending.format;

  /// Taille connue (Content-Length, ou estimation qualité).
  int get knownTotalBytes {
    if (totalBytes > 0) return totalBytes;
    return pending.expectedSizeBytes ?? 0;
  }

  bool get isQueued => status == OfflineDownloadJobStatus.queued;
  bool get isDownloading => status == OfflineDownloadJobStatus.downloading;
  bool get isPaused => status == OfflineDownloadJobStatus.paused;
  bool get isActive => isQueued || isDownloading || isPaused;
  bool get isError => status == OfflineDownloadJobStatus.error;
  bool get isSuccess => status == OfflineDownloadJobStatus.success;

  bool get canResume =>
      (isPaused || isError) &&
      ((pending.url != null && pending.url!.isNotEmpty) ||
          (pending.kind == OfflineDownloadKind.youtube &&
              pending.videoId != null));

  bool get canRetry => canResume;
  bool get canPause => isDownloading;

  bool matches({
    required OfflineMediaCategory category,
    required String sourceId,
    required OfflineMediaFormat format,
  }) =>
      pending.matches(
        category: category,
        sourceId: sourceId,
        format: format,
      );

  String statusLabel(AppLocalizations l10n) {
    switch (status) {
      case OfflineDownloadJobStatus.queued:
        return l10n.downloadQueued;
      case OfflineDownloadJobStatus.downloading:
        final value = progress;
        if (value != null && value > 0) {
          return l10n.downloadProgress((value * 100).round());
        }
        return l10n.downloadProgressActive;
      case OfflineDownloadJobStatus.paused:
        return l10n.downloadPaused;
      case OfflineDownloadJobStatus.success:
        return message ?? l10n.downloadAvailableOffline;
      case OfflineDownloadJobStatus.error:
        if (message == 'unavailable') return l10n.downloadVideoUnavailable;
        return message ?? l10n.downloadFailed;
    }
  }

  OfflineDownloadJob copyWith({
    PendingOfflineDownload? pending,
    OfflineDownloadJobStatus? status,
    double? progress,
    int? receivedBytes,
    int? totalBytes,
    int? bytesPerSecond,
    String? message,
    bool clearProgress = false,
    bool clearMessage = false,
  }) {
    return OfflineDownloadJob(
      pending: pending ?? this.pending,
      status: status ?? this.status,
      progress: clearProgress ? null : (progress ?? this.progress),
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      bytesPerSecond: bytesPerSecond ?? this.bytesPerSecond,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  Map<String, dynamic> toJson() => {
        'pending': pending.toJson(),
        'status': status.name,
        'progress': progress,
        'receivedBytes': receivedBytes,
        'totalBytes': totalBytes,
        'message': message,
      };

  factory OfflineDownloadJob.fromJson(Map<String, dynamic> json) {
    final statusName = json['status'] as String? ?? 'queued';
    var status = OfflineDownloadJobStatus.values.byName(statusName);
    if (status == OfflineDownloadJobStatus.downloading ||
        status == OfflineDownloadJobStatus.queued) {
      // Après redémarrage : reprise manuelle (état pause).
      status = OfflineDownloadJobStatus.paused;
    }
    return OfflineDownloadJob(
      pending: PendingOfflineDownload.fromJson(
        Map<String, dynamic>.from(json['pending'] as Map),
      ),
      status: status,
      progress: (json['progress'] as num?)?.toDouble(),
      receivedBytes: json['receivedBytes'] as int? ?? 0,
      totalBytes: json['totalBytes'] as int? ?? 0,
      message: json['message'] as String?,
    );
  }
}

class OfflineDownloadManagerState {
  const OfflineDownloadManagerState({this.jobs = const []});

  final List<OfflineDownloadJob> jobs;

  bool get isVisible => jobs.isNotEmpty;
  int get activeCount => jobs.where((j) => j.isActive).length;
  int get downloadingCount => jobs.where((j) => j.isDownloading).length;
  int get pausedCount => jobs.where((j) => j.isPaused).length;
  int get errorCount => jobs.where((j) => j.isError).length;
  bool get hasActive => activeCount > 0;
  bool get isDownloading => downloadingCount > 0;

  OfflineDownloadJob? get primaryFocus {
    for (final job in jobs) {
      if (job.isDownloading) return job;
    }
    for (final job in jobs) {
      if (job.isPaused) return job;
    }
    return null;
  }

  OfflineDownloadJob? byId(String id) {
    for (final job in jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  OfflineDownloadJob? jobFor({
    required OfflineMediaCategory category,
    required String sourceId,
    required OfflineMediaFormat format,
  }) {
    for (final job in jobs) {
      if (job.matches(
        category: category,
        sourceId: sourceId,
        format: format,
      )) {
        return job;
      }
    }
    return null;
  }

  bool matchesActive({
    required OfflineMediaCategory category,
    required String sourceId,
    required OfflineMediaFormat format,
  }) {
    return jobFor(
          category: category,
          sourceId: sourceId,
          format: format,
        )?.isActive ??
        false;
  }

  bool matchesError({
    required OfflineMediaCategory category,
    required String sourceId,
    required OfflineMediaFormat format,
  }) {
    return jobFor(
          category: category,
          sourceId: sourceId,
          format: format,
        )?.isError ??
        false;
  }
}

final offlineDownloadManagerProvider = NotifierProvider<
    OfflineDownloadManagerNotifier, OfflineDownloadManagerState>(
  OfflineDownloadManagerNotifier.new,
);

/// Alias historique — pointe vers le gestionnaire multi-téléchargements.
final offlineDownloadProgressProvider = offlineDownloadManagerProvider;

class _SpeedTracker {
  DateTime? lastAt;
  int lastBytes = 0;
  double smoothedBps = 0;
}

class OfflineDownloadManagerNotifier
    extends Notifier<OfflineDownloadManagerState> {
  static const _persistKey = 'offline_download_queue_v1';
  static const maxConcurrent = 2;

  final Map<String, CancelToken> _cancelTokens = {};
  final Set<String> _runningIds = {};
  final Set<String> _pauseRequested = {};
  final Map<String, _SpeedTracker> _speedTrackers = {};
  bool _hydrated = false;

  @override
  OfflineDownloadManagerState build() {
    Future.microtask(_hydrate);
    return const OfflineDownloadManagerState();
  }

  Future<void> _hydrate() async {
    if (_hydrated) return;
    _hydrated = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_persistKey);
      if (raw == null || raw.isEmpty) return;
      final list = jsonDecode(raw) as List<dynamic>;
      final jobs = list
          .whereType<Map>()
          .map((e) => OfflineDownloadJob.fromJson(Map<String, dynamic>.from(e)))
          .where((j) => j.isError || j.isPaused)
          .toList();
      if (jobs.isEmpty) return;
      state = OfflineDownloadManagerState(jobs: jobs);
    } catch (e, st) {
      debugPrint('Download queue hydrate failed: $e\n$st');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final toSave = state.jobs
          .where((j) => j.isActive || j.isPaused || j.isError)
          .map((j) => j.toJson())
          .toList();
      if (toSave.isEmpty) {
        await prefs.remove(_persistKey);
      } else {
        await prefs.setString(_persistKey, jsonEncode(toSave));
      }
    } catch (e, st) {
      debugPrint('Download queue persist failed: $e\n$st');
    }
  }

  void _setJobs(List<OfflineDownloadJob> jobs, {bool persist = true}) {
    state = OfflineDownloadManagerState(jobs: List.unmodifiable(jobs));
    if (persist) unawaited(_persist());
  }

  void _updateJob(
    String id,
    OfflineDownloadJob Function(OfflineDownloadJob) fn, {
    bool persist = true,
  }) {
    _setJobs(
      state.jobs.map((j) => j.id == id ? fn(j) : j).toList(),
      persist: persist,
    );
  }

  OfflineDownloadJob? activeFor({
    required OfflineMediaCategory category,
    required String sourceId,
    required OfflineMediaFormat format,
  }) {
    final job = state.jobFor(
      category: category,
      sourceId: sourceId,
      format: format,
    );
    if (job == null || !job.isActive) return null;
    return job;
  }

  /// Ajoute un téléchargement à la file. Retourne false si déjà sauvé / actif.
  Future<EnqueueResult> enqueue(
    PendingOfflineDownload pending, {
    bool resumeExisting = false,
  }) async {
    final id = pending.downloadId;
    final existing = state.byId(id);

    if (existing != null && existing.isActive) {
      if (existing.isPaused && resumeExisting) {
        resume(id);
        return EnqueueResult.resumed;
      }
      return EnqueueResult.alreadyActive;
    }

    if (existing != null && existing.isError && resumeExisting) {
      resume(id);
      return EnqueueResult.resumed;
    }

    final service = ref.read(offlineStorageServiceProvider);
    final already = await service.exists(
      category: pending.category,
      sourceId: pending.sourceId,
      format: pending.format,
    );
    if (already) return EnqueueResult.alreadySaved;

    if (existing != null) {
      _setJobs(state.jobs.where((j) => j.id != id).toList());
    }

    final job = OfflineDownloadJob(
      pending: pending,
      status: OfflineDownloadJobStatus.queued,
      receivedBytes: existing?.receivedBytes ?? 0,
      totalBytes: existing?.totalBytes ?? 0,
      progress: existing?.progress,
    );
    _setJobs([job, ...state.jobs.where((j) => j.id != id)]);
    unawaited(_pump());
    return EnqueueResult.queued;
  }

  void resume(String id) {
    final job = state.byId(id);
    if (job == null) return;
    if (job.isQueued || job.isDownloading) return;
    if (!job.isPaused && !job.isError) return;
    _updateJob(
      id,
      (j) => j.copyWith(
        status: OfflineDownloadJobStatus.queued,
        bytesPerSecond: 0,
        clearMessage: true,
      ),
    );
    unawaited(_pump());
  }

  void resumeAllFailed() {
    var changed = false;
    final next = state.jobs.map((j) {
      if (!j.isError && !j.isPaused) return j;
      changed = true;
      return j.copyWith(
        status: OfflineDownloadJobStatus.queued,
        bytesPerSecond: 0,
        clearMessage: true,
      );
    }).toList();
    if (!changed) return;
    _setJobs(next);
    unawaited(_pump());
  }

  /// Met en pause un téléchargement en cours (conserve le fichier partiel).
  void pause(String id) {
    final job = state.byId(id);
    if (job == null || !job.isDownloading) return;
    _pauseRequested.add(id);
    _cancelTokens[id]?.cancel('paused');
  }

  /// Pause tous les téléchargements en cours.
  void pauseAll() {
    for (final job in state.jobs) {
      if (job.isDownloading) pause(job.id);
    }
  }

  Future<void> cancel(String id) async {
    _pauseRequested.remove(id);
    _speedTrackers.remove(id);
    _cancelTokens.remove(id)?.cancel('cancelled');
    _runningIds.remove(id);
    final job = state.byId(id);
    _setJobs(state.jobs.where((j) => j.id != id).toList());
    if (job != null) {
      try {
        await ref.read(offlineStorageServiceProvider).deletePartial(
              category: job.pending.category,
              sourceId: job.pending.sourceId,
              format: job.pending.format,
              url: job.pending.url,
            );
      } catch (_) {}
    }
    unawaited(_pump());
  }

  void dismiss(String id) {
    final job = state.byId(id);
    if (job != null && job.isDownloading) return;
    _pauseRequested.remove(id);
    _speedTrackers.remove(id);
    _cancelTokens.remove(id)?.cancel('dismissed');
    _runningIds.remove(id);
    _setJobs(state.jobs.where((j) => j.id != id).toList());
  }

  void dismissFinished() {
    _setJobs(state.jobs.where((j) => !j.isSuccess).toList());
  }

  void clear() {
    for (final token in _cancelTokens.values) {
      token.cancel('cleared');
    }
    _cancelTokens.clear();
    _runningIds.clear();
    _pauseRequested.clear();
    _speedTrackers.clear();
    _setJobs(const []);
  }

  Future<void> _pump() async {
    while (_runningIds.length < maxConcurrent) {
      OfflineDownloadJob? next;
      for (final job in state.jobs) {
        if (job.isQueued && !_runningIds.contains(job.id)) {
          next = job;
          break;
        }
      }
      if (next == null) break;
      _runningIds.add(next.id);
      unawaited(_execute(next));
    }
  }

  bool _markPausedIfRequested(String id) {
    if (!_pauseRequested.remove(id)) return false;
    _speedTrackers.remove(id);
    final job = state.byId(id);
    if (job == null) return true;
    _updateJob(
      id,
      (j) => j.copyWith(
        status: OfflineDownloadJobStatus.paused,
        bytesPerSecond: 0,
      ),
    );
    return true;
  }

  Future<void> _execute(OfflineDownloadJob job) async {
    final id = job.id;
    final token = CancelToken();
    _cancelTokens[id] = token;
    _speedTrackers[id] = _SpeedTracker()..lastBytes = job.receivedBytes;

    _updateJob(
      id,
      (j) => j.copyWith(
        status: OfflineDownloadJobStatus.downloading,
        bytesPerSecond: 0,
        clearMessage: true,
      ),
    );

    try {
      final pending = job.pending;
      final mediaNotifier = ref.read(offlineMediaProvider.notifier);
      late final OfflineMediaItem saved;

      if (pending.kind == OfflineDownloadKind.youtube &&
          pending.videoId != null) {
        if (pending.format == OfflineMediaFormat.audio) {
          saved = await mediaNotifier.downloadYoutubeAudio(
            category: pending.category,
            sourceId: pending.sourceId,
            videoId: pending.videoId!,
            title: pending.title,
            subtitle: pending.subtitle,
            thumbnailUrl: pending.thumbnailUrl,
            resume: true,
            cancelToken: token,
            onProgress: (received, total) {
              _onProgress(id, received, total, pending.expectedSizeBytes);
            },
          );
        } else {
          saved = await mediaNotifier.downloadYoutubeVideo(
            category: pending.category,
            sourceId: pending.sourceId,
            videoId: pending.videoId!,
            title: pending.title,
            subtitle: pending.subtitle,
            thumbnailUrl: pending.thumbnailUrl,
            resume: true,
            cancelToken: token,
            onProgress: (received, total) {
              _onProgress(id, received, total, pending.expectedSizeBytes);
            },
          );
        }
      } else {
        final url = pending.url;
        if (url == null || url.isEmpty) {
          throw StateError('Missing download URL');
        }
        saved = await mediaNotifier.download(
          category: pending.category,
          format: pending.format,
          sourceId: pending.sourceId,
          title: pending.title,
          subtitle: pending.subtitle,
          url: url,
          thumbnailUrl: pending.thumbnailUrl,
          durationSeconds: pending.durationSeconds,
          expectedSizeBytes: pending.expectedSizeBytes,
          resume: true,
          cancelToken: token,
          onProgress: (received, total) {
            _onProgress(id, received, total, pending.expectedSizeBytes);
          },
          extraHeaders: pending.extraHeaders,
          fileExtension: pending.fileExtension,
        );
      }

      if (token.isCancelled) {
        _markPausedIfRequested(id);
        return;
      }

      _pauseRequested.remove(id);
      _speedTrackers.remove(id);
      _updateJob(
        id,
        (j) => j.copyWith(
          status: OfflineDownloadJobStatus.success,
          progress: 1,
          bytesPerSecond: 0,
          clearMessage: true,
        ),
      );
      _playDownloadedIfMedia(saved);
      Future<void>.delayed(const Duration(seconds: 4), () {
        if (state.byId(id)?.isSuccess == true) dismiss(id);
      });
    } on OfflineVideoUnavailableException {
      if (_markPausedIfRequested(id)) return;
      if (!token.isCancelled) {
        _speedTrackers.remove(id);
        _updateJob(
          id,
          (j) => j.copyWith(
            status: OfflineDownloadJobStatus.error,
            bytesPerSecond: 0,
            message: 'unavailable',
          ),
        );
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || token.isCancelled) {
        _markPausedIfRequested(id);
        return;
      }
      debugPrint('Download Dio error $id: $e');
      _speedTrackers.remove(id);
      _updateJob(
        id,
        (j) => j.copyWith(
          status: OfflineDownloadJobStatus.error,
          bytesPerSecond: 0,
        ),
      );
    } catch (e, st) {
      debugPrint('Download failed $id: $e\n$st');
      if (_markPausedIfRequested(id)) return;
      if (!token.isCancelled) {
        _speedTrackers.remove(id);
        _updateJob(
          id,
          (j) => j.copyWith(
            status: OfflineDownloadJobStatus.error,
            bytesPerSecond: 0,
          ),
        );
      }
    } finally {
      _cancelTokens.remove(id);
      _runningIds.remove(id);
      final still = state.byId(id);
      if (still != null && still.isDownloading) {
        _markPausedIfRequested(id);
      } else {
        _pauseRequested.remove(id);
      }
      unawaited(_pump());
    }
  }

  void _onProgress(
    String id,
    int received,
    int total,
    int? expectedSizeBytes,
  ) {
    final job = state.byId(id);
    if (job == null || !job.isDownloading) return;

    final effectiveTotal = total > 0
        ? total
        : (expectedSizeBytes ?? (job.totalBytes > 0 ? job.totalBytes : 0));
    final progress = effectiveTotal > 0
        ? (received / effectiveTotal).clamp(0.0, 0.99)
        : null;

    final now = DateTime.now();
    final tracker = _speedTrackers.putIfAbsent(id, _SpeedTracker.new);
    var bps = job.bytesPerSecond;
    final lastAt = tracker.lastAt;
    if (lastAt != null) {
      final elapsedMs = now.difference(lastAt).inMilliseconds;
      if (elapsedMs >= 250) {
        final delta = received - tracker.lastBytes;
        if (delta >= 0) {
          final instant = delta * 1000 / elapsedMs;
          tracker.smoothedBps = tracker.smoothedBps <= 0
              ? instant
              : tracker.smoothedBps * 0.7 + instant * 0.3;
          bps = tracker.smoothedBps.round();
        }
        tracker.lastAt = now;
        tracker.lastBytes = received;
      }
    } else {
      tracker.lastAt = now;
      tracker.lastBytes = received;
    }

    _updateJob(
      id,
      (j) => j.copyWith(
        receivedBytes: received,
        totalBytes: effectiveTotal > 0 ? effectiveTotal : j.totalBytes,
        progress: progress,
        bytesPerSecond: bps,
      ),
      persist: false,
    );
  }

  /// Lance la lecture hors ligne dès qu'un audio/vidéo est prêt (pas les PDF).
  /// Ne coupe jamais une lecture déjà en cours (hors ligne ou direct).
  void _playDownloadedIfMedia(OfflineMediaItem item) {
    if (item.format == OfflineMediaFormat.pdf) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offline = ref.read(offlinePlaybackProvider);
      if (offline.isActive) return;

      final live = ref.read(livePlaybackProvider);
      if (live.isPlaying || live.isFloating) return;

      final ctx = appNavigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      final all = ref.read(offlineMediaProvider).valueOrNull ?? const [];
      final queue = all
          .where(
            (e) => e.category == item.category && e.format == item.format,
          )
          .toList();
      openOfflinePlayer(
        ctx,
        item,
        playlist: queue.isEmpty ? [item] : queue,
      );
    });
  }
}

enum EnqueueResult { queued, resumed, alreadyActive, alreadySaved }
