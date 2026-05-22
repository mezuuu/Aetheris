import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/track.dart';

// ---------------------------------------------------------------------------
// Firestore Sync Service
// ---------------------------------------------------------------------------

/// Bi-directional sync engine for Firestore.
///
/// Syncs: favorites, playlists, recently played, download history,
/// connected platforms, and user settings.
///
/// Offline-first: uses Firestore's built-in offline persistence.
/// All writes are queued locally and synced when connectivity returns.
class FirestoreSyncService extends ChangeNotifier {
  FirestoreSyncService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance {
    // Enable offline persistence (default on mobile, explicit for safety).
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  // -------------------------------------------------------------------------
  // User Profile
  // -------------------------------------------------------------------------

  /// Initialize or update the user profile document on sign-in.
  Future<void> initUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = _userDoc;
    if (doc == null) return;

    await doc.set({
      'displayName': user.displayName ?? '',
      'email': user.email ?? '',
      'avatarUrl': user.photoURL ?? '',
      'lastSignIn': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // -------------------------------------------------------------------------
  // Favorites
  // -------------------------------------------------------------------------

  /// Add a track to favorites.
  Future<void> addFavorite(Track track) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.collection('favorites').doc(track.id).set({
      ...track.toJson(),
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a track from favorites.
  Future<void> removeFavorite(String trackId) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.collection('favorites').doc(trackId).delete();
  }

  /// Check if a track is in favorites.
  Future<bool> isFavorite(String trackId) async {
    final doc = _userDoc;
    if (doc == null) return false;

    final snap = await doc.collection('favorites').doc(trackId).get();
    return snap.exists;
  }

  /// Stream all favorites.
  Stream<List<Track>> watchFavorites() {
    final doc = _userDoc;
    if (doc == null) return Stream.value([]);

    return doc
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Track.fromJson(d.data()))
            .toList(growable: false));
  }

  // -------------------------------------------------------------------------
  // Playlists
  // -------------------------------------------------------------------------

  /// Create a new playlist.
  Future<String> createPlaylist(String name, {List<Track>? tracks}) async {
    final doc = _userDoc;
    if (doc == null) throw Exception('Not signed in');

    final playlistRef = doc.collection('playlists').doc();
    await playlistRef.set({
      'name': name,
      'tracks': (tracks ?? []).map((t) => t.toJson()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return playlistRef.id;
  }

  /// Add a track to an existing playlist.
  Future<void> addToPlaylist(String playlistId, Track track) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.collection('playlists').doc(playlistId).update({
      'tracks': FieldValue.arrayUnion([track.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a track from a playlist.
  Future<void> removeFromPlaylist(String playlistId, Track track) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.collection('playlists').doc(playlistId).update({
      'tracks': FieldValue.arrayRemove([track.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a playlist.
  Future<void> deletePlaylist(String playlistId) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.collection('playlists').doc(playlistId).delete();
  }

  /// Stream all playlists.
  Stream<List<Map<String, dynamic>>> watchPlaylists() {
    final doc = _userDoc;
    if (doc == null) return Stream.value([]);

    return doc
        .collection('playlists')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList(growable: false));
  }

  // -------------------------------------------------------------------------
  // Recently Played
  // -------------------------------------------------------------------------

  /// Record a track as recently played.
  Future<void> recordRecentlyPlayed(Track track, {Duration? position}) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.collection('recentlyPlayed').doc(track.id).set({
      ...track.toJson(),
      'playedAt': FieldValue.serverTimestamp(),
      'positionMs': position?.inMilliseconds ?? 0,
    });

    // Keep only last 50 recently played
    final all = await doc
        .collection('recentlyPlayed')
        .orderBy('playedAt', descending: true)
        .get();
    if (all.docs.length > 50) {
      final batch = _firestore.batch();
      for (final excess in all.docs.sublist(50)) {
        batch.delete(excess.reference);
      }
      await batch.commit();
    }
  }

  /// Stream recently played tracks.
  Stream<List<Track>> watchRecentlyPlayed({int limit = 20}) {
    final doc = _userDoc;
    if (doc == null) return Stream.value([]);

    return doc
        .collection('recentlyPlayed')
        .orderBy('playedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Track.fromJson(d.data()))
            .toList(growable: false));
  }

  // -------------------------------------------------------------------------
  // Download History
  // -------------------------------------------------------------------------

  /// Record a completed download.
  Future<void> recordDownload({
    required Track track,
    required String format,
    required String quality,
    required int fileSizeBytes,
    required String sourcePlatform,
  }) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.collection('downloads').add({
      'trackId': track.id,
      'title': track.title,
      'artist': track.artist,
      'album': track.album,
      'format': format,
      'quality': quality,
      'fileSizeBytes': fileSizeBytes,
      'sourcePlatform': sourcePlatform,
      'downloadedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream download history.
  Stream<List<Map<String, dynamic>>> watchDownloads({int limit = 50}) {
    final doc = _userDoc;
    if (doc == null) return Stream.value([]);

    return doc
        .collection('downloads')
        .orderBy('downloadedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList(growable: false));
  }

  // -------------------------------------------------------------------------
  // Connected Platforms
  // -------------------------------------------------------------------------

  /// Save the connection status of a platform (e.g., Spotify).
  Future<void> savePlatformConnection({
    required String platformId,
    required bool isConnected,
    DateTime? tokenExpiry,
    String? displayName,
  }) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.collection('connectedPlatforms').doc(platformId).set({
      'connected': isConnected,
      'tokenExpiry': tokenExpiry?.toIso8601String(),
      'displayName': displayName ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream connected platforms.
  Stream<Map<String, bool>> watchConnectedPlatforms() {
    final doc = _userDoc;
    if (doc == null) return Stream.value({});

    return doc.collection('connectedPlatforms').snapshots().map((snap) {
      final map = <String, bool>{};
      for (final d in snap.docs) {
        map[d.id] = d.data()['connected'] as bool? ?? false;
      }
      return map;
    });
  }

  // -------------------------------------------------------------------------
  // Settings Sync
  // -------------------------------------------------------------------------

  /// Save app settings to Firestore.
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.collection('settings').doc('preferences').set({
      ...settings,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Fetch settings from Firestore.
  Future<Map<String, dynamic>?> fetchSettings() async {
    final doc = _userDoc;
    if (doc == null) return null;

    final snap = await doc.collection('settings').doc('preferences').get();
    return snap.data();
  }

  /// Stream settings changes.
  Stream<Map<String, dynamic>?> watchSettings() {
    final doc = _userDoc;
    if (doc == null) return Stream.value(null);

    return doc
        .collection('settings')
        .doc('preferences')
        .snapshots()
        .map((snap) => snap.data());
  }

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  /// Cancel all active Firestore listeners.
  void cancelSubscriptions() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  @override
  void dispose() {
    cancelSubscriptions();
    super.dispose();
  }
}
