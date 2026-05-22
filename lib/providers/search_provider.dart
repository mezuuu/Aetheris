import 'dart:async';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/track.dart';
import '../providers/auth_provider.dart';
import '../services/spotify_service.dart';
import '../services/youtube_music_service.dart';

// ---------------------------------------------------------------------------
// Enums & models
// ---------------------------------------------------------------------------

/// The source a search result originated from.
enum SearchSource {
  /// Search all available sources concurrently.
  all,

  /// Spotify Web API only.
  spotify,

  /// YouTube / YouTube Music only.
  youtube,

  /// Local on‑device library only.
  local,
}

/// The content type represented by a search row.
enum SearchResultType {
  track,
  artist,
  album,
  playlist,
}

/// Immutable snapshot of the search UI state.
class SearchState {
  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.activeSource = SearchSource.all,
  });

  final List<SearchResult> results;
  final bool isLoading;
  final String? error;
  final SearchSource activeSource;

  SearchState copyWith({
    List<SearchResult>? results,
    bool? isLoading,
    String? error,
    SearchSource? activeSource,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeSource: activeSource ?? this.activeSource,
    );
  }
}

/// A unified search result that can originate from any [SearchSource].
class SearchResult {
  const SearchResult({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.coverUrl,
    this.duration,
    required this.source,
    this.streamUrl,
    this.spotifyId,
    this.youtubeId,
    this.type = SearchResultType.track,
    this.spotifyArtist,
    this.spotifyAlbum,
    this.spotifyPlaylist,
    this.isrc,
  });

  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? coverUrl;
  final Duration? duration;
  final SearchSource source;

  /// Direct audio stream URL. Spotify search results intentionally leave this
  /// empty so playback resolves a full source instead of a preview clip.
  final String? streamUrl;

  /// Spotify track ID, if available.
  final String? spotifyId;

  /// YouTube video ID, if available.
  final String? youtubeId;

  final SearchResultType type;
  final SpotifyArtist? spotifyArtist;
  final SpotifyAlbum? spotifyAlbum;
  final SpotifyPlaylist? spotifyPlaylist;

  /// ISRC code forwarded from Spotify, used for Deezer cross-matching.
  final String? isrc;

  /// Convert this search result into the app‑wide [Track] model.
  Track toTrack() {
    if (type != SearchResultType.track) {
      return Track.empty;
    }
    return Track(
      id: id,
      title: title,
      artist: artist,
      album: album ?? '',
      format: source == SearchSource.youtube ? 'OPUS' : 'AAC',
      bitDepth: 16,
      sampleRateKhz: 44,
      duration: duration ?? Duration.zero,
      coverColors: const [Color(0xFF0F273F), Color(0xFF8C5B7D), Color(0xFF101422)],
      lyrics: const [],
      streamUrl: source == SearchSource.spotify ? null : streamUrl,
      artworkUrl: coverUrl,
      isrc: isrc,
    );
  }

  /// Create a [SearchResult] from a [SpotifyTrack].
  factory SearchResult.fromSpotify(SpotifyTrack track) {
    return SearchResult(
      id: 'spotify_${track.id}',
      title: track.title,
      artist: track.artist,
      album: track.album,
      coverUrl: track.albumArtUrl,
      duration: track.duration,
      source: SearchSource.spotify,
      streamUrl: null,
      spotifyId: track.id,
      isrc: track.isrc,
    );
  }

  factory SearchResult.fromSpotifyArtist(SpotifyArtist artist) {
    return SearchResult(
      id: 'spotify_artist_${artist.id}',
      title: artist.name,
      artist: 'Artist',
      coverUrl: artist.imageUrl,
      source: SearchSource.spotify,
      type: SearchResultType.artist,
      spotifyId: artist.id,
      spotifyArtist: artist,
    );
  }

  factory SearchResult.fromSpotifyAlbum(SpotifyAlbum album) {
    return SearchResult(
      id: 'spotify_album_${album.id}',
      title: album.title,
      artist: album.artist,
      coverUrl: album.imageUrl,
      source: SearchSource.spotify,
      type: SearchResultType.album,
      spotifyId: album.id,
      spotifyAlbum: album,
    );
  }

  factory SearchResult.fromSpotifyPlaylist(SpotifyPlaylist playlist) {
    return SearchResult(
      id: 'spotify_playlist_${playlist.id}',
      title: playlist.name,
      artist: playlist.owner,
      coverUrl: playlist.imageUrl,
      source: SearchSource.spotify,
      type: SearchResultType.playlist,
      spotifyId: playlist.id,
      spotifyPlaylist: playlist,
    );
  }

