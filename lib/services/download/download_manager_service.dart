import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/track.dart';
import '../music_sources/music_source_manager.dart';
import 'download_converter.dart';
import 'download_task.dart';
import 'fallback_resolver.dart';

class DownloadManagerService extends ChangeNotifier {
  DownloadManagerService({
    required MusicSourceManager sourceManager,
  }) : _resolver = FallbackResolver(sourceManager: sourceManager) {
    _loadPersistedTasks();
  }

  static const String _prefsKey = 'aetheris_download_queue';

  final FallbackResolver _resolver;
  final Dio _dio = Dio();
  
  final Map<String, DownloadTask> _tasks = {};
  final List<DownloadTask> _queue = [];
  final Map<String, CancelToken> _cancelTokens = {};
  
  static const int _maxConcurrent = 3;
  int _activeCount = 0;

  List<DownloadTask> get tasks => _tasks.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  bool get hasActiveDownloads => _activeCount > 0;

  Future<void> _loadPersistedTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_prefsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        for (final item in decoded) {
          final task = DownloadTask.fromJson(item as Map<String, dynamic>);
          _tasks[task.id] = task;
          if (task.status == DownloadJobStatus.queued || task.status == DownloadJobStatus.paused) {
            _queue.add(task);
          }
        }
        notifyListeners();
        // Do not auto-start paused jobs, let the user manually resume
        _processQueue();
      }
    } catch (e) {
      if (kDebugMode) print('DownloadManagerService: Failed to load tasks - $e');
    }
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Only persist active or recently completed tasks
      final tasksToSave = _tasks.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // Keep up to 50 items
      final limitedTasks = tasksToSave.take(50).map((t) => t.toJson()).toList();
      await prefs.setString(_prefsKey, jsonEncode(limitedTasks));
    } catch (e) {
      if (kDebugMode) print('DownloadManagerService: Failed to save tasks - $e');
    }
  }

  /// Queue a track for download
  DownloadTask enqueue({
    required Track track,
    required String qualityId,
    required String qualityFormat,
    required String qualityBitrate,
    String? outputDir,
  }) {
    final taskId = '${DateTime.now().millisecondsSinceEpoch}_${track.id.hashCode.abs()}';
    
    final task = DownloadTask(
      id: taskId,
      track: track,
      qualityId: qualityId,
      qualityFormat: qualityFormat,
      qualityBitrate: qualityBitrate,
      outputDir: outputDir,
    );

    _tasks[taskId] = task;
    _queue.add(task);
    
    notifyListeners();
    _saveTasks();
    _processQueue();
    
    return task;
  }

  void pause(String taskId) {
    final task = _tasks[taskId];
    if (task != null && task.canPause) {
      _cancelTokens[taskId]?.cancel('Paused by user');
      _cancelTokens.remove(taskId);
      task.status = DownloadJobStatus.paused;
      _activeCount--;
      notifyListeners();
      _saveTasks();
      _processQueue();
    }
  }

  void resume(String taskId) {
    final task = _tasks[taskId];
    if (task != null && task.canResume) {
      task.status = DownloadJobStatus.resuming;
      _queue.insert(0, task); // High priority resume
      notifyListeners();
      _saveTasks();
      _processQueue();
    }
  }

  void cancel(String taskId) {
    final task = _tasks[taskId];
    if (task != null) {
      _cancelTokens[taskId]?.cancel('Cancelled by user');
      _cancelTokens.remove(taskId);
      _queue.remove(task);
      
      // Cleanup partial files
      if (task.filePath != null) {
        final file = File(task.filePath!);
        if (file.existsSync()) file.deleteSync();
      }
      
      task.status = DownloadJobStatus.cancelled;
      task.completedAt = DateTime.now();
      if (task.isActive) _activeCount--;
      
      notifyListeners();
      _saveTasks();
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    while (_activeCount < _maxConcurrent && _queue.isNotEmpty) {
      final task = _queue.removeAt(0);
      _activeCount++;
      _executeTask(task);
    }
  }

  Future<void> _executeTask(DownloadTask task) async {
    final cancelToken = CancelToken();
    _cancelTokens[task.id] = cancelToken;
    
    try {
      // 1. Resolve Stream
      task.status = DownloadJobStatus.downloading;
      notifyListeners();
      
      final streamInfo = await _resolver.resolve(task.track);
      if (streamInfo == null || streamInfo.url.isEmpty) {
        throw Exception('Failed to resolve audio stream');
      }

      // 2. Prepare File Paths
      final outDir = task.outputDir ?? (await getApplicationDocumentsDirectory()).path;
      final outDirFile = Directory(outDir);
      if (!outDirFile.existsSync()) {
        outDirFile.createSync(recursive: true);
      }
      
      final tempDir = (await getTemporaryDirectory()).path;
      final safeTitle = task.track.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');
      final ext = DownloadConverter.getExtensionForCodec(streamInfo.codec);
      final rawPath = '$tempDir/raw_${task.id}.$ext';
      final tempFinalPath = '$tempDir/$safeTitle.${task.qualityFormat.toLowerCase()}';
      final finalPath = '$outDir/$safeTitle.${task.qualityFormat.toLowerCase()}';
      
      // Check partial download for resume
      final rawFile = File(rawPath);
      int downloadedBytes = 0;
      if (rawFile.existsSync() && task.status == DownloadJobStatus.resuming) {
        downloadedBytes = rawFile.lengthSync();
        task.downloadedBytes = downloadedBytes;
      } else if (rawFile.existsSync()) {
        rawFile.deleteSync();
      }
      
      task.status = DownloadJobStatus.downloading;
      
      // 3. Download (with Range header if resuming)
      final options = Options(
        responseType: ResponseType.stream,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          if (downloadedBytes > 0) 'Range': 'bytes=$downloadedBytes-',
        },
      );

      final response = await _dio.get<ResponseBody>(
        streamInfo.url,
        options: options,
        cancelToken: cancelToken,
      );
      
      // Calculate total bytes
      final contentRange = response.headers.value('content-range');
      int totalBytes = -1;
      if (contentRange != null) {
        final parts = contentRange.split('/');
        if (parts.length == 2) totalBytes = int.tryParse(parts[1]) ?? -1;
      } else {
        totalBytes = int.tryParse(response.headers.value('content-length') ?? '-1') ?? -1;
      }
      if (totalBytes > 0) {
        task.totalBytes = totalBytes;
      }

      final sink = rawFile.openWrite(mode: downloadedBytes > 0 ? FileMode.append : FileMode.write);
      final stream = response.data!.stream;
      
      int lastUpdate = DateTime.now().millisecondsSinceEpoch;
      int bytesSinceUpdate = 0;

      await for (final chunk in stream) {
        if (cancelToken.isCancelled) break;
        
        sink.add(chunk);
        downloadedBytes += chunk.length;
        bytesSinceUpdate += chunk.length;
        task.downloadedBytes = downloadedBytes;
        
        if (task.totalBytes > 0) {
          task.progress = downloadedBytes / task.totalBytes;
        }

        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - lastUpdate >= 500) { // Update UI every 500ms
          task.speedBytesPerSecond = (bytesSinceUpdate / ((now - lastUpdate) / 1000)).round();
          bytesSinceUpdate = 0;
          lastUpdate = now;
          notifyListeners();
        }
      }
      await sink.close();

      if (cancelToken.isCancelled) {
        throw DioException.requestCancelled(requestOptions: response.requestOptions, reason: 'Cancelled by user');
      }

      // 4. Convert format via FFmpeg Isolate
      task.status = DownloadJobStatus.converting;
      task.speedBytesPerSecond = 0;
      notifyListeners();

      final successPath = await DownloadConverter.convertAudio(
        inputPath: rawPath,
        outputPath: tempFinalPath,
        targetFormat: task.qualityFormat,
        targetBitrate: task.qualityBitrate,
      );

      if (successPath == null) {
        throw Exception('FFmpeg conversion failed');
      }

      // Copy to public scoped storage directory
      File(tempFinalPath).copySync(finalPath);

      // Cleanup temp files
      if (rawFile.existsSync()) rawFile.deleteSync();
      final tempFinalFile = File(tempFinalPath);
      if (tempFinalFile.existsSync()) tempFinalFile.deleteSync();

      // 5. Success
      task.filePath = finalPath;
      task.status = DownloadJobStatus.completed;
      task.completedAt = DateTime.now();

    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        if (task.status != DownloadJobStatus.paused) {
          task.status = DownloadJobStatus.cancelled;
        }
      } else {
        task.status = DownloadJobStatus.failed;
        task.error = e.message;
      }
    } catch (e) {
      task.status = DownloadJobStatus.failed;
      task.error = e.toString();
    } finally {
      _cancelTokens.remove(task.id);
      if (task.status != DownloadJobStatus.paused) {
        _activeCount--;
      }
      notifyListeners();
      _saveTasks();
      _processQueue();
    }
  }
}
