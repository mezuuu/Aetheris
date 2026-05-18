import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_playback_engine.dart';
import '../services/audio_service.dart';
import '../services/library_service.dart';
import '../services/player_service.dart';

/// Audio playback engine provider
final audioEngineProvider = Provider<AudioPlaybackEngine>((ref) {
  return JustAudioPlaybackEngine();
});

/// Audio service provider
final audioServiceProvider = Provider<AudioService>((ref) {
  final engine = ref.watch(audioEngineProvider);
  return AudioService(engine: engine);
});

/// Library service provider
final libraryServiceProvider = Provider<LibraryService>((ref) {
  return LibraryService();
});

/// Player service provider (depends on audio and library services)
final playerServiceProvider = Provider<PlayerService>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final libraryService = ref.watch(libraryServiceProvider);
  return PlayerService(
    audioService: audioService,
    libraryService: libraryService,
  );
});
