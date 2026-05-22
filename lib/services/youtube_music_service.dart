import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// A music track sourced from YouTube / YouTube Music.
class YtMusicTrack {
  const YtMusicTrack({
    required this.videoId,
    required this.title,
    required this.artist,
    this.thumbnailUrl,
    required this.duration,
    this.audioStreamUrl,
  });

  final String videoId;
  final String title;

  /// Channel name (used as artist).
  final String artist;

  /// Highest‑resolution thumbnail available.
  final String? thumbnailUrl;

  final Duration duration;

  /// Direct audio stream URL. Populated lazily via [getAudioStreamUrl].
  final String? audioStreamUrl;

  /// Canonical YouTube watch URL.
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';

  /// Return a copy with an updated [audioStreamUrl].
  YtMusicTrack copyWithStreamUrl(String? url) => YtMusicTrack(
        videoId: videoId,
        title: title,
        artist: artist,
        thumbnailUrl: thumbnailUrl,
        duration: duration,
        audioStreamUrl: url,
      );

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'title': title,
        'artist': artist,
        'thumbnailUrl': thumbnailUrl,
        'durationMs': duration.inMilliseconds,
        'audioStreamUrl': audioStreamUrl,
      };
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Service for searching YouTube Music and obtaining audio stream URLs.
///
/// Uses the `youtube_explode_dart` package under the hood. Remember to call
/// [dispose] when the service is no longer needed so that underlying HTTP
/// clients are closed cleanly.
///
/// ```dart
/// final yt = YouTubeMusicService();
/// final results = await yt.searchTracks('Daft Punk - Around the World');
/// final streamUrl = await yt.getAudioStreamUrl(results.first.videoId);
/// yt.dispose();
/// ```
class YouTubeMusicService {
  YouTubeMusicService({YoutubeExplode? client})
      : _yt = client ?? YoutubeExplode();

  static const int _maxCachedStreamUrlSets = 48;
  static final Map<String, List<String>> _streamUrlCache = {};

  final YoutubeExplode _yt;
  bool _disposed = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Close the underlying HTTP client.
  ///
  /// After calling this the service must not be used again.
  void dispose() {
    if (!_disposed) {
      _yt.close();
      _disposed = true;
    }
  }

