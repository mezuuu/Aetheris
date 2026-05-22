import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/track.dart';

/// Optional lossless resolver compatible with a self-hosted Tidal-like backend.
///
/// Spotify is still used as metadata/search identity. Audio is resolved from
/// the configured lossless backend using title + artist, mirroring the
/// foundation project's JIT approach without hard-coding a private server.
class LosslessStreamService {
  const LosslessStreamService({Dio? dio}) : _dio = dio;

  static const String _apiUrl = String.fromEnvironment('TIDAL_API_URL');
  static const String _apiKey = String.fromEnvironment('TIDAL_API_KEY');

  final Dio? _dio;

  bool get isConfigured => _apiUrl.trim().isNotEmpty;

  Future<Track?> resolve(Track track) async {
    if (!isConfigured || track.title.trim().isEmpty) {
      return null;
    }

    final dio = _dio ?? Dio();
    dio.options
      ..connectTimeout = const Duration(seconds: 5)
      ..sendTimeout = const Duration(seconds: 5)
      ..receiveTimeout = const Duration(seconds: 6);

    try {
      final trackId = await _findTrackId(dio, track);
      if (trackId == null) {
        return null;
      }

      final streamUri = _buildStreamUri(trackId);
      return track.copyWith(
        streamUrl: streamUri.toString(),
        fallbackStreamUrls: [
          if (track.streamUrl != null) track.streamUrl!,
          ...track.fallbackStreamUrls,
        ],
        format: 'FLAC',
        bitDepth: 24,
        sampleRateKhz: 48,
        isBitPerfect: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print('LosslessStreamService: resolve failed: $e');
      }
      return null;
    }
  }

  Future<String?> _findTrackId(Dio dio, Track track) async {
    final base = Uri.parse(_apiUrl);
    final query = '${track.title} ${track.artist}'.trim();
    final searchUri = base.replace(
      path: _joinPath(base.path, 'search'),
      queryParameters: {
        'q': query,
        'limit': '5',
        if (_apiKey.isNotEmpty) 'key': _apiKey,
      },
    );

    final response = await dio.getUri<Object?>(
      searchUri,
      options: Options(
        headers: {
          if (_apiKey.isNotEmpty) 'x-api-key': _apiKey,
        },
      ),
    );
    final data = response.data;
    final items = _readItems(data);
    if (items.isEmpty) {
      return null;
    }

    final normalizedTitle = _normalize(track.title);
    final normalizedArtist = _normalize(track.artist);
    for (final item in items) {
      final title = _normalize(item['title']?.toString() ?? '');
      final artist = _normalize(
        item['artist'] is Map
            ? ((item['artist'] as Map)['name']?.toString() ?? '')
            : item['artist']?.toString() ?? '',
      );
      final id = item['id']?.toString();
      if (id == null || id.isEmpty) {
        continue;
      }
      if (title == normalizedTitle &&
          (artist.isEmpty ||
              normalizedArtist.isEmpty ||
              artist.contains(normalizedArtist) ||
              normalizedArtist.contains(artist))) {
        return id;
      }
    }

    return items.first['id']?.toString();
  }

  Uri _buildStreamUri(String trackId) {
    final base = Uri.parse(_apiUrl);
    return base.replace(
      path: _joinPath(base.path, 'stream'),
      queryParameters: {
        'id': trackId,
        'quality': 'HI_RES_LOSSLESS',
        if (_apiKey.isNotEmpty) 'key': _apiKey,
      },
    );
  }

  static List<Map<String, dynamic>> _readItems(Object? data) {
    if (data is List) {
      return data.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }
    if (data is Map) {
      final tracks = data['tracks'];
      if (tracks is Map && tracks['items'] is List) {
        return (tracks['items'] as List)
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList();
      }
      final items = data['items'];
      if (items is List) {
        return items.whereType<Map>().map(Map<String, dynamic>.from).toList();
      }
    }
    return const [];
  }

  static String _joinPath(String basePath, String child) {
    final normalized = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    return '$normalized/$child';
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'\s*-\s*topic$'), '')
        .replaceAll(RegExp(r'\b(feat|ft|featuring)\.?\b.*$'), '')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }
}
