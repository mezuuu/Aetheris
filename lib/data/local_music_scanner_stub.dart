class LocalMusicFile {
  const LocalMusicFile({required this.path, required this.uri});

  final String path;
  final String uri;
}

List<LocalMusicFile> scanLocalMusicFiles(String musicFolderPath) {
  return const [];
}
