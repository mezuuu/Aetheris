import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:palette_generator/palette_generator.dart';

import '../data/library_repository.dart';
import '../data/local_music_scanner.dart';
import '../models/album.dart';
import '../models/track.dart';
import '../services/audio_stream_cache_service.dart';
import '../services/audio_playback_engine.dart';
import '../services/lossless_stream_service.dart';
import '../services/lyrics_service.dart';
import '../services/playback_notification_service.dart';
import '../services/playback_history_service.dart';
import '../services/deezer_service.dart';
import '../services/youtube_music_service.dart';

class PlayerController extends ChangeNotifier {
  PlayerController({
    LibraryRepository libraryRepository = const DemoLibraryRepository(),
    AudioPlaybackEngine? audioEngine,
    this.historyService,
    this.onTrackPlayed,
    bool startPlaybackClock = true,
    bool autoPlay = true,
    bool preloadOnIdle = true,
    Duration initialPosition = Duration.zero,
    String? initialTrackId,
  }) : _libraryRepository = libraryRepository,
       _preloadOnIdle = preloadOnIdle,
       _audioEngine =
           startPlaybackClock
               ? audioEngine ?? JustAudioPlaybackEngine()
               : audioEngine {
    final loadedTracks = List<Track>.unmodifiable(libraryRepository.tracks);
    library.addAll(loadedTracks);
    _baseAlbums.addAll(libraryRepository.albums);

    if (initialTrackId != null && library.isNotEmpty) {
      final localTrack = _findTrackIn(library, initialTrackId);
      if (localTrack != null) {
        _currentTrack = localTrack;
        queue.addAll(library.where((t) => t.id != _currentTrack.id));
      } else if (initialTrackId.startsWith('yt_')) {
        _currentTrack = Track(
          id: initialTrackId,
          title: 'Loading last track...',
          artist: '',
          album: '',
          format: 'YT',
          bitDepth: 16,
          sampleRateKhz: 44,
          duration: Duration.zero,
          coverColors: const [Color(0xFF0F273F), Color(0xFF8C5B7D), Color(0xFF101422)],
          lyrics: [],
        );
        _fetchAndSetInitialYtTrack(initialTrackId);
      } else {
        _currentTrack = library.first;
        queue.addAll(library.where((t) => t.id != _currentTrack.id));
      }
    } else {
      _currentTrack = library.isNotEmpty ? library.first : Track.empty;
      queue.addAll(library.where((t) => t.id != _currentTrack.id));
    }
    
    _isPlaying = autoPlay && _currentTrack.id != 'empty';
    _position = _clampPosition(initialPosition, _currentTrack);

    _attachAudioEngine();
    _notificationService.setActionHandler(_handleNotificationAction);

    if (_currentTrack.hasStream && _currentTrack.id != 'empty') {
      if (autoPlay) {
        unawaited(_loadAndPlayCurrent(restart: true));
      } else if (preloadOnIdle) {
        // Preload if not auto playing but track exists
        unawaited(_prepareCurrentTrack());
      }
    }
  }

  final LibraryRepository _libraryRepository;
  LibraryRepository get libraryRepository => _libraryRepository;
  final bool _preloadOnIdle;
  final AudioPlaybackEngine? _audioEngine;
  final PlaybackHistoryService? historyService;
  final void Function(Track track, Duration position)? onTrackPlayed;
  final LyricsService _lyricsPrefetchService = LyricsService();
  final LosslessStreamService _losslessStreamService =
      const LosslessStreamService();
  final AudioStreamCacheService _streamCacheService = AudioStreamCacheService();
  final PlaybackNotificationService _notificationService =
      PlaybackNotificationService();
  final List<StreamSubscription<Object?>> _audioSubscriptions = [];

  final List<Track> library = [];
  final List<Album> _baseAlbums = [];

  List<Album> get albums {
    final likedTracks = library.where((t) => _likedIds.contains(t.id)).toList();
    if (likedTracks.isEmpty) return _baseAlbums;
    return [
      Album(
        id: 'liked_songs',
        title: 'Liked Songs',
        artist: 'You',
        description: 'Your favorite tracks.',
        tracks: likedTracks,
      ),
      ..._baseAlbums,
    ];
  }

  /// Mutable live queue. The current track is intentionally excluded.
  final List<Track> queue = [];

  /// Tracks that have already been played.
  final List<Track> history = [];

  final List<Track> _playlistContext = [];

  final Set<String> _likedIds = {};
  final Set<String> _blacklistedIds = {};

  late Track _currentTrack;
  late bool _isPlaying;
  int _selectedIndex = 0;
  late Duration _position;
  Duration? _actualDuration;
  bool _isBuffering = false;
  bool _isLibraryLoading = false;
  String? _playbackError;
  String? _libraryError;
  String? _loadedTrackKey;
  String? _loadingTrackKey;
  Future<void>? _loadingFuture;
  int _loadRequestId = 0;
  int _playbackRequestId = 0;
  bool _isDisposed = false;
  bool _isFetchingRelated = false;
  bool _isRecoveringOnlineSource = false;
  int _onlineRecoveryAttempts = 0;
  DateTime _lastNotificationSync = DateTime.fromMillisecondsSinceEpoch(0);
  final Set<String> _failedOnlineTrackIds = {};

  Track get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  bool get isLibraryLoading => _isLibraryLoading;
  int get selectedIndex => _selectedIndex;
  Duration get position => _position;
  Duration get actualDuration => _actualDuration ?? _currentTrack.duration;
  String? get playbackError => _playbackError;
  String? get libraryError => _libraryError;

  bool _isShuffleEnabled = false;
  int _repeatMode = 0; // 0 = off, 1 = all, 2 = one
  bool _autoPlayEndless = true;

  bool get isShuffleEnabled => _isShuffleEnabled;
  int get repeatMode => _repeatMode;
  bool get autoPlayEndless => _autoPlayEndless;

  set autoPlayEndless(bool value) {
    if (_autoPlayEndless != value) {
      _autoPlayEndless = value;
      if (value) {
        unawaited(_checkAndPopulateQueue());
      }
    }
  }

  Duration get remaining {
    final remaining = actualDuration - _position;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double get progress {
    final ms = actualDuration.inMilliseconds;
    if (ms <= 0) {
      return 0;
    }
    return (_position.inMilliseconds / ms).clamp(0.0, 1.0).toDouble();
  }

  bool isLiked(Track track) => _likedIds.contains(track.id);

  void toggleLike(Track track) {
    if (_likedIds.contains(track.id)) {
      _likedIds.remove(track.id);
    } else {
      _likedIds.add(track.id);
    }
    _safeNotifyListeners();
  }

  /// Blacklist a track so it never appears in auto-generated queue.
  bool isBlacklisted(Track track) => _blacklistedIds.contains(track.id);

  void blacklistTrack(Track track) {
    _blacklistedIds.add(track.id);
    // Also remove from current queue if present
    queue.removeWhere((t) => t.id == track.id);
    _safeNotifyListeners();
  }

  void unblacklistTrack(Track track) {
    _blacklistedIds.remove(track.id);
    _safeNotifyListeners();
  }

  Future<void> refreshLibrary() async {
    _isLibraryLoading = true;
    _libraryError = null;
    _safeNotifyListeners();

    try {
      final snapshot = await _libraryRepository.refresh();
      if (snapshot.tracks.isEmpty) {
        throw const LibraryRepositoryException(
          'Catalog does not contain tracks.',
        );
      }

      final currentId = _currentTrack.id;
      library
        ..clear()
        ..addAll(snapshot.tracks);
      _baseAlbums
        ..clear()
        ..addAll(snapshot.albums);

      _currentTrack = _findTrackIn(library, currentId) ?? (library.isNotEmpty ? library.first : Track.empty);
      queue
        ..clear()
        ..addAll(library.where((track) => track.id != _currentTrack.id));
      history.removeWhere((track) => _findTrackIn(library, track.id) == null);
      _actualDuration = null;
      _position = _clampPosition(_position, _currentTrack);
      if (_preloadOnIdle && !_isPlaying && _currentTrack.hasStream) {
        unawaited(_prepareCurrentTrack());
      }
    } catch (error) {
      _libraryError = error.toString();
    } finally {
      _isLibraryLoading = false;
      _safeNotifyListeners();
    }
  }

  List<Track> searchLibrary(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return List<Track>.unmodifiable(library);
    }

    final matches = library.where((track) {
      return track.title.toLowerCase().contains(normalizedQuery) ||
          track.artist.toLowerCase().contains(normalizedQuery) ||
          track.album.toLowerCase().contains(normalizedQuery) ||
          track.format.toLowerCase().contains(normalizedQuery);
    });

    return List<Track>.unmodifiable(matches);
  }

