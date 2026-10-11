enum AudioConversionProfile {
  economy,
  standard,
  compatible;

  String get apiValue => name;

  String get bitrateLabel => switch (this) {
        AudioConversionProfile.economy => '48 kb/s',
        AudioConversionProfile.standard => '64 kb/s',
        AudioConversionProfile.compatible => '96 kb/s',
      };

  String get formatLabel => switch (this) {
        AudioConversionProfile.compatible => 'AAC',
        _ => 'Opus',
      };

  String get fileExtension => switch (this) {
        AudioConversionProfile.compatible => '.m4a',
        _ => '.opus',
      };
}

enum AudioConversionJobStatus {
  queued,
  processing,
  completed,
  failed,
  cancelled;

  static AudioConversionJobStatus fromApi(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'processing':
        return AudioConversionJobStatus.processing;
      case 'completed':
        return AudioConversionJobStatus.completed;
      case 'failed':
        return AudioConversionJobStatus.failed;
      case 'cancelled':
        return AudioConversionJobStatus.cancelled;
      default:
        return AudioConversionJobStatus.queued;
    }
  }

  bool get isTerminal =>
      this == AudioConversionJobStatus.completed ||
      this == AudioConversionJobStatus.failed ||
      this == AudioConversionJobStatus.cancelled;
}

class AudioConversionJob {
  const AudioConversionJob({
    required this.jobId,
    required this.status,
    required this.progress,
    required this.mediaId,
    required this.profile,
    this.format,
    this.bitrate,
    this.fileSize,
    this.durationSeconds,
    this.downloadUrl,
    this.errorCode,
    this.message,
  });

  final String jobId;
  final AudioConversionJobStatus status;
  final int progress;
  final String mediaId;
  final String profile;
  final String? format;
  final String? bitrate;
  final int? fileSize;
  final int? durationSeconds;
  final String? downloadUrl;
  final String? errorCode;
  final String? message;

  factory AudioConversionJob.fromJson(Map<String, dynamic> json) {
    return AudioConversionJob(
      jobId: json['jobId']?.toString() ?? '',
      status: AudioConversionJobStatus.fromApi(json['status']?.toString()),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      mediaId: json['mediaId']?.toString() ?? '',
      profile: json['profile']?.toString() ?? 'standard',
      format: json['format']?.toString(),
      bitrate: json['bitrate']?.toString(),
      fileSize: (json['fileSize'] as num?)?.toInt(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      downloadUrl: json['downloadUrl']?.toString(),
      errorCode: json['errorCode']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
