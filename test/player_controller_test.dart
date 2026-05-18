import 'dart:async';

import 'package:aetheris_audio_player/data/demo_library.dart';
import 'package:aetheris_audio_player/models/track.dart';
import 'package:aetheris_audio_player/services/audio_playback_engine.dart';
import 'package:aetheris_audio_player/state/player_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PlayerController createController({bool autoPlay = true}) {
    return PlayerController(
      startPlaybackClock: false,
      autoPlay: autoPlay,
      initialPosition: Duration.zero,
    );
  }

  test('initializes library and upcoming queue correctly', () {
    final controller = createController();
    addTearDown(controller.dispose);

    expect(controller.library, demoTracks);
    expect(controller.queue, demoTracks.skip(1));
    expect(controller.currentTrack, demoTracks.first);
    expect(controller.currentTrack.hasStream, isTrue);
    expect(controller.position.inSeconds, greaterThanOrEqualTo(0));
  });

  test('searchLibrary matches title, artist, album, and format', () {
    final controller = createController();
    addTearDown(controller.dispose);

    expect(controller.searchLibrary('clear').map((track) => track.id), [
      'clear-sky',
    ]);
    expect(controller.searchLibrary('nova').map((track) => track.id), [
      'ethereal-echoes',
    ]);
    expect(controller.searchLibrary('particles').map((track) => track.id), [
      'quantum-state',
    ]);
    expect(controller.searchLibrary('wav').map((track) => track.id), [
      'midnight-synth',
    ]);
  });

  test('playTrackById starts the requested track and reports misses', () {
    final controller = createController();
    addTearDown(controller.dispose);

    expect(controller.playTrackById('soft-gravity'), isTrue);
    expect(controller.currentTrack.id, 'soft-gravity');
    expect(controller.position, Duration.zero);
    expect(controller.isPlaying, isTrue);

    expect(controller.playTrackById('missing-track'), isFalse);
    expect(controller.currentTrack.id, 'soft-gravity');
  });

  test('setQueue rejects empty queues and stores only upcoming tracks', () {
    final controller = createController();
    addTearDown(controller.dispose);

    expect(() => controller.setQueue(const []), throwsArgumentError);

    controller.setQueue(demoTracks.take(2), startAt: demoTracks[1]);

    expect(controller.currentTrack, demoTracks[1]);
    expect(controller.queue, [demoTracks.first]);
    expect(controller.position, Duration.zero);
    expect(controller.isPlaying, isTrue);
  });

  test('seek clamps progress and remaining time stays non-negative', () {
    final controller = createController();
    addTearDown(controller.dispose);

    controller.seekToPercent(2);

    expect(controller.position, controller.currentTrack.duration);
    expect(controller.progress, 1);
    expect(controller.remaining, Duration.zero);

    controller.seekToPercent(-1);

    expect(controller.position, Duration.zero);
    expect(controller.progress, 0);
  });

  test('advance respects pause state and skips at track end', () {
    final controller = createController(autoPlay: false);
    addTearDown(controller.dispose);

    controller.advance(const Duration(seconds: 30));
    expect(controller.position, Duration.zero);
    expect(controller.currentTrack, demoTracks.first);

    controller.togglePlay();
    controller.advance(demoTracks.first.duration);

    expect(controller.currentTrack, demoTracks[1]);
    expect(controller.position, Duration.zero);
    expect(controller.isPlaying, isTrue);
  });

  test('toggleLike adds and removes liked status', () {
    final controller = createController();
    addTearDown(controller.dispose);

    final track = demoTracks.first;
    expect(controller.isLiked(track), false);
    controller.toggleLike(track);
    expect(controller.isLiked(track), true);
    controller.toggleLike(track);
    expect(controller.isLiked(track), false);
  });

  test('removeFromQueue removes the track', () {
    final controller = createController();
    addTearDown(controller.dispose);

    final track = controller.queue.first;
    controller.removeFromQueue(track);
    expect(controller.queue.contains(track), false);
  });

  test('reorderQueue changes position', () {
    final controller = createController();
    addTearDown(controller.dispose);

    final first = controller.queue[0];
    controller.reorderQueue(0, 2);

    expect(controller.queue[0], isNot(first));
    expect(controller.queue[1], first);
  });

  test('Track.fromJson parses online stream metadata', () {
    final track = Track.fromJson({
      'id': 'online-track',
      'title': 'Online Track',
      'artist': 'Remote Artist',
      'album': 'Remote Album',
      'format': 'aac',
      'bitDepth': 16,
      'sampleRateKhz': 44,
      'durationMs': 123000,
      'streamUrl': 'https://example.com/audio.m4a',
      'coverColors': ['#112233', '#445566'],
      'lyrics': ['line one', 'line two'],
    });

    expect(track.id, 'online-track');
    expect(track.duration, const Duration(seconds: 123));
    expect(track.streamUri, Uri.parse('https://example.com/audio.m4a'));
    expect(track.audioSpec, 'AAC | 16-bit | 44kHz');
  });

  test('preloads the active stream so play and pause do not reload', () async {
    final audioEngine = _FakeAudioPlaybackEngine();
    final controller = PlayerController(
      audioEngine: audioEngine,
      autoPlay: false,
      initialPosition: Duration.zero,
    );
    addTearDown(controller.dispose);

    await pumpEventQueue();

    expect(audioEngine.loadCalls, ['clear-sky']);
    expect(audioEngine.playCount, 0);

    controller.togglePlay();
    await pumpEventQueue();

    expect(audioEngine.loadCalls, ['clear-sky']);
    expect(audioEngine.playCount, 1);
    expect(controller.isPlaying, isTrue);

    controller.togglePlay();
    await pumpEventQueue();

    expect(audioEngine.pauseCount, 1);
    expect(controller.isPlaying, isFalse);
  });
}

class _FakeAudioPlaybackEngine implements AudioPlaybackEngine {
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _bufferingController =
      StreamController<bool>.broadcast();
  final StreamController<void> _completedController =
      StreamController<void>.broadcast();

  final List<String> loadCalls = [];
  int playCount = 0;
  int pauseCount = 0;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<bool> get playingStream => _playingController.stream;

  @override
  Stream<bool> get bufferingStream => _bufferingController.stream;

  @override
  Stream<void> get completedStream => _completedController.stream;

  @override
  Future<void> load(
    Track track, {
    Duration initialPosition = Duration.zero,
  }) async {
    loadCalls.add(track.id);
  }

  @override
  Future<void> play() async {
    playCount++;
    _playingController.add(true);
  }

  @override
  Future<void> pause() async {
    pauseCount++;
    _playingController.add(false);
  }

  @override
  Future<void> seek(Duration position) async {
    _positionController.add(position);
  }

  @override
  Future<void> dispose() async {
    await _positionController.close();
    await _playingController.close();
    await _bufferingController.close();
    await _completedController.close();
  }
}
