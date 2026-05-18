import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_state.dart';
import '../models/queue.dart';
import '../models/track.dart';
import '../services/player_service.dart';
import 'services_provider.dart';

/// Playback state notifier
class PlaybackStateNotifier extends StateNotifier<PlayerState> {
  PlaybackStateNotifier(this._playerService)
      : super(const PlayerState());

  final PlayerService _playerService;

  void updateFromPlayer(PlayerState newState) {
    state = newState;
  }

  Future<void> playTrack(Track track) async {
    await _playerService.playTrack(track);
  }

  Future<void> pause() async {
    await _playerService.pause();
  }

  Future<void> play() async {
    await _playerService.play();
  }

  Future<void> togglePlayPause() async {
    await _playerService.togglePlayPause();
  }

  Future<void> seek(Duration position) async {
    await _playerService.seek(position);
  }

  Future<void> playNext() async {
    await _playerService.playNext();
  }

  Future<void> playPrevious() async {
    await _playerService.playPrevious();
  }
}

/// Playback state provider
final playbackStateProvider =
    StateNotifierProvider<PlaybackStateNotifier, PlayerState>((ref) {
  final playerService = ref.watch(playerServiceProvider);
  return PlaybackStateNotifier(playerService);
});

/// Queue state notifier
class QueueStateNotifier extends StateNotifier<QueueState> {
  QueueStateNotifier(this._playerService)
      : super(QueueState(
          items: const [],
          currentIndex: 0,
        ));

  final PlayerService _playerService;

  Future<void> queueNext(Track track) async {
    await _playerService.queueNext(track);
    state = _playerService.queueState;
  }

  Future<void> setPlaylist(List<Track> tracks, {int startIndex = 0}) async {
    await _playerService.setPlaylist(tracks, startIndex: startIndex);
    state = _playerService.queueState;
  }

  Future<void> removeFromQueue(int index) async {
    await _playerService.removeFromQueue(index);
    state = _playerService.queueState;
  }

  void toggleShuffle() {
    _playerService.toggleShuffle();
    state = _playerService.queueState;
  }

  void toggleLoopMode() {
    _playerService.toggleLoopMode();
    state = _playerService.queueState;
  }

  Future<void> clearQueue() async {
    await _playerService.clearQueue();
    state = _playerService.queueState;
  }
}

/// Queue state provider
final queueStateProvider =
    StateNotifierProvider<QueueStateNotifier, QueueState>((ref) {
  final playerService = ref.watch(playerServiceProvider);
  return QueueStateNotifier(playerService);
});
