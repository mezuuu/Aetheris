import 'package:flutter/foundation.dart';
import '../models/track.dart';

/// Download service with smart fallback chain
/// Priority: Spotify → Deezer → Apple Music → YouTube
class DownloadService {
  DownloadService({
    this.dailyDownloadLimit = 50,
  });

  final int dailyDownloadLimit;
  int _downloadsToday = 0;
  DateTime? _lastResetDate;

  /// Check if download limit reached
  bool get isDownloadLimitReached {
    _checkAndResetDailyLimit();
    return _downloadsToday >= dailyDownloadLimit;
  }

  /// Remaining downloads for today
  int get remainingDownloads {
    _checkAndResetDailyLimit();
    return dailyDownloadLimit - _downloadsToday;
  }

  void _checkAndResetDailyLimit() {
    final today = DateTime.now();
    final lastReset = _lastResetDate;

    if (lastReset == null ||
        lastReset.year != today.year ||
        lastReset.month != today.month ||
        lastReset.day != today.day) {
      _downloadsToday = 0;
      _lastResetDate = today;
    }
  }

  /// Download with smart fallback chain
  Future<bool> downloadTrack(Track track) async {
    try {
      if (isDownloadLimitReached) {
        throw Exception('Daily download limit reached (50 songs/day)');
      }

      // Try fallback chain
      bool success = false;

      // 1. Try Spotify FLAC
      if (!success) {
        success = await _downloadFromSpotify(track);
      }

      // 2. Try Deezer
      if (!success) {
        success = await _downloadFromDeezer(track);
      }

      // 3. Try Apple Music
      if (!success) {
        success = await _downloadFromAppleMusic(track);
      }

      // 4. Try YouTube
      if (!success) {
        success = await _downloadFromYouTube(track);
      }

      if (success) {
        _downloadsToday++;
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('DownloadService: Download failed: $e');
      }
      rethrow;
    }
  }

  /// Download from Spotify (FLAC if available)
  Future<bool> _downloadFromSpotify(Track track) async {
    try {
      if (kDebugMode) {
        print('DownloadService: Trying Spotify for ${track.title}');
      }

      // TODO: Implement Spotify download logic
      // Use Spotify Web API to find track and download

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('DownloadService: Spotify download failed: $e');
      }
      return false;
    }
  }

  /// Download from Deezer
  Future<bool> _downloadFromDeezer(Track track) async {
    try {
      if (kDebugMode) {
        print('DownloadService: Trying Deezer for ${track.title}');
      }

      // TODO: Implement Deezer download logic

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('DownloadService: Deezer download failed: $e');
      }
      return false;
    }
  }

  /// Download from Apple Music (ALAC/AAC lossless)
  Future<bool> _downloadFromAppleMusic(Track track) async {
    try {
      if (kDebugMode) {
        print('DownloadService: Trying Apple Music for ${track.title}');
      }

      // TODO: Implement Apple Music download logic

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('DownloadService: Apple Music download failed: $e');
      }
      return false;
    }
  }

  /// Download from YouTube (fallback)
  Future<bool> _downloadFromYouTube(Track track) async {
    try {
      if (kDebugMode) {
        print('DownloadService: Trying YouTube for ${track.title}');
      }

      // TODO: Implement YouTube download using yt-dlp
      // Use FFmpeg for audio extraction and encoding

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('DownloadService: YouTube download failed: $e');
      }
      return false;
    }
  }

  /// Bulk download multiple tracks
  Future<Map<String, bool>> bulkDownload(List<Track> tracks) async {
    try {
      final results = <String, bool>{};

      for (final track in tracks) {
        if (isDownloadLimitReached) {
          results[track.id] = false;
        } else {
          results[track.id] = await downloadTrack(track);
        }
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('DownloadService: Bulk download failed: $e');
      }
      rethrow;
    }
  }

  /// Import Spotify playlist
  Future<List<Track>> importSpotifyPlaylist(String playlistUrl) async {
    try {
      if (kDebugMode) {
        print('DownloadService: Importing Spotify playlist: $playlistUrl');
      }

      // TODO: Extract playlist ID from URL
      // Use Spotify API to fetch all tracks from playlist
      // Return list of tracks

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('DownloadService: Playlist import failed: $e');
      }
      rethrow;
    }
  }

  /// Import YouTube Music playlist
  Future<List<Track>> importYouTubeMusicPlaylist(String playlistUrl) async {
    try {
      if (kDebugMode) {
        print('DownloadService: Importing YouTube Music playlist: $playlistUrl');
      }

      // TODO: Implement YouTube Music playlist import

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('DownloadService: YouTube Music playlist import failed: $e');
      }
      rethrow;
    }
  }
}
