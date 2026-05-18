import 'package:isar/isar.dart';

part 'song.g.dart';

@collection
class SongEntity {
  SongEntity({
    this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.filePath,
    this.duration,
    this.bitrate,
    this.sampleRate,
    this.codec,
    this.isLocalFile = true,
    this.isBitPerfect = false,
    this.playCount = 0,
    this.lastPlayedAt,
    this.addedAt,
  });

  Id? id;

  late String title;
  late String artist;
  late String album;
  late String filePath;

  int? duration; // in milliseconds
  int? bitrate;
  int? sampleRate;
  String? codec;

  bool isLocalFile;
  bool isBitPerfect;
  int playCount;

  DateTime? lastPlayedAt;
  DateTime? addedAt;
}
