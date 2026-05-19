import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/library_repository.dart';
import '../models/album.dart';
import '../models/track.dart';
import '../services/audio_playback_engine.dart';

class PlayerController extends ChangeNotifier {
  PlayerController({
    LibraryRepository libraryRepository = const DemoLibraryRepository(),
    AudioPlaybackEngine? audioEngine,
    bool startPlaybackClock = true,
    bool autoPlay = true,
    Duration initialPosition = Duration.zero,
  }) : _libraryRepository = libraryRepository,
       _audioEngine =
           startPlaybackClock
               ? audioEngine ?? JustAudioPlaybackEngine()
               : audioEngine {
    final loadedTracks = List<Track>.unmodifiable(libraryRepository.tracks);
    if (loadedTracks.isEmpty) {
      throw StateError('PlayerController requires at least one track.');
    }

    library.addAll(loadedTracks);
    _baseAlbums.addAll(libraryRepository.albums);
    _currentTrack = library.first;
    queue.addAll(library.skip(1));
    _isPlaying = autoPlay;
    _position = _clampPosition(initialPosition, _currentTrack);

    _attachAudioEngine();

    if (_currentTrack.hasStream) {
      if (autoPlay) {
        unawaited(_loadAndPlayCurrent(restart: true));
      }
    }
  }

  final LibraryRepository _libraryRepository;
  final AudioPlaybackEngine? _audioEngine;
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

  final Set<String> _likedIds = {};

  late Track _currentTrack;
  late bool _isPlaying;
  int _selectedIndex = 0;
  late Duration _position;
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

  Track get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  bool get isLibraryLoading => _isLibraryLoading;
  int get selectedIndex => _selectedIndex;
  Duration get position => _position;
  String? get playbackError => _playbackError;
  String? get libraryError => _libraryError;

  bool _isShuffleEnabled = false;
  int _repeatMode = 0; // 0 = off, 1 = all, 2 = one

  bool get isShuffleEnabled => _isShuffleEnabled;
  int get repeatMode => _repeatMode;

  Duration get remaining {
    final remaining = _currentTrack.duration - _position;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double get progress {
    final ms = _currentTrack.duration.inMilliseconds;
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

      _currentTrack = _findTrackIn(library, currentId) ?? library.first;
      queue
        ..clear()
        ..addAll(library.where((track) => track.id != _currentTrack.id));
      history.removeWhere((track) => _findTrackIn(library, track.id) == null);
      _position = _clampPosition(_position, _currentTrack);
      if (!_isPlaying && _currentTrack.hasStream) {
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
    final isSameTrack = _sameTrack(_currentTrack, track);
    if (!isSameTrack) {
      _moveCurrentToHistory();
    }

    if (_findTrackIn(library, track.id) == null) {
      library.add(track);
    }

    queue.removeWhere((queuedTrack) => queuedTrack.id == track.id);
    _currentTrack = track;
    _position = Duration.zero;
    _isPlaying = true;
    _playbackError = null;
    _safeNotifyListeners();
    unawaited(
      _loadAndPlayCurrent(restart: !isSameTrack, forceSeek: isSameTrack),
    );
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

    _currentTrack = firstTrack;
    queue
      ..clear()
      ..addAll(nextQueue.where((track) => track.id != firstTrack.id));
    _position = Duration.zero;
    _isPlaying = true;
    _playbackError = null;
    _safeNotifyListeners();
    unawaited(
      _loadAndPlayCurrent(restart: !isSameTrack, forceSeek: isSameTrack),
    );
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    _safeNotifyListeners();

    final audioEngine = _audioEngine;
    if (audioEngine == null || !_currentTrack.hasStream) {
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
    _position = Duration(
      milliseconds: (_currentTrack.duration.inMilliseconds * clamped).round(),
    );
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
        queue.addAll(library.where((track) => track.id != _currentTrack.id));
        if (_isShuffleEnabled) queue.shuffle();
      }
    }
    if (queue.isEmpty) {
      _isPlaying = false;
      _position = Duration.zero;
      _safeNotifyListeners();
      unawaited(_pauseAudio());
      return;
    }

    _currentTrack = queue.removeAt(0);
    _position = Duration.zero;
    _isPlaying = true;
    _playbackError = null;
    _safeNotifyListeners();
    unawaited(_loadAndPlayCurrent(restart: true));
  }

  void skipPrevious() {
    if (history.isNotEmpty) {
      queue.insert(0, _currentTrack);
      _currentTrack = history.removeLast();
    }
    _position = Duration.zero;
    _isPlaying = true;
    _playbackError = null;
    _safeNotifyListeners();
    unawaited(_loadAndPlayCurrent(restart: true));
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
    if (nextPosition >= _currentTrack.duration) {
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
          _position = _clampPosition(position, _currentTrack);
          _safeNotifyListeners();
        }),
      )
      ..add(
        audioEngine.playingStream.listen((isPlaying) {
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
      ..add(audioEngine.completedStream.listen((_) => skipNext()));
  }

  Future<void> _loadAndPlayCurrent({
    bool restart = false,
    bool forceSeek = false,
  }) async {
    final audioEngine = _audioEngine;
    if (audioEngine == null || !_currentTrack.hasStream) {
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
    if (audioEngine == null || !_currentTrack.hasStream) {
      return false;
    }

    final track = _currentTrack;
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
      await loadingFuture;
      return _loadedTrackKey == trackKey;
    }

    final loadRequestId = ++_loadRequestId;
    _loadingTrackKey = trackKey;
    if (showBuffering) {
      _isBuffering = true;
      _safeNotifyListeners();
    }

    final loadFuture = audioEngine.load(track, initialPosition: _position);
    _loadingFuture = loadFuture;

    try {
      await loadFuture;
      if (loadRequestId != _loadRequestId || _isDisposed) {
        return false;
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

  Future<void> _pauseAudio() async {
    try {
      await _audioEngine?.pause();
    } catch (error) {
      _playbackError = error.toString();
      _safeNotifyListeners();
    }
  }

  void _moveCurrentToHistory() {
    if (history.isEmpty || history.last.id != _currentTrack.id) {
      history.add(_currentTrack);
    }
  }

  bool get _isCurrentTrackLoaded =>
      _loadedTrackKey == _sourceKey(_currentTrack);

  static String _sourceKey(Track track) {
    return '${track.id}|${track.streamUrl ?? ''}';
  }

  static Duration _clampPosition(Duration position, Track track) {
    if (position.isNegative) {
      return Duration.zero;
    }
    if (position > track.duration) {
      return track.duration;
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
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (final subscription in _audioSubscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_audioEngine?.dispose());
    super.dispose();
  }
}
