import 'package:isar/isar.dart';

part 'queue.g.dart';

@collection
class QueueItem {
  QueueItem({
    this.id,
    required this.trackId,
    this.queueType = QueueType.user,
    this.order = 0,
    this.addedAt,
    this.source,
  });

  Id? id;

  /// Reference to Track ID
  late String trackId;

  /// Type of queue (user, playlist, recommendation)
  @enumerated
  late QueueType queueType;

  /// Order in the queue
  late int order;

  /// When added to queue
  DateTime? addedAt;

  /// Source playlist or context
  String? source;
}

enum QueueType {
  /// User manually queued
  user,

  /// From current playlist/album
  playlist,

  /// Recommended/auto-queue
  recommendation,
}

/// Queue state for Riverpod
class QueueState {
  const QueueState({
    required this.items,
    required this.currentIndex,
    this.shuffleEnabled = false,
    this.loopMode = LoopMode.off,
  });

  final List<QueueItem> items;
  final int currentIndex;
  final bool shuffleEnabled;
  final LoopMode loopMode;

  QueueState copyWith({
    List<QueueItem>? items,
    int? currentIndex,
    bool? shuffleEnabled,
    LoopMode? loopMode,
  }) =>
      QueueState(
        items: items ?? this.items,
        currentIndex: currentIndex ?? this.currentIndex,
        shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
        loopMode: loopMode ?? this.loopMode,
      );
}

enum LoopMode {
  off,
  one,
  all,
}
