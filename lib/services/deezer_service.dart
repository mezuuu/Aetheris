import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// A track from the Deezer public API.
///
/// Used for ISRC-based cross-matching between Spotify and YouTube.
/// Deezer's public API does not require authentication.
class DeezerTrack {
  const DeezerTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationSeconds,
    this.isrc,
    this.previewUrl,
    this.coverUrl,
  });

  factory DeezerTrack.fromJson(Map<String, dynamic> json) {
    final artistJson = json['artist'] as Map<String, dynamic>?;
    final albumJson = json['album'] as Map<String, dynamic>?;

    return DeezerTrack(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      artist: artistJson?['name'] as String? ?? '',
      album: albumJson?['title'] as String? ?? '',
      durationSeconds: (json['duration'] as num?)?.toInt() ?? 0,
      isrc: json['isrc'] as String?,
      previewUrl: json['preview'] as String?,
      coverUrl: albumJson?['cover_big'] as String? ??
          albumJson?['cover_medium'] as String?,
    );
  }

  final int id;
  final String title;
  final String artist;
  final String album;

  /// Duration in seconds (Deezer API returns seconds, not ms).
  final int durationSeconds;

  /// ISRC code — identical across Spotify, Deezer, and other services.
  final String? isrc;

  /// 30-second preview URL (not used for playback, only for verification).
  final String? previewUrl;

  /// Album cover art URL.
  final String? coverUrl;

  Duration get duration => Duration(seconds: durationSeconds);
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Client for the Deezer public API.
///
/// Used exclusively for ISRC-based track matching — finding the exact same
/// track on Deezer (via ISRC) so we can build a more accurate YouTube search
/// query. **Does NOT stream audio from Deezer.**
///
/// The Deezer API is free and requires no authentication.
///
/// ```dart
/// final deezer = DeezerService();
/// final tracks = await deezer.searchByIsrc('USAT21301012');
/// ```
class DeezerService {
  DeezerService({Dio? dio})
      : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = _apiBase
      ..connectTimeout = const Duration(seconds: 6)
      ..sendTimeout = const Duration(seconds: 6)
      ..receiveTimeout = const Duration(seconds: 6);
  }

  final Dio _dio;

  static const String _apiBase = 'https://api.deezer.com';

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Search for a track by its ISRC code.
  ///
  /// ISRC (International Standard Recording Code) is a globally unique
  /// identifier for a recording. Spotify and Deezer share the same ISRC
  /// for identical recordings, making this the most accurate cross-matching
  /// method available.
  ///
  /// Returns an empty list if the ISRC is not found.
  Future<List<DeezerTrack>> searchByIsrc(String isrc) async {
    if (isrc.trim().isEmpty) return [];

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/track/isrc:${isrc.trim()}',
      );

      final data = response.data;
      if (data == null || data['error'] != null) return [];

      // The ISRC endpoint returns a single track object (not a list).
      return [DeezerTrack.fromJson(data)];
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DeezerService: searchByIsrc error: $e');
      }
      return [];
    }
  }

  /// Search for tracks by a free-text query.
  ///
  /// Used as a secondary fallback if ISRC is not available.
  Future<List<DeezerTrack>> searchTracks(
    String query, {
    int limit = 10,
  }) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/search',
        queryParameters: {
          'q': query.trim(),
          'limit': limit.clamp(1, 25),
        },
      );

      final data = response.data;
      if (data == null) return [];

      final items = data['data'] as List<dynamic>? ?? [];

      return items
          .whereType<Map<String, dynamic>>()
          .map(DeezerTrack.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DeezerService: searchTracks error: $e');
      }
      return [];
    }
  }

  /// Get full details for a specific track ID.
  Future<DeezerTrack?> getTrackDetails(int trackId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/track/$trackId',
      );

      final data = response.data;
      if (data == null || data['error'] != null) return null;

      return DeezerTrack.fromJson(data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DeezerService: getTrackDetails error: $e');
      }
      return null;
    }
  }

  /// Release resources held by the underlying [Dio] instance.
  void dispose() {
    _dio.close(force: true);
  }
}
