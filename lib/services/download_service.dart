import 'package:flutter/foundation.dart';

import '../models/track.dart';
import 'download/download_manager_service.dart';
import 'download/download_task.dart';

// Re-export task models for UI
export 'download/download_task.dart' show DownloadJobStatus, DownloadTask;
typedef DownloadJob = DownloadTask;

/// Represents a download quality option shown to the user.
class DownloadQuality {
  const DownloadQuality({
    required this.id,
    required this.label,
    required this.description,
    required this.format,
    required this.bitrate,
    this.icon,
  });

  final String id;
  final String label;
  final String description;
  final String format;
  final String bitrate;
  final String? icon;

  static const List<DownloadQuality> presets = [
    DownloadQuality(
      id: 'MP3_128',
      label: 'MP3 Standard',
      description: 'Standard • 44.1 kHz / 16-bit',
      format: 'MP3',
      bitrate: '128 kbps',
      icon: '📱',
    ),
    DownloadQuality(
      id: 'MP3_320',
      label: 'MP3 High Quality',
      description: 'High quality • 48.0 kHz / 16-bit',
      format: 'MP3',
      bitrate: '320 kbps',
      icon: '🎵',
    ),
    DownloadQuality(
      id: 'FLAC',
      label: 'FLAC Lossless',
      description: 'CD quality container • 44.1 kHz / 16-bit',
      format: 'FLAC',
      bitrate: '1411 kbps',
      icon: '🎧',
    ),
    DownloadQuality(
      id: 'WAV',
      label: 'WAV Uncompressed',
      description: 'Studio raw PCM • 44.1 kHz / 16-bit',
      format: 'WAV',
      bitrate: '1411 kbps',
      icon: '💿',
    ),
    DownloadQuality(
      id: 'AAC_256',
      label: 'AAC High',
      description: 'Advanced Audio Coding • 48 kHz / 16-bit',
      format: 'AAC',
      bitrate: '256 kbps',
      icon: '🎶',
    ),
    DownloadQuality(
      id: 'OPUS_160',
      label: 'Opus Efficient',
      description: 'Modern efficient format • 48 kHz',
      format: 'OPUS',
      bitrate: '160 kbps',
      icon: '✨',
    ),
    DownloadQuality(
      id: 'OGG_320',
      label: 'Ogg Vorbis',
      description: 'Open container • 48 kHz',
      format: 'OGG',
      bitrate: '320 kbps',
      icon: '🎼',
    ),
  ];
}

/// Facade bridging the UI with the core DownloadManagerService.
class DownloadService extends ChangeNotifier {
  DownloadService({required DownloadManagerService downloadManager})
      : _downloadManager = downloadManager {
    _downloadManager.addListener(notifyListeners);
  }

  final DownloadManagerService _downloadManager;

  // Accessors for UI
  List<DownloadTask> get activeJobs => _downloadManager.tasks.where((t) => t.isActive).toList();
  List<DownloadTask> get history => _downloadManager.tasks.where((t) => !t.isActive).toList();

  bool get hasActiveDownloads => _downloadManager.hasActiveDownloads;
  int get activeDownloadCount => activeJobs.length;

  Future<bool> isBackendAvailable() async => true;

  Future<List<DownloadQuality>> fetchQualities() async => DownloadQuality.presets;

  Future<DownloadTask?> downloadTrack(
    Track track, {
    required String quality,
    List<String>? services,
    String? outputDir,
    void Function(bool success, String? path, String? error)? onCompleted,
  }) async {
    final qualityPreset = DownloadQuality.presets.firstWhere(
      (q) => q.id == quality,
      orElse: () => DownloadQuality.presets.first,
    );

    final task = _downloadManager.enqueue(
      track: track,
      qualityId: qualityPreset.id,
      qualityFormat: qualityPreset.format,
      qualityBitrate: qualityPreset.bitrate,
      outputDir: outputDir,
    );

    if (onCompleted != null) {
      // Monitor task until completion to fire callback
      _monitorTask(task.id, onCompleted);
    }

    return task;
  }

  void _monitorTask(String taskId, void Function(bool, String?, String?) onCompleted) {
    void listener() {
      final task = _downloadManager.tasks.firstWhere(
        (t) => t.id == taskId,
      );
      if (!task.isActive) {
        _downloadManager.removeListener(listener);
        onCompleted(
          task.status == DownloadJobStatus.completed,
          task.filePath,
          task.error,
        );
      }
    }
    _downloadManager.addListener(listener);
  }

  Future<DownloadTask?> downloadFromUrl({
    required String url,
    required String quality,
    List<String>? services,
    String? outputDir,
    String title = '',
    String artist = '',
  }) async {
    final track = Track(
      id: 'url_${DateTime.now().millisecondsSinceEpoch}',
      title: title.isNotEmpty ? title : 'URL Download',
      artist: artist.isNotEmpty ? artist : 'Unknown',
      album: 'Online Download',
      format: 'M4A',
      bitDepth: 16,
      sampleRateKhz: 44,
      duration: Duration.zero,
      coverColors: const [],
      lyrics: const [],
    );

    return downloadTrack(
      track,
      quality: quality,
      services: services,
      outputDir: outputDir,
    );
  }

  Future<bool> cancelDownload(String jobId) async {
    _downloadManager.cancel(jobId);
    return true;
  }

  void pauseDownload(String jobId) {
    _downloadManager.pause(jobId);
  }

  void resumeDownload(String jobId) {
    _downloadManager.resume(jobId);
  }

  @override
  void dispose() {
    _downloadManager.removeListener(notifyListeners);
    super.dispose();
  }
}
