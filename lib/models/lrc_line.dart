/// Model for synced lyrics in LRC (Lyric) format.
///
/// Supports parsing standard LRC timestamps (`[mm:ss.xx]` / `[mm:ss.xxx]`),
/// metadata tags, multiple timestamps per line, and provides efficient
/// active-line lookup at a given playback position.
library;

/// A single line of synced lyrics.
class LrcLine implements Comparable<LrcLine> {
  /// Creates an [LrcLine] with the given [timestamp] and [text].
  LrcLine({
    required this.timestamp,
    required this.text,
    this.translation,
    this.romanization,
  });

  /// Timestamp at which this line should be displayed.
  final Duration timestamp;

  /// Lyric text for this line.
  final String text;

  /// Optional translated text (filled by translation service).
  String? translation;

  /// Optional romanized text (e.g. romaji for Japanese, pinyin for Chinese).
  String? romanization;

  /// Sort lines chronologically.
  @override
  int compareTo(LrcLine other) => timestamp.compareTo(other.timestamp);

  /// Creates a copy of this line with optional overrides.
  LrcLine copyWith({
    Duration? timestamp,
    String? text,
    String? translation,
    String? romanization,
  }) {
    return LrcLine(
      timestamp: timestamp ?? this.timestamp,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      romanization: romanization ?? this.romanization,
    );
  }