  void _assertNotDisposed() {
    if (_disposed) {
      throw StateError('YouTubeMusicService has been disposed');
    }
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  /// Search YouTube for music tracks matching [query].
  ///
  /// Results are filtered heuristically to prefer music content (official
  /// audio, topic channels, short‑form videos ≤ 15 min).
  ///
  /// Returns up to [limit] results.
  Future<List<YtMusicTrack>> searchTracks(
    String query, {
    int limit = 20,
  }) async {
    _assertNotDisposed();

    if (query.trim().isEmpty) return [];

    try {
      final searchList = await _yt.search
          .search(
            query,
            filter: TypeFilters.video,
          )
          .timeout(const Duration(seconds: 12));

      final results = <YtMusicTrack>[];

      for (final video in searchList) {
        if (results.length >= limit) break;

        // Filter: skip excessively long videos (likely podcasts / mixes).
        final duration = video.duration;
        if (duration == null) continue;
        if (duration.inMinutes > 15) continue;

        // Filter: skip very short clips (< 30 s).
        if (duration.inSeconds < 30) continue;

        results.add(_videoToTrack(video));
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('YouTubeMusicService: searchTracks error: $e');
      }
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Audio stream
  // ---------------------------------------------------------------------------

  /// Obtain the best audio‑only stream URL for the given [videoId].
  ///
  /// Prefers audio‑only streams sorted by bitrate descending so we get the
  /// highest quality available. Returns `null` if no suitable stream is found.
  Future<String?> getAudioStreamUrl(String videoId) async {
    if (videoId.trim().isEmpty) return null;

    try {
      _assertNotDisposed();
      final manifest = await _getBestManifest(videoId);

      // Prefer audio‑only streams.
      final audioOnly = manifest.audioOnly.sortByBitrate();
      if (audioOnly.isNotEmpty) {
        return audioOnly.last.url.toString();
      }

      // Fall back to muxed streams (audio + video) if no audio‑only exists.
      final muxed = manifest.muxed.sortByBitrate();
      if (muxed.isNotEmpty) {
        return muxed.last.url.toString();
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('YouTubeMusicService: getAudioStreamUrl error: $e');
      }
      return null;
    }
  }

  Future<List<String>> getAudioStreamUrls(String videoId) async {
    final trimmedVideoId = videoId.trim();
    if (trimmedVideoId.isEmpty) return const [];

    final cached = _streamUrlCache[trimmedVideoId];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    try {
      _assertNotDisposed();
      final manifest = await _getBestManifest(trimmedVideoId);

      final audioOnly = manifest.audioOnly.sortByBitrate().reversed.toList();
      final muxed = manifest.muxed.sortByBitrate().reversed.toList();
      final mp4Candidates = <String>[
        for (final stream in audioOnly)
          if (stream.container.name == 'mp4') stream.url.toString(),
        for (final stream in muxed)
          if (stream.container.name == 'mp4') stream.url.toString(),
      ];
      final fallbackCandidates = <String>[
        for (final stream in audioOnly) stream.url.toString(),
        for (final stream in muxed) stream.url.toString(),
      ];

      final seen = <String>{};
      final candidates = mp4Candidates.isNotEmpty
          ? mp4Candidates.take(8)
          : fallbackCandidates.take(6);
      final urls = List<String>.unmodifiable(candidates.where(seen.add));
      _cacheStreamUrls(trimmedVideoId, urls);
      return urls;
    } catch (e) {
      if (kDebugMode) {
        print('YouTubeMusicService: getAudioStreamUrls error: $e');
      }
      return const [];
    }
  }

  Future<void> prefetchAudioStreamUrls(String videoId) async {
    if (videoId.trim().isEmpty || _streamUrlCache.containsKey(videoId.trim())) {
      return;
    }
    try {
      await getAudioStreamUrls(videoId);
    } catch (e) {
      if (kDebugMode) {
        print('YouTubeMusicService: prefetchAudioStreamUrls error: $e');
      }
    }
  }

  static void _cacheStreamUrls(String videoId, List<String> urls) {
    if (urls.isEmpty) {
      return;
    }
    if (_streamUrlCache.length >= _maxCachedStreamUrlSets) {
      _streamUrlCache.remove(_streamUrlCache.keys.first);
    }
    _streamUrlCache[videoId] = urls;
  }

  Future<StreamManifest> _getBestManifest(String videoId) async {
    final id = VideoId(videoId);

    // Explicit list of clients avoiding the watch page to bypass 429 rate limiting.
    final attempts = <List<YoutubeApiClient>>[
      [YoutubeApiClient.androidVr],
      [YoutubeApiClient.androidSdkless],
      [YoutubeApiClient.ios],
      [YoutubeApiClient.androidMusic],
      [YoutubeApiClient.mweb],
      [YoutubeApiClient.tv],
    ];

    Object? lastError;
    for (final clients in attempts) {
      try {
        return await _yt.videos.streamsClient
            .getManifest(id, ytClients: clients, requireWatchPage: false)
            .timeout(const Duration(seconds: 12));
      } catch (error) {
        lastError = error;
      }
    }

    // Last resort fallback using the default standard flow
    try {
      return await _yt.videos.streamsClient
          .getManifest(id)
          .timeout(const Duration(seconds: 12));
    } catch (error) {
      lastError = error;
    }

    throw lastError;
  }

  // ---------------------------------------------------------------------------
  // Playlist
  // ---------------------------------------------------------------------------

  /// Fetch all tracks from a YouTube playlist.
  ///
  /// Accepts a full YouTube playlist URL or a raw playlist ID. For example:
  /// - `https://www.youtube.com/playlist?list=PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf`
  /// - `PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf`
  ///
  /// Returns up to [limit] tracks (defaults to 200).
  Future<List<YtMusicTrack>> getPlaylistTracks(
    String playlistUrl, {
    int limit = 200,
  }) async {
    _assertNotDisposed();

    final playlistId = _extractPlaylistId(playlistUrl);
    if (playlistId == null) {
      if (kDebugMode) {
        print('YouTubeMusicService: Invalid playlist URL: $playlistUrl');
      }
      return [];
    }

    try {
      final playlist = await _yt.playlists.get(PlaylistId(playlistId));
      if (kDebugMode) {
        print('YouTubeMusicService: Loading playlist '
            '"${playlist.title}" (${playlist.videoCount ?? "?"} videos)');
      }

      final tracks = <YtMusicTrack>[];

      await for (final video
          in _yt.playlists.getVideos(PlaylistId(playlistId))) {
        if (tracks.length >= limit) break;
        tracks.add(_playlistVideoToTrack(video));
      }

      return tracks;
    } catch (e) {
      if (kDebugMode) {
        print('YouTubeMusicService: getPlaylistTracks error: $e');
      }
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Video info & Related
  // ---------------------------------------------------------------------------

  /// Fetch metadata for a single YouTube video by [videoId].
  ///
  /// Returns `null` on failure.
  Future<YtMusicTrack?> getVideoInfo(String videoId) async {
    _assertNotDisposed();

    if (videoId.trim().isEmpty) return null;

    try {
      final video = await _yt.videos
          .get(VideoId(videoId))
          .timeout(const Duration(seconds: 10));
      return YtMusicTrack(
        videoId: video.id.value,
        title: video.title,
        artist: video.author,
        thumbnailUrl: video.thumbnails.highResUrl,
        duration: video.duration ?? Duration.zero,
      );
    } catch (e) {
      if (kDebugMode) {
        print('YouTubeMusicService: getVideoInfo error: $e');
      }
      return null;
    }
  }

  /// Fetch related tracks for a given [videoId] to populate an endless queue.
  Future<List<YtMusicTrack>> getRelatedTracks(String videoId) async {
    _assertNotDisposed();

    if (videoId.trim().isEmpty) return [];

    try {
      // Get the video instance first
      final video = await _yt.videos
          .get(VideoId(videoId))
          .timeout(const Duration(seconds: 10));
      // Use the videos client to get related videos
      final relatedVideos = await _yt.videos
          .getRelatedVideos(video)
          .timeout(const Duration(seconds: 12));
      if (relatedVideos == null) return [];

      final results = <YtMusicTrack>[];
      for (final video in relatedVideos) {
        if (results.length >= 20) break; // Limit to 20 related tracks
        
        // Skip overly long videos
        final duration = video.duration;
        if (duration != null && duration.inMinutes > 15) continue;
        
        results.add(YtMusicTrack(
          videoId: video.id.value,
          title: _cleanTitle(video.title),
          artist: video.author,
          thumbnailUrl: video.thumbnails.highResUrl,
          duration: video.duration ?? Duration.zero,
        ));
      }
      return results;
    } catch (e) {
      if (kDebugMode) {
        print('YouTubeMusicService: getRelatedTracks error: $e');
      }
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Convert a [Video] search result into a [YtMusicTrack].
  YtMusicTrack _videoToTrack(Video video) {
    return YtMusicTrack(
      videoId: video.id.value,
      title: _cleanTitle(video.title),
      artist: video.author,
      thumbnailUrl: video.thumbnails.highResUrl,
      duration: video.duration ?? Duration.zero,
    );
  }

  /// Convert a playlist [Video] into a [YtMusicTrack].
  YtMusicTrack _playlistVideoToTrack(Video video) {
    return YtMusicTrack(
      videoId: video.id.value,
      title: _cleanTitle(video.title),
      artist: video.author,
      thumbnailUrl: video.thumbnails.highResUrl,
      duration: video.duration ?? Duration.zero,
    );
  }

  /// Strip common noise from YouTube video titles (e.g. "(Official Video)").
  String _cleanTitle(String raw) {
    return raw
        .replaceAll(RegExp(r'\(Official\s*(Music\s*)?Video\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(Official\s*Audio\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[Official\s*(Music\s*)?Video\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[Official\s*Audio\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(Lyrics?\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[Lyrics?\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(Audio\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[Audio\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(HD\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(HQ\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }

  /// Extract a playlist ID from a YouTube URL or return the raw ID.
  ///
  /// Supports:
  /// - `https://www.youtube.com/playlist?list=PLxxx`
  /// - `https://music.youtube.com/playlist?list=PLxxx`
  /// - `PLxxx` (raw ID)
  String? _extractPlaylistId(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // URL format with ?list= parameter
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.queryParameters.containsKey('list')) {
      return uri.queryParameters['list'];
    }

    // Raw playlist ID (starts with PL, OL, RD, etc.)
    if (RegExp(r'^[A-Za-z0-9_-]{10,}$').hasMatch(trimmed)) {
      return trimmed;
    }

    return null;
  }
}
