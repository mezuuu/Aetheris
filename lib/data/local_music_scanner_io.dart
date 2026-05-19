import 'dart:io';

class LocalMusicFile {
  const LocalMusicFile({required this.path, required this.uri});

  final String path;
  final String uri;
}

List<LocalMusicFile> scanLocalMusicFiles(String musicFolderPath) {
  final roots = <Directory>[
    Directory(musicFolderPath),
    Directory('music'),
    if (Platform.isAndroid) ...[
      Directory('/storage/emulated/0/Music'),
      Directory('/sdcard/Music'),
    ],
    if (Platform.isLinux || Platform.isMacOS)
      Directory('${Platform.environment['HOME'] ?? ''}/Music'),
    if (Platform.isWindows)
      Directory('${Platform.environment['USERPROFILE'] ?? ''}\\Music'),
  ];

  final files = <LocalMusicFile>[];
  final seenPaths = <String>{};
  for (final root in roots) {
    if (!root.existsSync()) {
      continue;
    }

    final entries = root.listSync(recursive: true).whereType<File>();
    for (final file in entries) {
      final ext = _extensionOf(file.path);
      if (ext != 'mp3' && ext != 'wav' && ext != 'flac') {
        continue;
      }
      if (!seenPaths.add(file.path)) {
        continue;
      }
      files.add(LocalMusicFile(path: file.path, uri: file.uri.toString()));
    }
  }

  return List<LocalMusicFile>.unmodifiable(files);
}

String _extensionOf(String path) {
  final dot = path.lastIndexOf('.');
  if (dot < 0 || dot == path.length - 1) return '';
  return path.substring(dot + 1).toLowerCase();
}
