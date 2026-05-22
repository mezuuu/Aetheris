class LocalMusicFile {
  const LocalMusicFile({
    required this.path,
    required this.uri,
    this.title,
    this.artist,
    this.album,
    this.durationMs,
    this.mimeType,
    this.lyrics,
    this.artworkUri,
  });

  final String path;
  final String uri;
  final String? title;
  final String? artist;
  final String? album;
  final int? durationMs;
  final String? mimeType;
  final String? lyrics;
  final String? artworkUri;
}

Future<List<LocalMusicFile>> scanLocalMusicFiles(List<String> allowedFolders) async {
  return const [];
}

Future<LocalMusicFile?> readLocalMusicMetadata({
  required String uri,
  required String path,
  required String id,
}) async {
  return null;
}
