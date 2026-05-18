import 'package:flutter/foundation.dart';
import '../models/track.dart';

/// Service untuk manage library lokal dan scanning
class LibraryService {
  LibraryService();

  final List<Track> _cachedLibrary = [];

  List<Track> get library => List.unmodifiable(_cachedLibrary);
  int get librarySize => _cachedLibrary.length;

  /// Load library dari cache atau database
  Future<List<Track>> loadLibrary() async {
    try {
      // TODO: Load dari Isar database
      // Untuk sekarang, return cached
      return _cachedLibrary;
    } catch (e) {
      if (kDebugMode) {
        print('LibraryService: Failed to load library: $e');
      }
      rethrow;
    }
  }

  /// Scan folder untuk musik lokal
  Future<void> scanFolder(String folderPath) async {
    try {
      // TODO: Implement folder scanning
      // Gunakan path_provider dan file system API
      if (kDebugMode) {
        print('LibraryService: Scanning $folderPath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('LibraryService: Scan failed: $e');
      }
      rethrow;
    }
  }

  /// Add track ke library
  Future<void> addTrack(Track track) async {
    try {
      if (!_cachedLibrary.any((t) => t.id == track.id)) {
        _cachedLibrary.add(track);
        // TODO: Save ke database
      }
    } catch (e) {
      if (kDebugMode) {
        print('LibraryService: Failed to add track: $e');
      }
      rethrow;
    }
  }

  /// Search tracks
  List<Track> searchTracks(String query) {
    if (query.isEmpty) return _cachedLibrary;

    final lowerQuery = query.toLowerCase();
    return _cachedLibrary
        .where((track) =>
            track.title.toLowerCase().contains(lowerQuery) ||
            track.artist.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get albums
  List<String> getAlbums() {
    return _cachedLibrary
        .map((t) => t.album)
        .toSet()
        .toList();
  }

  /// Get artists
  List<String> getArtists() {
    return _cachedLibrary
        .map((t) => t.artist)
        .toSet()
        .toList();
  }

  /// Get tracks by artist
  List<Track> getTracksByArtist(String artist) {
    return _cachedLibrary
        .where((track) => track.artist == artist)
        .toList();
  }

  /// Get tracks by album
  List<Track> getTracksByAlbum(String album) {
    return _cachedLibrary
        .where((track) => track.album == album)
        .toList();
  }

  Future<void> dispose() async {
    _cachedLibrary.clear();
  }
}
