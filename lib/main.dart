import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/aetheris_app.dart';
import 'config/firebase_config.dart';
import 'services/playback_history_service.dart';
import 'state/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (graceful — app works without it)
  bool firebaseReady = false;
  if (FirebaseConfig.isConfigured) {
    try {
      await Firebase.initializeApp(
        options: FirebaseConfig.currentPlatform,
      );
      firebaseReady = true;
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
  } else {
    debugPrint('Firebase not configured. Running in offline-only mode.');
  }

  final prefs = await SharedPreferences.getInstance();

  final historyService = PlaybackHistoryService(prefs: prefs);
  final lastPlayed = await historyService.getLastPlayed();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: AetherisApp(
        historyService: historyService,
        initialTrackId: lastPlayed?.trackId,
        initialPosition: lastPlayed?.position ?? Duration.zero,
        firebaseReady: firebaseReady,
      ),
    ),
  );
}
