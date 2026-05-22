import '../../models/track.dart';

enum DownloadJobStatus {
  queued,
  downloading,
  converting,
  validating,
  completed,
  failed,
  cancelled,
  paused,
  resuming;

  static DownloadJobStatus fromString(String value) {
    return DownloadJobStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => DownloadJobStatus.queued,
    );
  }
}

class DownloadTask {
  DownloadTask({
    required this.id,
    required this.track,
    required this.qualityId,
    required this.qualityFormat,
    required this.qualityBitrate,
    this.outputDir,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final Track track;
  final String qualityId;
  final String qualityFormat;
  final String qualityBitrate;
  final String? outputDir;
  final DateTime createdAt;

  DownloadJobStatus status = DownloadJobStatus.queued;
  double progress = 0.0;
  String? filePath;
  int downloadedBytes = 0;
  int totalBytes = 0;
  int speedBytesPerSecond = 0;
  String? error;
  DateTime? completedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'track': track.toJson(),
      'qualityId': qualityId,
      'qualityFormat': qualityFormat,
      'qualityBitrate': qualityBitrate,
      'outputDir': outputDir,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'status': status.name,
      'progress': progress,
      'filePath': filePath,
      'downloadedBytes': downloadedBytes,
      'totalBytes': totalBytes,
      'error': error,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  factory DownloadTask.fromJson(Map<String, dynamic> json) {
    final task = DownloadTask(
      id: json['id'] as String,
      track: Track.fromJson(json['track'] as Map<String, dynamic>),
      qualityId: json['qualityId'] as String,
      qualityFormat: json['qualityFormat'] as String,
      qualityBitrate: json['qualityBitrate'] as String,
      outputDir: json['outputDir'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
    );
    task.status = DownloadJobStatus.fromString(json['status'] as String? ?? 'queued');
    // Important for persistence: downloading jobs must be paused on restart
    if (task.status == DownloadJobStatus.downloading || task.status == DownloadJobStatus.resuming) {
      task.status = DownloadJobStatus.paused;
    }
    task.progress = (json['progress'] as num?)?.toDouble() ?? 0.0;
    task.filePath = json['filePath'] as String?;
    task.downloadedBytes = (json['downloadedBytes'] as num?)?.toInt() ?? 0;
    task.totalBytes = (json['totalBytes'] as num?)?.toInt() ?? 0;
    task.error = json['error'] as String?;
    task.completedAt = json['completedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int)
        : null;
    return task;
  }

  // Internal state for pause/cancel
  bool get isActive =>
      status == DownloadJobStatus.queued ||
      status == DownloadJobStatus.downloading ||
      status == DownloadJobStatus.converting ||
      status == DownloadJobStatus.validating ||
      status == DownloadJobStatus.resuming;

  bool get canPause => status == DownloadJobStatus.downloading;
  bool get canResume => status == DownloadJobStatus.paused;
  bool get canCancel => isActive || status == DownloadJobStatus.paused;

  String get fileSizeLabel {
    if (totalBytes <= 0) return '';
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get speedLabel {
    if (speedBytesPerSecond <= 0) return '';
    if (speedBytesPerSecond < 1024 * 1024) {
      return '${(speedBytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(speedBytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
}
