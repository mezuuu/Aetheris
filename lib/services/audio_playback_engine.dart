import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../models/track.dart';

abstract interface class AudioPlaybackEngine {
  Stream<Duration> get positionStream;
  Stream<bool> get playingStream;
  Stream<bool> get bufferingStream;
  Stream<void> get completedStream;

  Future<void> load(Track track, {Duration initialPosition = Duration.zero});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> dispose();
}

class JustAudioPlaybackEngine implements AudioPlaybackEngine {
  JustAudioPlaybackEngine({AudioPlayer? player})
    : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<bool> get playingStream => _player.playingStream;

  @override
  Stream<bool> get bufferingStream {
    return _player.processingStateStream.map((state) {
      return state == ProcessingState.loading ||
          state == ProcessingState.buffering;
    }).distinct();
  }

  @override
  Stream<void> get completedStream {
    return _player.processingStateStream
        .where((state) => state == ProcessingState.completed)
        .map((_) {});
  }

  @override
  Future<void> load(
    Track track, {
    Duration initialPosition = Duration.zero,
  }) async {
    final streamUri = track.streamUri;
    if (streamUri == null) {
      throw StateError('Track ${track.id} does not have a valid stream URL.');
    }
    await _player.setAudioSource(
      AudioSource.uri(streamUri, tag: track.id),
      initialPosition: initialPosition,
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() => _player.dispose();
}
