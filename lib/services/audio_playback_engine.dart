import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../models/track.dart';

abstract interface class AudioPlaybackEngine {
  Stream<Duration> get positionStream;
  Stream<bool> get playingStream;
  Stream<bool> get bufferingStream;
  Stream<void> get completedStream;
  Stream<String> get errorStream;

  /// Stream that emits the actual duration of the loaded audio source.
  /// This is the real duration from the audio engine, not the metadata.
  Stream<Duration> get durationStream;

  Future<void> load(Track track, {Duration initialPosition = Duration.zero});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> dispose();
}

class JustAudioPlaybackEngine implements AudioPlaybackEngine {
  JustAudioPlaybackEngine({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _playerErrorSubscription = _player.errorStream.listen((error) {
      final message = error.message ?? 'Audio playback failed (${error.code}).';
      if (_isLoadingSource) {
        _lastSuppressedLoadError = message;
        return;
      }
      _justAudioErrorController.add(message);
    });
  }

  final AudioPlayer _player;
  final _native = _AndroidNativeAudioBridge();
  final _justAudioErrorController = StreamController<String>.broadcast();
  late final StreamSubscription<PlayerException> _playerErrorSubscription;
  int _activeLoadCount = 0;
  int _loadGeneration = 0;
  String? _lastSuppressedLoadError;
  bool _usingNative = false;

  bool get _isLoadingSource => _activeLoadCount > 0;

  Stream<Duration> get _nativePositionStream => _native.positionStream;

  @override
  Stream<bool> get playingStream {
    return _activeStream(_player.playingStream, _native.playingStream);
  }

  @override
  Stream<Duration> get positionStream {
    return _activeStream(_player.positionStream, _nativePositionStream);
  }

  @override
  Stream<Duration> get durationStream {
    return _activeStream(
      _player.durationStream.where((d) => d != null).map((d) => d!),
      _native.durationStream,
    );
  }

  @override
  Stream<bool> get bufferingStream {
    final justAudioBuffering = _player.processingStateStream.map((state) {
      return state == ProcessingState.loading ||
          state == ProcessingState.buffering;
    }).distinct();
    return _activeStream(justAudioBuffering, _native.bufferingStream);
  }

  @override
  Stream<void> get completedStream {
    return _activeStream(
      _player.processingStateStream
          .where((state) => state == ProcessingState.completed)
          .map((_) {}),
      _native.completedStream,
    );
  }

  @override
  Stream<String> get errorStream {
    return _activeStream(
      _justAudioErrorController.stream,
      _native.errorStream,
    );
  }

  @override
  Future<void> load(
    Track track, {
    Duration initialPosition = Duration.zero,
  }) async {
    final generation = ++_loadGeneration;
    final streamUris = track.streamUris;
    if (streamUris.isEmpty) {
      throw StateError('Track ${track.id} does not have a valid stream URL.');
    }

    Object? lastError;
    for (final streamUri in streamUris) {
      _throwIfStaleLoad(generation);
      try {
        if (_shouldUseNative(streamUri)) {
          _usingNative = true;
          await _player.stop();
          await _native.load(streamUri, initialPosition: initialPosition);
          _throwIfStaleLoad(generation);
          return;
        }

        if (Platform.isAndroid) {
          await _native.stop();
        }
        _usingNative = false;
        _lastSuppressedLoadError = null;
        await _loadUri(
          streamUri,
          track: track,
          initialPosition: initialPosition,
          generation: generation,
        );
        _throwIfStaleLoad(generation);
        return;
      } catch (error) {
        lastError = error;
        if (_isLoadingInterrupted(error)) {
          rethrow;
        }
        _throwIfStaleLoad(generation);
      }
    }

    throw StateError(
      'Unable to load ${track.title}: '
      '${lastError ?? _lastSuppressedLoadError ?? 'source error'}',
    );
  }

  Future<void> _loadUri(
    Uri streamUri, {
    required Track track,
    required Duration initialPosition,
    required int generation,
  }) async {
    final timeout = streamUri.scheme == 'http' || streamUri.scheme == 'https'
        ? const Duration(seconds: 16)
        : const Duration(seconds: 14);

    Object? lastError;
    for (final source in _audioSourceCandidates(streamUri, track)) {
      _throwIfStaleLoad(generation);
      _activeLoadCount++;
      try {
        await _player
            .setAudioSource(
              source,
              initialPosition: initialPosition,
            )
            .timeout(timeout);
        return;
      } catch (error) {
        lastError = error;
        if (_isLoadingInterrupted(error)) {
          rethrow;
        }
        await _player.stop();
      } finally {
        _activeLoadCount--;
      }
    }

    throw lastError ?? StateError('source error');
  }

  @override
  Future<void> play() {
    if (_usingNative) {
      return _native.play();
    }
    return _player.play();
  }

  @override
  Future<void> pause() => _usingNative ? _native.pause() : _player.pause();

  @override
  Future<void> seek(Duration position) {
    return _usingNative ? _native.seek(position) : _player.seek(position);
  }

  @override
  Future<void> dispose() async {
    await _playerErrorSubscription.cancel();
    await _justAudioErrorController.close();
    if (Platform.isAndroid) {
      await _native.dispose();
    } else {
      await _native.closeStreams();
    }
    await _player.dispose();
  }

  bool _shouldUseNative(Uri uri) {
    if (!Platform.isAndroid) {
      return false;
    }
    return uri.scheme == 'file' || uri.scheme == 'content';
  }

  Map<String, String>? _remoteHeaders(Uri uri) {
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return null;
    }
    return const {
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36',
      'Accept': '*/*',
      'Connection': 'keep-alive',
    };
  }

