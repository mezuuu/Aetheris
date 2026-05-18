import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/track.dart';
import '../models/queue.dart';
import 'audio_service.dart';
import 'library_service.dart';

/// Player service with advanced queue management (3-tier system)
/// Tier 1: User queue (Play Next priority)
/// Tier 2: Playlist queue (Current context: album/playlist/folder)
/// Tier 3: Recommendation queue (Auto-suggestions)
class PlayerService {
  PlayerService({
    required AudioService audioService,
    required LibraryService libraryService,
  })  : _audioService = audioService,
        _libraryService = libraryService;

  final AudioService _audioService;
  final LibraryService _libraryService;

  // Queue state
  final List<QueueItem> _userQueue = [];
  final List<QueueItem> _playlistQueue = [];
  final List<QueueItem> _recommendationQueue = [];

  int _currentIndex = 0;
  bool _shuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;

  // Getters
  QueueState get queueState => QueueState(
        items: _getCombinedQueue(),
        currentIndex: _currentIndex,
        shuffleEnabled: _shuffleEnabled,
        loopMode: _loopMode,
      );

  /// Get combined queue (3-tier merged)
  List<QueueItem> _getCombinedQueue() {
    return [
      ..._userQueue,
      ..._playlistQueue,
      ..._recommendationQueue,
    ];
  }

  /// Load and play a track
  Future<void> playTrack(Track track, {bool autoPlay = true}) async {
    try {
      await _audioService.loadTrack(track, autoPlay: autoPlay);
    } catch (e) {
      if (kDebugMode) {
        print('PlayerService: Failed to play track: $e');
      }
      rethrow;
    }
  }

  /// Add to queue (Tier 1: User priority)
  Future<void> queueNext(Track track) async {
    try {
      final item = QueueItem(
        trackId: track.id,
        queueType: QueueType.user,
        order: _userQueue.length,
        addedAt: DateTime.now(),
      );
      _userQueue.add(item);
    } catch (e) {
      if (kDebugMode) {
        print('PlayerService: Failed to queue track: $e');
      }
      rethrow;
    }
  }

  /// Set playlist queue (Tier 2)
  Future<void> setPlaylist(List<Track> tracks, {int startIndex = 0}) async {
    try {
      _playlistQueue.clear();
      for (int i = 0; i < tracks.length; i++) {
        final item = QueueItem(
          trackId: tracks[i].id,
          queueType: QueueType.playlist,
          order: i,
          source: 'playlist',
        );
        _playlistQueue.add(item);
      }
      _currentIndex = startIndex;
      if (tracks.isNotEmpty) {
        await playTrack(tracks[startIndex]);
      }
    } catch (e) {
      if (kDebugMode) {
        print('PlayerService: Failed to set playlist: $e');
      }
      rethrow;
    }
  }

  /// Add recommendations (Tier 3)
  Future<void> addRecommendations(List<Track> tracks) async {
    try {
      for (int i = 0; i < tracks.length; i++) {
        final item = QueueItem(
          trackId: tracks[i].id,
          queueType: QueueType.recommendation,
          order: _recommendationQueue.length + i,
        );
        _recommendationQueue.add(item);
      }
    } catch (e) {
      if (kDebugMode) {
        print('PlayerService: Failed to add recommendations: $e');
      }
      rethrow;
    }
  }

  /// Play next track in queue
  Future<void> playNext() async {
    try {
      final queue = _getCombinedQueue();
      if (_currentIndex + 1 < queue.length) {
        _currentIndex++;
        final nextItem = queue[_currentIndex];
        final track = _libraryService.library
            .firstWhere((t) => t.id == nextItem.trackId);
        await playTrack(track);
      }
    } catch (e) {
      if (kDebugMode) {
        print('PlayerService: Failed to play next: $e');
      }
      rethrow;
    }
  }

  /// Play previous track
  Future<void> playPrevious() async {
    try {
      if (_currentIndex > 0) {
        _currentIndex--;
        final queue = _getCombinedQueue();
        final prevItem = queue[_currentIndex];
        final track = _libraryService.library
            .firstWhere((t) => t.id == prevItem.trackId);
        await playTrack(track);
      }
    } catch (e) {
      if (kDebugMode) {
        print('PlayerService: Failed to play previous: $e');
      }
      rethrow;
    }
  }

  /// Remove track from queue
  Future<void> removeFromQueue(int index) async {
    try {
      if (index >= 0 && index < _getCombinedQueue().length) {
        _getCombinedQueue().removeAt(index);
        if (index == _currentIndex && index > 0) {
          _currentIndex--;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('PlayerService: Failed to remove from queue: $e');
      }
      rethrow;
    }
  }

  /// Clear all queues
  Future<void> clearQueue() async {
    try {
      _userQueue.clear();
      _playlistQueue.clear();
      _recommendationQueue.clear();
      _currentIndex = 0;
    } catch (e) {
      if (kDebugMode) {
        print('PlayerService: Failed to clear queue: $e');
      }
      rethrow;
    }
  }

  /// Toggle shuffle
  void toggleShuffle() {
    _shuffleEnabled = !_shuffleEnabled;
    // TODO: Implement shuffle logic
  }

  /// Toggle loop mode
  void toggleLoopMode() {
    _loopMode = switch (_loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
  }

  // Forward audio service methods
  Future<void> pause() => _audioService.pause();
  Future<void> play() => _audioService.play();
  Future<void> togglePlayPause() => _audioService.togglePlayPause();
  Future<void> seek(Duration position) => _audioService.seek(position);

  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<bool> get bufferingStream => _audioService.bufferingStream;
  Stream<void> get completedStream => _audioService.completedStream;

  Future<void> dispose() async {
    await _audioService.dispose();
  }
}
