/// Service for persisting playback history using [SharedPreferences].
///
/// Tracks the last played song and position for resume-on-launch,
/// and maintains a recently played list (capped at 20 entries).
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for saving and loading playback history.
///
/// Uses [SharedPreferences] to persist:
/// - The last played track ID and playback position (for resume)
/// - A recently played list of up to [maxRecentItems] track IDs
class PlaybackHistoryService {
  /// Creates a [PlaybackHistoryService].
  ///
  /// If [prefs] is provided, it will be used directly. Otherwise, the
  /// service will lazily initialize SharedPreferences on first access.
  PlaybackHistoryService({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  /// Maximum number of recently played items to retain.
  static const int maxRecentItems = 20;

  // SharedPreferences keys
  static const String _keyLastTrackId = 'playback_history_last_track_id';
  static const String _keyLastPositionMs = 'playback_history_last_position_ms';
  static const String _keyRecentlyPlayed = 'playback_history_recently_played';

  /// Ensures SharedPreferences is initialized.
  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Saves the last played track ID and playback position.
  ///
  /// Call this periodically during playback (e.g. every 5 seconds) or
  /// when playback is paused/stopped, so the user can resume later.
  ///
  /// ```dart
  /// await historyService.saveLastPlayed('track-123', Duration(seconds: 42));
  /// ```
  Future<void> saveLastPlayed(String trackId, Duration position) async {
    try {
      final prefs = await _ensurePrefs();
      await Future.wait([
        prefs.setString(_keyLastTrackId, trackId),
        prefs.setInt(_keyLastPositionMs, position.inMilliseconds),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('PlaybackHistoryService: Failed to save last played: $e');
      }
    }
  }

  /// Retrieves the last played track ID and position.
  ///
  /// Returns a record `({String trackId, Duration position})` if a last
  /// played track exists, or `null` if no history is saved.
  ///
  /// ```dart
  /// final lastPlayed = await historyService.getLastPlayed();
  /// if (lastPlayed != null) {
  ///   player.seekTo(lastPlayed.trackId, lastPlayed.position);
  /// }
  /// ```
  Future<({String trackId, Duration position})?> getLastPlayed() async {
    try {
      final prefs = await _ensurePrefs();
      final trackId = prefs.getString(_keyLastTrackId);

      if (trackId == null || trackId.isEmpty) return null;

      final positionMs = prefs.getInt(_keyLastPositionMs) ?? 0;
      return (
        trackId: trackId,
        position: Duration(milliseconds: positionMs),
      );
    } catch (e) {
      if (kDebugMode) {
        print('PlaybackHistoryService: Failed to get last played: $e');
      }
      return null;
    }
  }

  /// Clears all saved playback history (last played and recently played).
  Future<void> clearHistory() async {
    try {
      final prefs = await _ensurePrefs();
      await Future.wait([
        prefs.remove(_keyLastTrackId),
        prefs.remove(_keyLastPositionMs),
        prefs.remove(_keyRecentlyPlayed),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('PlaybackHistoryService: Failed to clear history: $e');
      }
    }
  }

  /// Adds a track ID to the recently played list.
  ///
  /// The list is capped at [maxRecentItems]. If the track already exists
  /// in the list, it is moved to the front (most recent position).
  /// Duplicate entries are removed to keep the list clean.
  ///
  /// ```dart
  /// await historyService.saveRecentlyPlayed('track-123');
  /// ```
  Future<void> saveRecentlyPlayed(String trackId) async {
    try {
      if (trackId.isEmpty) return;

      final prefs = await _ensurePrefs();
      final current = prefs.getStringList(_keyRecentlyPlayed) ?? [];

      // Remove existing entry if present (will re-add at front)
      current.remove(trackId);

      // Add to front (most recently played first)
      current.insert(0, trackId);

      // Trim to max size
      final trimmed = current.length > maxRecentItems
          ? current.sublist(0, maxRecentItems)
          : current;

      await prefs.setStringList(_keyRecentlyPlayed, trimmed);
    } catch (e) {
      if (kDebugMode) {
        print('PlaybackHistoryService: Failed to save recently played: $e');
      }
    }
  }

  /// Returns the list of recently played track IDs.
  ///
  /// The list is ordered most-recent-first, with a maximum of
  /// [maxRecentItems] entries.
  Future<List<String>> getRecentlyPlayed() async {
    try {
      final prefs = await _ensurePrefs();
      return prefs.getStringList(_keyRecentlyPlayed) ?? [];
    } catch (e) {
      if (kDebugMode) {
        print('PlaybackHistoryService: Failed to get recently played: $e');
      }
      return [];
    }
  }

  /// Removes a specific track from the recently played list.
  ///
  /// Useful when a track is deleted from the library.
  Future<void> removeFromRecentlyPlayed(String trackId) async {
    try {
      final prefs = await _ensurePrefs();
      final current = prefs.getStringList(_keyRecentlyPlayed) ?? [];
      current.remove(trackId);
      await prefs.setStringList(_keyRecentlyPlayed, current);
    } catch (e) {
      if (kDebugMode) {
        print('PlaybackHistoryService: Failed to remove from recently played: $e');
      }
    }
  }

  /// Returns the number of recently played tracks.
  Future<int> get recentlyPlayedCount async {
    final list = await getRecentlyPlayed();
    return list.length;
  }
}
