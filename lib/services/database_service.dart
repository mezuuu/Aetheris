import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../models/song_entity.dart';
import '../models/playlist_entity.dart';
import '../models/play_stats_entity.dart';
import '../models/app_settings_entity.dart';

/// Database service for Isar operations
class DatabaseService {
  DatabaseService(this._isar);

  final Isar _isar;

  // Collections
  IsarCollection<SongEntity> get songs => _isar.songEntitys;
  IsarCollection<PlaylistEntity> get playlists => _isar.playlistEntitys;
  IsarCollection<PlayStatsEntity> get playStats => _isar.playStatsEntitys;
  IsarCollection<ListeningStatistics> get statistics =>
      _isar.listeningStatistics;
  IsarCollection<AppSettingsEntity> get settings => _isar.appSettingsEntitys;

  // ─── Songs ──────────────────────────────────────────────────────────

  Future<void> addSong(SongEntity song) async {
    try {
      await _isar.writeTxn(() async {
        await songs.put(song);
      });
    } catch (e) {
      if (kDebugMode) {
        print('DatabaseService: Failed to add song: $e');
      }
      rethrow;
    }
  }

  Future<void> addSongs(List<SongEntity> songList) async {
    try {
      await _isar.writeTxn(() async {
        await songs.putAll(songList);
      });
    } catch (e) {
      if (kDebugMode) {
        print('DatabaseService: Failed to add songs: $e');
      }
      rethrow;
    }
  }

  Future<List<SongEntity>> getAllSongs() async {
    try {
      return await songs.where().findAll();
    } catch (e) {
      if (kDebugMode) {
        print('DatabaseService: Failed to get songs: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteSong(int id) async {
    try {
      await _isar.writeTxn(() async {
        await songs.delete(id);
      });
    } catch (e) {
      if (kDebugMode) {
        print('DatabaseService: Failed to delete song: $e');
      }
      rethrow;
    }
  }

  // ─── Playlists ─────────────────────────────────────────────────────

  Future<void> addPlaylist(PlaylistEntity playlist) async {
    try {
      await _isar.writeTxn(() async {
        await playlists.put(playlist);
      });
    } catch (e) {
      if (kDebugMode) {
        print('DatabaseService: Failed to add playlist: $e');
      }
      rethrow;
    }
  }

  Future<List<PlaylistEntity>> getAllPlaylists() async {
    try {
      return await playlists.where().findAll();
    } catch (e) {
      if (kDebugMode) {
        print('DatabaseService: Failed to get playlists: $e');
      }
      rethrow;
    }
  }

  Future<void> updatePlaylist(PlaylistEntity playlist) async {
    try {
      await _isar.writeTxn(() async {
        await playlists.put(playlist);
      });
    } catch (e) {
      if (kDebugMode) {
        print('DatabaseService: Failed to update playlist: $e');
      }
      rethrow;
    }
  }

  Future<void> deletePlaylist(int id) async {
    try {
      await _isar.writeTxn(() async {
        await playlists.delete(id);
      });
    } catch (e) {
      if (kDebugMode) {
        print('DatabaseService: Failed to delete playlist: $e');
      }
      rethrow;
    }
  }

  // ─── Play Stats ────────────────────────────────────────────────────

  Future<void> recordPlayback(PlayStatsEntity stat) async {
    try {
      await _isar.writeTxn(() async {
        await playStats.put(stat);
      });
    } catch (e) {
      if (kDebugMode) {
        print('DatabaseService: Failed to record playback: $e');
      }
      rethrow;
    }
  }

  Future<List<PlayStatsEntity>> getPlayHistory({int limit = 50}) async {
    try {
      return await playStats
          .where()
          .sortByPlayedAtDesc()
          .limit(limit)
          .findAll();
    } catch (e) {
      if (kDebugMode) {
        print('DatabaseService: Failed to get play history: $e');
      }
      rethrow;
    }
  }

  // ─── Settings ──────────────────────────────────────────────────────

  Future<AppSettingsEntity?> getSettings() async {
    try {
      return await settings.get(1);
    } catch (e) {
      if (kDebugMode) {
        print('DatabaseService: Failed to get settings: $e');
      }
      rethrow;
    }
  }

  Future<void> updateSettings(AppSettingsEntity settingsData) async {
    try {
      await _isar.writeTxn(() async {
        await settings.put(settingsData);
      });
    } catch (e) {
      if (kDebugMode) {
        print('DatabaseService: Failed to update settings: $e');
      }
      rethrow;
    }
  }

  // ─── Cleanup ───────────────────────────────────────────────────────

  Future<void> clearAll() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.clear();
      });
    } catch (e) {
      if (kDebugMode) {
        print('DatabaseService: Failed to clear database: $e');
      }
      rethrow;
    }
  }

  Future<void> close() async {
    try {
      await _isar.close();
    } catch (e) {
      if (kDebugMode) {
        print('DatabaseService: Failed to close database: $e');
      }
      rethrow;
    }
  }
}
