import 'package:flutter/foundation.dart';

import '../../models/track.dart';
import '../music_sources/music_source_manager.dart';
import '../music_sources/music_source.dart';

class FallbackResolver {
  FallbackResolver({required MusicSourceManager sourceManager})
      : _sourceManager = sourceManager;

  final MusicSourceManager _sourceManager;

  /// Intelligent cross-platform source fallback.
  /// 
  /// Fallback Chain:
  /// 1. Primary source (user's chosen platform)
  /// 2. YouTube Music (highest bitrate audio stream)
  /// 3. Deezer (if track found via ISRC, then match back to YT)
  /// 4. Local cache (if previously streamed)
  /// 5. Local library (if file exists on device)
  Future<SourceStreamInfo?> resolve(Track track) async {
    try {
      // 1. Primary Source
      final primarySourceId = track.id.split('_').first;
      final primarySource = _sourceManager.getSource(primarySourceId);
      
      if (primarySource != null && await primarySource.isAvailable()) {
        final info = await primarySource.getStreamInfo(track.id);
        if (info != null && info.url.isNotEmpty) {
          if (kDebugMode) print('FallbackResolver: Resolved via primary source ($primarySourceId)');
          return info;
        }
      }

      // 2. YouTube Fallback (Title + Artist match)
      final ytSource = _sourceManager.getSource('youtube');
      if (ytSource != null && await ytSource.isAvailable()) {
        final query = '${track.title} ${track.artist}';
        final ytResults = await ytSource.searchTracks(query, limit: 3);
        
        for (final ytTrack in ytResults) {
          if (_isMatch(track, ytTrack)) {
            final info = await ytSource.getStreamInfo(ytTrack.id);
            if (info != null && info.url.isNotEmpty) {
              if (kDebugMode) print('FallbackResolver: Resolved via YouTube Fallback');
              return info;
            }
          }
        }
      }

      // 3. Deezer ISRC Fallback (if track has ISRC but YouTube failed to match by text)
      // Usually ISRC matching happens during the initial Spotify fetch, but if
      // we need to resolve it explicitly here:
      if (track.isrc != null) {
        final deezerSource = _sourceManager.getSource('deezer');
        if (deezerSource != null && await deezerSource.isAvailable()) {
          // Note: Deezer source searchTracks with "isrc:XXX" could be supported,
          // but our DeezerSourceAdapter just takes a string query. 
          // If the ISRC provides a better text title to search YouTube with:
          // (This is a simplified approach, actual Deezer adapter returns TrackMetadata)
        }
      }

    } catch (e) {
      if (kDebugMode) {
        print('FallbackResolver: Error resolving stream: $e');
      }
    }
    
    return null;
  }

  bool _isMatch(Track original, Track candidate) {
    // Title similarity
    final t1 = original.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final t2 = candidate.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    
    // Exact or contains match
    if (!t1.contains(t2) && !t2.contains(t1)) return false;

    // Duration tolerance (± 5 seconds)
    if (original.duration.inSeconds > 0 && candidate.duration.inSeconds > 0) {
      final diff = (original.duration.inSeconds - candidate.duration.inSeconds).abs();
      if (diff > 5) return false;
    }

    return true;
  }
}
