import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

import '../../models/track.dart';
import '../youtube_music_service.dart';
import 'music_source.dart';

// ---------------------------------------------------------------------------
// YouTube Source Adapter
// ---------------------------------------------------------------------------

/// Wraps the [YouTubeMusicService] as a [MusicSource].
///
/// This source provides both search results and direct audio streams
/// (which can be downloaded or played).
class YouTubeSourceService implements MusicSource {
  YouTubeSourceService({required YouTubeMusicService youtubeService})
      : _youtube = youtubeService;

  final YouTubeMusicService _youtube;

  @override
  String get sourceId => 'youtube';

  @override
  String get displayName => 'YouTube Music';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return const [];

    try {
      final ytTracks = await _youtube.searchTracks(query, limit: limit);
      return ytTracks.map(_ytTrackToTrack).toList(growable: false);
    } catch (e) {
      if (kDebugMode) {
        print('YouTubeSourceService: searchTracks error: $e');
      }
      return const [];
    }
  }

  @override
  Future<TrackMetadata?> getTrackMetadata(String trackId) async {
    // YouTube service doesn't expose a single track details fetcher easily yet,
    // but in a unified system, we usually resolve metadata from existing search results.
    return null;
  }

  @override
  Future<bool> isDownloadable(String trackId) async => true;

  @override
  Future<SourceStreamInfo?> getStreamInfo(String trackId) async {
    try {
      final streamUrl = await _youtube.getAudioStreamUrl(trackId);
      if (streamUrl == null) return null;

      return SourceStreamInfo(
        url: streamUrl,
        codec: 'opus', // YouTube predominantly serves OPUS/M4A
        bitrateBps: 160000, // Estimate
        sizeBytes: 0,
        sourcePlatform: sourceId,
        isLossless: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('YouTubeSourceService: getStreamInfo error: $e');
      }
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static Track _ytTrackToTrack(YtMusicTrack yt) {
    return Track(
      id: 'yt_${yt.videoId}',
      title: yt.title,
      artist: yt.artist,
      album: '', // YouTube search doesn't reliably return album
      format: 'OPUS',
      bitDepth: 16,
      sampleRateKhz: 48,
      duration: yt.duration,
      coverColors: const [
        Color(0xFF29112B),
        Color(0xFF0AB3B5),
        Color(0xFF101018),
      ],
      lyrics: const [],
      streamUrl: yt.audioStreamUrl,
      artworkUrl: yt.thumbnailUrl,
    );
  }
}
