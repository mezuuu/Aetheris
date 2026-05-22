import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';
import 'package:flutter/foundation.dart';

class DownloadConverter {
  /// Converts the input audio file to the desired output format using FFmpeg.
  /// 
  /// Uses FFmpegKit which runs natively in the background (C thread),
  /// so it does not block the Dart main isolate UI thread.
  static Future<String?> convertAudio({
    required String inputPath,
    required String outputPath,
    required String targetFormat,
    required String targetBitrate,
  }) async {
    final format = targetFormat.toUpperCase();
    String ffmpegCommand = '-y -i "$inputPath" -vn ';

    // Map the requested format/bitrate to FFmpeg arguments
    if (format == 'MP3') {
      final bitrateK = targetBitrate.replaceAll(' kbps', 'k');
      ffmpegCommand += '-c:a libmp3lame -b:a $bitrateK ';
    } else if (format == 'FLAC') {
      ffmpegCommand += '-c:a flac -compression_level 5 ';
    } else if (format == 'WAV') {
      ffmpegCommand += '-c:a pcm_s16le ';
    } else if (format == 'AAC') {
      final bitrateK = targetBitrate.replaceAll(' kbps', 'k');
      ffmpegCommand += '-c:a aac -b:a $bitrateK ';
    } else if (format == 'OPUS') {
      final bitrateK = targetBitrate.replaceAll(' kbps', 'k');
      ffmpegCommand += '-c:a libopus -b:a $bitrateK ';
    } else if (format == 'OGG') {
      final bitrateK = targetBitrate.replaceAll(' kbps', 'k');
      ffmpegCommand += '-c:a libvorbis -b:a $bitrateK ';
    } else {
      // Fallback
      ffmpegCommand += '-c:a copy ';
    }

    ffmpegCommand += '"$outputPath"';

    if (kDebugMode) {
      print('DownloadConverter: Running FFmpeg -> $ffmpegCommand');
    }

    final session = await FFmpegKit.execute(ffmpegCommand);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      if (kDebugMode) {
        print('DownloadConverter: FFmpeg success.');
      }
      return outputPath;
    } else {
      final failStackTrace = await session.getFailStackTrace();
      final logs = await session.getLogs();
      final logString = logs.map((l) => l.getMessage()).join('\n');
      
      if (kDebugMode) {
        print('DownloadConverter: FFmpeg failed with state $returnCode');
        print('Logs: $logString');
        print('Stack trace: $failStackTrace');
      }
      return null;
    }
  }

  /// Extracts the original extension of the stream.
  static String getExtensionForCodec(String codec) {
    if (codec.contains('mp4a') || codec.contains('aac')) return 'm4a';
    if (codec.contains('opus')) return 'webm';
    if (codec.contains('flac')) return 'flac';
    return 'm4a'; // default fallback for YouTube
  }
}
