import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/track.dart';
import 'music_source.dart';

// ---------------------------------------------------------------------------
// Unified Music Source Manager
// ---------------------------------------------------------------------------

/// Orchestrates multiple [MusicSource] implementations.
///
/// This manager acts as the single point of entry for resolving tracks,
/// searching across multiple platforms, and acquiring audio streams
/// with built-in fallback logic.
class MusicSourceManager {
  MusicSourceManager({Iterable<MusicSource>? sources}) {
    if (sources != null) {
      for (final source in sources) {
        registerSource(source);
      }
    }
  }

  final Map<String, MusicSource> _sources = {};

  /// Register a new music source adapter.
  void registerSource(MusicSource source) {
    _sources[source.sourceId] = source;
  }

  /// Get a specific source by its ID.
  MusicSource? getSource(String sourceId) => _sources[sourceId];

  /// Search across all registered sources concurrently.
  Future<List<Track>> searchAll(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return const [];

    final futures = _sources.values.map((source) async {
      try {
        if (await source.isAvailable()) {
          return await source.searchTracks(query, limit: limit);
        }
      } catch (e) {
        if (kDebugMode) {
          print('MusicSourceManager: search failed on ${source.sourceId}: $e');
        }
      }
      return <Track>[];
    });

    final results = await Future.wait(futures);
    final allTracks = results.expand((tracks) => tracks).toList();
    
    // Deduplicate by title and artist combination
    final seen = <String>{};
    return allTracks.where((t) {
      final key = '${t.title.toLowerCase()}|${t.artist.toLowerCase()}';
      return seen.add(key);
    }).toList(growable: false);
  }

  /// Resolves the best available stream for a given [track].
  ///
  /// Fallback logic:
  /// 1. Tries the track's primary source platform.
  /// 2. If the primary source fails (or doesn't provide streams like Spotify),
  ///    falls back to YouTube Music.
  Future<SourceStreamInfo?> resolveBestStream(Track track) async {
    // Track IDs are typically formatted as 'sourceId_actualId'
    final primarySourceId = track.id.split('_').first;
    var source = _sources[primarySourceId];
    
    if (source != null && await source.isAvailable()) {
      final info = await source.getStreamInfo(track.id);
      if (info != null) return info;
    }

    // Fallback: Try resolving via YouTube Music
    final yt = _sources['youtube'];
    if (yt != null && yt.sourceId != primarySourceId && await yt.isAvailable()) {
      // Query exactly by Artist + Title to find the closest match
      final ytResults = await yt.searchTracks('${track.artist} ${track.title}', limit: 3);
      if (ytResults.isNotEmpty) {
        // Return the highest quality stream from the first result
        return await yt.getStreamInfo(ytResults.first.id);
      }
    }

    return null;
  }
}