  List<AudioSource> _audioSourceCandidates(Uri uri, Track track) {
    if (uri.scheme == 'file') {
      return [AudioSource.file(uri.toFilePath(), tag: track.id)];
    }
    if (uri.scheme == 'content') {
      return [AudioSource.uri(uri, tag: track.id)];
    }

    final headers = _remoteHeaders(uri);
    final isYouTubeCdn = uri.host.contains('googlevideo.com') ||
        uri.host.contains('youtube.com') ||
        uri.queryParameters.containsKey('expire');
    if (isYouTubeCdn) {
      return [AudioSource.uri(uri, tag: track.id)];
    }
    return [
      if (headers != null)
        AudioSource.uri(uri, headers: headers, tag: track.id),
      AudioSource.uri(uri, tag: track.id),
    ];
  }

  void _throwIfStaleLoad(int generation) {
    if (generation != _loadGeneration) {
      throw StateError('Loading interrupted by a newer request.');
    }
  }

  bool _isLoadingInterrupted(Object error) {
    return error.toString().toLowerCase().contains('loading interrupted');
  }

  Stream<T> _activeStream<T>(Stream<T> justAudio, Stream<T> native) {
    late StreamController<T> controller;
    StreamSubscription<T>? leftSub;
    StreamSubscription<T>? rightSub;

    controller = StreamController<T>.broadcast(
      onListen: () {
        leftSub ??= justAudio.listen((value) {
          if (!_usingNative) {
            controller.add(value);
          }
        }, onError: controller.addError);
        rightSub ??= native.listen((value) {
          if (_usingNative) {
            controller.add(value);
          }
        }, onError: controller.addError);
      },
      onCancel: () async {
        if (!controller.hasListener) {
          await leftSub?.cancel();
          await rightSub?.cancel();
          leftSub = null;
          rightSub = null;
        }
      },
    );

    return controller.stream;
  }
}

class _AndroidNativeAudioBridge {
  final _channel = const MethodChannel('aetheris/native_audio');
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _playingController = StreamController<bool>.broadcast();
  final _bufferingController = StreamController<bool>.broadcast();
  final _completedController = StreamController<void>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  Timer? _pollTimer;
  bool _lastCompleted = false;

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<bool> get playingStream => _playingController.stream;
  Stream<bool> get bufferingStream => _bufferingController.stream;
  Stream<void> get completedStream => _completedController.stream;
  Stream<String> get errorStream => _errorController.stream;

  Future<void> load(Uri uri, {required Duration initialPosition}) async {
    _bufferingController.add(true);
    try {
      final state = await _channel.invokeMapMethod<String, Object?>(
        'load',
        {'uri': uri.toString()},
      );
      _emitState(state);
      if (initialPosition > Duration.zero) {
        await seek(initialPosition);
      }
    } on PlatformException catch (error) {
      _errorController.add(error.message ?? 'Native audio source error.');
      rethrow;
    } finally {
      _bufferingController.add(false);
    }
  }

  Future<void> play() async {
    await _channel.invokeMethod<void>('play');
    _playingController.add(true);
    _startPolling();
  }

  Future<void> pause() async {
    await _channel.invokeMethod<void>('pause');
    _playingController.add(false);
  }

  Future<void> seek(Duration position) async {
    await _channel.invokeMethod<void>('seek', {
      'positionMs': position.inMilliseconds,
    });
    await _poll();
  }

  Future<void> stop() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _lastCompleted = false;
    await _channel.invokeMethod<void>('dispose');
  }

  Future<void> dispose() async {
    await stop();
    await closeStreams();
  }

  Future<void> closeStreams() async {
    await _positionController.close();
    await _durationController.close();
    await _playingController.close();
    await _bufferingController.close();
    await _completedController.close();
    await _errorController.close();
  }

  void _startPolling() {
    _pollTimer ??= Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => unawaited(_poll()),
    );
  }

  Future<void> _poll() async {
    try {
      final state = await _channel.invokeMapMethod<String, Object?>('state');
      _emitState(state);
    } on PlatformException catch (error) {
      _errorController.add(error.message ?? 'Native audio state error.');
    }
  }

  void _emitState(Map<String, Object?>? state) {
    if (state == null) {
      return;
    }
    final positionMs = _readInt(state['positionMs']);
    final durationMs = _readInt(state['durationMs']);
    final isPlaying = state['isPlaying'] == true;
    final completed = state['completed'] == true;

    _positionController.add(Duration(milliseconds: positionMs));
    if (durationMs > 0) {
      _durationController.add(Duration(milliseconds: durationMs));
    }
    _playingController.add(isPlaying);

    if (completed && !_lastCompleted) {
      _completedController.add(null);
      _pollTimer?.cancel();
      _pollTimer = null;
    }
    _lastCompleted = completed;
  }

  int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return 0;
  }
}
