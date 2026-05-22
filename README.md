# Aetheris Audio Player

Aetheris is a premium Hi-Fi music player built with Flutter, Riverpod, and FFmpegKit. It features unified streaming (Spotify, YouTube, Deezer), lossless audio downloads, and a beautiful UI.

## Features

- **Unified Music Source**: Aggregates metadata from Spotify/Deezer and streams from YouTube Music.
- **Native Download Manager**: Concurrent downloads with FFmpeg transcoding to MP3, FLAC, WAV, AAC, OPUS, OGG.
- **Persistent Queue**: Downloads pause and resume automatically across app restarts.
- **Offline Library**: Browse and play downloaded files directly.

## Getting Started

Aetheris is now 100% Dart/Flutter. The Python backend has been completely replaced with a native `ffmpeg_kit_flutter` implementation.

```bash
flutter clean
flutter pub get
flutter run
```

## Architecture

- **State Management**: Riverpod (`services_provider.dart`)
- **Database**: Isar & SharedPreferences
- **Download Engine**: Dio (HTTP) + FFmpegKit (Conversion)
- **Audio Playback**: `just_audio` + `media_kit`
