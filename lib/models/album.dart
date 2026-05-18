import 'track.dart';

class Album {
  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.description,
    required this.tracks,
  });

  final String id;
  final String title;
  final String artist;
  final String description;
  final List<Track> tracks;

  int get trackCount => tracks.length;

  Duration get totalDuration {
    return tracks.fold(Duration.zero, (total, track) => total + track.duration);
  }
}