  void selectTab(int index) {
    if (index < 0 || _selectedIndex == index) {
      return;
    }
    _selectedIndex = index;
    _safeNotifyListeners();
  }

  void playTrack(Track track) {
    _playlistContext.clear();
    _playlistContext.addAll(library);
    final playableTrack = _preferLocalLosslessTrack(track);
    final isSameTrack = _sameTrack(_currentTrack, playableTrack);
    if (!isSameTrack) {
      _moveCurrentToHistory();
    }

    if (_findTrackIn(library, playableTrack.id) == null) {
      library.add(playableTrack);
    }

    _beginTrackTransition(playableTrack);
    _currentTrack = playableTrack;
    _resetOnlineRecoveryState();
    _actualDuration = playableTrack.duration > Duration.zero
        ? playableTrack.duration
        : null;
    _rebuildSmartQueueForCurrent();
    _position = Duration.zero;
    _isPlaying = true;
    _playbackError = null;
    _safeNotifyListeners();
    unawaited(_prefetchLyricsFor(playableTrack));
    unawaited(
      _loadAndPlayCurrent(restart: !isSameTrack, forceSeek: isSameTrack),
    );
    unawaited(_checkAndPopulateQueue());
  }

  bool playTrackById(String id) {
    final track = _findTrackIn(library, id);
    if (track == null) {
      return false;
    }
    playTrack(track);
    return true;
  }

  void setQueue(Iterable<Track> tracks, {Track? startAt}) {
    final nextQueue = List<Track>.of(tracks);
    if (nextQueue.isEmpty) {
      throw ArgumentError.value(tracks, 'tracks', 'Queue cannot be empty.');
    }

    _playlistContext.clear();
    _playlistContext.addAll(nextQueue);

    final firstTrack = startAt ?? nextQueue.first;
    if (_findTrackIn(nextQueue, firstTrack.id) == null) {
      throw ArgumentError.value(
        startAt,
        'startAt',
        'Track must exist in queue.',
      );
    }

    final isSameTrack = _sameTrack(_currentTrack, firstTrack);
    if (!isSameTrack) {
      _moveCurrentToHistory();
    }

    _beginTrackTransition(firstTrack);
    _currentTrack = firstTrack;
    _resetOnlineRecoveryState();
    _actualDuration = firstTrack.duration > Duration.zero
        ? firstTrack.duration
        : null;
    queue
      ..clear()
      ..addAll(nextQueue.where((track) => track.id != firstTrack.id));
    _position = Duration.zero;
    _isPlaying = true;
    _playbackError = null;
    _safeNotifyListeners();
    unawaited(_prefetchLyricsFor(firstTrack));
    unawaited(
      _loadAndPlayCurrent(restart: !isSameTrack, forceSeek: isSameTrack),
    );
    unawaited(_checkAndPopulateQueue());
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    _safeNotifyListeners();

    final audioEngine = _audioEngine;
    if (audioEngine == null) {
      return;
    }
    if (!_canResolveForPlayback(_currentTrack)) {
      _isPlaying = false;
      _safeNotifyListeners();
      return;
    }

    if (_isPlaying) {
      unawaited(_loadAndPlayCurrent());
    } else {
      _playbackRequestId++;
      _isBuffering = false;
      _safeNotifyListeners();
      unawaited(_pauseAudio());
    }
  }

  void seekToPercent(double percent) {
    final clamped = percent.clamp(0.0, 1.0).toDouble();
    seekTo(
      Duration(milliseconds: (actualDuration.inMilliseconds * clamped).round()),
    );
  }

