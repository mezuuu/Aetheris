import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/lrc_line.dart';

class LyricsSearchResult {
  final int id;
  final String name;
  final String artistName;
  final String? albumName;
  final int duration;
  final bool instrumentel;
  final String? plainLyrics;
  final String? syncedLyrics;

  LyricsSearchResult({
    required this.id,
    required this.name,
    required this.artistName,
    this.albumName,
    required this.duration,
    required this.instrumentel,
    this.plainLyrics,
    this.syncedLyrics,
  });

  factory LyricsSearchResult.fromJson(Map<String, dynamic> json) {
    return LyricsSearchResult(
      id: json['id'] as int,
      name: json['name'] as String,
      artistName: json['artistName'] as String,
      albumName: json['albumName'] as String?,
      duration: json['duration'] as int? ?? 0,
      instrumentel: json['instrumental'] == true,
      plainLyrics: json['plainLyrics'] as String?,
      syncedLyrics: json['syncedLyrics'] as String?,
    );
  }
}

class LyricsService {
  LyricsService({Dio? dio}) {
    _dio = dio ?? Dio();
    _dio.options.baseUrl = 'https://lrclib.net/api';
    _dio.options.connectTimeout = const Duration(seconds: 4);
    _dio.options.receiveTimeout = const Duration(seconds: 4);
    _dio.options.sendTimeout = const Duration(seconds: 4);
    _dio.options.headers = {
      'User-Agent': 'Aetheris v1.0.0 (https://github.com/aetheris)',
    };
  }

  static const int _maxCachedLyrics = 64;
  static final Map<String, LrcData?> _lyricsCache = {};
  static final Map<String, Future<LrcData?>> _inFlightLyrics = {};

  late final Dio _dio;

  Future<LrcData?> fetchSyncedLyrics(
    String title,
    String artist, {
    String? album,
    int? durationMs,
  }) async {
    final cacheKey = _cacheKey(title, artist, album, durationMs);
    if (_lyricsCache.containsKey(cacheKey)) {
      return _lyricsCache[cacheKey];
    }
    final inFlight = _inFlightLyrics[cacheKey];
    if (inFlight != null) {
      return inFlight;
    }

    final future = _fetchSyncedLyricsUncached(
      title,
      artist,
      album: album,
      durationMs: durationMs,
      cacheKey: cacheKey,
    );
    _inFlightLyrics[cacheKey] = future;
    try {
      return await future;
    } finally {
      _inFlightLyrics.remove(cacheKey);
    }
  }

  Future<LrcData?> _fetchSyncedLyricsUncached(
    String title,
    String artist, {
    String? album,
    int? durationMs,
    required String cacheKey,
  }) async {
    LrcData? result;
    try {
      final queryParams = {
        'track_name': title,
        'artist_name': artist,
      };
      
      if (album != null && album.isNotEmpty) {
        queryParams['album_name'] = album;
      }
      
      if (durationMs != null && durationMs > 0) {
        // API expects seconds
        queryParams['duration'] = (durationMs / 1000).round().toString();
      }

      final response = await _dio.get('/get', queryParameters: queryParams);
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final syncedLyrics = data['syncedLyrics'] as String?;
        final plainLyrics = data['plainLyrics'] as String?;
        final resultDuration = data['duration'] as num?;

        // Validate duration match: reject if the returned lyrics are
        // for a track with significantly different duration (>15s).
        if (durationMs != null && durationMs > 0 && resultDuration != null && resultDuration > 0) {
          final durationDelta = ((durationMs / 1000).round() - resultDuration.round()).abs();
          if (durationDelta > 15) {
            if (kDebugMode) {
              debugPrint('LyricsService: Primary result duration mismatch '
                  '(delta: ${durationDelta}s), falling back to search');
            }
            // Fall through to search-based fallback below
          } else if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
            result = LrcData.parse(syncedLyrics);
            _cacheLyrics(cacheKey, result);
            return result;
          } else if (plainLyrics != null && plainLyrics.isNotEmpty) {
            result = LrcData.fromPlainText(plainLyrics);
            _cacheLyrics(cacheKey, result);
            return result;
          }
        } else {
          // No duration to validate against — accept the result.
          if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
            result = LrcData.parse(syncedLyrics);
            _cacheLyrics(cacheKey, result);
            return result;
          } else if (plainLyrics != null && plainLyrics.isNotEmpty) {
            result = LrcData.fromPlainText(plainLyrics);
            _cacheLyrics(cacheKey, result);
            return result;
          }
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) {
        // Not a simple "not found", but a network or server error
        if (kDebugMode) {
          debugPrint('Error fetching lyrics: ${e.message}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unknown error fetching lyrics: $e');
      }
    }

