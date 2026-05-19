import 'package:flutter/widgets.dart';

import '../data/library_repository.dart';
import '../services/audio_playback_engine.dart';
import 'player_controller.dart';

class AetherisScope extends InheritedNotifier<PlayerController> {
  const AetherisScope({
    super.key,
    required PlayerController controller,
    required super.child,
  }) : super(notifier: controller);

  static PlayerController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AetherisScope>();
    final controller = scope?.notifier;
    if (controller != null) {
      return controller;
    }
    return _FallbackController.instance;
  }
}

class _FallbackController {
  static final PlayerController instance = PlayerController(
    libraryRepository: const DemoLibraryRepository(),
    audioEngine: JustAudioPlaybackEngine(),
    autoPlay: false,
  );
}