  void seekTo(Duration position) {
    _position = _clampPosition(position, _currentTrack);
    _safeNotifyListeners();

    final audioEngine = _audioEngine;
    if (audioEngine != null && _isCurrentTrackLoaded) {
      unawaited(audioEngine.seek(_position));
    }
  }

  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    if (_isShuffleEnabled) {
      queue.shuffle();
    } else {
      // Attempt to restore queue to original library order
      final currentQueueIds = queue.map((t) => t.id).toSet();
      final ordered = library.where((t) => currentQueueIds.contains(t.id)).toList();
      queue.clear();
      queue.addAll(ordered);
    }
    _safeNotifyListeners();
  }

  void toggleRepeat() {
    _repeatMode = (_repeatMode + 1) % 3;
    _safeNotifyListeners();
  }

  void skipNext({bool forceNextTrack = false}) {
    // If repeating one track and it wasn't a manual skip, just restart current
    if (!forceNextTrack && _repeatMode == 2) {
      _position = Duration.zero;
      _safeNotifyListeners();
      unawaited(_loadAndPlayCurrent(restart: true));
      return;
    }

    _moveCurrentToHistory();
    if (queue.isEmpty) {
      if (_repeatMode == 1 || forceNextTrack) {
        if (_playlistContext.isNotEmpty) {
          queue.addAll(_playlistContext.where((track) => track.id != _currentTrack.id || _playlistContext.length == 1));
        } else {
          queue.addAll(library.where((track) => track.id != _currentTrack.id));
        }
        if (_isShuffleEnabled) queue.shuffle();
      }
    }
    if (queue.isEmpty) {
      _rebuildSmartQueueForCurrent();
    }
    if (queue.isEmpty) {
      _isPlaying = false;
      _position = Duration.zero;
      _safeNotifyListeners();
      unawaited(_pauseAudio());
      return;
    }

    final nextTrack = queue.removeAt(0);
    _beginTrackTransition(nextTrack);
    _currentTrack = nextTrack;
    _resetOnlineRecoveryState();
    _actualDuration = nextTrack.duration > Duration.zero ? nextTrack.duration : null;
    _position = Duration.zero;
    _isPlaying = true;
    _playbackError = null;
    _safeNotifyListeners();
    unawaited(_prefetchLyricsFor(_currentTrack));
    unawaited(_loadAndPlayCurrent(restart: true));
    unawaited(_checkAndPopulateQueue());
  }

  void skipPrevious() {
    if (_position > const Duration(seconds: 5)) {
      _position = Duration.zero;
      _safeNotifyListeners();
      final audioEngine = _audioEngine;
      if (audioEngine != null && _isCurrentTrackLoaded) {
        unawaited(audioEngine.seek(Duration.zero));
        if (_isPlaying) {
          unawaited(audioEngine.play());
        }
      } else if (_isPlaying) {
        unawaited(_loadAndPlayCurrent(restart: true));
      }
      return;
    }

    if (history.isNotEmpty) {
      queue.insert(0, _currentTrack);
      final previousTrack = history.removeLast();
      _beginTrackTransition(previousTrack);
      _currentTrack = previousTrack;
    }
    _resetOnlineRecoveryState();
    _actualDuration = _currentTrack.duration > Duration.zero
        ? _currentTrack.duration
        : null;
    _position = Duration.zero;
    _isPlaying = true;
    _playbackError = null;
    _safeNotifyListeners();
    unawaited(_prefetchLyricsFor(_currentTrack));
    unawaited(_loadAndPlayCurrent(restart: true));
    unawaited(_checkAndPopulateQueue());
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= queue.length) {
      return;
    }
    if (newIndex < 0 || newIndex > queue.length) {
      return;
    }
    if (newIndex > oldIndex) {
      newIndex--;
    }
    final track = queue.removeAt(oldIndex);
    queue.insert(newIndex, track);
    _safeNotifyListeners();
  }

  void removeFromQueue(Track track) {
    queue.removeWhere((queuedTrack) => queuedTrack.id == track.id);
    _safeNotifyListeners();
  }

  void advance(Duration delta) {
    if (!_isPlaying || delta <= Duration.zero) {
      return;
    }

    final nextPosition = _position + delta;
    if (nextPosition >= actualDuration) {
      skipNext();
      return;
    }

    _position = nextPosition;
    _safeNotifyListeners();
  }

  void _attachAudioEngine() {
    final audioEngine = _audioEngine;
    if (audioEngine == null) {
      return;
    }

    _audioSubscriptions
      ..add(
        audioEngine.positionStream.listen((position) {
          if (!_isCurrentTrackLoaded) {
            return;
          }
          _position = _clampPosition(position, _currentTrack);
          _safeNotifyListeners();
          
          // Save history every 5 seconds
          if (_position.inSeconds % 5 == 0 && _currentTrack.id != 'empty') {
             historyService?.saveLastPlayed(_currentTrack.id, _position);
          }
          
          // Trigger recommendation tracking at 30 seconds
          if (_position.inSeconds == 30 && _currentTrack.id != 'empty') {
             onTrackPlayed?.call(_currentTrack, _position);
          }
        }),
      )
      ..add(
        audioEngine.durationStream.listen((duration) {
          if (!_isCurrentTrackLoaded) {
            return;
          }
          _actualDuration = duration;
          _safeNotifyListeners();
        }),
      )
      ..add(
        audioEngine.playingStream.listen((isPlaying) {
          if (!_isCurrentTrackLoaded) {
            return;
          }
          if (_isPlaying == isPlaying) {
            return;
          }
          _isPlaying = isPlaying;
          _safeNotifyListeners();
        }),
      )
      ..add(
        audioEngine.bufferingStream.listen((isBuffering) {
          if (_isBuffering == isBuffering) {
            return;
          }
          _isBuffering = isBuffering;
          _safeNotifyListeners();
        }),
      )
      ..add(
        audioEngine.completedStream.listen((_) {
          if (_isCurrentTrackLoaded && !_isBuffering) {
            skipNext();
          }
        }),
      )
      ..add(
        audioEngine.errorStream.listen((message) {
          if (_shouldRecoverPlaybackError(message)) {
            _playbackError = message;
            _isBuffering = true;
            _safeNotifyListeners();
            unawaited(_recoverFromOnlinePlaybackError(message));
            return;
          }
          _isPlaying = false;
          _isBuffering = false;
          _playbackError = message;
          _safeNotifyListeners();
        }),
      );
  }

  Future<void> _loadAndPlayCurrent({
    bool restart = false,
    bool forceSeek = false,
  }) async {
    final audioEngine = _audioEngine;
    if (audioEngine == null || !_canResolveForPlayback(_currentTrack)) {
      return;
    }

    final requestId = ++_playbackRequestId;
    _playbackError = null;
    final wasLoaded = _isCurrentTrackLoaded;

    try {
      final loaded = await _prepareCurrentTrack(
        restart: restart,
        showBuffering: !wasLoaded,
      );

      if (!loaded) {
        if (requestId == _playbackRequestId) {
          _isPlaying = false;
          _safeNotifyListeners();
        }
        return;
      }

      if (requestId != _playbackRequestId || _isDisposed || !_isPlaying) {
        return;
      }

      if (forceSeek) {
        await audioEngine.seek(_position);
      }

      if (requestId != _playbackRequestId || _isDisposed || !_isPlaying) {
        return;
      }

      await audioEngine.play();
    } catch (error) {
      if (requestId == _playbackRequestId) {
        if (_shouldRecoverPlaybackError(error.toString())) {
          _playbackError = error.toString();
          _isBuffering = true;
          _safeNotifyListeners();
          unawaited(_recoverFromOnlinePlaybackError(error.toString()));
          return;
        }
        _isPlaying = false;
        _playbackError = error.toString();
      }
    } finally {
      if (requestId == _playbackRequestId) {
        _isBuffering = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<bool> _prepareCurrentTrack({
    bool restart = false,
    bool showBuffering = false,
  }) async {
    final audioEngine = _audioEngine;
    if (audioEngine == null) {
      return false;
    }

    if (restart) {
      _loadedTrackKey = null;
    }

    var track = _currentTrack;
    if (track.id.startsWith('local_')) {
      final hydrated = await _hydrateLocalTrack(track);
      if (hydrated != null) {
        track = hydrated;
        _replaceCurrentTrack(track);
        _safeNotifyListeners();
      }
    }

    if ((track.id.startsWith('spotify_') || !track.hasStream) &&
        _canResolveForPlayback(track)) {
      if (showBuffering && !_isBuffering) {
        _isBuffering = true;
        _safeNotifyListeners();
      }
      try {
        final resolvedTrack = await _resolvePlayableTrack(track);
        if (resolvedTrack != null && resolvedTrack.hasStream) {
          track = resolvedTrack;
          _replaceCurrentTrack(track);
          _safeNotifyListeners();
        } else {
          _playbackError = track.id.startsWith('spotify_')
              ? 'Unable to find a full playable source for this Spotify track.'
              : 'Unable to find a playable stream for this track.';
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error resolving online stream URL: $e');
        }
        _playbackError = 'Unable to start online playback.';
        return false;
      }
    }

    if (!track.hasStream) {
      return false;
    }

    final trackKey = _sourceKey(track);
    if (!restart && _loadedTrackKey == trackKey) {
      return true;
    }

    final loadingFuture = _loadingFuture;
    if (!restart && _loadingTrackKey == trackKey && loadingFuture != null) {
      if (showBuffering && !_isBuffering) {
        _isBuffering = true;
        _safeNotifyListeners();
      }
      try {
        await loadingFuture;
      } catch (error) {
        if (_isLoadingInterrupted(error)) {
          return _prepareCurrentTrack(
            restart: true,
            showBuffering: showBuffering,
          );
        }
        return false;
      }
      return _loadedTrackKey == trackKey;
    }

    final loadRequestId = ++_loadRequestId;
    _loadingTrackKey = trackKey;
    if (showBuffering) {
      _isBuffering = true;
      _safeNotifyListeners();
    }

    try {
      var interruptedRetries = 0;
      while (true) {
        final loadFuture = audioEngine.load(track, initialPosition: _position);
        _loadingFuture = loadFuture;

        try {
          await loadFuture;
          break;
        } catch (error) {
          if (loadRequestId != _loadRequestId || _isDisposed) {
            return false;
          }

          if (_isLoadingInterrupted(error) && interruptedRetries < 2) {
            interruptedRetries++;
            await Future<void>.delayed(
              Duration(milliseconds: 160 * interruptedRetries),
            );
            continue;
          }

          final cachedTrack = await _cacheRemoteTrackForPlayback(track);
          if (cachedTrack != null && cachedTrack.hasStream) {
            track = cachedTrack;
            _replaceCurrentTrack(track);
            _safeNotifyListeners();
            _loadingTrackKey = null;
            _loadingFuture = null;
            return _prepareCurrentTrack(
              restart: true,
              showBuffering: showBuffering,
            );
          }

          if (_canTryAlternativeOnlineSource(track)) {
            _markOnlineSourceFailed(track);
            final alternative = await _resolveAlternativeOnlineTrack(track);
            if (alternative != null && alternative.hasStream) {
              _replaceCurrentTrack(alternative);
              _safeNotifyListeners();
              _loadingTrackKey = null;
              _loadingFuture = null;
              return _prepareCurrentTrack(
                restart: true,
                showBuffering: showBuffering,
              );
            }
          }

          if (track.id.startsWith('spotify_')) {
            final fallback = await _resolveSpotifyFallbackAudio(track);
            if (fallback != null && fallback.hasStream) {
              track = fallback;
              _replaceCurrentTrack(track);
              _safeNotifyListeners();
              _loadingTrackKey = null;
              _loadingFuture = null;
              return _prepareCurrentTrack(
                restart: true,
                showBuffering: showBuffering,
              );
            }
            _playbackError =
                'Unable to load a full playable source for this Spotify track.';
            return false;
          }

          rethrow;
        }
      }

      if (loadRequestId != _loadRequestId || _isDisposed) {
        return false;
      }

      // Extract colors dynamically if not already extracted and artwork is available
      if (track.artworkUri != null &&
          track.coverColors.length == 3 &&
          track.coverColors[0] == const Color(0xFF0F273F)) {
        unawaited(_extractColors(track));
      }

      _loadedTrackKey = trackKey;
      _playbackError = null;
      return _sourceKey(_currentTrack) == trackKey;
    } catch (error) {
      if (loadRequestId == _loadRequestId) {
        _playbackError = error.toString();
      }
      return false;
    } finally {
      if (loadRequestId == _loadRequestId) {
        _loadingTrackKey = null;
        _loadingFuture = null;
        if (showBuffering) {
          _isBuffering = false;
        }
        _safeNotifyListeners();
      }
    }
  }

  Future<Track?> _cacheRemoteTrackForPlayback(Track track) async {
    final uri = track.streamUri;
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return _streamCacheService.cacheForPlayback(track);
  }

  Future<void> _pauseAudio() async {
    try {
      await _audioEngine?.pause();
    } catch (error) {
      _playbackError = error.toString();
      _safeNotifyListeners();
    }
  }

  Future<void> _extractColors(Track track) async {
    try {
      final imageProvider = NetworkImage(track.artworkUri!.toString());
      final palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 10,
      );

      final List<Color> newColors = [];
      if (palette.dominantColor != null) {
        newColors.add(palette.dominantColor!.color);
      }
      if (palette.darkVibrantColor != null) {
        newColors.add(palette.darkVibrantColor!.color);
      } else if (palette.darkMutedColor != null) {
        newColors.add(palette.darkMutedColor!.color);
      }
      if (palette.lightVibrantColor != null) {
        newColors.add(palette.lightVibrantColor!.color);
      } else if (palette.mutedColor != null) {
        newColors.add(palette.mutedColor!.color);
      }

      // Ensure we have at least 2 colors for gradient
      if (newColors.length == 1) {
        newColors.add(newColors.first.withValues(alpha: 0.5));
      } else if (newColors.isEmpty) {
        return; // fallback
      }

      if (_currentTrack.id == track.id) {
        _currentTrack = _currentTrack.copyWith(coverColors: newColors);
        _safeNotifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error extracting colors: $e');
      }
    }
  }

  Future<Track?> _resolvePlayableTrack(Track track) async {
    if (track.hasStream &&
        !track.id.startsWith('spotify_') &&
        !track.id.startsWith('yt_')) {
      return track;
    }

    if (track.hasStream && track.streamUri?.scheme == 'file') {
      return track;
    }

    if (track.id.startsWith('spotify_')) {
      final losslessTrack = await _losslessStreamService.resolve(track);
      if (losslessTrack != null && losslessTrack.hasStream) {
        return losslessTrack;
      }
      if (track.hasStream && track.format.toUpperCase() == 'OPUS') {
        return track;
      }
      final fullTrackFallback = await _resolveSpotifyFallbackAudio(track);
      if (fullTrackFallback != null && fullTrackFallback.hasStream) {
        return fullTrackFallback;
      }
      return null;
    }

    final ytService = YouTubeMusicService();
    try {
      if (track.id.startsWith('yt_')) {
        final videoId = track.id.replaceFirst('yt_', '');
        final streamUrls = await ytService.getAudioStreamUrls(videoId);
        if (streamUrls.isNotEmpty) {
          final resolved = track.copyWith(
            streamUrl: streamUrls.first,
            fallbackStreamUrls: streamUrls.skip(1).toList(growable: false),
          );
          return await _cacheRemoteTrackForPlayback(resolved) ?? resolved;
        }

        final alternatives = await ytService.searchTracks(
          _searchQueryFor(track),
          limit: 12,
        );
        final resolved = await _resolveFromYtMatches(
          ytService,
          track,
          alternatives,
          excludedVideoIds: {videoId},
        );
        if (resolved != null) return resolved;
        return null;
      }
      return null;
    } finally {
      ytService.dispose();
    }
  }

  Future<Track?> _resolveSpotifyFallbackAudio(Track track) async {
    // --- Step 1: ISRC-based resolution (most accurate) ---
    if (track.isrc != null && track.isrc!.isNotEmpty) {
      final isrcResult = await _resolveViaIsrcMatching(track);
      if (isrcResult != null) return isrcResult;
    }

    // --- Step 2: Direct YouTube search with progressive relaxation ---
    final ytService = YouTubeMusicService();
    try {
      final matches = await ytService.searchTracks(
        _searchQueryFor(track),
        limit: 15,
      );

      // Remove already-failed candidates up front.
      final viable = matches.where((m) {
        return !_failedOnlineTrackIds.contains('yt_${m.videoId}');
      }).toList(growable: false);

      if (viable.isEmpty) return null;

      // --- Pass 2a: strict filter (version tags + duration ≤30s) ---
      final strictScored = <(YtMusicTrack, int)>[];
      for (final match in viable) {
        if (!_isLikelySameTrack(track, match)) continue;
        strictScored.add((match, _ytMatchScore(track, match)));
      }
      strictScored.sort((a, b) => b.$2.compareTo(a.$2));

      final strictResult = await _tryResolveFromScored(
        ytService, track, strictScored,
      );
      if (strictResult != null) return strictResult;

      // --- Pass 2b: relaxed filter (ignore version tags, duration ≤60s) ---
      if (kDebugMode) {
        print('SpotifyFallback: strict filter found no match, relaxing…');
      }
      final relaxedScored = <(YtMusicTrack, int)>[];
      for (final match in viable) {
        if (!_isLikelySameTrackRelaxed(track, match)) continue;
        relaxedScored.add((match, _ytMatchScore(track, match)));
      }
      relaxedScored.sort((a, b) => b.$2.compareTo(a.$2));

      final relaxedResult = await _tryResolveFromScored(
        ytService, track, relaxedScored,
      );
      if (relaxedResult != null) return relaxedResult;

      // --- Pass 2c: best-effort – take the highest-scored candidate ---
      if (kDebugMode) {
        print('SpotifyFallback: relaxed filter found no match, using best-effort…');
      }
      final bestEffortScored = viable
          .map((m) => (m, _ytMatchScore(track, m)))
          .toList(growable: false)
        ..sort((a, b) => b.$2.compareTo(a.$2));

      return _tryResolveFromScored(ytService, track, bestEffortScored);
    } catch (e) {
      if (kDebugMode) {
        print('Error resolving Spotify fallback audio: $e');
      }
    } finally {
      ytService.dispose();
    }
    return null;
  }

  /// Attempt to resolve audio via ISRC cross-matching:
  /// Spotify ISRC → Deezer (exact match) → YouTube (precise query).
  ///
  /// ISRC is a globally unique code for a specific recording, so matching
  /// via ISRC gives us the exact title/artist as catalogued by Deezer,
  /// which we then use to build a much more precise YouTube search query.
  Future<Track?> _resolveViaIsrcMatching(Track track) async {
    final deezerService = DeezerService();
    final ytService = YouTubeMusicService();
    try {
      if (kDebugMode) {
        print('ISRC Resolution: trying ISRC "${track.isrc}" for "${track.title}"');
      }

      final deezerResults = await deezerService.searchByIsrc(track.isrc!);
      if (deezerResults.isEmpty) {
        if (kDebugMode) {
          print('ISRC Resolution: no Deezer match for ISRC ${track.isrc}');
        }
        return null;
      }

      final deezerTrack = deezerResults.first;
      // Build a precise YouTube query using the Deezer-verified title/artist.
      final preciseQuery = '${deezerTrack.artist} ${deezerTrack.title}';
      if (kDebugMode) {
        print('ISRC Resolution: Deezer match → "$preciseQuery" '
            '(${deezerTrack.durationSeconds}s)');
      }

      final ytMatches = await ytService.searchTracks(preciseQuery, limit: 10);

      // Filter and score with knowledge from Deezer.
      final viable = ytMatches.where((m) {
        return !_failedOnlineTrackIds.contains('yt_${m.videoId}');
      }).toList(growable: false);

      if (viable.isEmpty) return null;

      // Use the Deezer duration for more accurate matching.
      final deezerDuration = deezerTrack.duration;
      final scored = <(YtMusicTrack, int)>[];
      for (final match in viable) {
        // Duration check using Deezer's known-correct duration.
        if (match.duration > Duration.zero && deezerDuration > Duration.zero) {
          final delta =
              (deezerDuration.inSeconds - match.duration.inSeconds).abs();
          if (delta > 15) continue; // Tighter tolerance for ISRC matches.
        }
        scored.add((match, _ytMatchScore(track, match)));
      }
      scored.sort((a, b) => b.$2.compareTo(a.$2));

      final result = await _tryResolveFromScored(ytService, track, scored);
      if (result != null) {
        if (kDebugMode) {
          print('ISRC Resolution: ✓ resolved via ISRC cross-match');
        }
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('ISRC Resolution: error: $e');
      }
      return null;
    } finally {
      deezerService.dispose();
      ytService.dispose();
    }
  }

  /// Try to resolve an audio stream from a scored list of YouTube matches.
  Future<Track?> _tryResolveFromScored(
    YouTubeMusicService ytService,
    Track track,
    List<(YtMusicTrack, int)> scored,
  ) async {
    for (final (match, _) in scored) {
      if (track.duration > const Duration(seconds: 60) &&
          match.duration <= const Duration(seconds: 60)) {
        continue;
      }
      final candidateId = 'yt_${match.videoId}';
      final streamUrls = await ytService.getAudioStreamUrls(match.videoId);
      if (streamUrls.isEmpty) {
        _failedOnlineTrackIds.add(candidateId);
        continue;
      }
      final resolved = track.copyWith(
        streamUrl: streamUrls.first,
        fallbackStreamUrls: [
          ...streamUrls.skip(1),
          if (track.streamUrl != null) track.streamUrl!,
          ...track.fallbackStreamUrls,
        ],
        format: 'OPUS',
        album: track.album.isNotEmpty ? track.album : 'Spotify metadata',
        artworkUrl: track.artworkUrl,
      );
      return await _cacheRemoteTrackForPlayback(resolved) ?? resolved;
    }
    return null;
  }

  /// Version/variant tags that indicate an alternative version of a song.
  static final _versionTagPattern = RegExp(
    r'\b(chinese|chinese ver|mandarin|japanese|japan ver|english|'
    r'spanish|hindi|thai|indo|korean|'
    r'remix|remixed|live|acoustic|acapella|a cappella|'
    r'instrumental|karaoke|cover|sped up|slowed|reverb|'
    r'8d audio|nightcore|lofi|lo-fi|bass boosted|'
    r'demo|radio edit|extended|deluxe)\b'
    r'|(\bver(sion)?\.?\s*$)',
    caseSensitive: false,
  );

  /// Extract version tags from a title string.
  static Set<String> _extractVersionTags(String title) {
    final lower = title.toLowerCase();
    final tags = <String>{};
    for (final match in _versionTagPattern.allMatches(lower)) {
      final tag = match.group(1)?.trim();
      if (tag != null && tag.isNotEmpty) {
        tags.add(tag);
      }
    }
    return tags;
  }

  /// Score a YouTube match against a Spotify track for relevance ranking.
  static int _ytMatchScore(Track track, YtMusicTrack match) {
    var score = 0;
    final trackTitle = _normalizeSongField(track.title);
    final matchTitle = _normalizeSongField(match.title);

    // Exact title match is most relevant.
    if (matchTitle == trackTitle) {
      score += 20;
    } else if (matchTitle.contains(trackTitle)) {
      score += 8;
    } else if (trackTitle.contains(matchTitle)) {
      score += 6;
    }

    // Duration proximity.
    if (track.duration > Duration.zero && match.duration > Duration.zero) {
      final delta = (track.duration.inSeconds - match.duration.inSeconds).abs();
      if (delta <= 3) {
        score += 15;
      } else if (delta <= 10) {
        score += 8;
      } else if (delta <= 20) {
        score += 3;
      }
    }

    // Artist match.
    final trackArtist = _normalizeSongField(track.artist);
    final matchArtist = _normalizeSongField(match.artist);
    if (trackArtist.isNotEmpty && matchArtist.isNotEmpty) {
      if (matchArtist == trackArtist) {
        score += 10;
      } else if (matchArtist.contains(trackArtist) ||
          trackArtist.contains(matchArtist)) {
        score += 5;
      }
    }

    return score;
  }

  static bool _isLikelySameTrack(Track track, YtMusicTrack match) {
    final trackTitle = _normalizeSongField(track.title);
    final matchTitle = _normalizeSongField(match.title);
    final trackArtist = _normalizeSongField(track.artist);
    final matchArtist = _normalizeSongField(match.artist);

    if (trackTitle.isEmpty || matchTitle.isEmpty) {
      return false;
    }

    // --- Version/variant mismatch filter ---
    final trackTags = _extractVersionTags(track.title);
    final matchTags = _extractVersionTags(match.title);

    // If the original track has NO version tags but the YouTube match does,
    // reject it (e.g. "Catch Catch" vs "Catch Catch (Chinese Version)").
    if (trackTags.isEmpty && matchTags.isNotEmpty) {
      if (kDebugMode) {
        print('_isLikelySameTrack: rejected "${match.title}" — '
            'unwanted version tags: $matchTags');
      }
      return false;
    }

    // If both have version tags but they differ, reject
    // (e.g. "Korean Version" vs "Chinese Version").
    if (trackTags.isNotEmpty && matchTags.isNotEmpty &&
        trackTags.intersection(matchTags).isEmpty) {
      if (kDebugMode) {
        print('_isLikelySameTrack: rejected "${match.title}" — '
            'version mismatch: $trackTags vs $matchTags');
      }
      return false;
    }

    // --- Duration mismatch filter ---
    if (track.duration > Duration.zero && match.duration > Duration.zero) {
      final delta = (track.duration.inSeconds - match.duration.inSeconds).abs();
      if (delta > 30) {
        if (kDebugMode) {
          print('_isLikelySameTrack: rejected "${match.title}" — '
              'duration delta ${delta}s exceeds 30s threshold');
        }
        return false;
      }
    }

    // --- Title matching ---
    final titleMatches = matchTitle == trackTitle ||
        matchTitle.contains(trackTitle) ||
        trackTitle.contains(matchTitle);
    if (!titleMatches) {
      return false;
    }

    // --- Artist matching ---
    if (trackArtist.isEmpty || matchArtist.isEmpty) {
      return true;
    }
    return matchArtist.contains(trackArtist) ||
        trackArtist.contains(matchArtist) ||
        _hasSharedToken(trackArtist, matchArtist) ||
        matchTitle.contains(trackArtist) ||
        trackTitle.contains(matchArtist);
  }

  /// Relaxed version of [_isLikelySameTrack]: skips version-tag checks and
  /// uses a 60-second duration tolerance. Used as fallback when strict matching
  /// rejects all YouTube candidates.
  static bool _isLikelySameTrackRelaxed(Track track, YtMusicTrack match) {
    final trackTitle = _normalizeSongField(track.title);
    final matchTitle = _normalizeSongField(match.title);
    final trackArtist = _normalizeSongField(track.artist);
    final matchArtist = _normalizeSongField(match.artist);

    if (trackTitle.isEmpty || matchTitle.isEmpty) {
      return false;
    }

    // Duration filter with wider tolerance (60s), OR allow if Spotify is a clip and YT is full track.
    if (track.duration > Duration.zero && match.duration > Duration.zero) {
      final delta = (track.duration.inSeconds - match.duration.inSeconds).abs();
      if (delta > 60) {
        final isSpotifyClip = track.duration.inSeconds < 120;
        final isYtFullTrack = match.duration.inSeconds >= 120;
        if (!(isSpotifyClip && isYtFullTrack)) {
          return false;
        }
      }
    }

    // Title matching.
    final titleMatches = matchTitle == trackTitle ||
        matchTitle.contains(trackTitle) ||
        trackTitle.contains(matchTitle);
    if (!titleMatches) {
      return false;
    }

    // Artist matching. Check if they share tokens, OR if the collab artist is mentioned in the video title
    if (trackArtist.isEmpty || matchArtist.isEmpty) {
      return true;
    }
    final artistMatches = matchArtist.contains(trackArtist) ||
        trackArtist.contains(matchArtist) ||
        _hasSharedToken(trackArtist, matchArtist) ||
        matchTitle.contains(trackArtist) ||
        trackTitle.contains(matchArtist);

    return artistMatches;
  }

  Future<Track?> _resolveAlternativeOnlineTrack(Track track) async {
    final ytService = YouTubeMusicService();
    try {
      final currentVideoId =
          track.id.startsWith('yt_') ? track.id.replaceFirst('yt_', '') : '';
      final matches = await ytService.searchTracks(
        _searchQueryFor(track),
        limit: 12,
      );

      return _resolveFromYtMatches(
        ytService,
        track,
        matches,
        excludedVideoIds: {if (currentVideoId.isNotEmpty) currentVideoId},
      );
    } finally {
      ytService.dispose();
    }
  }

  Future<Track?> _resolveFromYtMatches(
    YouTubeMusicService ytService,
    Track track,
    List<YtMusicTrack> matches, {
    Set<String> excludedVideoIds = const {},
  }) async {
    for (final match in matches) {
      final nextId = 'yt_${match.videoId}';
      if (excludedVideoIds.contains(match.videoId) ||
          _failedOnlineTrackIds.contains(nextId)) {
        continue;
      }
      final streamUrls = await ytService.getAudioStreamUrls(match.videoId);
      if (streamUrls.isEmpty) {
        _failedOnlineTrackIds.add(nextId);
        continue;
      }
      final resolved = Track(
        id: nextId,
        title: track.id.startsWith('spotify_') ? track.title : match.title,
        artist: track.id.startsWith('spotify_') ? track.artist : match.artist,
        album: track.album.isNotEmpty ? track.album : 'Online',
        format: 'OPUS',
        bitDepth: 16,
        sampleRateKhz: 44,
        duration: track.duration > Duration.zero ? track.duration : match.duration,
        coverColors: track.coverColors,
        lyrics: track.lyrics,
        streamUrl: streamUrls.first,
        fallbackStreamUrls: streamUrls.skip(1).toList(growable: false),
        artworkUrl: match.thumbnailUrl ?? track.artworkUrl,
      );
      return await _cacheRemoteTrackForPlayback(resolved) ?? resolved;
    }
    return null;
  }

  Future<void> _recoverFromOnlinePlaybackError(String message) async {
    if (_isRecoveringOnlineSource ||
        !_canTryAlternativeOnlineSource(_currentTrack) ||
        _onlineRecoveryAttempts >= 3) {
      _isPlaying = false;
      _isBuffering = false;
      _playbackError = message;
      _safeNotifyListeners();
      return;
    }

    _isRecoveringOnlineSource = true;
    _onlineRecoveryAttempts++;
    _markOnlineSourceFailed(_currentTrack);

    try {
      final alternative = await _resolveAlternativeOnlineTrack(_currentTrack);
      if (alternative == null || !alternative.hasStream || _isDisposed) {
        _isPlaying = false;
        _playbackError = message;
        return;
      }

      _replaceCurrentTrack(alternative);
      _actualDuration = null;
      _position = Duration.zero;
      _loadedTrackKey = null;
      _loadingTrackKey = null;
      _loadingFuture = null;
      _isPlaying = true;
      _playbackError = null;
      _safeNotifyListeners();
      unawaited(_prefetchLyricsFor(alternative));
      await _loadAndPlayCurrent(restart: true);
    } catch (error) {
      _isPlaying = false;
      _playbackError = error.toString();
    } finally {
      _isRecoveringOnlineSource = false;
      _isBuffering = false;
      _safeNotifyListeners();
    }
  }

  void _resetOnlineRecoveryState() {
    _isRecoveringOnlineSource = false;
    _onlineRecoveryAttempts = 0;
    _failedOnlineTrackIds.clear();
  }

  void _markOnlineSourceFailed(Track track) {
    if (track.id.startsWith('yt_')) {
      _failedOnlineTrackIds.add(track.id);
    }
  }

  Future<void> _prefetchLyricsFor(Track track) async {
    if (track.id == 'empty' ||
        !_canPrefetchLyrics(track) ||
        track.title.trim().isEmpty ||
        track.artist.trim().isEmpty ||
        _hasSyncedLyrics(track)) {
      return;
    }

    try {
      await _lyricsPrefetchService.prefetchSyncedLyrics(
        track.title,
        track.artist,
        album: track.album,
        durationMs: track.duration.inMilliseconds,
      );
    } catch (_) {
      // Lyrics are optional; keep playback responsive if the network is slow.
    }
  }

  static bool _hasSyncedLyrics(Track track) {
    if (track.lyrics.isEmpty) {
      return false;
    }
    final raw = track.lyrics.join('\n');
    return RegExp(r'\[\d{1,3}:\d{2}(?:\.\d{2,3})?\]').hasMatch(raw);
  }

  static bool _canPrefetchLyrics(Track track) {
    return track.id.startsWith('local_') ||
        track.id.startsWith('yt_') ||
        track.id.startsWith('spotify_');
  }

  Future<Track?> _hydrateLocalTrack(Track track) async {
    if (track.lyrics.isNotEmpty && track.artworkUrl != null) {
      return null;
    }

    final primaryUri = track.streamUri?.toString();
    if (primaryUri == null) {
      return null;
    }
    final metadata = await readLocalMusicMetadata(
      uri: primaryUri,
      path: _localPathFor(track),
      id: track.id,
    );
    if (metadata == null) {
      return null;
    }

    final lyrics = metadata.lyrics == null || metadata.lyrics!.trim().isEmpty
        ? track.lyrics
        : metadata.lyrics!
            .split(RegExp(r'\r?\n'))
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList(growable: false);

    return track.copyWith(
      title: _fallbackText(metadata.title, track.title),
      artist: _fallbackText(metadata.artist, track.artist),
      album: _fallbackText(metadata.album, track.album),
      lyrics: lyrics,
      artworkUrl: metadata.artworkUri ?? track.artworkUrl,
    );
  }

  static String _localPathFor(Track track) {
    final uri = track.streamUri;
    if (uri != null && uri.scheme == 'file') {
      return uri.toFilePath();
    }
    for (final value in track.fallbackStreamUrls) {
      final fallback = Uri.tryParse(value);
      if (fallback != null && fallback.scheme == 'file') {
        return fallback.toFilePath();
      }
    }
    return track.title;
  }

  static String _fallbackText(String? value, String fallback) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
  }

  void _replaceCurrentTrack(Track resolvedTrack) {
    final previousId = _currentTrack.id;
    _currentTrack = resolvedTrack;

    final existingIndex = library.indexWhere((track) => track.id == previousId);
    if (existingIndex >= 0) {
      library[existingIndex] = resolvedTrack;
    } else if (_findTrackIn(library, resolvedTrack.id) == null) {
      library.add(resolvedTrack);
    }

    queue.removeWhere((track) {
      return track.id == previousId || track.id == resolvedTrack.id;
    });
  }

  void _beginTrackTransition(Track nextTrack) {
    _playbackRequestId++;
    _loadRequestId++;
    _loadedTrackKey = null;
    _loadingTrackKey = null;
    _loadingFuture = null;
    _isBuffering = false;
    if (!_sameTrack(_currentTrack, nextTrack)) {
      unawaited(_pauseAudio());
    }
  }

  void _moveCurrentToHistory() {
    if (history.isEmpty || history.last.id != _currentTrack.id) {
      history.add(_currentTrack);
    }
    if (_currentTrack.id != 'empty') {
      historyService?.saveRecentlyPlayed(_currentTrack.id);
    }
  }

  Future<void> _fetchAndSetInitialYtTrack(String ytTrackId) async {
    try {
      final ytService = YouTubeMusicService();
      final videoId = ytTrackId.replaceFirst('yt_', '');
      final info = await ytService.getVideoInfo(videoId);
      ytService.dispose();

      if (info != null && _currentTrack.id == ytTrackId) {
        _currentTrack = Track(
          id: ytTrackId,
          title: info.title,
          artist: info.artist,
          album: 'YouTube Music',
          format: 'YT',
          bitDepth: 16,
          sampleRateKhz: 44,
          duration: info.duration,
          coverColors: const [Color(0xFF0F273F), Color(0xFF8C5B7D), Color(0xFF101422)],
          lyrics: [],
          artworkUrl: info.thumbnailUrl,
        );
        _safeNotifyListeners();
        if (_currentTrack.artworkUrl != null) {
          unawaited(_extractColors(_currentTrack));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching initial YT track: $e');
      }
    }
  }

  bool get _isCurrentTrackLoaded =>
      _loadedTrackKey == _sourceKey(_currentTrack);

  static String _sourceKey(Track track) {
    return '${track.id}|${track.streamUrl ?? ''}|${track.fallbackStreamUrls.join('|')}';
  }

  Duration _clampPosition(Duration position, Track track) {
    if (position.isNegative) {
      return Duration.zero;
    }
    final limit = actualDuration;
    if (position > limit) {
      return limit;
    }
    return position;
  }

  static Track? _findTrackIn(List<Track> tracks, String id) {
    for (final track in tracks) {
      if (track.id == id) {
        return track;
      }
    }
    return null;
  }

  static bool _sameTrack(Track a, Track b) => a.id == b.id;

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
      _syncPlaybackNotification();
    }
  }

  void _syncPlaybackNotification({bool force = false}) {
    final now = DateTime.now();
    if (!force &&
        now.difference(_lastNotificationSync) < const Duration(seconds: 1)) {
      return;
    }
    _lastNotificationSync = now;
    unawaited(
      _notificationService.sync(
        track: _currentTrack,
        isPlaying: _isPlaying,
        position: _position,
        duration: actualDuration,
      ),
    );
  }

  Future<void> _handleNotificationAction(
    String action,
    Duration? position,
  ) async {
    switch (action) {
      case 'toggle':
        togglePlay();
        break;
      case 'next':
        skipNext(forceNextTrack: true);
        break;
      case 'previous':
        skipPrevious();
        break;
      case 'seek':
        if (position != null) {
          seekTo(position);
        }
        break;
    }
    _syncPlaybackNotification(force: true);
  }

  Future<void> _checkAndPopulateQueue() async {
    if (_isFetchingRelated || _currentTrack.id == 'empty' || !_autoPlayEndless || _repeatMode != 0) {
      return;
    }

    // Keep an endless queue shaped around the currently playing track.
    if (queue.length < 12) {
      _isFetchingRelated = true;
      final ytService = YouTubeMusicService();
      try {
        final relatedById = <String, YtMusicTrack>{};

        if (_currentTrack.id.startsWith('yt_')) {
          final videoId = _currentTrack.id.replaceFirst('yt_', '');
          final related = await ytService.getRelatedTracks(videoId);
          for (final track in related) {
            relatedById[track.videoId] = track;
          }
        } else {
          final searchResults = await ytService.searchTracks(
            _searchQueryFor(_currentTrack),
            limit: 4,
          );
          if (searchResults.isNotEmpty) {
            final related =
                await ytService.getRelatedTracks(searchResults.first.videoId);
            for (final track in related) {
              relatedById[track.videoId] = track;
            }
          }
        }

        for (final query in _queueDiscoveryQueries(_currentTrack).take(3)) {
          final searchResults = await ytService.searchTracks(query, limit: 8);
          for (final track in searchResults) {
            relatedById.putIfAbsent(track.videoId, () => track);
          }
          if (relatedById.length >= 18) {
            break;
          }
        }

        final existingIds = {
          ...queue.map((t) => t.id),
          ...history.map((t) => t.id),
          _currentTrack.id,
        };
        final candidates = relatedById.values.map(_trackFromYtRelated).where((track) {
          return !existingIds.contains(track.id) && !_blacklistedIds.contains(track.id);
        }).toList(growable: false);

        final scored = candidates
            .map((track) => (track: track, score: _queueScore(_currentTrack, track)))
            .where((item) => item.score > 0)
            .toList(growable: false);
        scored.sort((a, b) => b.score.compareTo(a.score));

        var added = 0;
        for (final item in scored) {
          if (queue.length >= 16 || added >= 10) {
            break;
          }
          if (existingIds.add(item.track.id)) {
            queue.add(item.track);
            added++;
          }
        }

        if (added > 0) {
          _safeNotifyListeners();
        }
      } catch (e) {
        if (kDebugMode) print('Error populating endless queue: $e');
      } finally {
        ytService.dispose();
        _isFetchingRelated = false;
      }
    }
  }

  Track _trackFromYtRelated(YtMusicTrack ytTrack) {
    return Track(
      id: 'yt_${ytTrack.videoId}',
      title: ytTrack.title,
      artist: ytTrack.artist,
      album: _currentTrack.album.isNotEmpty ? _currentTrack.album : 'Related',
      format: 'OPUS',
      bitDepth: 16,
      sampleRateKhz: 44,
      duration: ytTrack.duration,
      coverColors: _currentTrack.coverColors,
      lyrics: const [],
      artworkUrl: ytTrack.thumbnailUrl,
    );
  }

  void _rebuildSmartQueueForCurrent() {
    final current = _currentTrack;
    if (current.id == 'empty') {
      queue.clear();
      return;
    }

    final scored = <({Track track, int score})>[];
    for (final track in library) {
      if (track.id == current.id || _blacklistedIds.contains(track.id)) {
        continue;
      }
      final score = _queueScore(current, track);
      if (score > 0) {
        scored.add((track: track, score: score));
      }
    }

    scored.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) {
        return scoreCompare;
      }
      return b.track.playCount.compareTo(a.track.playCount);
    });

    final seen = <String>{current.id};
    queue
      ..clear()
      ..addAll(
        scored
            .map((item) => item.track)
            .where((track) => seen.add(track.id))
            .take(8),
      );

    if (queue.length < 4) {
      final fallback = library
          .where((track) => track.id != current.id && seen.add(track.id))
          .toList(growable: false)
        ..sort((a, b) => _queueScore(current, b).compareTo(_queueScore(current, a)));
      final limitedFallback = fallback.take(4 - queue.length);
      queue.addAll(limitedFallback);
    }
  }

  int _queueScore(Track current, Track candidate) {
    var score = _relatednessScore(current, candidate);
    if (_likedIds.contains(candidate.id)) {
      score += 5;
    }
    if (history.any((track) => track.id == candidate.id)) {
      score -= 3;
    }
    if (candidate.playCount > 0) {
      score += candidate.playCount.clamp(0, 4);
    }
    return score;
  }

  static int _relatednessScore(Track current, Track candidate) {
    var score = 0;
    final currentArtist = _normalizeArtist(current.artist);
    final candidateArtist = _normalizeArtist(candidate.artist);
    final currentAlbum = current.album.toLowerCase();
    final candidateAlbum = candidate.album.toLowerCase();

    if (currentArtist.isNotEmpty && candidateArtist == currentArtist) {
      score += 8;
    } else if (_hasSharedToken(currentArtist, candidateArtist)) {
      score += 4;
    }

    if (currentAlbum.isNotEmpty && candidateAlbum == currentAlbum) {
      score += 7;
    }

    if (current.format.toLowerCase() == candidate.format.toLowerCase()) {
      score += 1;
    }

    if (_hasSharedToken(current.title.toLowerCase(), candidate.title.toLowerCase())) {
      score += 2;
    }

    final sharedTokens = _trackTokens(current).intersection(_trackTokens(candidate));
    score += sharedTokens.length.clamp(0, 6);

    final sharedThemes = _themeTags(current).intersection(_themeTags(candidate));
    score += sharedThemes.length * 4;

    final currentDuration = current.duration.inSeconds;
    final candidateDuration = candidate.duration.inSeconds;
    if (currentDuration > 0 && candidateDuration > 0) {
      final delta = (currentDuration - candidateDuration).abs();
      if (delta <= 35) {
        score += 2;
      } else if (delta <= 75) {
        score += 1;
      }
    }

    return score;
  }

  static bool _hasSharedToken(String left, String right) {
    final leftTokens = _tokens(left);
    if (leftTokens.isEmpty) {
      return false;
    }
    final rightTokens = _tokens(right);
    return leftTokens.any(rightTokens.contains);
  }

  static Set<String> _tokens(String value) {
    return value
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.length > 2 && !_queueStopWords.contains(token))
        .toSet();
  }

  static Set<String> _trackTokens(Track track) {
    return {
      ..._tokens(track.title.toLowerCase()),
      ..._tokens(track.artist.toLowerCase()),
      ..._tokens(track.album.toLowerCase()),
    };
  }

  static String _normalizeArtist(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'\s*-\s*topic$'), '')
        .replaceAll(RegExp(r'\bvevo\b'), '')
        .replaceAll(RegExp(r'\bofficial\b'), '')
        .trim();
  }

  static Set<String> _themeTags(Track track) {
    final text = '${track.title} ${track.artist} ${track.album}'.toLowerCase();
    final tokens = _tokens(text);
    final tags = <String>{};
    for (final entry in _themeKeywordGroups.entries) {
      if (entry.value.any((keyword) {
        return tokens.contains(keyword) || text.contains(keyword);
      })) {
        tags.add(entry.key);
      }
    }
    return tags;
  }

  static List<String> _queueDiscoveryQueries(Track track) {
    final artist = _normalizeArtist(track.artist);
    final title = track.title.trim();
    final album = track.album.trim();
    final themes = _themeTags(track).take(2).join(' ');
    return [
      _searchQueryFor(track),
      if (artist.isNotEmpty && album.isNotEmpty) '$artist $album',
      if (artist.isNotEmpty) '$artist similar songs',
      if (artist.isNotEmpty && themes.isNotEmpty) '$artist $themes music',
      if (themes.isNotEmpty) '$themes songs like $title',
      if (title.isNotEmpty) '$title similar songs',
    ].where((query) => query.trim().isNotEmpty).toList(growable: false);
  }

  static const Set<String> _queueStopWords = {
    'the',
    'and',
    'with',
    'feat',
    'ft',
    'official',
    'audio',
    'video',
    'lyrics',
    'music',
    'song',
    'topic',
    'yang',
    'dan',
    'untuk',
    'kamu',
    'aku',
    'dari',
    'ini',
    'itu',
  };

  static const Map<String, Set<String>> _themeKeywordGroups = {
    'sad': {
      'sad',
      'galau',
      'patah',
      'broken',
      'heartbreak',
      'cry',
      'tears',
      'rain',
      'hujan',
      'rindu',
      'sendiri',
      'lonely',
      'kecewa',
    },
    'love': {
      'love',
      'cinta',
      'sayang',
      'bahagia',
      'kasih',
      'heart',
      'romance',
      'romantis',
      'forever',
    },
    'party': {
      'party',
      'dance',
      'club',
      'funk',
      'disco',
      'remix',
      'edm',
      'dj',
      'mania',
    },
    'calm': {
      'calm',
      'chill',
      'lofi',
      'sleep',
      'dream',
      'soft',
      'acoustic',
      'piano',
      'malam',
    },
    'rock': {
      'rock',
      'metal',
      'punk',
      'guitar',
      'band',
      'alternative',
    },
    'pop': {
      'pop',
      'hits',
      'viral',
      'single',
      'radio',
      'chart',
    },
  };

  static bool _canResolveForPlayback(Track track) {
    return track.hasStream ||
        track.id.startsWith('yt_') ||
        track.id.startsWith('spotify_');
  }

  static bool _canTryAlternativeOnlineSource(Track track) {
    return false;
  }

  Track _preferLocalLosslessTrack(Track track) {
    if (!_isOnlineTrack(track)) {
      return track;
    }

    for (final candidate in library) {
      if (!candidate.isLossless || !candidate.hasStream) {
        continue;
      }
      if (_sameSongIdentity(candidate, track)) {
        return candidate;
      }
    }

    return track;
  }

  static bool _isOnlineTrack(Track track) {
    return track.id.startsWith('spotify_') || track.id.startsWith('yt_');
  }

  static bool _sameSongIdentity(Track localTrack, Track onlineTrack) {
    final localTitle = _normalizeSongField(localTrack.title);
    final onlineTitle = _normalizeSongField(onlineTrack.title);
    if (localTitle.isEmpty || onlineTitle.isEmpty || localTitle != onlineTitle) {
      return false;
    }

    final localArtist = _normalizeSongField(localTrack.artist);
    final onlineArtist = _normalizeSongField(onlineTrack.artist);
    if (localArtist.isEmpty || onlineArtist.isEmpty) {
      return true;
    }

    return localArtist == onlineArtist ||
        localArtist.contains(onlineArtist) ||
        onlineArtist.contains(localArtist);
  }

  static String _normalizeSongField(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'\s*-\s*topic$'), '')
        .replaceAll(RegExp(r'\b(feat|ft|featuring)\.?\b.*$'), '')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }

  bool _shouldRecoverPlaybackError(String message) {
    if (!_canTryAlternativeOnlineSource(_currentTrack) ||
        _isRecoveringOnlineSource ||
        _onlineRecoveryAttempts >= 3) {
      return false;
    }

    final normalized = message.toLowerCase();
    return normalized.contains('source error') ||
        normalized.contains('unexpected runtime error') ||
        normalized.contains('timeoutexception') ||
        normalized.contains('future not completed') ||
        normalized.contains('prepare failed');
  }

  static String _searchQueryFor(Track track) {
    // Only use artist + title for YouTube search; album name adds noise.
    final parts = [
      track.artist,
      track.title,
    ];
    return parts.where((part) => part.trim().isNotEmpty).join(' ');
  }

  static bool _isLoadingInterrupted(Object error) {
    return error.toString().toLowerCase().contains('loading interrupted');
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_notificationService.hide());
    for (final subscription in _audioSubscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_audioEngine?.dispose());
    super.dispose();
  }
}
