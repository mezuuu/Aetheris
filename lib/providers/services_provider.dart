import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_playback_engine.dart';
import '../services/audio_service.dart';
import '../services/deezer_service.dart';
import '../services/download/download_manager_service.dart';
import '../services/download_service.dart';
import '../services/library_service.dart';
import '../services/music_sources/deezer_source_service.dart';
import '../services/music_sources/local_source_service.dart';
import '../services/music_sources/music_source_manager.dart';
import '../services/music_sources/spotify_source_service.dart';
import '../services/music_sources/youtube_source_service.dart';
import '../services/player_service.dart';
import 'search_provider.dart';

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

/// Unified Music Source Manager provider
final musicSourceManagerProvider = Provider<MusicSourceManager>((ref) {
  final library = ref.watch(libraryServiceProvider);
  final spotify = ref.watch(spotifyServiceProvider);
  final youtube = ref.watch(youtubeServiceProvider);
  
  final deezer = DeezerService();

  return MusicSourceManager(sources: [
    LocalSourceService(libraryService: library),
    SpotifySourceService(spotifyService: spotify),
    YouTubeSourceService(youtubeService: youtube),
    DeezerSourceService(deezerService: deezer),
  ]);
});

/// Download Manager Service
final downloadManagerProvider = ChangeNotifierProvider<DownloadManagerService>((ref) {
  final sourceManager = ref.watch(musicSourceManagerProvider);
  return DownloadManagerService(sourceManager: sourceManager);
});

/// Legacy Download service provider — delegating to the new manager.
final downloadServiceProvider = ChangeNotifierProvider<DownloadService>((ref) {
  final manager = ref.watch(downloadManagerProvider);
  return DownloadService(downloadManager: manager);
});


