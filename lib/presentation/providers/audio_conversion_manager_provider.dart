import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/notifications_auth_interceptor.dart';
import '../../data/services/audio_conversion_api_service.dart';
import '../../data/services/fcm_token_cache.dart';
import '../../data/services/installation_id_service.dart';
import '../../domain/entities/audio_conversion_job.dart';
import '../../domain/entities/offline_media.dart';
import '../../domain/entities/pending_offline_download.dart';
import '../../l10n/app_localizations.dart';
import 'audio_conversion_provider.dart';
import 'offline_download_progress_provider.dart';

enum AudioConversionUiStatus {
  starting,
  processing,
  failed,
  cancelled,
}

class PendingAudioConversion {
  const PendingAudioConversion({
    required this.mediaId,
    required this.provider,
    required this.videoId,
    required this.profile,
    required this.title,
    required this.subtitle,
    required this.category,
    this.thumbnailUrl,
    this.youtubeFallbackOnUnsupported = false,
  });

  final String mediaId;
  final String provider;
  final String videoId;
  final AudioConversionProfile profile;
  final String title;
  final String subtitle;
  final OfflineMediaCategory category;
  final String? thumbnailUrl;
  final bool youtubeFallbackOnUnsupported;
}

class AudioConversionUiJob {
  const AudioConversionUiJob({
    required this.id,
    required this.pending,
    this.serverJobId,
    this.status = AudioConversionUiStatus.starting,
    this.progress = 0,
    this.errorCode,
    this.message,
  });

  final String id;
  final PendingAudioConversion pending;
  final String? serverJobId;
  final AudioConversionUiStatus status;
  final int progress;
  final String? errorCode;
  final String? message;

  String get title => pending.title;

  bool get isActive =>
      status == AudioConversionUiStatus.starting ||
      status == AudioConversionUiStatus.processing;

  bool get isFailed => status == AudioConversionUiStatus.failed;

  bool get canCancel => isActive;

  bool get canDismiss => !isActive;

  String statusLabel(AppLocalizations l10n) {
    switch (status) {
      case AudioConversionUiStatus.starting:
        return l10n.audioConversionStarting;
      case AudioConversionUiStatus.processing:
        return l10n.audioConversionProgressPercent(progress.clamp(0, 100));
      case AudioConversionUiStatus.failed:
        return message ?? l10n.audioConversionFailed;
      case AudioConversionUiStatus.cancelled:
        return l10n.cancel;
    }
  }

  AudioConversionUiJob copyWith({
    String? serverJobId,
    AudioConversionUiStatus? status,
    int? progress,
    String? errorCode,
    String? message,
    bool clearServerJobId = false,
    bool clearError = false,
  }) {
    return AudioConversionUiJob(
      id: id,
      pending: pending,
      serverJobId: clearServerJobId ? null : (serverJobId ?? this.serverJobId),
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      message: clearError ? null : (message ?? this.message),
    );
  }
}

class AudioConversionManagerState {
  const AudioConversionManagerState({this.jobs = const []});

  final List<AudioConversionUiJob> jobs;

  bool get isVisible => jobs.isNotEmpty;
  int get activeCount => jobs.where((j) => j.isActive).length;
  int get errorCount => jobs.where((j) => j.isFailed).length;
  bool get hasActive => activeCount > 0;

  AudioConversionUiJob? get primaryFocus {
    for (final job in jobs) {
      if (job.isActive) return job;
    }
    for (final job in jobs) {
      if (job.isFailed) return job;
    }
    return null;
  }

