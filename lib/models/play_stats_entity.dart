import 'package:isar/isar.dart';

part 'play_stats_entity.g.dart';

@collection
class PlayStatsEntity {
  PlayStatsEntity({
    this.id,
    required this.songId,
    required this.playedAt,
    this.duration,
  });

  Id? id;

  late String songId;
  late DateTime playedAt;

  /// Duration played in milliseconds
  int? duration;
}

@collection
class ListeningStatistics {
  ListeningStatistics({
    this.id,
    this.totalListeningTime = 0,
    this.totalSongsPlayed = 0,
    this.topGenres = const [],
    this.topArtists = const [],
    this.updatedAt,
  });

  Id? id = 1; // Singleton pattern

  int totalListeningTime; // in seconds
  int totalSongsPlayed;

  late List<String> topGenres;
  late List<String> topArtists;

  DateTime? updatedAt;
}
