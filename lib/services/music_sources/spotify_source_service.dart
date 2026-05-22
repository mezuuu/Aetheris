import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

import '../../models/track.dart';
import '../spotify_service.dart';
import 'music_source.dart';

// ---------------------------------------------------------------------------
// Spotify Source Adapter
// ---------------------------------------------------------------------------

/// Wraps the existing [SpotifyService] (Client Credentials flow) as a
/// [MusicSource] for the unified search/play/download system.
///
/// When the user connects their Spotify account via PKCE (Phase 2), the
/// [SpotifyAuthService] token can be injected to unlock user-specific
/// endpoints (liked songs, playlists, etc.). For now this adapter uses
/// the existing Client Credentials search which works without user login.
class SpotifySourceService implements MusicSource {
  SpotifySourceService({required SpotifyService spotifyService})
      : _spotify = spotifyService;

  final SpotifyService _spotify;

  @override
  String get sourceId => 'spotify';

  @override
  String get displayName => 'Spotify';

  @override
  Future<bool> isAvailable() async => _spotify.hasCredentials;

  @override
  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return const [];

    try {
      final spotifyTracks = await _spotify.searchTracks(query, limit: limit);
      return spotifyTracks.map(_spotifyTrackToTrack).toList(growable: false);
    } catch (e) {
      if (kDebugMode) {
        print('SpotifySourceService: searchTracks error: $e');
      }
      return const [];
    }
  }

  @override
  Future<TrackMetadata?> getTrackMetadata(String trackId) async {
    // Spotify service doesn't have a getTrack(id) method exposed yet,
    // but we can build metadata from search results when available.
    return null;
  }

  @override
  Future<bool> isDownloadable(String trackId) async {
    // Spotify tracks are not directly downloadable (DRM).
    // Download requires fallback to YouTube/Deezer source.
    return false;
  }

  @override
  Future<SourceStreamInfo?> getStreamInfo(String trackId) async {
    // Spotify Web API does not provide direct audio streams.
    // Playback is handled via Spotify App Remote (Phase 3) or
    // YouTube fallback in the player controller.
    return null;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static Track _spotifyTrackToTrack(SpotifyTrack spotify) {
    return Track(
      id: 'spotify_${spotify.id}',
      title: spotify.title,
      artist: spotify.artist,
      album: spotify.album,
      format: 'AAC',
      bitDepth: 16,
      sampleRateKhz: 44,
      duration: spotify.duration,
      coverColors: const [
        Color(0xFF0F273F),
        Color(0xFF8C5B7D),
        Color(0xFF101422),
      ],
      lyrics: const [],
      streamUrl: null, // Spotify does not expose full streams
      artworkUrl: spotify.albumArtUrl,
      isrc: spotify.isrc,
    );
  }
}
