import 'package:flutter/foundation.dart';

import '../../models/track.dart';
import '../deezer_service.dart';
import 'music_source.dart';

// ---------------------------------------------------------------------------
// Deezer Source Adapter
// ---------------------------------------------------------------------------

/// Wraps the [DeezerService] as a [MusicSource].
///
/// Deezer is primarily used for ISRC cross-matching and metadata augmentation.
/// It does not provide full audio streams (only 30s previews).
class DeezerSourceService implements MusicSource {
  DeezerSourceService({required DeezerService deezerService})
      : _deezer = deezerService;

  final DeezerService _deezer;

  @override
  String get sourceId => 'deezer';

  @override
  String get displayName => 'Deezer';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return const [];

    try {
      final deezerTracks = await _deezer.searchTracks(query, limit: limit);
      return deezerTracks.map(_deezerTrackToTrack).toList(growable: false);
    } catch (e) {
      if (kDebugMode) {
        print('DeezerSourceService: searchTracks error: $e');
      }
      return const [];
    }
  }

  @override
  Future<TrackMetadata?> getTrackMetadata(String trackId) async {
    try {
      final id = int.tryParse(trackId.replaceFirst('deezer_', ''));
      if (id == null) return null;

      final track = await _deezer.getTrackDetails(id);
      if (track == null) return null;

      return TrackMetadata(
        sourceId: track.id.toString(),
        sourcePlatform: sourceId,
        title: track.title,
        artist: track.artist,
        album: track.album,
        duration: track.duration,
        coverUrl: track.coverUrl,
        isrc: track.isrc,
        isDownloadable: false, // Deezer only gives previews
        isPlayable: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('DeezerSourceService: getTrackMetadata error: $e');
      }
      return null;
    }
  }

  @override
  Future<bool> isDownloadable(String trackId) async => false;

  @override
  Future<SourceStreamInfo?> getStreamInfo(String trackId) async {
    // Deezer public API does not provide full streams, only previews.
    return null;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static Track _deezerTrackToTrack(DeezerTrack deezer) {
    return Track(
      id: 'deezer_${deezer.id}',
      title: deezer.title,
      artist: deezer.artist,
      album: deezer.album,
      format: 'MP3',
      bitDepth: 16,
      sampleRateKhz: 44,
      duration: deezer.duration,
      coverColors: const [],
      lyrics: const [],
      streamUrl: null, // Preview only, not suitable for full playback
      artworkUrl: deezer.coverUrl,
      isrc: deezer.isrc,
    );
  }
}
