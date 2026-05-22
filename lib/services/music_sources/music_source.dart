import '../../models/track.dart';

// ---------------------------------------------------------------------------
// Abstract Music Source Interface
// ---------------------------------------------------------------------------

/// Metadata about a stream that can be downloaded or played.
class SourceStreamInfo {
  const SourceStreamInfo({
    required this.url,
    required this.codec,
    required this.bitrateBps,
    required this.sizeBytes,
    required this.sourcePlatform,
    this.isLossless = false,
  });

  final String url;
  final String codec; // opus, aac, mp3, flac, etc.
  final int bitrateBps;
  final int sizeBytes;
  final String sourcePlatform;
  final bool isLossless;

  int get bitrateKbps => bitrateBps ~/ 1000;
}

/// Extended metadata for a track from a specific source.
class TrackMetadata {
  const TrackMetadata({
    required this.sourceId,
    required this.sourcePlatform,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.isrc,
    this.coverUrl,
    this.isDownloadable = false,
    this.isPlayable = false,
    this.requiresPremium = false,
  });

  final String sourceId;
  final String sourcePlatform;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String? isrc;
  final String? coverUrl;
  final bool isDownloadable;
  final bool isPlayable;
  final bool requiresPremium;
}

/// Abstract interface that every music source must implement.
///
/// New sources can be added by creating a class that extends this
/// and registering it with [MusicSourceManager].
abstract class MusicSource {
  /// Unique identifier for this source (e.g., 'spotify', 'youtube', 'local').
  String get sourceId;

  /// Human-readable name (e.g., 'Spotify', 'YouTube Music').
  String get displayName;

  /// Whether this source is currently available/connected.
  Future<bool> isAvailable();

  /// Search for tracks matching [query].
  Future<List<Track>> searchTracks(String query, {int limit = 20});

  /// Get detailed metadata for a specific track.
  Future<TrackMetadata?> getTrackMetadata(String trackId);

  /// Whether this track can be downloaded from this source.
  Future<bool> isDownloadable(String trackId);

  /// Get stream info for downloading/playing.
  ///
  /// Returns null if streaming is not available.
  Future<SourceStreamInfo?> getStreamInfo(String trackId);
}
