import 'dart:ui';

class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.format,
    required this.bitDepth,
    required this.sampleRateKhz,
    required this.duration,
    required this.coverColors,
    required this.lyrics,
    this.streamUrl,
    this.fallbackStreamUrls = const [],
    this.artworkUrl,
    this.isBitPerfect = false,
    this.playCount = 0,
    this.isrc,
  }) : assert(bitDepth > 0),
       assert(sampleRateKhz > 0),
       assert(playCount >= 0);

  static const empty = Track(
    id: 'empty',
    title: 'Not Playing',
    artist: 'Select a track to play',
    album: '',
    format: '',
    bitDepth: 16,
    sampleRateKhz: 44,
    duration: Duration.zero,
    coverColors: [Color(0xFF202020), Color(0xFF121212)],
    lyrics: [],
  );


  factory Track.fromJson(Map<String, Object?> json) {
    return Track(
      id: _readString(json, 'id'),
      title: _readString(json, 'title'),
      artist: _readString(json, 'artist'),
      album: _readString(json, 'album'),
      format: _readString(json, 'format', fallback: 'MP3'),
      bitDepth: _readInt(json, 'bitDepth', fallback: 16),
      sampleRateKhz: _readInt(json, 'sampleRateKhz', fallback: 44),
      duration: _readDuration(json),
      coverColors: _readColors(json['coverColors']),
      lyrics: _readStringList(json['lyrics']),
      streamUrl: _readNullableString(json, 'streamUrl'),
      fallbackStreamUrls: _readStringList(json['fallbackStreamUrls']),
      artworkUrl: _readNullableString(json, 'artworkUrl'),
      isBitPerfect: json['isBitPerfect'] == true,
      playCount: _readInt(json, 'playCount'),
      isrc: _readNullableString(json, 'isrc'),
    );
  }

  final String id;
  final String title;
  final String artist;
  final String album;
  final String format;
  final int bitDepth;
  final int sampleRateKhz;
  final Duration duration;
  final List<Color> coverColors;
  final List<String> lyrics;
  final String? streamUrl;
  final List<String> fallbackStreamUrls;
  final String? artworkUrl;
  final bool isBitPerfect;
  final int playCount;

  /// ISRC code for cross-service matching (Spotify → Deezer → YouTube).
  final String? isrc;

  bool get isHiRes => bitDepth >= 24 || sampleRateKhz >= 88;

  bool get isLossless {
    return const {
      'FLAC',
      'WAV',
      'AIFF',
      'ALAC',
      'DSD',
    }.contains(format.toUpperCase());
  }

  bool get hasStream => streamUri != null;

  Uri? get streamUri {
    final value = streamUrl?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) {
      return null;
    }
    return uri;
  }

  List<Uri> get streamUris {
    final uris = <Uri>[
      if (streamUri case final primary?) primary,
      for (final value in fallbackStreamUrls)
        if (_tryReadUri(value) case final fallback?) fallback,
    ];
    final seen = <String>{};
    return List<Uri>.unmodifiable(
      uris.where((uri) => seen.add(uri.toString())),
    );
  }

  Uri? get artworkUri {
    final value = artworkUrl?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) {
      return null;
    }
    return uri;
  }

  String get durationLabel {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
    }
    return '$minutes:$seconds';
  }

  String get audioSpec =>
      '${format.toUpperCase()} | $bitDepth-bit | ${sampleRateKhz}kHz';

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'format': format,
      'bitDepth': bitDepth,
      'sampleRateKhz': sampleRateKhz,
      'durationMs': duration.inMilliseconds,
      'coverColors': coverColors.map(_colorToHex).toList(),
      'lyrics': lyrics,
      'streamUrl': streamUrl,
      'fallbackStreamUrls': fallbackStreamUrls,
      'artworkUrl': artworkUrl,
      'isBitPerfect': isBitPerfect,
      'playCount': playCount,
      'isrc': isrc,
    };
  }

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? format,
    int? bitDepth,
    int? sampleRateKhz,
    Duration? duration,
    List<Color>? coverColors,
    List<String>? lyrics,
    String? streamUrl,
    List<String>? fallbackStreamUrls,
    String? artworkUrl,
    bool? isBitPerfect,
    int? playCount,
    String? isrc,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      format: format ?? this.format,
      bitDepth: bitDepth ?? this.bitDepth,
      sampleRateKhz: sampleRateKhz ?? this.sampleRateKhz,
      duration: duration ?? this.duration,
      coverColors: coverColors ?? this.coverColors,
      lyrics: lyrics ?? this.lyrics,
      streamUrl: streamUrl ?? this.streamUrl,
      fallbackStreamUrls: fallbackStreamUrls ?? this.fallbackStreamUrls,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      isBitPerfect: isBitPerfect ?? this.isBitPerfect,
      playCount: playCount ?? this.playCount,
      isrc: isrc ?? this.isrc,
    );
  }

  static String _readString(
    Map<String, Object?> json,
    String key, {
    String fallback = '',
  }) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback;
  }

  static String? _readNullableString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  static Uri? _tryReadUri(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) {
      return null;
    }
    return uri;
  }

  static int _readInt(
    Map<String, Object?> json,
    String key, {
    int fallback = 0,
  }) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static Duration _readDuration(Map<String, Object?> json) {
    final durationMs = _readInt(json, 'durationMs');
    if (durationMs > 0) {
      return Duration(milliseconds: durationMs);
    }

    final durationSeconds = _readInt(json, 'durationSeconds');
    if (durationSeconds > 0) {
      return Duration(seconds: durationSeconds);
    }

    return Duration.zero;
  }

  static List<String> _readStringList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return List<String>.unmodifiable(
      value
          .whereType<String>()
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty),
    );
  }

  static List<Color> _readColors(Object? value) {
    const fallback = [Color(0xFF0F273F), Color(0xFF8C5B7D), Color(0xFF101422)];

    if (value is! List) {
      return fallback;
    }

    final colors = value
        .whereType<String>()
        .map(_tryParseColor)
        .whereType<Color>()
        .toList(growable: false);

    return colors.isEmpty ? fallback : List<Color>.unmodifiable(colors);
  }

  static Color? _tryParseColor(String value) {
    final normalized = value.trim().replaceFirst('#', '');
    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
    final colorValue = int.tryParse(hex, radix: 16);
    return colorValue == null ? null : Color(colorValue);
  }

  static String _colorToHex(Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2).toUpperCase()}';
  }
}
