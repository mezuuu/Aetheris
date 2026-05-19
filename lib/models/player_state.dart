import 'track.dart';

/// Complete player state for Riverpod
class PlayerState {
  const PlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
  });

  final Track? currentTrack;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final double volume;

  bool get hasTrack => currentTrack != null;
  bool get isCompleted => duration.inMilliseconds > 0 &&
      position.inMilliseconds >= duration.inMilliseconds;

  double get progress {
    if (duration.inMilliseconds == 0) return 0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  PlayerState copyWith({
    Track? currentTrack,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    double? volume,
  }) =>
      PlayerState(
        currentTrack: currentTrack ?? this.currentTrack,
        isPlaying: isPlaying ?? this.isPlaying,
        isBuffering: isBuffering ?? this.isBuffering,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        volume: volume ?? this.volume,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerState &&
          runtimeType == other.runtimeType &&
          currentTrack?.id == other.currentTrack?.id &&
          isPlaying == other.isPlaying &&
          isBuffering == other.isBuffering &&
          position == other.position &&
          duration == other.duration &&
          volume == other.volume;

  @override
  int get hashCode =>
      currentTrack?.id.hashCode ??
      0 ^
          isPlaying.hashCode ^
          isBuffering.hashCode ^
          position.hashCode ^
          duration.hashCode ^
          volume.hashCode;
}
