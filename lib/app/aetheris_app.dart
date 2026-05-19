import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/library_repository.dart';
import '../services/audio_playback_engine.dart';
import '../state/aetheris_scope.dart';
import '../state/player_controller.dart';
import '../theme/aetheris_theme.dart';
import '../widgets/aetheris_shell.dart';

/// Aetheris App using Riverpod for state management
class AetherisApp extends ConsumerStatefulWidget {
  const AetherisApp({
    super.key,
    this.showOnboarding = true,
    this.showLogin = true,
  });

  final bool showOnboarding;
  final bool showLogin;

  @override
  ConsumerState<AetherisApp> createState() => _AetherisAppState();
}

class _AetherisAppState extends ConsumerState<AetherisApp> {
  late final PlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PlayerController(
      libraryRepository: LocalMusicLibraryRepository(),
      audioEngine: JustAudioPlaybackEngine(),
      autoPlay: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
