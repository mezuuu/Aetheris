import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/track.dart';
import 'audio_playback_engine.dart';

/// Audio service abstraction supporting multiple engines
class AudioService {
  AudioService({required AudioPlaybackEngine engine}) : _engine = engine;

  final AudioPlaybackEngine _engine;

  // Streams
  late final _positionController = StreamController<Duration>.broadcast();
  late final _playingController = StreamController<bool>.broadcast();
  late final _bufferingController = StreamController<bool>.broadcast();
  late final _completedController = StreamController<void>.broadcast();
  late final _errorController = StreamController<String>.broadcast();

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<bool> get playingStream => _playingController.stream;
  Stream<bool> get bufferingStream => _bufferingController.stream;
  Stream<void> get completedStream => _completedController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // State
  Track? _currentTrack;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;

  Track? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  Duration get position => _currentPosition;
  Duration get duration => _duration;

  bool get hasTrack => _currentTrack != null;

  Future<void> initialize() async {
    _setupEngineListeners();
  }

  void _setupEngineListeners() {
    _engine.positionStream.listen((position) {
      _currentPosition = position;
      _positionController.add(position);
    }).onError((error) {
      _handleError('Position stream error: $error');
    });

    _engine.playingStream.listen((isPlaying) {
      _isPlaying = isPlaying;
      _playingController.add(isPlaying);
    }).onError((error) {
      _handleError('Playing stream error: $error');
    });

    _engine.bufferingStream.listen((isBuffering) {
      _bufferingController.add(isBuffering);
    }).onError((error) {
      _handleError('Buffering stream error: $error');
    });

    _engine.completedStream.listen((_) {
      _completedController.add(null);
    }).onError((error) {
      _handleError('Completed stream error: $error');
    });
  }

  Future<void> loadTrack(
    Track track, {
    bool autoPlay = true,
    Duration initialPosition = Duration.zero,
  }) async {
    try {
      _currentTrack = track;
      _duration = Duration.zero;

      await _engine.load(
        track,
        initialPosition: initialPosition,
      );

      // Fetch duration if available
      if (track.duration != null) {
        _duration = track.duration!;
      }

      if (autoPlay) {
        await play();
      }
    } catch (e) {
      _handleError('Failed to load track: $e');
      rethrow;
    }
  }

  Future<void> play() async {
    try {
      await _engine.play();
    } catch (e) {
      _handleError('Play error: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await _engine.pause();
    } catch (e) {
      _handleError('Pause error: $e');
      rethrow;
    }
  }

  Future<void> togglePlayPause() async {
    try {
      if (_isPlaying) {
        await pause();
      } else {
        await play();
      }
    } catch (e) {
      _handleError('Toggle error: $e');
      rethrow;
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _engine.seek(position);
      _currentPosition = position;
    } catch (e) {
      _handleError('Seek error: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await pause();
      _currentTrack = null;
      _duration = Duration.zero;
      _currentPosition = Duration.zero;
    } catch (e) {
      _handleError('Stop error: $e');
      rethrow;
    }
  }

  void _handleError(String message) {
    if (kDebugMode) {
      print('AudioService Error: $message');
    }
    _errorController.add(message);
  }

  Future<void> dispose() async {
    await _engine.dispose();
    await _positionController.close();
    await _playingController.close();
    await _bufferingController.close();
    await _completedController.close();
    await _errorController.close();
  }
}
