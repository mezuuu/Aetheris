import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/library_repository.dart';
import '../services/audio_playback_engine.dart';
import '../services/playback_history_service.dart';
import '../state/aetheris_scope.dart';
import '../state/app_settings.dart';
import '../providers/library_provider.dart';
import '../state/player_controller.dart';
import '../theme/aetheris_theme.dart';
import '../widgets/aetheris_shell.dart';

/// Aetheris App using Riverpod for state management
class AetherisApp extends ConsumerStatefulWidget {
  const AetherisApp({
    super.key,
    this.showOnboarding = true,
    this.showLogin = true,
    this.historyService,
    this.initialTrackId,
    this.initialPosition = Duration.zero,
    this.firebaseReady = false,
  });

  final bool showOnboarding;
  final bool showLogin;
  final PlaybackHistoryService? historyService;
  final String? initialTrackId;
  final Duration initialPosition;
  final bool firebaseReady;

  @override
  ConsumerState<AetherisApp> createState() => _AetherisAppState();
}

class _AetherisAppState extends ConsumerState<AetherisApp> {
  late final PlayerController _controller;

  @override
  void initState() {
    super.initState();
    // We can't use ref in initState, so we initialize with empty or default.
    // The build method will immediately sync the latest from riverpod.
    _controller = PlayerController(
      libraryRepository: LocalMusicLibraryRepository(),
      audioEngine: JustAudioPlaybackEngine(),
      historyService: widget.historyService,
      initialTrackId: widget.initialTrackId,
      initialPosition: widget.initialPosition,
      autoPlay: false,
      preloadOnIdle: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sync settings to the controller (listen avoids rebuilding the whole app)
    ref.listen(
      appSettingsProvider.select((s) => s.autoPlay),
      (_, next) => _controller.autoPlayEndless = next,
    );
    
    // Sync allowed folders to the repository
    ref.listen(
      appSettingsProvider.select((s) => s.allowedLocalFolders),
      (_, next) {
        final repo = _controller.libraryRepository;
        if (repo is LocalMusicLibraryRepository) {
          repo.updateAllowedFolders(next);
          // When folders change, immediately refresh the library provider
          ref.read(libraryProvider.notifier).loadLibrary();
        }
      },
    );

    // Ensure it's in sync initially
    _controller.autoPlayEndless = ref.read(appSettingsProvider).autoPlay;
    final repo = _controller.libraryRepository;
    if (repo is LocalMusicLibraryRepository) {
      repo.updateAllowedFolders(ref.read(appSettingsProvider).allowedLocalFolders);
    }

    return AetherisScope(
      controller: _controller,
      child: MaterialApp(
        title: 'Aetheris',
        debugShowCheckedModeBanner: false,
        theme: AetherisTheme.dark(),
        home: AetherisShell(
          showOnboarding: widget.showOnboarding,
          showLogin: widget.showLogin,
        ),
      ),
    );
  }
}
