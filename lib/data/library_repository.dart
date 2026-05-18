import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/album.dart';
import '../models/track.dart';
import 'demo_library.dart';

class LibrarySnapshot {
  const LibrarySnapshot({required this.tracks, required this.albums});

  final List<Track> tracks;
  final List<Album> albums;
}

abstract interface class LibraryRepository {
  List<Track> get tracks;
  List<Album> get albums;

  Future<LibrarySnapshot> refresh();
  Track? findTrackById(String id);
  List<Track> searchTracks(String query);
}

class DemoLibraryRepository implements LibraryRepository {
  const DemoLibraryRepository();

  @override
  List<Track> get tracks => demoTracks;

  @override
  List<Album> get albums => demoAlbums;

  @override
  Future<LibrarySnapshot> refresh() async {
    return LibrarySnapshot(tracks: tracks, albums: albums);
  }

  @override
  Track? findTrackById(String id) {
    return _findTrackById(tracks, id);
  }

  @override
  List<Track> searchTracks(String query) {
    return _searchTracks(tracks, query);
  }
}

class RemoteLibraryRepository implements LibraryRepository {
  RemoteLibraryRepository({
    required this.catalogUri,
    http.Client? client,
    this.fallback = const DemoLibraryRepository(),
  }) : _client = client ?? http.Client();

  final Uri catalogUri;
  final http.Client _client;
  final LibraryRepository fallback;

  List<Track>? _tracks;
  List<Album>? _albums;

  @override
  List<Track> get tracks => _tracks ?? fallback.tracks;

  @override
  List<Album> get albums => _albums ?? fallback.albums;

  @override
  Future<LibrarySnapshot> refresh() async {
    final response = await _client
        .get(catalogUri)
        .timeout(const Duration(seconds: 12));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LibraryRepositoryException(
        'Catalog request failed with HTTP ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw const LibraryRepositoryException(
        'Catalog response must be a JSON object.',
      );
    }

    final tracks = _parseTracks(decoded['tracks']);
    if (tracks.isEmpty) {
      throw const LibraryRepositoryException(
        'Catalog does not contain tracks.',
      );
    }

    final albums = _parseAlbums(decoded['albums'], tracks);

    _tracks = List<Track>.unmodifiable(tracks);
    _albums = List<Album>.unmodifiable(albums);

    return LibrarySnapshot(tracks: this.tracks, albums: this.albums);
  }

  @override
  Track? findTrackById(String id) {
    return _findTrackById(tracks, id);
  }

  @override
  List<Track> searchTracks(String query) {
    return _searchTracks(tracks, query);
  }

  static List<Track> _parseTracks(Object? value) {
    if (value is! List) {
      return const [];
    }

    return List<Track>.unmodifiable(
      value
          .whereType<Map>()
          .map(
            (trackJson) => Track.fromJson(Map<String, Object?>.from(trackJson)),
          )
          .where((track) => track.id.isNotEmpty && track.title.isNotEmpty)
          .where((track) => track.hasStream)
          .toList(growable: false),
    );
  }

  static List<Album> _parseAlbums(Object? value, List<Track> tracks) {
    if (value is List) {
      final albums = value
          .whereType<Map>()
          .map(
            (albumJson) =>
                _albumFromJson(Map<String, Object?>.from(albumJson), tracks),
          )
          .whereType<Album>()
          .toList(growable: false);

      if (albums.isNotEmpty) {
        return List<Album>.unmodifiable(albums);
      }
    }

    return _groupAlbumsFromTracks(tracks);
  }

  static Album? _albumFromJson(Map<String, Object?> json, List<Track> tracks) {
    final id = (json['id'] as String?)?.trim() ?? '';
    final title = (json['title'] as String?)?.trim() ?? '';
    final artist = (json['artist'] as String?)?.trim() ?? '';
    final description = (json['description'] as String?)?.trim() ?? '';
    final trackIds = json['trackIds'];

    if (id.isEmpty || title.isEmpty || trackIds is! List) {
      return null;
    }

    final albumTracks = [
      for (final trackId in trackIds.whereType<String>())
        if (_findTrackById(tracks, trackId) case final track?) track,
    ];

    if (albumTracks.isEmpty) {
      return null;
    }

    return Album(
      id: id,
      title: title,
      artist: artist.isEmpty ? albumTracks.first.artist : artist,
      description: description,
      tracks: List<Track>.unmodifiable(albumTracks),
    );
  }

  static List<Album> _groupAlbumsFromTracks(List<Track> tracks) {
    final grouped = <String, List<Track>>{};
    for (final track in tracks) {
      grouped.putIfAbsent(track.album, () => []).add(track);
    }

    return List<Album>.unmodifiable(
      grouped.entries.map((entry) {
        final albumTracks = List<Track>.unmodifiable(entry.value);
        final firstTrack = albumTracks.first;
        return Album(
          id: _slug(entry.key),
          title: entry.key,
          artist: firstTrack.artist,
          description: 'Online album from Aetheris catalog.',
          tracks: albumTracks,
        );
      }),
    );
  }

  static String _slug(String value) {
    final normalized = value.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '-',
    );
    return normalized.replaceAll(RegExp(r'^-+|-+$'), '');
  }
}

class LibraryRepositoryException implements Exception {
  const LibraryRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'LibraryRepositoryException: $message';
}

Track? _findTrackById(List<Track> tracks, String id) {
  for (final track in tracks) {
    if (track.id == id) {
      return track;
    }
  }
  return null;
}

List<Track> _searchTracks(List<Track> tracks, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return List<Track>.unmodifiable(tracks);
  }

  final matches = tracks.where((track) {
    return track.title.toLowerCase().contains(normalizedQuery) ||
        track.artist.toLowerCase().contains(normalizedQuery) ||
        track.album.toLowerCase().contains(normalizedQuery) ||
        track.format.toLowerCase().contains(normalizedQuery);
  });

  return List<Track>.unmodifiable(matches);
}