  @override
  String toString() {
    final mm = timestamp.inMinutes.toString().padLeft(2, '0');
    final ss = (timestamp.inSeconds % 60).toString().padLeft(2, '0');
    final ms = ((timestamp.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    return '[$mm:$ss.$ms] $text';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LrcLine &&
          timestamp == other.timestamp &&
          text == other.text;

  @override
  int get hashCode => Object.hash(timestamp, text);
}

/// Parsed LRC data containing all lyric lines and metadata.
class LrcData {
  /// Creates [LrcData] from pre-parsed [lines].
  const LrcData({
    required this.lines,
    required this.isSynced,
    this.title,
    this.artist,
    this.album,
    this.author,
    this.offset = Duration.zero,
  });

  /// All lyric lines, sorted by timestamp.
  final List<LrcLine> lines;

  /// Whether these lyrics have valid timestamps (synced) or are plain text.
  final bool isSynced;

  /// Song title from LRC metadata tag `[ti:]`.
  final String? title;

  /// Artist name from LRC metadata tag `[ar:]`.
  final String? artist;

  /// Album name from LRC metadata tag `[al:]`.
  final String? album;

  /// LRC author from metadata tag `[au:]`.
  final String? author;

  /// Global offset from LRC metadata tag `[offset:]` (in milliseconds).
  final Duration offset;

  /// Whether there are no lyric lines.
  bool get isEmpty => lines.isEmpty;

  /// Total number of lyric lines.
  int get length => lines.length;

  /// Regular expression matching LRC timestamp tags.
  ///
  /// Matches formats:
  /// - `[mm:ss.xx]`  — centisecond precision
  /// - `[mm:ss.xxx]` — millisecond precision
  /// - `[mm:ss]`     — second precision
  static final _timestampRegex = RegExp(
    r'\[(\d{1,3}):(\d{2})(?:\.(\d{2,3}))?\]',
  );

  /// Regular expression matching LRC metadata tags like `[ti:Title]`.
  static final _metadataRegex = RegExp(
    r'^\[([a-zA-Z#]+):(.+)\]$',
  );

  /// Parses an LRC format string into [LrcData].
  ///
  /// Handles:
  /// - Standard timestamps `[mm:ss.xx]` and `[mm:ss.xxx]`
  /// - Multiple timestamps per line (e.g. `[00:12.34][00:56.78] text`)
  /// - Metadata tags (`[ti:]`, `[ar:]`, `[al:]`, `[au:]`, `[offset:]`)
  /// - Empty lines and whitespace
  /// - Lines without timestamps (treated as unsynced)
  factory LrcData.parse(String lrcContent) {
    if (lrcContent.trim().isEmpty) {
      return const LrcData(lines: [], isSynced: false);
    }

    final lines = <LrcLine>[];
    String? title;
    String? artist;
    String? album;
    String? author;
    var offsetMs = 0;

    final rawLines = lrcContent.split('\n');

    for (final rawLine in rawLines) {
      final trimmed = rawLine.trim();
      if (trimmed.isEmpty) continue;

      // Check for metadata-only lines (no timestamp, just [key:value])
      final metaMatch = _metadataRegex.firstMatch(trimmed);
      if (metaMatch != null && !_timestampRegex.hasMatch(trimmed)) {
        final key = metaMatch.group(1)!.toLowerCase();
        final value = metaMatch.group(2)!.trim();
        switch (key) {
          case 'ti':
            title = value;
          case 'ar':
            artist = value;
          case 'al':
            album = value;
          case 'au':
            author = value;
          case 'offset':
            offsetMs = int.tryParse(value) ?? 0;
          default:
            // Ignore other metadata tags ([by:], [re:], [ve:], etc.)
            break;
        }
        continue;
      }

      // Extract all timestamps from this line
      final timestamps = <Duration>[];
      for (final match in _timestampRegex.allMatches(trimmed)) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final subSecondStr = match.group(3);

        int milliseconds = 0;
        if (subSecondStr != null) {
          if (subSecondStr.length == 2) {
            // Centiseconds → milliseconds
            milliseconds = int.parse(subSecondStr) * 10;
          } else {
            // Milliseconds
            milliseconds = int.parse(subSecondStr);
          }
        }

        timestamps.add(Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        ));
      }

      if (timestamps.isEmpty) continue;

      // Extract the text portion (everything after the last timestamp tag)
      final lastTagEnd = _timestampRegex
          .allMatches(trimmed)
          .last
          .end;
      final text = trimmed.substring(lastTagEnd).trim();

      // Create a line for each timestamp (handles multi-timestamp lines)
      for (final ts in timestamps) {
        lines.add(LrcLine(timestamp: ts, text: text));
      }
    }

    // Sort chronologically
    lines.sort();

    return LrcData(
      lines: List<LrcLine>.unmodifiable(lines),
      isSynced: lines.isNotEmpty,
      title: title,
      artist: artist,
      album: album,
      author: author,
      offset: Duration(milliseconds: offsetMs),
    );
  }

  /// Creates [LrcData] from plain (unsynced) lyrics text.
  ///
  /// Each non-empty line becomes an [LrcLine] with [Duration.zero] timestamp.
  factory LrcData.fromPlainText(String plainText) {
    if (plainText.trim().isEmpty) {
      return const LrcData(lines: [], isSynced: false);
    }

    final lines = plainText
        .split('\n')
        .map((line) => line.trim())
        .map((line) => line.replaceAll(_timestampRegex, '').trim())
        .where((line) => !_metadataRegex.hasMatch(line))
        .where((line) => line.isNotEmpty)
        .map((text) => LrcLine(timestamp: Duration.zero, text: text))
        .toList(growable: false);

    return LrcData(
      lines: List<LrcLine>.unmodifiable(lines),
      isSynced: false,
    );
  }

  /// Finds the index of the active lyric line at the given playback [position].
  ///
  /// Returns the index of the last line whose timestamp is ≤ [position],
  /// applying the global [offset]. Returns `-1` if no line is active yet.
  ///
  /// Uses binary search for O(log n) performance.
  int activeIndexAt(Duration position) {
    if (lines.isEmpty) return -1;

    // Apply global offset
    final adjusted = position + offset;

    // Binary search for the last line with timestamp ≤ adjusted position
    var low = 0;
    var high = lines.length - 1;
    var result = -1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (lines[mid].timestamp <= adjusted) {
        result = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return result;
  }

  /// Returns the active [LrcLine] at the given playback [position],
  /// or `null` if no line is active yet.
  LrcLine? activeLineAt(Duration position) {
    final index = activeIndexAt(position);
    return index >= 0 ? lines[index] : null;
  }

  /// Serializes this [LrcData] back to LRC format string.
  String toLrcString() {
    final buffer = StringBuffer();

    if (title != null) buffer.writeln('[ti:$title]');
    if (artist != null) buffer.writeln('[ar:$artist]');
    if (album != null) buffer.writeln('[al:$album]');
    if (author != null) buffer.writeln('[au:$author]');
    if (offset != Duration.zero) {
      buffer.writeln('[offset:${offset.inMilliseconds}]');
    }

    if (buffer.isNotEmpty) buffer.writeln();

    for (final line in lines) {
      buffer.writeln(line.toString());
    }

    return buffer.toString();
  }

  @override
  String toString() =>
      'LrcData(lines: ${lines.length}, isSynced: $isSynced)';
}