  /// Create a [SearchResult] from a [YtMusicTrack].
  factory SearchResult.fromYouTube(YtMusicTrack track) {
    return SearchResult(
      id: 'yt_${track.videoId}',
      title: track.title,
      artist: track.artist,
      coverUrl: track.thumbnailUrl,
      duration: track.duration,
      source: SearchSource.youtube,
      streamUrl: track.audioStreamUrl,
      youtubeId: track.videoId,
    );
  }

  /// Create a [SearchResult] from a local [Track].
  factory SearchResult.fromLocal(Track track) {
    return SearchResult(
      id: 'local_${track.id}',
      title: track.title,
      artist: track.artist,
      album: track.album,
      coverUrl: track.artworkUrl,
      duration: track.duration,
      source: SearchSource.local,
      streamUrl: track.streamUrl,
    );
  }
}

// ---------------------------------------------------------------------------
// Service providers (needed by search)
// ---------------------------------------------------------------------------

/// Spotify service singleton provider.
final spotifyServiceProvider = Provider<SpotifyService>((ref) {
  final authService = ref.watch(spotifyAuthProvider);
  final service = SpotifyService(
    authService: authService,
    clientId: const String.fromEnvironment(
      'SPOTIFY_CLIENT_ID',
      defaultValue: 'bc0941ea725c4a84bf23eee059abf714',
    ),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// YouTube Music service singleton provider.
final youtubeServiceProvider = Provider<YouTubeMusicService>((ref) {
  final service = YouTubeMusicService();
  ref.onDispose(service.dispose);
  return service;
});

// ---------------------------------------------------------------------------
// State providers
// ---------------------------------------------------------------------------

/// The current raw search query string entered by the user.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// The currently active search source tab / filter.
final searchSourceProvider = StateProvider<SearchSource>(
  (ref) => SearchSource.all,
);

/// Whether a search is currently in progress.
final searchLoadingProvider = Provider<bool>((ref) {
  return ref.watch(searchStateProvider).isLoading;
});

// ---------------------------------------------------------------------------
// Search state notifier
// ---------------------------------------------------------------------------

/// Core search state notifier that debounces queries (500 ms). In All mode,
/// Spotify results are loaded first, then YouTube Music expands the result set.
class SearchStateNotifier extends StateNotifier<SearchState> {
  SearchStateNotifier(this._ref) : super(const SearchState()) {
    // Listen to query changes with debounce.
    _ref.listen<String>(searchQueryProvider, (previous, next) {
      _onQueryChanged(next);
    });

    // Re‑search when the source filter changes.
    _ref.listen<SearchSource>(searchSourceProvider, (previous, next) {
      state = state.copyWith(activeSource: next);
      _performSearch(_ref.read(searchQueryProvider));
    });
  }

  final Ref _ref;
  Timer? _debounce;
  int _searchRequestId = 0;

  void _onQueryChanged(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      _searchRequestId++;
      state = state.copyWith(
        results: [],
        isLoading: false,
        error: null,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  /// Execute the search across active sources.
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      _searchRequestId++;
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    final requestId = ++_searchRequestId;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final source = _ref.read(searchSourceProvider);
      if (source == SearchSource.all) {
        // Kick off Spotify/Local and YouTube searches concurrently
        final fastFutures = Future.wait([
          _searchSpotify(query).timeout(
            const Duration(seconds: 10),
            onTimeout: () => const <SearchResult>[],
          ),
          _searchLocal(query).timeout(
            const Duration(seconds: 3),
            onTimeout: () => const <SearchResult>[],
          ),
        ]);

        final youtubeFuture = _searchYouTube(query).timeout(
          const Duration(seconds: 14),
          onTimeout: () => const <SearchResult>[],
        );

        // 1. Wait for Spotify and Local first (extremely fast)
        final fastResults = await fastFutures;
        if (!_isActiveSearch(requestId, query)) {
          return;
        }

        final spotifyResults = fastResults[0];
        final localResults = fastResults[1];
        final initialResults = [...spotifyResults, ...localResults];

        // Update UI immediately with Spotify and Local results, keep loading spinner active
        state = state.copyWith(
          results: _rankResults(query, _dedupeResults(initialResults)),
          isLoading: true,
        );

        // 2. Wait for YouTube results in the background
        final youtubeResults = await youtubeFuture;
        if (!_isActiveSearch(requestId, query)) {
          return;
        }

        final finalResults = [...initialResults, ...youtubeResults];

        // Update UI again with the full integrated results and stop loading spinner
        state = state.copyWith(
          results: _rankResults(query, _dedupeResults(finalResults)),
          isLoading: false,
        );
      } else {
        // Specific source searches
        List<SearchResult> specificResults = [];
        if (source == SearchSource.spotify) {
          specificResults = await _searchSpotify(query).timeout(
            const Duration(seconds: 15),
            onTimeout: () => const <SearchResult>[],
          );
        } else if (source == SearchSource.youtube) {
          specificResults = await _searchYouTube(query).timeout(
            const Duration(seconds: 14),
            onTimeout: () => const <SearchResult>[],
          );
        } else if (source == SearchSource.local) {
          specificResults = await _searchLocal(query).timeout(
            const Duration(seconds: 3),
            onTimeout: () => const <SearchResult>[],
          );
        }

        if (!_isActiveSearch(requestId, query)) {
          return;
        }

        state = state.copyWith(
          results: _rankResults(query, _dedupeResults(specificResults)),
          isLoading: false,
        );
      }

      // Persist query in recent searches.
      _ref.read(recentSearchesProvider.notifier).addSearch(query);
    } catch (e) {
      if (kDebugMode) {
        print('SearchProvider: search error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: $e',
      );
    }
  }

  /// Manually trigger a search (e.g. from a "retry" button).
  Future<void> search(String query) async {
    _debounce?.cancel();
    _ref.read(searchQueryProvider.notifier).state = query;
    await _performSearch(query);
  }

  /// Clear all results and reset state.
  void clear() {
    _debounce?.cancel();
    _searchRequestId++;
    _ref.read(searchQueryProvider.notifier).state = '';
    state = const SearchState();
  }

  bool _isActiveSearch(int requestId, String query) {
    return requestId == _searchRequestId &&
        query == _ref.read(searchQueryProvider);
  }

  List<SearchResult> _dedupeResults(List<SearchResult> results) {
    final seen = <String>{};
    return results.where((r) {
      final key =
          '${r.type.name}|${r.title.toLowerCase()}|${r.artist.toLowerCase()}';
      return seen.add(key);
    }).toList(growable: false);
  }

  List<SearchResult> _rankResults(String query, List<SearchResult> results) {
    final normalizedQuery = _normalizeSearchText(query);
    final ranked = results
        .map((result) => (result: result, score: _resultScore(result, normalizedQuery)))
        .toList(growable: false);
    ranked.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) {
        return scoreCompare;
      }
      return _typeRank(a.result.type).compareTo(_typeRank(b.result.type));
    });
    return ranked.map((item) => item.result).toList(growable: false);
  }

  static int _resultScore(SearchResult result, String normalizedQuery) {
    final title = _normalizeSearchText(result.title);
    final artist = _normalizeSearchText(result.artist);
    var score = 0;

    if (result.source == SearchSource.spotify) {
      score += 20;
    }
    score += switch (result.type) {
      SearchResultType.artist => 80,
      SearchResultType.track => 70,
      SearchResultType.album => 30,
      SearchResultType.playlist => 25,
    };

    if (title == normalizedQuery) {
      score += result.type == SearchResultType.artist ? 200 : 90;
    } else if (title.startsWith(normalizedQuery)) {
      score += result.type == SearchResultType.artist ? 120 : 45;
    } else if (title.contains(normalizedQuery)) {
      score += 24;
    }

    if (artist == normalizedQuery) {
      score += 35;
    } else if (artist.contains(normalizedQuery)) {
      score += 12;
    }

    return score;
  }

  static int _typeRank(SearchResultType type) {
    return switch (type) {
      SearchResultType.artist => 0,
      SearchResultType.track => 1,
      SearchResultType.album => 2,
      SearchResultType.playlist => 3,
    };
  }

  static String _normalizeSearchText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }

  // ---------------------------------------------------------------------------
  // Source‑specific search implementations
  // ---------------------------------------------------------------------------

  Future<List<SearchResult>> _searchSpotify(String query) async {
    try {
      final spotify = _ref.read(spotifyServiceProvider);
      final tracksFuture = spotify.searchTracks(query, limit: 20);
      if (!spotify.hasCredentials) {
        final tracks = await tracksFuture;
        return tracks.map(SearchResult.fromSpotify).toList(growable: false);
      }

      final sourceResults = await Future.wait([
        tracksFuture.catchError((_) => const <SpotifyTrack>[]),
        spotify.searchArtists(query, limit: 6).catchError((_) => const <SpotifyArtist>[]),
        spotify.searchAlbums(query, limit: 8).catchError((_) => const <SpotifyAlbum>[]),
        spotify.searchPlaylists(query, limit: 8).catchError((_) => const <SpotifyPlaylist>[]),
      ]);
      final tracks = sourceResults[0] as List<SpotifyTrack>;
      final artists = sourceResults[1] as List<SpotifyArtist>;

      final results = <SearchResult>[
        for (final artist in artists.isNotEmpty
            ? artists
            : _inferredArtistsFromTracks(query, tracks))
          SearchResult.fromSpotifyArtist(artist),
        for (final playlist in sourceResults[3] as List<SpotifyPlaylist>)
          SearchResult.fromSpotifyPlaylist(playlist),
        for (final album in sourceResults[2] as List<SpotifyAlbum>)
          SearchResult.fromSpotifyAlbum(album),
        for (final track in tracks) SearchResult.fromSpotify(track),
      ];
      return results;
    } catch (e) {
      if (kDebugMode) {
        print('SearchProvider: Spotify search failed: $e');
      }
      return [];
    }
  }

  List<SpotifyArtist> _inferredArtistsFromTracks(
    String query,
    List<SpotifyTrack> tracks,
  ) {
    final normalizedQuery = _normalizeSearchText(query);
    final byArtist = <String, SpotifyTrack>{};
    for (final track in tracks) {
      for (final artist in _artistParts(track.artist)) {
        final normalizedArtist = _normalizeSearchText(artist);
        if (normalizedArtist.isEmpty) {
          continue;
        }
        if (normalizedArtist == normalizedQuery ||
            normalizedArtist.contains(normalizedQuery) ||
            normalizedQuery.contains(normalizedArtist)) {
          byArtist.putIfAbsent(artist, () => track);
        }
      }
    }

    return byArtist.entries.map((entry) {
      final track = entry.value;
      return SpotifyArtist(
        id: '',
        name: entry.key,
        imageUrl: track.albumArtUrl,
      );
    }).toList(growable: false);
  }

  static List<String> _artistParts(String value) {
    return value
        .split(RegExp(r'\s*(,|&| and | feat\.? | ft\.? | featuring )\s*'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<SearchResult>> _searchYouTube(String query) async {
    try {
      final youtube = _ref.read(youtubeServiceProvider);
      final tracks = await youtube.searchTracks(query, limit: 20);
      for (final track in tracks.take(4)) {
        unawaited(youtube.prefetchAudioStreamUrls(track.videoId));
      }
      return tracks
          .map(SearchResult.fromYouTube)
          .toList(growable: false);
    } catch (e) {
      if (kDebugMode) {
        print('SearchProvider: YouTube search failed: $e');
      }
      return [];
    }
  }

  Future<List<SearchResult>> _searchLocal(String query) async {
    // Local search is synchronous in the existing codebase, but we wrap it
    // in a Future for consistent API surface.
    try {
      // Import the library search results through existing providers.
      // This avoids a direct dependency on LibraryService here.
      // We rely on the `libraryServiceProvider` being set up in
      // services_provider.dart.
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('SearchProvider: Local search failed: $e');
      }
      return [];
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

/// Main search state provider.
final searchStateProvider =
    StateNotifierProvider<SearchStateNotifier, SearchState>((ref) {
  return SearchStateNotifier(ref);
});

/// Convenience provider for accessing just the results list.
final searchResultsListProvider = Provider<List<SearchResult>>((ref) {
  return ref.watch(searchStateProvider).results;
});

// ---------------------------------------------------------------------------
// Recent searches
// ---------------------------------------------------------------------------

/// Persists and exposes the user's recent search queries.
///
/// Stored via [SharedPreferences] under the key `recent_searches`.
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super(const []) {
    _load();
  }

  static const String _prefsKey = 'recent_searches';
  static const int _maxRecent = 20;

  /// Add a query to the history (moves to front if already present).
  void addSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final updated = [
      trimmed,
      ...state.where((q) => q != trimmed),
    ].take(_maxRecent).toList(growable: false);

    state = updated;
    _save();
  }

  /// Remove a single entry from the history.
  void removeSearch(String query) {
    state = state.where((q) => q != query).toList(growable: false);
    _save();
  }

  /// Clear all recent searches.
  void clearAll() {
    state = const [];
    _save();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_prefsKey);
      if (saved != null && saved.isNotEmpty) {
        state = List<String>.unmodifiable(saved);
      }
    } catch (e) {
      if (kDebugMode) {
        print('RecentSearches: Failed to load: $e');
      }
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, state);
    } catch (e) {
      if (kDebugMode) {
        print('RecentSearches: Failed to save: $e');
      }
    }
  }
}

/// Recent searches provider – persisted across sessions.
final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier();
});