    final fallback = await _searchBestMatch(title, artist, durationMs);
    if (fallback != null) {
      if (fallback.syncedLyrics != null && fallback.syncedLyrics!.isNotEmpty) {
        result = LrcData.parse(fallback.syncedLyrics!);
        _cacheLyrics(cacheKey, result);
        return result;
      }
      if (fallback.plainLyrics != null && fallback.plainLyrics!.isNotEmpty) {
        result = LrcData.fromPlainText(fallback.plainLyrics!);
        _cacheLyrics(cacheKey, result);
        return result;
      }
    }

    _cacheLyrics(cacheKey, null);
    return null;
  }

  Future<void> prefetchSyncedLyrics(
    String title,
    String artist, {
    String? album,
    int? durationMs,
  }) async {
    final cacheKey = _cacheKey(title, artist, album, durationMs);
    if (_lyricsCache.containsKey(cacheKey)) {
      return;
    }
    await fetchSyncedLyrics(
      title,
      artist,
      album: album,
      durationMs: durationMs,
    );
  }

  Future<List<LyricsSearchResult>> searchLyrics(String query) async {
    try {
      final response = await _dio.get('/search', queryParameters: {'q': query});
      
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => LyricsSearchResult.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error searching lyrics: $e');
      }
    }
    
    return [];
  }

  Future<LyricsSearchResult?> _searchBestMatch(
    String title,
    String artist,
    int? durationMs,
  ) async {
    final queries = [
      [artist, title].where((value) => value.trim().isNotEmpty).join(' '),
      title,
    ];

    final matches = <LyricsSearchResult>[];
    final seen = <int>{};
    for (final query in queries) {
      if (query.trim().isEmpty) {
        continue;
      }
      final queryMatches = await searchLyrics(query);
      for (final match in queryMatches) {
        if (seen.add(match.id)) {
          matches.add(match);
        }
      }
      if (matches.any((match) => match.syncedLyrics?.isNotEmpty == true)) {
        break;
      }
    }
    if (matches.isEmpty) {
      return null;
    }

    final durationSeconds = durationMs == null ? null : (durationMs / 1000).round();
    matches.sort((a, b) {
      final aScore = _matchScore(a, title, artist, durationSeconds);
      final bScore = _matchScore(b, title, artist, durationSeconds);
      return bScore.compareTo(aScore);
    });
    return matches.first;
  }

  int _matchScore(
    LyricsSearchResult result,
    String title,
    String artist,
    int? durationSeconds,
  ) {
    var score = 0;
    final titleValue = title.toLowerCase();
    final artistValue = artist.toLowerCase();

    // Title matching — exact match is heavily favored.
    if (result.name.toLowerCase() == titleValue) {
      score += 15;
    } else if (result.name.toLowerCase().contains(titleValue) ||
        titleValue.contains(result.name.toLowerCase())) {
      score += 4;
    }

    // Artist matching.
    if (result.artistName.toLowerCase().contains(artistValue) ||
        artistValue.contains(result.artistName.toLowerCase())) {
      score += 6;
    }

    // Duration matching — critical for correct version selection.
    if (durationSeconds != null && result.duration > 0) {
      final delta = (result.duration - durationSeconds).abs();
      if (delta <= 2) {
        score += 10;  // Near-perfect match.
      } else if (delta <= 8) {
        score += 5;
      } else if (delta <= 15) {
        score += 1;
      } else if (delta > 30) {
        score -= 10;  // Heavy penalty — likely wrong version/remix.
      }
    }

    // Synced lyrics preferred over plain text.
    if (result.syncedLyrics != null && result.syncedLyrics!.isNotEmpty) {
      score += 3;
    }
    return score;
  }

  static String _cacheKey(
    String title,
    String artist,
    String? album,
    int? durationMs,
  ) {
    final durationSeconds = durationMs == null ? '' : (durationMs / 1000).round();
    return [
      title.trim().toLowerCase(),
      artist.trim().toLowerCase(),
      album?.trim().toLowerCase() ?? '',
      durationSeconds,
    ].join('|');
  }

  static void _cacheLyrics(String key, LrcData? data) {
    if (_lyricsCache.length >= _maxCachedLyrics) {
      _lyricsCache.remove(_lyricsCache.keys.first);
    }
    _lyricsCache[key] = data;
  }
}
