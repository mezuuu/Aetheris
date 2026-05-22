import 'dart:io';

import 'package:flutter/services.dart';

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

const _mediaStoreChannel = MethodChannel('aetheris/media_store');

Future<List<LocalMusicFile>> scanLocalMusicFiles(List<String> allowedFolders) async {
  if (allowedFolders.isEmpty) {
    return const [];
  }

  if (Platform.isAndroid) {
    final mediaStoreFiles = await _scanAndroidMediaStore();
    if (mediaStoreFiles.isNotEmpty) {
      final filtered = mediaStoreFiles.where((file) {
        return allowedFolders.any((folder) => file.path.startsWith(folder));
      }).toList();
      return List<LocalMusicFile>.unmodifiable(filtered);
    }
  }

  final roots = allowedFolders.map((path) => Directory(path)).toList();

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

Future<List<LocalMusicFile>> _scanAndroidMediaStore() async {
  try {
    final result = await _mediaStoreChannel.invokeMethod<List<Object?>>(
      'scanAudio',
    );
    if (result == null) {
      return const [];
    }

    return result
        .whereType<Map<Object?, Object?>>()
        .map((item) {
          final uri = item['uri'] as String?;
          final path = item['path'] as String?;
          if (uri == null || uri.isEmpty || path == null || path.isEmpty) {
            return null;
          }
          return LocalMusicFile(
            path: path,
            uri: uri,
            title: item['title'] as String?,
            artist: item['artist'] as String?,
            album: item['album'] as String?,
            durationMs: _readInt(item['durationMs']),
            mimeType: item['mimeType'] as String?,
            lyrics: item['lyrics'] as String?,
            artworkUri: item['artworkUri'] as String?,
          );
        })
        .whereType<LocalMusicFile>()
        .toList(growable: false);
  } on MissingPluginException {
    return const [];
  } on PlatformException {
    return const [];
  }
}

Future<LocalMusicFile?> readLocalMusicMetadata({
  required String uri,
  required String path,
  required String id,
}) async {
  if (!Platform.isAndroid) {
    return null;
  }

  try {
    final item = await _mediaStoreChannel.invokeMapMethod<Object?, Object?>(
      'readMetadata',
      {
        'uri': uri,
        'path': path,
        'id': id,
      },
    );
    if (item == null) {
      return null;
    }
    return LocalMusicFile(
      path: path,
      uri: uri,
      title: item['title'] as String?,
      artist: item['artist'] as String?,
      album: item['album'] as String?,
      lyrics: item['lyrics'] as String?,
      artworkUri: item['artworkUri'] as String?,
    );
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  return null;
}

String _extensionOf(String path) {
  final dot = path.lastIndexOf('.');
  if (dot < 0 || dot == path.length - 1) return '';
  return path.substring(dot + 1).toLowerCase();
}
