import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firebase/auth_service.dart';
import '../services/firebase/firestore_sync_service.dart';
import '../services/spotify/spotify_auth_service.dart';

// ---------------------------------------------------------------------------
// Firebase Auth
// ---------------------------------------------------------------------------

/// Provides the global [AuthService] singleton.
final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  return AuthService();
});

/// Stream of Firebase auth state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.authStateChanges;
});

/// Whether the user is currently signed in.
final isSignedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(data: (user) => user != null) ?? false;
});

// ---------------------------------------------------------------------------
// Firestore Sync
// ---------------------------------------------------------------------------

/// Provides the global [FirestoreSyncService] singleton.
final firestoreSyncProvider = ChangeNotifierProvider<FirestoreSyncService>((ref) {
  return FirestoreSyncService();
});

// ---------------------------------------------------------------------------
// Spotify Auth
// ---------------------------------------------------------------------------

/// Provides the global [SpotifyAuthService] singleton.
final spotifyAuthProvider = ChangeNotifierProvider<SpotifyAuthService>((ref) {
  final service = SpotifyAuthService();
  // Initialize from secure storage on creation
  service.initialize();
  return service;
});

/// Whether Spotify is connected.
final isSpotifyConnectedProvider = Provider<bool>((ref) {
  final spotifyAuth = ref.watch(spotifyAuthProvider);
  return spotifyAuth.isConnected;
});
