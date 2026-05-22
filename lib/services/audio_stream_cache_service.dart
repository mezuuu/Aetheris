import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/track.dart';

class AudioStreamCacheService {
  AudioStreamCacheService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<Track?> cacheForPlayback(Track track) async {
    final remoteUris = track.streamUris
        .where((uri) => uri.scheme == 'http' || uri.scheme == 'https')
        .toList(growable: false);
    if (remoteUris.isEmpty) return null;

    for (final remoteUri in remoteUris) {
      final cached = await _cacheUriForPlayback(track, remoteUri);
      if (cached != null) return cached;
    }
    return null;
  }

  Future<Track?> _cacheUriForPlayback(Track track, Uri remoteUri) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final dir = Directory('${cacheDir.path}${Platform.pathSeparator}aetheris_stream_cache');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final fallbackExtension = _extensionFor(track, remoteUri);
      final existingFile = await _existingCachedFile(dir, track);
      if (existingFile != null) {
        return _trackFromCachedFile(track, existingFile);
      }
      final tempFile = File(
        '${dir.path}${Platform.pathSeparator}${_safeName(track)}.part',
      );
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      var file = File(
        '${dir.path}${Platform.pathSeparator}${_safeName(track)}.$fallbackExtension',
      );
      if (await file.exists() && await file.length() > 4096) {
        return _trackFromCachedFile(track, file);
      }

      final response = await _dio.getUri<ResponseBody>(
        remoteUri,
        options: Options(
          responseType: ResponseType.stream,
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 8),
          headers: _headersFor(remoteUri),
        ),
      );

      final contentType = response.headers.value(Headers.contentTypeHeader);
      final extension = _extensionFromContentType(contentType) ?? fallbackExtension;
      file = File(
        '${dir.path}${Platform.pathSeparator}${_safeName(track)}.$extension',
      );
      if (await file.exists()) {
        await file.delete();
      }

      final sink = tempFile.openWrite();
      var received = 0;
      await for (final chunk in response.data!.stream) {
        received += chunk.length;
        sink.add(chunk);
      }
      await sink.flush();
      await sink.close();

      if (received <= 4096 || !await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
        return null;
      }
      await tempFile.rename(file.path);

      return _trackFromCachedFile(track, file);
    } catch (e) {
      if (kDebugMode) {
        print('AudioStreamCacheService: cacheForPlayback failed for $remoteUri: $e');
      }
      return null;
    }
  }

  Track _trackFromCachedFile(Track track, File file) {
    return track.copyWith(
      streamUrl: file.uri.toString(),
      fallbackStreamUrls: const [],
    );
  }

  static String _safeName(Track track) {
    final raw = '${track.id}_${track.title}_${track.artist}';
    return raw
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '')
        .take(96);
  }

  static String _extensionFor(Track track, Uri uri) {
    final path = uri.path.toLowerCase();
    for (final ext in ['m4a', 'mp4', 'mp3', 'opus', 'ogg', 'webm', 'flac', 'wav']) {
      if (path.endsWith('.$ext')) {
        return ext == 'mp4' ? 'm4a' : ext;
      }
    }

    return switch (track.format.toUpperCase()) {
      'AAC' => 'm4a',
      'OPUS' => 'webm',
      'MP3' => 'mp3',
      'FLAC' => 'flac',
      'WAV' => 'wav',
      _ => 'm4a',
    };
  }

  static String? _extensionFromContentType(String? contentType) {
    final value = contentType?.toLowerCase() ?? '';
    if (value.contains('audio/webm') || value.contains('video/webm')) {
      return 'webm';
    }
    if (value.contains('audio/ogg') || value.contains('application/ogg')) {
      return 'ogg';
    }
    if (value.contains('audio/mp4') ||
        value.contains('video/mp4') ||
        value.contains('audio/aac')) {
      return 'm4a';
    }
    if (value.contains('mpeg')) {
      return 'mp3';
    }
    if (value.contains('flac')) {
      return 'flac';
    }
    if (value.contains('wav')) {
      return 'wav';
    }
    return null;
  }

  static Map<String, String>? _headersFor(Uri uri) {
    final isYouTubeCdn = uri.host.contains('googlevideo.com') ||
        uri.host.contains('youtube.com') ||
        uri.queryParameters.containsKey('expire');
    if (isYouTubeCdn) {
      return null;
    }
    return const {
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36',
      'Accept': '*/*',
    };
  }

  static Future<File?> _existingCachedFile(Directory dir, Track track) async {
    final baseName = _safeName(track);
    for (final ext in ['m4a', 'webm', 'ogg', 'mp3', 'flac', 'wav']) {
      final file = File('${dir.path}${Platform.pathSeparator}$baseName.$ext');
      if (await file.exists() && await file.length() > 4096) {
        return file;
      }
    }
    return null;
  }
}

extension on String {
  String take(int maxLength) {
    if (length <= maxLength) {
      return this;
    }
    return substring(0, maxLength);
  }
}
