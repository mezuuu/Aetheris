import 'package:isar/isar.dart';

part 'app_settings_entity.g.dart';

@collection
class AppSettingsEntity {
  AppSettingsEntity({
    this.id,
    this.theme = 'dark',
    this.accentColor = 0xFF6C5CE7,
    this.volume = 1.0,
    this.shuffleEnabled = false,
    this.loopMode = 'off',
    this.equalizerPreset = 'normal',
    this.crossfadeDuration = 0,
    this.sleepTimerMinutes,
    this.autoPlayEnabled = true,
    this.cloudSyncEnabled = false,
    this.downloadQuality = 'high',
    this.preferredLanguage = 'en',
    this.lastLibraryScanAt,
  });

  Id? id = 1; // Singleton

  late String theme; // 'dark', 'light', etc
  late int accentColor;

  late double volume; // 0.0 - 1.0
  bool shuffleEnabled;
  late String loopMode; // 'off', 'one', 'all'

  late String equalizerPreset;
  int crossfadeDuration; // in milliseconds

  int? sleepTimerMinutes;

  bool autoPlayEnabled;
  bool cloudSyncEnabled;

  late String downloadQuality; // 'low', 'normal', 'high', 'flac'
  late String preferredLanguage;

  DateTime? lastLibraryScanAt;
}
