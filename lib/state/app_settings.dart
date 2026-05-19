import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    this.wifiOnly = true,
    this.exclusiveMode = false,
    this.autoPlay = true,
    this.automix = true,
    this.showLyrics = true,
    this.normalizeVolume = true,
    this.crossfade = false,
    this.showNotification = true,
    this.crossfadeDuration = 3,
    this.audioQuality = 'High',
    this.downloadFormat = 'MP3',
  });

  final bool wifiOnly;
  final bool exclusiveMode;
  final bool autoPlay;
  final bool automix;
  final bool showLyrics;
  final bool normalizeVolume;
  final bool crossfade;
  final bool showNotification;
  final double crossfadeDuration;
  final String audioQuality;
  final String downloadFormat;

  AppSettings copyWith({
    bool? wifiOnly,
    bool? exclusiveMode,
    bool? autoPlay,
    bool? automix,
    bool? showLyrics,
    bool? normalizeVolume,
    bool? crossfade,
    bool? showNotification,
    double? crossfadeDuration,
    String? audioQuality,
    String? downloadFormat,
  }) {
    return AppSettings(
      wifiOnly: wifiOnly ?? this.wifiOnly,
      exclusiveMode: exclusiveMode ?? this.exclusiveMode,
      autoPlay: autoPlay ?? this.autoPlay,
      automix: automix ?? this.automix,
      showLyrics: showLyrics ?? this.showLyrics,
      normalizeVolume: normalizeVolume ?? this.normalizeVolume,
      crossfade: crossfade ?? this.crossfade,
      showNotification: showNotification ?? this.showNotification,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      audioQuality: audioQuality ?? this.audioQuality,
      downloadFormat: downloadFormat ?? this.downloadFormat,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier(this._prefs) : super(const AppSettings()) {
    _load();
  }

  final SharedPreferences _prefs;

  static const _kWifiOnly = 'settings.wifi_only';
  static const _kExclusiveMode = 'settings.exclusive_mode';
  static const _kAutoPlay = 'settings.auto_play';
  static const _kAutomix = 'settings.automix';
  static const _kShowLyrics = 'settings.show_lyrics';
  static const _kNormalizeVolume = 'settings.normalize_volume';
  static const _kCrossfade = 'settings.crossfade';
  static const _kShowNotification = 'settings.show_notification';
  static const _kCrossfadeDuration = 'settings.crossfade_duration';
  static const _kAudioQuality = 'settings.audio_quality';
  static const _kDownloadFormat = 'settings.download_format';

  void _load() {
    state = state.copyWith(
      wifiOnly: _prefs.getBool(_kWifiOnly) ?? state.wifiOnly,
      exclusiveMode: _prefs.getBool(_kExclusiveMode) ?? state.exclusiveMode,
      autoPlay: _prefs.getBool(_kAutoPlay) ?? state.autoPlay,
      automix: _prefs.getBool(_kAutomix) ?? state.automix,
      showLyrics: _prefs.getBool(_kShowLyrics) ?? state.showLyrics,
      normalizeVolume:
          _prefs.getBool(_kNormalizeVolume) ?? state.normalizeVolume,
      crossfade: _prefs.getBool(_kCrossfade) ?? state.crossfade,
      showNotification:
          _prefs.getBool(_kShowNotification) ?? state.showNotification,
      crossfadeDuration:
          _prefs.getDouble(_kCrossfadeDuration) ?? state.crossfadeDuration,
      audioQuality: _prefs.getString(_kAudioQuality) ?? state.audioQuality,
      downloadFormat:
          _prefs.getString(_kDownloadFormat) ?? state.downloadFormat,
    );
  }

  void update(AppSettings value) {
    state = value;
    _prefs
      ..setBool(_kWifiOnly, value.wifiOnly)
      ..setBool(_kExclusiveMode, value.exclusiveMode)
      ..setBool(_kAutoPlay, value.autoPlay)
      ..setBool(_kAutomix, value.automix)
      ..setBool(_kShowLyrics, value.showLyrics)
      ..setBool(_kNormalizeVolume, value.normalizeVolume)
      ..setBool(_kCrossfade, value.crossfade)
      ..setBool(_kShowNotification, value.showNotification)
      ..setDouble(_kCrossfadeDuration, value.crossfadeDuration)
      ..setString(_kAudioQuality, value.audioQuality)
      ..setString(_kDownloadFormat, value.downloadFormat);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden.');
});

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return AppSettingsNotifier(prefs);
    });