  AudioConversionUiJob? byId(String id) {
    for (final job in jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  AudioConversionUiJob? activeForMedia(String mediaId) {
    for (final job in jobs) {
      if (job.pending.mediaId == mediaId && job.isActive) return job;
    }
    return null;
  }
}

enum AudioConversionEnqueueResult {
  queued,
  alreadyActive,
}

final audioConversionManagerProvider = NotifierProvider<
    AudioConversionManagerNotifier, AudioConversionManagerState>(
  AudioConversionManagerNotifier.new,
);

class AudioConversionManagerNotifier
    extends Notifier<AudioConversionManagerState> {
  static const _uuid = Uuid();

  final Map<String, CancelToken> _cancelTokens = {};
  final Set<String> _runningIds = {};

  @override
  AudioConversionManagerState build() {
    ref.onDispose(() {
      for (final token in _cancelTokens.values) {
        if (!token.isCancelled) token.cancel('disposed');
      }
      _cancelTokens.clear();
      _runningIds.clear();
    });
    return const AudioConversionManagerState();
  }

  Future<AudioConversionEnqueueResult> enqueue(
    PendingAudioConversion pending,
  ) async {
    final existing = state.activeForMedia(pending.mediaId);
    if (existing != null) {
      return AudioConversionEnqueueResult.alreadyActive;
    }

    final id = _uuid.v4();
    final job = AudioConversionUiJob(id: id, pending: pending);
    state = AudioConversionManagerState(jobs: [...state.jobs, job]);
    unawaited(_run(id));
    return AudioConversionEnqueueResult.queued;
  }

  Future<void> cancel(String id) async {
    final job = state.byId(id);
    if (job == null) return;

    final token = _cancelTokens[id];
    if (token != null && !token.isCancelled) {
      token.cancel('user');
    }

    final serverId = job.serverJobId;
    if (serverId != null && serverId.isNotEmpty) {
      unawaited(ref.read(audioConversionApiServiceProvider).cancel(serverId));
    }

    _removeJob(id);
  }

  void dismiss(String id) {
    final job = state.byId(id);
    if (job == null || job.isActive) return;
    _removeJob(id);
  }

  void dismissAllTerminal() {
    final remaining = state.jobs.where((j) => j.isActive).toList();
    state = AudioConversionManagerState(jobs: remaining);
  }

  Future<void> _run(String id) async {
    if (_runningIds.contains(id)) return;
    _runningIds.add(id);

    final cancelToken = CancelToken();
    _cancelTokens[id] = cancelToken;

    final api = ref.read(audioConversionApiServiceProvider);

    try {
      final job = state.byId(id);
      if (job == null) return;
      final pending = job.pending;

      final started = await api.startConversion(
        mediaId: pending.mediaId,
        provider: pending.provider,
        videoId: pending.videoId,
        profile: pending.profile,
      );

      if (cancelToken.isCancelled) return;
      _updateJob(
        id,
        (j) => j.copyWith(
          serverJobId: started.jobId,
          status: AudioConversionUiStatus.processing,
          progress: started.progress,
          clearError: true,
        ),
      );

      final AudioConversionJob completed;
      if (started.status == AudioConversionJobStatus.completed) {
        completed = started;
      } else {
        completed = await api.waitUntilComplete(
          started.jobId,
          cancelToken: cancelToken,
          onProgress: (j) {
            if (cancelToken.isCancelled) return;
            _updateJob(
              id,
              (current) => current.copyWith(
                status: AudioConversionUiStatus.processing,
                progress: j.progress,
              ),
            );
          },
        );
      }

      if (cancelToken.isCancelled) return;

      if (completed.status == AudioConversionJobStatus.completed) {
        await _onCompleted(id, completed);
        return;
      }

      if (completed.errorCode == 'UNSUPPORTED_SOURCE' &&
          pending.youtubeFallbackOnUnsupported) {
        await _enqueueYoutubeFallback(pending);
        _removeJob(id);
        return;
      }

      _updateJob(
        id,
        (j) => j.copyWith(
          status: AudioConversionUiStatus.failed,
          errorCode: completed.errorCode,
          message: completed.message ??
              _defaultMessageForCode(completed.errorCode),
        ),
      );
    } on AudioConversionApiException catch (e) {
      if (e.errorCode == 'CANCELLED' || cancelToken.isCancelled) {
        _removeJob(id);
        return;
      }
      final job = state.byId(id);
      if (job != null &&
          e.errorCode == 'UNSUPPORTED_SOURCE' &&
          job.pending.youtubeFallbackOnUnsupported) {
        await _enqueueYoutubeFallback(job.pending);
        _removeJob(id);
        return;
      }
      _updateJob(
        id,
        (j) => j.copyWith(
          status: AudioConversionUiStatus.failed,
          errorCode: e.errorCode,
          message: e.message,
        ),
      );
    } catch (e, st) {
      debugPrint('Audio conversion error: $e\n$st');
      if (cancelToken.isCancelled) {
        _removeJob(id);
        return;
      }
      _updateJob(
        id,
        (j) => j.copyWith(
          status: AudioConversionUiStatus.failed,
          message: null,
        ),
      );
    } finally {
      _runningIds.remove(id);
      _cancelTokens.remove(id);
    }
  }

  Future<void> _onCompleted(String id, AudioConversionJob job) async {
    final uiJob = state.byId(id);
    if (uiJob == null) return;
    final pending = uiJob.pending;
    final api = ref.read(audioConversionApiServiceProvider);
    final downloadUrl = api.resolveDownloadUrl(job.downloadUrl);

    if (downloadUrl.isEmpty) {
      _updateJob(
        id,
        (j) => j.copyWith(
          status: AudioConversionUiStatus.failed,
          message: null,
        ),
      );
      return;
    }

    final installationId = await InstallationIdService.getOrCreate();
    final fcmToken = await FcmTokenCache.load();
    final headers = <String, String>{
      installationIdHeader: installationId,
      if (fcmToken != null && fcmToken.isNotEmpty) fcmTokenHeader: fcmToken,
    };

    final ext = switch ((job.format ?? '').toLowerCase()) {
      'aac' => '.m4a',
      'opus' => '.opus',
      _ => pending.profile.fileExtension,
    };

    await ref.read(offlineDownloadManagerProvider.notifier).enqueue(
          PendingOfflineDownload(
            category: pending.category,
            format: OfflineMediaFormat.audio,
            sourceId: pending.mediaId,
            title: pending.title,
            subtitle: pending.subtitle,
            url: downloadUrl,
            thumbnailUrl: pending.thumbnailUrl,
            durationSeconds: job.durationSeconds,
            expectedSizeBytes: job.fileSize,
            extraHeaders: headers,
            fileExtension: ext,
          ),
        );

    _removeJob(id);
  }

  Future<void> _enqueueYoutubeFallback(PendingAudioConversion pending) async {
    await ref.read(offlineDownloadManagerProvider.notifier).enqueue(
          PendingOfflineDownload(
            category: pending.category,
            format: OfflineMediaFormat.audio,
            sourceId: pending.mediaId,
            title: pending.title,
            subtitle: pending.subtitle,
            videoId: pending.videoId,
            thumbnailUrl: pending.thumbnailUrl,
            kind: OfflineDownloadKind.youtube,
          ),
        );
  }

  String? _defaultMessageForCode(String? code) {
    // Localized in UI via errorCode; keep API message when present.
    switch (code) {
      case 'SOURCE_UNAVAILABLE':
      case 'UNSUPPORTED_SOURCE':
      case 'TIMEOUT':
      case 'FFMPEG_UNAVAILABLE':
      case 'FEATURE_DISABLED':
      case 'CONVERSION_ALREADY_RUNNING':
        return null;
      default:
        return null;
    }
  }

  void _updateJob(
    String id,
    AudioConversionUiJob Function(AudioConversionUiJob) transform,
  ) {
    final jobs = [...state.jobs];
    final index = jobs.indexWhere((j) => j.id == id);
    if (index < 0) return;
    jobs[index] = transform(jobs[index]);
    state = AudioConversionManagerState(jobs: jobs);
  }

  void _removeJob(String id) {
    state = AudioConversionManagerState(
      jobs: state.jobs.where((j) => j.id != id).toList(),
    );
  }
}

String? audioConversionErrorMessage(
  AppLocalizations l10n, {
  String? errorCode,
  String? message,
}) {
  switch (errorCode) {
    case 'SOURCE_UNAVAILABLE':
      return l10n.audioConversionSourceUnavailable;
    case 'UNSUPPORTED_SOURCE':
      return l10n.audioConversionUnsupportedSource;
    case 'TIMEOUT':
      return l10n.audioConversionTimeout;
    case 'FFMPEG_UNAVAILABLE':
    case 'FEATURE_DISABLED':
      return l10n.audioConversionUnavailable;
    case 'CONVERSION_ALREADY_RUNNING':
      return l10n.audioConversionAlreadyRunning;
    default:
      return message ?? l10n.audioConversionFailed;
  }
}
