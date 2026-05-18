import 'package:isar/isar.dart';

part 'playlist_entity.g.dart';

@collection
class PlaylistEntity {
  PlaylistEntity({
    this.id,
    required this.name,
    this.description,
    this.trackIds = const [],
    this.createdAt,
    this.modifiedAt,
    this.isShared = false,
    this.shareCode,
  });

  Id? id;

  late String name;
  String? description;

  /// List of song IDs in this playlist
  late List<String> trackIds;

  DateTime? createdAt;
  DateTime? modifiedAt;

  bool isShared;
  String? shareCode;
}
