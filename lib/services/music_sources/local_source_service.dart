import '../../services/library_service.dart';
import '../../models/track.dart';
import 'music_source.dart';

// ---------------------------------------------------------------------------
// Local Source Adapter
// ---------------------------------------------------------------------------

/// Wraps [LibraryService] as a [MusicSource] so local on-device
/// music can participate in the unified search system.
class LocalSourceService implements MusicSource {
  LocalSourceService({required LibraryService libraryService})
      : _service = libraryService;

  final LibraryService _service;

  @override
  String get sourceId => 'local';

  @override
  String get displayName => 'Local Library';

  @override
  Future<bool> isAvailable() async => _service.librarySize > 0;

  @override
  Future<List<Track>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return const [];
    final results = _service.searchTracks(query);
    return results.take(limit).toList(growable: false);
  }

  @override
  Future<TrackMetadata?> getTrackMetadata(String trackId) async {
    final track = _service.library.where((t) => t.id == trackId).firstOrNull;
    if (track == null) return null;

    return TrackMetadata(
      sourceId: track.id,
      sourcePlatform: sourceId,
      title: track.title,
      artist: track.artist,
      album: track.album,
      duration: track.duration,
      coverUrl: track.artworkUrl,
      isDownloadable: false, // Already local
      isPlayable: track.hasStream,
    );
  }

  @override
  Future<bool> isDownloadable(String trackId) async => false;

  @override
  Future<SourceStreamInfo?> getStreamInfo(String trackId) async {
    final track = _service.library.where((t) => t.id == trackId).firstOrNull;
    if (track == null || !track.hasStream) return null;

    return SourceStreamInfo(
      url: track.streamUrl!,
      codec: track.format.toLowerCase(),
      bitrateBps: track.isLossless ? 1411000 : 320000,
      sizeBytes: 0, // Unknown for local files
      sourcePlatform: sourceId,
      isLossless: track.isLossless,
    );
  }
}
